import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import 'package:commutify/components/map_widget.dart';
import 'package:commutify/components/search/search_container.dart';
import 'package:commutify/models/map_box_place.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      // Use fallback token if needed
      final mapBoxAccessToken = dotenv.env['accessToken'] ?? 'pk.eyJ1Ijoic2lkZGhhcnRoa2FubmEiLCJhIjoiY201aWN3amljMHJqdTJsc2czMmowN2NwOCJ9.9G2HoNPdQYrW1NuXX5CWDA';
      final url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json?access_token=$mapBoxAccessToken';
      
      print("Making geocoding request to: $url");
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].length > 0) {
          return data['features'][0]['place_name'];
        } else {
          print("No features returned from geocoding API");
          return 'Unknown Location';
        }
      } else {
        print("Geocoding API error: ${response.statusCode} - ${response.body}");
        return 'Error fetching address';
      }
    } catch (e) {
      print("Exception in getAddressFromCoordinates: $e");
      return 'Error fetching address';
    }
  }

  void getCurrentLocation() async {
    print("Getting current location...");
    setState(() {
      isLoading = true;
    });
    
    try {
      LatLng? currentLatLng = await LocationService.getCurrentLocation();
      print("Location service returned: $currentLatLng");
      
      if (currentLatLng != null) {
        print("Getting address for coordinates: $currentLatLng");
        String address;
        try {
          address = await getAddressFromCoordinates(
            currentLatLng.latitude,
            currentLatLng.longitude,
          );
          print("Got address: $address");
        } catch (e) {
          print("Error getting address: $e");
          address = "Current Location";
        }

        setState(() {
          pickupLocation = currentLatLng;
          currentLocation = MapBoxPlace(
            latitude: currentLatLng.latitude,
            longitude: currentLatLng.longitude,
            placeName: address,
          );
          isLoading = false;
        });

        print("Setting pickup location...");
        setPickupLocation(currentLocation!);
        print("Pickup location set");
      } else {
        print("Failed to get current location");
        setState(() {
          isLoading = false;
        });
        
        // Show a snackbar with an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access your location. Please check your device settings.'),
            duration: Duration(seconds: 3),
            backgroundColor: Apptheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Error in getCurrentLocation: $e");
      setState(() {
        isLoading = false;
      });
      
      // Show a snackbar with an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          duration: Duration(seconds: 3),
          backgroundColor: Apptheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void setPickupLocation(MapBoxPlace location) {
    print("Setting pickup location: ${location.placeName} at ${location.latitude}, ${location.longitude}");
    // Use the scheduler to ensure setState is called after the frame is built
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        pickupLocation = LatLng(location.latitude, location.longitude);
        print("Pickup location set to: $pickupLocation");
        
        // If destination is already set, this will trigger route recalculation
        if (destinationLocation != null) {
          print("Destination exists, route should update");
        }
      });
    });
  }

  void setDestinationLocation(MapBoxPlace location) {
    print("ROUTE DEBUG: Setting destination location: ${location.placeName} at ${location.latitude}, ${location.longitude}");
    // Use the scheduler to ensure setState is called after the frame is built
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        destinationLocation = LatLng(location.latitude, location.longitude);
        print("ROUTE DEBUG: Destination location set to: $destinationLocation, route should display");
      });
      
      // Force rebuild to ensure route is displayed
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {
          // Just force a rebuild
          print("ROUTE DEBUG: Forcing map rebuild after destination set");
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // Add padding for navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navbarHeight = 70.0 + 20.0; // Height of navbar (70) plus vertical margin (20)
    
    // Debug print for locations
    print("Build HomeScreen - pickupLocation: $pickupLocation, destinationLocation: $destinationLocation");
    
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
                Apptheme.primary.withOpacity(0.7),
                Apptheme.primary.withOpacity(0.0),
              ],
            ),
          ),
        ),
        title: const Text(
          'Commutify',
          style: TextStyle(
            color: Apptheme.surface,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              backgroundColor: Apptheme.surface.withOpacity(0.2),
              radius: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Apptheme.surface,
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
          // Map layer - always show map for debugging
          MapWidget(
            key: ValueKey('map-${DateTime.now().millisecondsSinceEpoch}-${pickupLocation?.latitude}-${pickupLocation?.longitude}-${destinationLocation?.latitude}-${destinationLocation?.longitude}'),
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
                  color: Apptheme.primary,
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
                backgroundColor: Apptheme.primary,
                mini: false, // Use normal sized button
                elevation: 8,
                child: const Icon(
                  Icons.my_location,
                  color: Apptheme.surface,
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
                  color: Apptheme.background.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Powered by MapBox',
                  style: TextStyle(
                    color: Apptheme.text,
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
