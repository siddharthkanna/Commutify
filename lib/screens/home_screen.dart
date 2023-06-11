import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mlritpool/components/map_widget.dart';
import 'package:mlritpool/components/search_container.dart';
import 'package:mlritpool/models/map_box_place.dart';
import 'package:mlritpool/themes/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
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
          if ((pickupLocation != null && destinationLocation == null) ||
              (pickupLocation != null && destinationLocation != null))
            MapWidget(
              pickupLocation: pickupLocation,
              destinationLocation: destinationLocation,
              isCurrentLocation: true,
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
          Positioned(
            bottom: 100,
            right: 18,
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
