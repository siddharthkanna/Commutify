import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import 'package:mlritpool/components/map_widget.dart';
import 'package:mlritpool/components/search/search_container.dart';
import 'package:mlritpool/models/map_box_place.dart';
import 'package:mlritpool/Themes/app_theme.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng? pickupLocation;
  LatLng? destinationLocation;
  bool showCurrentLocationButton = true;

  MapBoxPlace? currentLocation;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void getCurrentLocation() async {
    LatLng? currentLatLng = await LocationService.getCurrentLocation();
    if (currentLatLng != null) {
      String address = await getAddressFromCoordinates(
        currentLatLng.latitude,
        currentLatLng.longitude,
      );

      setState(() {
        pickupLocation = currentLatLng;
        currentLocation = MapBoxPlace(
          latitude: currentLatLng.latitude,
          longitude: currentLatLng.longitude,
          placeName: address,
        );
      });

      setPickupLocation(currentLocation!);
    }
  }

  void setPickupLocation(MapBoxPlace location) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        pickupLocation = LatLng(location.latitude, location.longitude);
      });
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
              currentLocation: currentLocation,
              setPickupLocation: setPickupLocation,
              setDestinationLocation: setDestinationLocation,
            ),
          ),
          Positioned(
            bottom: 80,
            right: 18,
            child: FloatingActionButton(
              onPressed: getCurrentLocation,
              backgroundColor: Apptheme.navy,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
