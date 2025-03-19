import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
  bool _isConnected = true; // Flag to track internet connectivity

  @override
  void initState() {
    super.initState();
    _checkDownloadedFiles(); // Check for previously downloaded files on initialization
  }

  // Request storage permissions
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Request storage permissions for Android 9 and below
      if (await Permission.storage.request().isGranted) {
        print("Storage Permission granted");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
      }

      // For Android 10 and above, request MANAGE_EXTERNAL_STORAGE permission if needed
      if (await Permission.manageExternalStorage.request().isGranted) {
        print("MANAGE_EXTERNAL_STORAGE permission granted");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('App needs access to storage')),
        );
      }
    }
  }

  // Check if the PDF file is already downloaded
  Future<void> _checkDownloadedFiles() async {
    final directory = await getExternalStorageDirectory();

    if (directory == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to access storage')));
      return;
    }

    for (int i = 0; i < _pdfUrls.length; i++) {
      final fileName = _pdfUrls[i].split('/').last;
      final file = File('${directory.path}/$fileName');

      if (await file.exists()) {
        setState(() {
          _localPaths[i] = file.path; // If file exists, update the local path
        });
      }
    }
  }

  // Method to check for internet connectivity
Future<void> _checkInternetConnectivity() async {
  print("Checking internet connectivity...");

  // Get the connectivity result list
  final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

  print("Connectivity result: $connectivityResult");

  setState(() {
    // Check if the connectivity result contains any active connection types
    if (connectivityResult.contains(ConnectivityResult.none)) {
      // No internet connection
      print("No internet connection.");
      _isConnected = false;
    } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
      // Mobile network available
      print("Mobile network available.");
      _isConnected = true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      // Wi-Fi available
      print("Wi-Fi available.");
      _isConnected = true;
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      // Ethernet connection available
      print("Ethernet connection available.");
      _isConnected = true;
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
      // VPN connection active
      print("VPN connection active.");
      _isConnected = true;
    } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
      // Bluetooth connection available (this might be a rare case)
      print("Bluetooth connection available.");
      _isConnected = true;
    } else if (connectivityResult.contains(ConnectivityResult.other)) {
      // Connected to an unknown network type (e.g., a custom network or another type)
      print("Connected to an unknown network type.");
      _isConnected = true;
    }
  });
}

  // Method to download PDF with the correct name and location
  Future<void> _downloadPdf(int index) async {
    try {
      // Get the "Download" directory path using path_provider
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to access storage')));
        return;
      }

      final fileName = _pdfUrls[index].split('/').last;
      final file = File('${directory.path}/$fileName');

      final response = await http.get(Uri.parse(_pdfUrls[index]));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _localPaths[index] = file.path; // Update path after download
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF downloaded to ${file.path}')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to download PDF')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading PDF: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF List Viewer')),
      body: ListView.builder(
        itemCount: _pdfUrls.length,
        itemBuilder: (context, index) {
          final file = File('${_localPaths[index]}');

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
                      _downloadPdf(index);  // Trigger PDF download
                    },
                  ),
            onTap: () async {
              print("Tapped on PDF ${index + 1}");
              // Check internet connectivity before navigating
              await _checkInternetConnectivity(); // Force check the internet connectivity
              print("Is connected to internet: $_isConnected");

              if (file.existsSync() || _isConnected) {
                // Proceed to open the PDF if file exists or if connected to internet
                print("Navigating to PDF viewer...");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewerScreen(
                        pdfUrl: _pdfUrls[index], pdfFile: file.existsSync() ? file : null),
                  ),
                );
              } else {
                // Show message when no internet is available
                print("No internet connection to load the PDF.");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No internet connection to load the PDF.')),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final File? pdfFile;

  const PdfViewerScreen({Key? key, this.pdfUrl = '', this.pdfFile}) : super(key: key);

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
