import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import 'package:commutify/components/map_widget.dart';
import 'package:commutify/components/search/search_container.dart';
import 'package:commutify/models/map_box_place.dart';
import 'package:commutify/Themes/app_theme.dart';
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
  bool isLoading = false;

  MapBoxPlace? currentLocation;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });
    
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
        isLoading = false;
      });

      setPickupLocation(currentLocation!);
    } else {
      setState(() {
        isLoading = false;
      });
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
    final screenSize = MediaQuery.of(context).size;
    // Add padding for navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navbarHeight = 70.0 + 20.0; // Height of navbar (70) plus vertical margin (20)
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Apptheme.navy.withOpacity(0.7),
                Apptheme.navy.withOpacity(0.0),
              ],
            ),
          ),
        ),
        title: const Text(
          'Commutify',
          style: TextStyle(
            color: Apptheme.ivory,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              backgroundColor: Apptheme.ivory.withOpacity(0.2),
              radius: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Apptheme.ivory,
                ),
                onPressed: () {
                  // Handle notification button press
                },
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map layer
          if ((pickupLocation != null && destinationLocation == null) ||
              (pickupLocation != null && destinationLocation != null))
            MapWidget(
              pickupLocation: pickupLocation,
              destinationLocation: destinationLocation,
              isCurrentLocation: true,
            ),
            
          // Loading indicator
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Apptheme.ivory,
                ),
              ),
            ),
            
          // Search container
          Positioned(
            top: screenSize.height * 0.12,
            left: 20,
            right: 20,
            child: SearchContainer(
              currentLocation: currentLocation,
              setPickupLocation: setPickupLocation,
              setDestinationLocation: setDestinationLocation,
            ),
          ),
          
          // Location button - position directly above navbar
          Positioned(
            bottom: navbarHeight + 15.0, // Place 15px above the navbar
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: getCurrentLocation,
                backgroundColor: Apptheme.navy,
                mini: false, // Use normal sized button
                elevation: 8,
                child: const Icon(
                  Icons.my_location,
                  color: Apptheme.ivory,
                  size: 20, // Normal icon size
                ),
              ),
            ),
          ),
          
          // Attribution - position it lower to avoid overlapping with the larger button
          Positioned(
            bottom: navbarHeight - 5.0, // Position closer to the navbar
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Apptheme.ivory.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Powered by MapBox',
                  style: TextStyle(
                    color: Apptheme.navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
