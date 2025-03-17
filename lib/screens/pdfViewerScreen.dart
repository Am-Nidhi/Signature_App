import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http; // HTTP request package

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {

  final String _pdfPath = 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer')),
      body: SfPdfViewer.network(
        _pdfPath,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          showErrorDialog(context, details.error, details.description);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _downloadPdf();  // Call the function properly here
        },
        label: const Icon(Icons.download),
      ),
    );
  }

  // Function to download PDF
  Future<void> _downloadPdf() async {
    // Request storage permissions
    PermissionStatus permissionStatus = await Permission.storage.request();

    if (permissionStatus.isGranted) {
      try {
        // Get the "Download" directory path
        final directory = Directory('/storage/emulated/0/Download');
        
        if (!await directory.exists()) {
          // If directory doesn't exist, create it
          await directory.create(recursive: true);
        }

        final file = File('${directory.path}/downloaded_pdf.pdf');

        // Download PDF using http package
        final response = await http.get(Uri.parse(_pdfPath));
        if (response.statusCode == 200) {
          // Save the file
          await file.writeAsBytes(response.bodyBytes);

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

  void showErrorDialog(BuildContext context, String error, String description) {
    showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(error),
          content: Text(description),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
