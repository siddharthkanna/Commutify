import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/screens/myrides/ride_details_booked.dart.dart';
import 'package:commutify/services/ride_api.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../models/ride_modal.dart';

class RideDetailsPublished extends ConsumerStatefulWidget {
  final Ride ride;
  const RideDetailsPublished({super.key, required this.ride});

  @override
  _RideDetailsPublishedState createState() => _RideDetailsPublishedState();
}

class _RideDetailsPublishedState extends ConsumerState<RideDetailsPublished> {
  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = MediaQuery.of(context).size.width;

    final String rideStatus = widget.ride.rideStatus;
    bool isLoading = false;

    List<String> pickupParts = widget.ride.pickupLocation.placeName.split(',');
    String pickupPlaceName = pickupParts[0].trim();
    String pickupAddress = pickupParts.sublist(1).join(',').trim();

    List<String> destinationParts =
        widget.ride.destinationLocation.placeName.split(',');
    String destinationPlaceName = destinationParts[0].trim();
    String destinationAddress = destinationParts.sublist(1).join(',').trim();

    final double containerWidth =
        isPortrait ? screenWidth * 0.6 : screenWidth * 0.5;
    print(widget.ride.passengers);

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

    Future<void> completeRide() async {
      setState(() => isLoading = true);

      bool isSuccess = await RideApi.completeRide(widget.ride.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isSuccess
                ? 'Ride completed successfully!'
                : 'Failed to complete the ride. Please try again.')),
      );

      setState(() => isLoading = false);
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
        backgroundColor: Apptheme.ivory,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Apptheme.navy,
          iconTheme: const IconThemeData(color: Apptheme.ivory),
          title: const Text(
            'Ride Details',
            style: TextStyle(
              color: Apptheme.ivory,
              fontWeight: FontWeight.w600,
            ),
          ),
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
                        color: getStatusColor(rideStatus),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Text(
                          rideStatus,
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
                        'Passengers',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var passenger in widget.ride.passengers)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6), // Add vertical spacing
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        passenger.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      Text(
                                        passenger.status,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      launchPhoneDialer(passenger.phoneNumber);
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          // Set the color as needed
                                        ),
                                        const SizedBox(
                                            width:
                                                15), // Add some spacing between icon and profile picture
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(
                                            passenger.photoUrl,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const Divider(thickness: 1),
                          if (widget.ride.rideStatus == 'Upcoming')
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextButton(
                                    onPressed: completeRide,
                                    child: const Text(
                                      'Complete Ride',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Apptheme.noir,
                                      ),
                                    ),
                                  ),
                                  const Divider(thickness: 1),
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
                                  const Divider(thickness: 1),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ]),
              ),
            ]))));
  }
}
