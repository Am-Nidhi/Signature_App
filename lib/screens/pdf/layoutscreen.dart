import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class layoutScreen extends StatelessWidget {
  final List<Map<String, String>> pdfList;

  const layoutScreen({Key? key, required this.pdfList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF List Viewer")),
      body: ListView.builder(
        itemCount: pdfList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(pdfList[index]["name"] ?? ""),
            onTap: () => _openPdfIfAvailable(
              context,
              pdfList[index]["filename"]!,
            ),
          );
        },
      ),
    );
  }

  /// Open the PDF if it exists, otherwise show an error dialog.
  Future<void> _openPdfIfAvailable(BuildContext context, String fileName) async {
    try {
      // Get the application's documents directory
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/$fileName';

      // Check if the file exists locally
      if (await File(filePath).exists()) {
        print("file: ${filePath}");
        // If the file exists, open it
        OpenFilex.open(filePath);
      } else {
        // Show error dialog if the file is not found
        _showMissingFileDialog(context, fileName);
      }
    } catch (e) {
      debugPrint("Error opening PDF: $e");
      _showMissingFileDialog(context, fileName);
    }
  }

  // Show an error dialog when the PDF file is missing.
  void _showMissingFileDialog(BuildContext context, String missingFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Missing PDF"),
          content: Text("The PDF file '$missingFile' is not available on the device."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}