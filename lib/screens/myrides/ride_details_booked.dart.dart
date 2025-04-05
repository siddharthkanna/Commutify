import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/services/ride_api.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../models/ride_modal.dart';
import 'package:url_launcher/url_launcher.dart';

class RideDetailsBooked extends ConsumerStatefulWidget {
  final Ride ride;
  const RideDetailsBooked({required this.ride});

  @override
  _RideDetailsBookedState createState() => _RideDetailsBookedState();
}

class _RideDetailsBookedState extends ConsumerState<RideDetailsBooked> {
  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = MediaQuery.of(context).size.width;

    final String passengerStatus = widget.ride.passengerStatus;

    List<String> pickupParts = widget.ride.pickupLocation.placeName.split(',');
    String pickupPlaceName = pickupParts[0].trim();
    String pickupAddress = pickupParts.sublist(1).join(',').trim();

    bool isLoading = false;

    List<String> destinationParts =
        widget.ride.destinationLocation.placeName.split(',');
    String destinationPlaceName = destinationParts[0].trim();
    String destinationAddress = destinationParts.sublist(1).join(',').trim();

    final double containerWidth =
        isPortrait ? screenWidth * 0.6 : screenWidth * 0.5;

    print(widget.ride.driverNumber);

    Color getStatusColor(String status) {
      if (status == 'Upcoming') {
        return const Color(0xffFFFFA7);
      } else if (status == 'Completed') {
        return const Color(0xff98fb98);
      } else if (status == 'Cancelled') {
        return const Color(0xffd9544d);
      } else {
        return Colors.grey;
      }
    }

    Future<void> cancelRide() async {
      setState(() {
        isLoading = true;
      });

      bool isSuccess = await RideApi.cancelRideDriver(widget.ride.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isSuccess
                ? 'Ride Cancelled successfully!'
                : 'Failed to Cancel the ride. Please try again.')),
      );

      setState(() {
        isLoading = false;
      });
    }

    return Scaffold(
      backgroundColor: Apptheme.mist,
      appBar: AppBar(
        backgroundColor: Apptheme.mist,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ride Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 85,
                      decoration: BoxDecoration(
                        color: getStatusColor(passengerStatus),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Text(
                          passengerStatus,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TimelineTile(
                alignment: TimelineAlign.manual,
                afterLineStyle: const LineStyle(color: Apptheme.navy),
                indicatorStyle: IndicatorStyle(
                  color: Apptheme.navy,
                  iconStyle: IconStyle(
                    color: Apptheme.mist,
                    iconData: Icons.circle_rounded,
                  ),
                ),
                lineXY: 0.1,
                isFirst: true,
                endChild: Container(
                  padding: const EdgeInsets.only(top: 50),
                  constraints: const BoxConstraints(
                    minHeight: 120,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.circle_rounded, color: Apptheme.mist),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pickupPlaceName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: SizedBox(
                                width: containerWidth,
                                child: Text(
                                  pickupAddress,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TimelineTile(
                alignment: TimelineAlign.manual,
                indicatorStyle: IndicatorStyle(
                  color: Apptheme.navy,
                  iconStyle: IconStyle(
                    color: Apptheme.mist,
                    iconData: Icons.circle_rounded,
                  ),
                ),
                beforeLineStyle: const LineStyle(color: Apptheme.navy),
                lineXY: 0.1,
                isLast: true,
                endChild: Container(
                  padding: const EdgeInsets.only(top: 50),
                  constraints: const BoxConstraints(
                    minHeight: 120,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.circle_rounded, color: Apptheme.mist),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              destinationPlaceName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              child: SizedBox(
                                width: containerWidth,
                                child: Text(
                                  destinationAddress,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(
                thickness: 1,
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Driver',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.ride.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            launchPhoneDialer(widget.ride.driverNumber);
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.phone,
                                  color: Apptheme.noir), // Dialer icon
                              const SizedBox(width: 15),
                              CircleAvatar(
                                radius: 25,
                                backgroundImage:
                                    NetworkImage(widget.ride.driverPhotoUrl),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(
                thickness: 1,
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.ride.vehicle.vehicleName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          widget.ride.vehicle.vehicleNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(
                thickness: 1,
              ),
              const SizedBox(height: 20),
              if (passengerStatus != 'Cancelled')
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton(
                        onPressed: cancelRide,
                        child: const Text(
                          'Cancel Ride',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromARGB(255, 191, 50, 39),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

void launchPhoneDialer(String phoneNumber) async {
  final Uri phoneUrl = Uri(scheme: 'tel', path: phoneNumber);

  if (await canLaunchUrl(phoneUrl)) {
    await launchUrl(phoneUrl);
  } else {
    throw 'Could not launch phone dialer';
  }
}
