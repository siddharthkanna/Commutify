import 'package:flutter/material.dart';
import 'package:mlritpool/Themes/app_theme.dart';
import '../../models/ride_modal.dart';
import '../../models/map_box_place.dart';
import './book_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';

class PassengerScreen extends ConsumerStatefulWidget {
  final MapBoxPlace? pickupLocation;
  final MapBoxPlace? destinationLocation;

  PassengerScreen({
    required this.pickupLocation,
    required this.destinationLocation,
  });

  @override
  _PassengerScreenState createState() => _PassengerScreenState();
}

class _PassengerScreenState extends ConsumerState<PassengerScreen> {
  List<Ride> rides = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRidesFromBackend();
  }

  Future<void> fetchRidesFromBackend() async {
    try {
      final List<Ride> fetchedRides = await ApiService.fetchPublishedRides();

      // Filter the rides to keep only the ones with the same destination as the passenger
      final List<Ride> filteredRides = fetchedRides.where((ride) {
        return ride.destinationLocation.placeName ==
            widget.destinationLocation?.placeName;
      }).toList();

      setState(() {
        rides = filteredRides;
        isLoading = false;
      });
    } catch (error) {
      print(error);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double iconSize = screenSize.width * 0.045;

    return Scaffold(
      backgroundColor: Apptheme.mist,
      appBar: AppBar(
        backgroundColor: Apptheme.mist,
        title: const Text(
          'Available Rides',
          style: TextStyle(color: Apptheme.noir, fontWeight: FontWeight.bold),
        ),
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(screenSize.width * 0.02,
            screenSize.width * 0.04, screenSize.width * 0.02, 0),
        child: Stack(
          children: [
            // Show the circular progress indicator while loading
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : rides.isEmpty
                    ? Center(
                        child: Text(
                          'No rides available!',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView.builder(
                        itemCount: rides.length,
                        itemBuilder: (context, index) {
                          return RideCard(ride: rides[index]);
                        },
                      ),
            Positioned(
              bottom: screenSize.width * 0.04,
              right: screenSize.width * 0.04,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Apptheme.noir,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(screenSize.width * 0.25),
                  ),
                ),
                child: Icon(
                  Icons.filter_alt_rounded,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
