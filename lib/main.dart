// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// add http package
import 'package:http/http.dart' as http;

const apiKey = "API_KEY";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  var sessionToken = DateTime.now().millisecondsSinceEpoch;
  final _searchController = TextEditingController();
  List _predictions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps App'),
      ),
      body: Stack(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.7749, -122.4194), // San Francisco coordinates
                zoom: 12,
              ),
            ),
          ),
          Positioned(
            // Change background color to white
            top: 10,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter a location',
                      contentPadding: EdgeInsets.all(10),
                    ),
                    onChanged: (value) => handleChange(value),
                  ),
                ),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: _predictions.length,
                    itemBuilder: (context, index) {
                      return Container(
                        color: Colors.white,
                        child: ListTile(
                          tileColor:
                              Colors.white, // Change background color to white
                          title: Text(_predictions[index]["description"]),
                        ),
                      );
                    })
              ],
            ),
          ),
        ],
      ),
    );
  }

  // define handlePress function
  void handleChange(value) async {
    // make an autocomplete request
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$value&types=establishment&key=$apiKey&sessiontoken=$sessionToken'));
    // create an autocomplete prediction list below the TextInput
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['predictions'] as List<dynamic>;
      // print the data to the console
      // print("Data result: $data");
      // map through the data and store it in the _predictions list
      final predictions = data
          .map((prediction) => {
                "description": prediction['description'],
                "place_id": prediction['place_id']
              })
          .toList();
      // print the predictions to the console
      print("Predictions result: $predictions");
      // set the state of the _predictions list
      setState(() {
        _predictions = predictions;
      });
    } else {
      // show an alert dialog if the response is not successful
      showError();
    }
  }

  void showError() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('An error occurred while searching for places'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
