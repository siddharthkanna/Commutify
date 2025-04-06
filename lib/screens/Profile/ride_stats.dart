import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/common/loading.dart';
import 'package:commutify/common/error.dart';
import 'package:commutify/controllers/profile_controller.dart';
import 'package:commutify/services/user_api.dart';

class RideStatsScreen extends StatefulWidget {
  const RideStatsScreen({super.key});

  @override
  _RideStatsScreenState createState() => _RideStatsScreenState();
}

class _RideStatsScreenState extends State<RideStatsScreen> {
  int ridesAsPassenger = 0;
  int ridesAsDriver = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRideCounts();
  }

  Future<void> fetchRideCounts() async {
    final rideStats = await ProfileController.fetchRideStats(
      context,
      onLoadingStart: () => setState(() => isLoading = true),
      onLoadingEnd: () => setState(() => isLoading = false),
    );
    
    if (rideStats != null) {
      setState(() {
        ridesAsPassenger = rideStats['ridesAsPassenger'] ?? 0;
        ridesAsDriver = rideStats['ridesAsDriver'] ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Text(
          'Ride Stats',
          style: TextStyle(color: Apptheme.noir, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Apptheme.mist,
        iconTheme: const IconThemeData(color: Apptheme.noir),
      ),
      body: Container(
        color: Apptheme.mist,
        child: isLoading
            ? const Loader()
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Rides as Passenger: $ridesAsPassenger",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Rides as Driver: $ridesAsDriver",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
