import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:latlong2/latlong.dart';
import '../components/map_widget.dart';
import '../Themes/app_theme.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng? pickupLocation;
  LatLng? destinationLocation;
  bool showCurrentLocationButton = true;
  final TextEditingController _pickupController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        pickupLocation = LatLng(position.latitude, position.longitude);
        _pickupController.text = 'Your Location';
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void setPickupLocation(MapBoxPlace location) {
    setState(() {
      pickupLocation = LatLng(location.latitude, location.longitude);
    });
  }

  void setDestinationLocation(MapBoxPlace location) {
    setState(() {
      destinationLocation = LatLng(location.latitude, location.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (pickupLocation != null && destinationLocation != null)
            MapWidget(
              pickupLocation: pickupLocation!,
              destinationLocation: destinationLocation!,
            ),
          Positioned(
            top: 70,
            left: 20,
            right: 20,
            child: SearchContainer(
              setPickupLocation: setPickupLocation,
              setDestinationLocation: setDestinationLocation,
              pickupController: _pickupController,
            ),
          ),
          if (showCurrentLocationButton)
            Positioned(
              bottom: 100,
              right: 20,
              height: 50,
              width: 50,
              child: FloatingActionButton(
                onPressed: getCurrentLocation,
                backgroundColor: Apptheme.primaryColor,
                child: const Icon(Icons.my_location),
              ),
            ),
        ],
      ),
    );
  }
}

class SearchContainer extends StatefulWidget {
  final Function(MapBoxPlace) setPickupLocation;
  final Function(MapBoxPlace) setDestinationLocation;
  final TextEditingController pickupController;

  const SearchContainer({
    required this.setPickupLocation,
    required this.setDestinationLocation,
    required this.pickupController,
  });

  @override
  _SearchContainerState createState() => _SearchContainerState();
}

class _SearchContainerState extends State<SearchContainer> {
  final TextEditingController _destinationController = TextEditingController();
  @override
  void dispose() {
    widget.pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<List<MapBoxPlace>> fetchLocationSuggestions(String query) async {
    final apiKey = mapBoxAccessToken;
    const country = 'IN';
    final endpoint =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json?country=$country&access_token=$apiKey';

    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final features = data['features'] as List<dynamic>;
      return features
          .map((feature) => MapBoxPlace(
                placeName: feature['place_name'],
                longitude: feature['geometry']['coordinates'][0],
                latitude: feature['geometry']['coordinates'][1],
              ))
          .toList();
    } else {
      throw Exception('Failed to fetch location suggestions');
    }
  }

  void showDriverPassengerPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
           shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: const BorderSide(color: Colors.black),
        ),
          title: const Text(
              style: TextStyle(fontWeight: FontWeight.bold),
              'Select Your Role!'),
          backgroundColor: Apptheme.fourthColor,
          
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Apptheme.button,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                    fontSize: 15.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  minimumSize: const Size(100, 40),
                ),
                onPressed: () {
                  // Handle driver button press
                  Navigator.of(context).pop();
                  // Navigate to driver screen
                },
                child: const Text('Driver'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Apptheme.button,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                    fontSize: 15.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  minimumSize: const Size(50, 40),
                ),
                onPressed: () {
                  // Handle passenger button press
                  Navigator.of(context).pop();
                  // Navigate to passenger screen
                },
                child: const Text('Passenger'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Apptheme.conatainer,
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.black),
      ),
      constraints: const BoxConstraints(minHeight: 200.0, minWidth: 330.0),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Where to?',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15.0),
          SizedBox(
            width: 300.0,
            height: 60,
            child: TypeAheadField<MapBoxPlace>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: widget.pickupController,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  labelText: 'Pickup',
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: Apptheme.inputBox,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      widget.pickupController.clear();
                    },
                  ),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return await fetchLocationSuggestions(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion.placeName),
                );
              },
              onSuggestionSelected: (suggestion) {
                widget.pickupController.text = suggestion.placeName;
                widget.setPickupLocation(suggestion);
              },
            ),
          ),
          const SizedBox(height: 10.0),
          SizedBox(
            width: 300.0,
            height: 60.0,
            child: TypeAheadField<MapBoxPlace>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _destinationController,
                decoration: InputDecoration(
                  labelText: 'Destination',
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: Apptheme.inputBox,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _destinationController.clear();
                    },
                  ),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return await fetchLocationSuggestions(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion.placeName),
                );
              },
              onSuggestionSelected: (suggestion) {
                _destinationController.text = suggestion.placeName;
                widget.setDestinationLocation(suggestion);
              },
            ),
          ),
          const SizedBox(
            height: 5.0,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Apptheme.button,
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
                fontSize: 15.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              minimumSize: const Size(100, 40),
            ),
            onPressed: () {
              // Handle button press
              showDriverPassengerPopup();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class MapBoxPlace {
  final String placeName;
  final double longitude;
  final double latitude;

  MapBoxPlace({
    required this.placeName,
    required this.longitude,
    required this.latitude,
  });
}
