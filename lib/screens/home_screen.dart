import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import 'package:mlritpool/components/map_widget.dart';
import 'package:mlritpool/components/search/search_container.dart';
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
    LatLng? currentLocation = await LocationService.getCurrentLocation();
    if (currentLocation != null) {
      setState(() {
        pickupLocation = currentLocation;
        _pickupController.text = 'Your Location';
      });
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
