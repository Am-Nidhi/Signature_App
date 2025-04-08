import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfDownloadService {
  // List of PDFs to download
  final List<Map<String, String>> pdfList = [
    {
      "name": "Sample PDF 1",
      "url": "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
      "filename": "sample_pdf_1.pdf",
    },
    {
      "name": "Sample PDF 2",
      "url": "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
      "filename": "sample_pdf_2.pdf",
    },
    // Add more PDFs as required
  ];

  // Function to request storage permissions (Android only)
  Future<bool> _requestPermissions() async {
  if (Platform.isAndroid) {
    // Check for the storage permission
    var status = await Permission.storage.request();

    if (status.isGranted) {
      return true; // Permission granted
    } else {
      // On Android 11 or above, check for MANAGE_EXTERNAL_STORAGE
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      } else {
        // Request access to external storage
        await Permission.manageExternalStorage.request();
      }
    }
  }
  return true; // For iOS, assume permission is granted.
}

  // Function to download a PDF from the provided URL
  Future<void> _downloadPdf(String url, String filePath) async {
    Dio dio = Dio();
    try {
      // Check if the file already exists before downloading
      File file = File(filePath);
      if (await file.exists()) {
        print("File already exists: $filePath");
        return; // Do nothing if the file already exists
      }

      // If the file doesn't exist, download it
      Response response = await dio.download(url, filePath);
      if (response.statusCode == 200) {
        print("PDF downloaded: $filePath");
      } else {
        throw Exception("Failed to download PDF");
      }
    } catch (e) {
      print("Download error: $e");
      throw Exception("Failed to download PDF: $e");
    }
  }

  // Main function to download all PDFs
  Future<void> downloadAllPdfs() async {
    // Request permission to access storage
    bool hasPermission = await _requestPermissions();
    if (!hasPermission) {
      print("Storage permission is not granted.");
      return; // Exit if permission is not granted.
    }

    // Get the application's documents directory
    Directory directory = await getApplicationDocumentsDirectory();
    List<String> missingFiles = [];

    // Check if each PDF is already downloaded or needs to be downloaded
    for (var pdf in pdfList) {
      String filePath = '${directory.path}/${pdf['filename']}';
      File file = File(filePath);

      // If the file doesn't exist, try downloading it
      if (!await file.exists()) {
        print("File missing: ${pdf['name']}. Downloading...");
        try {
          await _downloadPdf(pdf['url']!, filePath);
        } catch (e) {
          missingFiles.add(pdf['name']!); // Track missing files for error reporting
        }
      } else {
        print("Skipping download (file already exists): ${pdf['name']}");
      }
    }

    // If there are missing files, show a dialog (you can adapt this to your UI framework)
    if (missingFiles.isNotEmpty) {
      print("The following PDFs could not be downloaded: ${missingFiles.join(', ')}");
      // Optionally show a dialog or alert to the user indicating which files are missing
    } else {
      print("All PDFs downloaded successfully!");
      // You can navigate to the next screen or perform another action here
    }
  }
}