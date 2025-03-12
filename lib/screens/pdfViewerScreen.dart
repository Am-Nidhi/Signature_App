import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

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
      body: SfPdfViewer.network(
        _pdfPath,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          showErrorDialog(context, details.error, details.description);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
      onPressed: () {
        _downloadPdf;
      }, label: Icon(Icons.download),
      ),
    );
  }

  
  // Function to download PDF
  Future<void> _downloadPdf() async {
    // Request storage permissions
    PermissionStatus permissionStatus = await Permission.storage.request();

    if (permissionStatus.isGranted) {
      // Get the directory to save the PDF
      final directory = await getExternalStorageDirectory();
      final file = File('${directory!.path}/downloaded_pdf.pdf');
      
      // Here, you'll download the PDF. For simplicity, let's assume you're downloading from a URL.
      final response = await HttpClient().getUrl(Uri.parse(_pdfPath));
      final bytes = await response.close().then((res) => res.fold<List<int>>([], (buffer, data) => buffer..addAll(data)));

      await file.writeAsBytes(bytes);

      // Inform the user that the file has been saved
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF downloaded to ${file.path}')));
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
        });
  }
}
