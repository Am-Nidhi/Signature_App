import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfListViewerScreen extends StatefulWidget {
  const PdfListViewerScreen({super.key});

  @override
  State<PdfListViewerScreen> createState() => _PdfListViewerScreenState();
}

class _PdfListViewerScreenState extends State<PdfListViewerScreen> {
  final List<String> _pdfUrls = [
    'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
    'https://morth.nic.in/sites/default/files/dd12-13_0.pdf',
    'https://www.aeee.in/wp-content/uploads/2020/08/Sample-pdf.pdf',
  ];

  List<String> _localPaths = List.generate(3, (_) => ""); // List to store local file paths

  // Method to download PDF with the correct name and location
  Future<void> _downloadPdf(int index) async {
    // Request storage permissions
    PermissionStatus permissionStatus = await Permission.storage.request();

    if (permissionStatus.isGranted) {
      try {
        // Get the "Download" directory path
        final directory = Directory('/storage/emulated/0/Download');
        
        if (!await directory.exists()) {
          // If the directory doesn't exist, create it
          await directory.create(recursive: true);
        }

        // Extract file name from the URL (you can adjust it based on your needs)
        final fileName = _pdfUrls[index].split('/').last;
        final file = File('${directory.path}/$fileName');

        // Download PDF using the http package
        final response = await http.get(Uri.parse(_pdfUrls[index]));
        if (response.statusCode == 200) {
          // Save the file
          await file.writeAsBytes(response.bodyBytes);

          // Update the local path list to store the downloaded file path
          setState(() {
            _localPaths[index] = file.path;
          });

          // Inform the user that the file has been saved
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF downloaded to ${file.path}')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to download PDF')));
        }
      } catch (e) {
        // Handle any errors that occur during the download process
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error downloading PDF: $e')));
      }
    } else {
      // Inform the user if permission is denied
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Permission denied')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF List Viewer')),
      body: ListView.builder(
        itemCount: _pdfUrls.length,
        itemBuilder: (context, index) {
          // Check if the file exists locally
          final file = File('/storage/emulated/0/Download/${_pdfUrls[index].split('/').last}');
          
          return ListTile(
            title: Text('PDF ${index + 1}'),
            trailing: file.existsSync()
                ? Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  )
                : IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      _downloadPdf(index);
                    },
                  ),
            onTap: () {
              // Open PDF from local file or network based on download status
              if (file.existsSync()) {
                // Open PDF from local storage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewerScreen1(pdfFile: file),
                  ),
                );
              } else {
                // Open PDF from network
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewerScreen1(pdfUrl: _pdfUrls[index]),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class PdfViewerScreen1 extends StatelessWidget {
  final String pdfUrl;
  final File? pdfFile;

  const PdfViewerScreen1({Key? key, this.pdfUrl = '', this.pdfFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer')),
      body: pdfFile != null
          ? SfPdfViewer.file(pdfFile!) // Open from local file
          : SfPdfViewer.network(pdfUrl), // Open from network
    );
  }
}
