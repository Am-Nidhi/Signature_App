import 'package:flutter/material.dart';
import 'package:sign_capture/screens/pdfList.dart';
import 'package:sign_capture/screens/pdfViewerScreen.dart';
import 'package:sign_capture/screens/signScreen.dart';

class Initialpage extends StatefulWidget {
  const Initialpage({super.key});

  @override
  State<Initialpage> createState() => _InitialpageState();
}

class _InitialpageState extends State<Initialpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter App"),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              
              //mainAxisAlignment: MainAxisAlignment.center,

              children: <Widget>[
            
              //Signature Screen Button
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignatureScreen(),
                        ));
                  },
                  child: Text('Signature Screen')),
            
                  //SPdf Viewer Screen
                  // ElevatedButton(
                  // onPressed: () {
                  //   Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => PdfViewerScreen(),
                  //       ));
                  // },
                  // child: Text('Pdf Viewer Screen')),


                  //list
                  ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfListViewerScreen(),
                        ));
                  },
                  child: Text('Pdf List Screen')),

            ]),
          )),
    );
  }
}
