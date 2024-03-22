// ignore_for_file: library_private_types_in_public_api

import 'package:autocomplete_example/api_keys.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemaps_flutter_webservices/places.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';

const apiKey = googleMapsApiKey;

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
  // controllers for the map and search bar
  GoogleMapController? _mapController;
  final _searchController = TextEditingController();

  // this is where we store the predictions for the ListView.builder
  final _predictions = [];
  // create storage for markers
  final Set<Marker> _markers = {};

  // create a new instance of GoogleMapsPlaces
  final places = GoogleMapsPlaces(apiKey: apiKey);

  // create a new session token using the Uuid package
  var sessionToken = const Uuid().v4();

  // build the widget
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
              markers: _markers,
            ),
          ),
          Positioned(
            // Change background color to white
            top: 0,
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
                          onTap: () async {
                            var placeId = _predictions[index]["placeId"];
                            var res = await places.getDetailsByPlaceId(placeId,
                                sessionToken: sessionToken);
                            if (res.isOkay) {
                              var lat = res.result.geometry?.location.lat;
                              var lng = res.result.geometry?.location.lng;
                              _mapController!.animateCamera(
                                // move the camera and zoom
                                CameraUpdate.newLatLngZoom(
                                  LatLng(lat!, lng!),
                                  15,
                                ),
                              );

                              // add a marker to the map
                              _markers.add(
                                Marker(
                                  markerId: MarkerId(placeId),
                                  position: LatLng(lat, lng),
                                  infoWindow: InfoWindow(
                                    title: res.result.name,
                                    snippet: res.result.formattedAddress,
                                  ),
                                ),
                              );
                              // clear predictions and replace the search bar text
                              setState(() {
                                _predictions.clear();
                                _searchController.text = res.result.name;
                                // reset the session token
                                sessionToken = const Uuid().v4();
                              });
                            }
                          },
                        ),
                      );
                    }),
                Container(
                  // fill max width
                  width: double.infinity,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    // Create a row with text and image for Google attribution
                    child: Row(
                      children: [
                        const Text(
                          "Powered by ",
                        ),
                        // google attribution icon from asset folder
                        Image.asset("assets/google_on_white.png"),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // define handlePress function
  void handleChange(value) async {
    // this is to check if session tokens have been implemented correctly
    print("Session Token: $sessionToken");
    var predictions = [];
    var res = await places.autocomplete(value,
        sessionToken: sessionToken.toString(), types: ["establishment"]);
    if (res.isOkay) {
      for (var p in res.predictions) {
        predictions.add({"description": p.description, "placeId": p.placeId});
      }
      setState(() {
        _predictions.clear();
        _predictions.addAll(predictions);
      });
    } else {
      showError(res.errorMessage);
    }
  }

  showError(error) {
    // toast the error using Fluttertoast package
    Fluttertoast.showToast(
      msg: error,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
