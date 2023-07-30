import 'package:flutter/material.dart';
import 'package:mlritpool/Themes/app_theme.dart';
import '../../models/ride_modal.dart';

class RideCard extends StatelessWidget {
  final Ride ride;

  const RideCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double fontSize16 = screenSize.width * 0.04;
    final double fontSize14 = screenSize.width * 0.035;
    final double padding20 = screenSize.width * 0.05;
    final double padding10 = screenSize.width * 0.025;
    final double padding14 = screenSize.width * 0.035;
    final double padding8 = screenSize.width * 0.02;
    final double padding12 = screenSize.width * 0.03;
    final double padding16 = screenSize.width * 0.04;
    final double padding4 = screenSize.width * 0.01;

    return Card(
      elevation: 5.0,
      margin: EdgeInsets.symmetric(horizontal: padding20, vertical: padding10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(padding14),
        side: const BorderSide(color: Colors.black),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${_getShortPlaceName(ride.pickupLocation.placeName)}  \u2192  ${_getShortPlaceName(ride.destinationLocation.placeName)}',
                    style: TextStyle(
                      fontSize: fontSize16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '\Rs.${ride.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: fontSize16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: padding10),
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 16.0, color: Colors.black54),
                SizedBox(width: padding4),
                Text(
                  ride.time,
                  style: TextStyle(fontSize: fontSize14, color: Colors.black54),
                ),
                Spacer(),
                const Icon(Icons.event_seat, size: 16.0, color: Colors.black54),
                SizedBox(width: padding4),
                Text(
                  '${ride.availableSeats}',
                  style: TextStyle(fontSize: fontSize14, color: Colors.black54),
                ),
              ],
            ),
            SizedBox(height: padding14),
            Row(
              children: [
                CircleAvatar(
                  radius: padding20,
                  backgroundImage: NetworkImage(
                      'https://pbs.twimg.com/profile_images/1485050791488483328/UNJ05AV8_400x400.jpg'), // Add the driver's image path here
                ),
                SizedBox(width: padding8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            ride.name,
                            style: TextStyle(
                                fontSize: fontSize16, color: Colors.black),
                          ),
                          const Spacer(),
                          const Icon(Icons.directions_car,
                              size: 16.0, color: Colors.black),
                          SizedBox(width: padding4),
                          Text(
                            ride.vehicleName,
                            style: TextStyle(
                                fontSize: fontSize14, color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: padding10),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  // Implement the booking functionality here
                  // For example, you can show a confirmation dialog or navigate to a booking screen.
                  // For simplicity, I'm just printing a message to the console.
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Apptheme.navy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(padding12),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: padding16, vertical: padding12),
                  child: Text(
                    'Book Ride',
                    style: TextStyle(color: Colors.white, fontSize: fontSize14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _getShortPlaceName(String placeName) {
  // Split the place name by a delimiter (e.g., comma) and take the first part
  List<String> parts = placeName.split(',');
  return parts[0].trim();
}
