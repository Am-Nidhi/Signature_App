import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sign_capture/screens/pdfViewerScreen.dart';
import 'package:sign_capture/utils/database.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class SignatureScreen extends StatefulWidget {
  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();

  // Clear the signature pad
  void _clear() {
    _signaturePadKey.currentState?.clear();
  }

  // Save the signature as an image, Base64, and to SQLite
  Future<void> _saveSignature() async {
    // Get the signature as a byte array
    final signature = await _signaturePadKey.currentState?.toImage();
    if (signature == null) return;

    // Convert the signature image to PNG bytes
    final byteData = await signature.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    // Convert image to Base64
    String base64String = base64Encode(buffer);

    // Save the image to a file first (for gallery)
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/signature.png';
    final file = File(filePath);

    // Write the byte data to the file
    await file.writeAsBytes(buffer);
    print("Signature saved as PNG at $filePath");

    // Save the image to the gallery using `gal`
    await Gal.putImage(filePath,
        album: 'Signatures'); // You can specify your album name

    // Save the Base64 and image data to SQLite database
    await DatabaseHelper.saveSignature(base64String, buffer);

    // Show a confirmation Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Signature saved to gallery and database!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Signature Pad"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Signature Pad
            SfSignaturePad(
              key: _signaturePadKey,
              backgroundColor: Colors.grey[200]!,
              strokeColor: Colors.black,
              minimumStrokeWidth: 1.0,
              maximumStrokeWidth: 4.0,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _clear,
                  child: Text("Clear"),
                ),
                ElevatedButton(
                  onPressed: _saveSignature,
                  child: Text("Save to Gallery and DB"),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
