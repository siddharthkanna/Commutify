import 'package:flutter/material.dart';
import 'package:mlritpool/Themes/app_theme.dart';
import '../../models/ride_modal.dart';

class PublishedCard extends StatelessWidget {
  final Ride ride;

  const PublishedCard({Key? key, required this.ride}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final double fontSize16 = screenSize.width * 0.04;
    final double fontSize14 = screenSize.width * 0.035;
    final double fontSize12 = screenSize.width * 0.03;

    final double padding18 = screenSize.width * 0.045;
    final double padding14 = screenSize.width * 0.035;

    return Container(
      decoration: BoxDecoration(
        color: Apptheme.ivory,
        borderRadius: BorderRadius.circular(padding14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            spreadRadius: 3,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.black,
          width: 0.8,
        ),
      ),
      padding: EdgeInsets.all(padding18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8.0),
          Row(
            children: [
              Text(
                '${_getShortPlaceName(ride.pickupLocation.placeName)}',
                style: TextStyle(
                  fontSize: fontSize16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward,
                size: 16.0, // Adjust this value to make the arrow icon larger
              ),
              const SizedBox(width: 6),
              Text(
                '${_getShortPlaceName(ride.destinationLocation.placeName)}',
                style: TextStyle(
                  fontSize: fontSize16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5.0),
          Text(
            'Rs.${ride.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: fontSize14,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16.0,
                color: Colors.black54,
              ),
              const SizedBox(width: 4.0),
              Text(
                '12th October',
                style: TextStyle(fontSize: fontSize12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16.0,
                color: Colors.black54,
              ),
              const SizedBox(width: 4.0),
              Text(
                ride.time,
                style: TextStyle(fontSize: fontSize12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Row(
            children: [
              const Icon(
                Icons.people,
                size: 16.0,
                color: Colors.black54,
              ),
              const SizedBox(width: 4.0),
              Text(
                ride.availableSeats.toString(),
                style: TextStyle(fontSize: fontSize12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

String _getShortPlaceName(String placeName) {
  // Split the place name by a delimiter (e.g., comma) and take the first part
  List<String> parts = placeName.split(',');
  return parts[0].trim();
}
