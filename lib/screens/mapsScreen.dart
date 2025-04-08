import 'package:flutter/material.dart';
import 'dart:io' as io;

import 'package:url_launcher/url_launcher.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {

  TextEditingController _latitudeController = TextEditingController();
  TextEditingController _longitudeController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: screenWidth * 0.3,
                                      height: 45,
                                      child: const Text("Enter Latitude",
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold))),
                                  const SizedBox(width: 5),
                                  SizedBox(
                                    height: 40,
                                    width: screenWidth * 0.4,
                                    child: TextField(
                                      controller: _latitudeController,
                                      style: const TextStyle(
                                          color: Colors
                                              .black), // To hide password input
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: const BorderSide(
                                              color: Colors
                                                  .black), // black border when inactive
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: const BorderSide(
                                              color: Colors.black,
                                              width:
                                                  2), // black border when focused
                                        ),
                                        hintText: '',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: screenWidth * 0.3,
                                      height: 45,
                                      child: const Text("Enter Longitude",
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold))),
                                  const SizedBox(width: 5),
                                  SizedBox(
                                    height: 40,
                                    width: screenWidth * 0.4,
                                    child: TextField(
                                      controller: _longitudeController,
                                      style: const TextStyle(
                                          color: Colors
                                              .black), // To hide password input
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: const BorderSide(
                                              color: Colors
                                                  .black), // White border when inactive
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: const BorderSide(
                                              color: Colors.black,
                                              width:
                                                  2), // White border when focused
                                        ),
                                        hintText: '',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                            width: 15,
                          ),
                          // Button to open map
                          Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.black, width: 1.5)),
                            child: CircleAvatar(
                              backgroundColor: Colors.orangeAccent,
                              radius: 25,
                              child: IconButton(
                                  color: Colors.black,
                                  onPressed: _launchMapWithCoordinates,
                                  iconSize: 28,
                                  icon: Icon(Icons.location_on)),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  // Method to launch map with coordinates
  void _launchMapWithCoordinates() {
    double? latitude = double.tryParse(_latitudeController.text);
    double? longitude = double.tryParse(_longitudeController.text);

    if (latitude != null && longitude != null) {
      openMap(latitude, longitude);
    } else {
      _showInvalidCoordinatesDialog();
    }
  }
  void openMap(double latitude, double longitude) async {
  String urlString = io.Platform.isAndroid
      ? 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'
      : 'https://maps.apple.com/?q=$latitude,$longitude';

  Uri url = Uri.parse(urlString);

  // Check if the URL can be launched
  if (await canLaunchUrl(url)) {
    print(url);
    await launchUrl(url);
  } else {
    print('Cannot launch $url');
  }
  }
  void _showInvalidCoordinatesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Invalid Coordinates"),
          content: const Text("Please enter valid latitude and longitude."),
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