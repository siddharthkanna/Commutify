import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/common/loading.dart';
import 'package:commutify/screens/Passenger/ride_booked.dart';
import 'package:commutify/services/user_api.dart';
import 'package:commutify/services/ride_api.dart';
import '../../models/ride_modal.dart';

class RideCard extends StatefulWidget {
  final Ride ride;

  const RideCard({super.key, required this.ride});

  @override
  _RideCardState createState() => _RideCardState();
}

class _RideCardState extends State<RideCard> {
  bool isBooking = false;

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
                    '${_getShortPlaceName(widget.ride.pickupLocation.placeName)}  \u2192  ${_getShortPlaceName(widget.ride.destinationLocation.placeName)}',
                    style: TextStyle(
                      fontSize: fontSize16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Rs.${widget.ride.price.toStringAsFixed(2)}',
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
                  widget.ride.time,
                  style: TextStyle(fontSize: fontSize14, color: Colors.black54),
                ),
                const Spacer(),
                const Icon(Icons.event_seat, size: 16.0, color: Colors.black54),
                SizedBox(width: padding4),
                Text(
                  '${widget.ride.availableSeats}',
                  style: TextStyle(fontSize: fontSize14, color: Colors.black54),
                ),
              ],
            ),
            SizedBox(height: padding14),
            Row(
              children: [
                CircleAvatar(
                  radius: padding20,
                  backgroundImage: NetworkImage(widget
                      .ride.driverPhotoUrl), // Add the driver's image path here
                ),
                SizedBox(width: padding8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.ride.name,
                            style: TextStyle(
                                fontSize: fontSize16, color: Colors.black),
                          ),
                          const Spacer(),
                          const Icon(Icons.directions_car,
                              size: 16.0, color: Colors.black),
                          SizedBox(width: padding4),
                          Text(
                            widget.ride.vehicle.vehicleName,
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
              child: isBooking
                  ? const SizedBox(width: 24, height: 24, child: Loader())
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isBooking = true;
                        });

                        final bool success =
                            await RideApi.bookRide(widget.ride.id);

                        setState(() {
                          isBooking = false;
                        });

                        if (success) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Ridebooked()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Failed to book the ride. Please try again later.'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Apptheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(padding12),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: padding16, vertical: padding12),
                        child: Text(
                          'Book Ride',
                          style: TextStyle(
                              color: Colors.white, fontSize: fontSize14),
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
