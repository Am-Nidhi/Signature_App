import 'package:flutter/material.dart';
import 'package:sign_capture/screens/pdf/helper.dart';
import 'package:sign_capture/screens/pdf/layoutscreen.dart';

class Pdflist2 extends StatefulWidget {
  const Pdflist2({super.key});

  @override
  State<Pdflist2> createState() => _Pdflist2State();
}

class _Pdflist2State extends State<Pdflist2> {
  PdfDownloadService _pdfDownloadService = PdfDownloadService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ElevatedButton(onPressed: _downloadAllPdfs, child: Text('View pdf list')),
    );
  }

  Future<void> _downloadAllPdfs() async {
    try {
      await _pdfDownloadService.downloadAllPdfs();
      // After download is complete, navigate or show success
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                layoutScreen(pdfList: _pdfDownloadService.pdfList)),
      );
    } catch (e) {
      print("Error during PDF download: $e");
      // Show an error dialog or message
    }
  }
}