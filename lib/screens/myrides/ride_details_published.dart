import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/screens/myrides/ride_details_booked.dart.dart';
import 'package:commutify/services/ride_api.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../models/ride_modal.dart';
import 'package:url_launcher/url_launcher.dart';

class RideDetailsPublished extends ConsumerStatefulWidget {
  final Ride ride;
  const RideDetailsPublished({super.key, required this.ride});

  @override
  _RideDetailsPublishedState createState() => _RideDetailsPublishedState();
}

class _RideDetailsPublishedState extends ConsumerState<RideDetailsPublished> {
    bool isLoading = false;

  // Method to handle completing a ride
    Future<void> completeRide() async {
      setState(() => isLoading = true);

      bool isSuccess = await RideApi.completeRide(widget.ride.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isSuccess
                ? 'Ride completed successfully!'
            : 'Failed to complete the ride. Please try again.'),
      ),
      );

      setState(() => isLoading = false);
    if (isSuccess) {
      Navigator.pop(context);
    }
    }

  // Method to handle cancelling a ride
    Future<void> cancelRide() async {
      setState(() {
        isLoading = true;
      });

      bool isSuccess = await RideApi.cancelRideDriver(widget.ride.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isSuccess
            ? 'Ride cancelled successfully!'
            : 'Failed to cancel the ride. Please try again.'),
      ),
      );

      setState(() {
        isLoading = false;
      });
    if (isSuccess) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final containerWidth = screenWidth - 150;
    
    // Process pickup location to handle multi-line addresses properly
    final List<String> pickupParts = widget.ride.pickupLocation.placeName.split(',');
    final String pickupPlaceName = pickupParts.isNotEmpty ? pickupParts[0].trim() : 'Unknown';
    final String pickupAddress = pickupParts.length > 1 ? pickupParts.sublist(1).join(',').trim() : '';
    
    // Process destination location to handle multi-line addresses properly
    final List<String> destinationParts = widget.ride.destinationLocation.placeName.split(',');
    final String destinationPlaceName = destinationParts.isNotEmpty ? destinationParts[0].trim() : 'Unknown';
    final String destinationAddress = destinationParts.length > 1 ? destinationParts.sublist(1).join(',').trim() : '';
    
    final rideStatus = widget.ride.rideStatus;

    return Stack(
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
          elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Apptheme.noir,
                ),
              ),
            ),
            actions: [],
          ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // Header with gradient - Outside SafeArea to overlap with status bar
                  Container(
                    width: double.infinity,
                    height: screenHeight * 0.22, // Slightly reduce height
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Apptheme.primary,
                          Color.lerp(Apptheme.primary, Apptheme.secondary, 0.5)!,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Apptheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: rideStatus.toLowerCase() == 'upcoming' ? 
                                          const Color(0xFF4CAF50) : 
                                          Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      rideStatus.isEmpty ? 'Unknown' : rideStatus,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                    Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                        child: Text(
                                  "₹${widget.ride.price}",
                                  style: TextStyle(
                                    fontSize: 16,
                            fontWeight: FontWeight.bold,
                                    fontFamily: 'Outfit',
                                    color: Apptheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Your Ride',
                            style: TextStyle(
                              fontSize: 24, // Slightly smaller font
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                              color: Colors.white,
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  blurRadius: 10.0,
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatTimeString(widget.ride.time),
                                style: const TextStyle(
                            fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Outfit',
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Content area with padding for bottom overflow
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Route Timeline - Modern Design
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title with icon
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Apptheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.map_outlined,
                  color: Apptheme.primary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Route',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Outfit',
                                          color: Apptheme.noir,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Dotted line connecting pickup and destination
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                  child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                        Column(
                                          children: [
                                            // Pickup point
                                            Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 3,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.green.withOpacity(0.3),
                                                    blurRadius: 5,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Dotted line
                                            Container(
                                              height: 40,
                                              child: LayoutBuilder(
                                                builder: (context, constraints) {
                                                  return Flex(
                                                    direction: Axis.vertical,
                                                    mainAxisSize: MainAxisSize.max,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: List.generate(
                                                      5, // Number of dots
                                                      (index) => Container(
                                                        width: 2,
                                                        height: 4,
                                                        color: Apptheme.primary.withOpacity(0.3),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            // Destination point
                                            Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 3,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.red.withOpacity(0.3),
                                                    blurRadius: 5,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Pickup details
                                              Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                                                  Text(
                                                    'PICKUP',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.grey.shade600,
                                                      letterSpacing: 1.0,
                                                      fontFamily: 'Outfit',
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                            Text(
                              pickupPlaceName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                                      fontFamily: 'Outfit',
                              ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                            ),
                                                  if (pickupAddress.isNotEmpty) 
                            Padding(
                                                      padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  pickupAddress,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.grey.shade600,
                                                          fontFamily: 'Outfit',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 24),
                                              // Destination details
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'DESTINATION',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.grey.shade600,
                                                      letterSpacing: 1.0,
                                                      fontFamily: 'Outfit',
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    destinationPlaceName,
                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: 'Outfit',
                                  ),
                                                    maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                                  if (destinationAddress.isNotEmpty) 
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 2.0),
                                                      child: Text(
                                                        destinationAddress,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.grey.shade600,
                                                          fontFamily: 'Outfit',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                                  
                                  // Add a way to view full address if needed
                                  if (pickupAddress.isNotEmpty || destinationAddress.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Apptheme.mist.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Apptheme.primary.withOpacity(0.1),
                                            width: 1,
                                          ),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(10),
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                                ),
                                                builder: (context) => _buildAddressDetails(
                                                  pickupPlaceName, 
                                                  pickupAddress, 
                                                  destinationPlaceName, 
                                                  destinationAddress
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 16,
                  color: Apptheme.primary,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'View full address details',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Apptheme.primary,
                                                      fontWeight: FontWeight.w600,
                                                      fontFamily: 'Outfit',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Route Details section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title with icon
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Apptheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.info_outline,
                                      color: Apptheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                              const Text(
                                'Route Details',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: 'Outfit',
                                ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              
                              // Details Card
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Apptheme.primary.withOpacity(0.05),
                                      Apptheme.primary.withOpacity(0.15),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Apptheme.primary.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Apptheme.primary.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // Distance and Duration in a row
                                    Row(
                                      children: [
                                        // Distance info (50% width)
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.03),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                  ),
                  child: Row(
                    children: [
                                                Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Apptheme.primary.withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.route,
                                                    color: Apptheme.primary,
                                                    size: 18,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                                        'Distance',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey.shade600,
                                                          fontFamily: 'Outfit',
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        widget.ride.estimatedDistance != null 
                                            ? '${widget.ride.estimatedDistance!.toStringAsFixed(1)} km'
                                            : 'Unknown',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                                          fontFamily: 'Outfit',
                                                          color: Apptheme.noir,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Duration info (50% width)
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.03),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                        Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Apptheme.primary.withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.timer,
                                                    color: Apptheme.primary,
                                                    size: 18,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Duration',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey.shade600,
                                                          fontFamily: 'Outfit',
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        widget.ride.estimatedDuration != null 
                                            ? '${widget.ride.estimatedDuration!.toStringAsFixed(0)} min'
                                            : 'Unknown',
                                  style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          fontFamily: 'Outfit',
                                                          color: Apptheme.noir,
                        ),
                      ),
                    ],
                  ),
                ),
                          ],
              ),
              ),
                      ),
                    ],
                  ),
                                    
                                    if (widget.ride.price > 0) ...[
              const SizedBox(height: 15),
                                      // Fare info
                                      Container(
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.03),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.payments_outlined,
                                                color: Colors.green,
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 15),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Fare',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey.shade600,
                                                      fontFamily: 'Outfit',
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        '₹${widget.ride.price}',
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          fontFamily: 'Outfit',
                                                          color: Apptheme.noir,
                                                        ),
                                                      ),
                                                      if (widget.ride.estimatedDistance != null && widget.ride.estimatedDistance! > 0) ...[
                                                        const SizedBox(width: 8),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 3,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.green.withOpacity(0.1),
                                                            borderRadius: BorderRadius.circular(30),
                                                          ),
                                          child: Text(
                                                            '₹${(widget.ride.price / widget.ride.estimatedDistance!).toStringAsFixed(1)}/km',
                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.green.shade700,
                                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Outfit',
                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 25),
                        
                        // Vehicle details section
              Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                              // Title with icon
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Apptheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.directions_car,
                                      color: Apptheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                      const Text(
                                    'Vehicle',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              
                              // Vehicle card with gradient background
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      Apptheme.mist.withOpacity(0.3),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                        children: [
                                    // Vehicle header with type icon
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                      decoration: BoxDecoration(
                                        color: Apptheme.noir,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              _getVehicleIcon(widget.ride.vehicle.vehicleType),
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            widget.ride.vehicle.vehicleType.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Outfit',
                                              color: Colors.white,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            child: Text(
                                              '${widget.ride.availableSeats} seats',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Outfit',
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Vehicle details
                            Padding(
                                      padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                          // Vehicle illustration/icon
                                          Container(
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              color: Apptheme.primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Icon(
                                                _getVehicleIcon(widget.ride.vehicle.vehicleType),
                                                size: 40,
                                                color: Apptheme.primary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          
                                          // Vehicle info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                                // Vehicle name
                                      Text(
                                                  widget.ride.vehicle.vehicleName,
                                        style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Outfit',
                                                    color: Apptheme.noir,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                
                                                // Registration number
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Apptheme.noir.withOpacity(0.08),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(
                                                      color: Apptheme.noir.withOpacity(0.1),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    widget.ride.vehicle.vehicleNumber,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      fontFamily: 'Outfit',
                                                      color: Apptheme.noir.withOpacity(0.8),
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 25),
                        
                        // Passengers section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title with icon
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Apptheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.people_alt_rounded,
                                      color: Apptheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Passengers',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Apptheme.mist.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${widget.ride.passengers.length}/${widget.ride.availableSeats}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Outfit',
                                        color: Apptheme.noir,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              
                              if (widget.ride.passengers.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Apptheme.mist.withOpacity(0.3),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.people_outline,
                                            size: 30,
                                            color: Apptheme.noir.withOpacity(0.5),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'No passengers yet',
                                          style: TextStyle(
                                          fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Outfit',
                                            color: Apptheme.noir,
                                        ),
                                      ),
                                        const SizedBox(height: 8),
                                      Text(
                                          'Passengers will appear here once they book your ride',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Outfit',
                                            color: Colors.black.withOpacity(0.6),
                                          ),
                                          textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: widget.ride.passengers.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final passenger = widget.ride.passengers[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                          // Show action sheet for passenger
                                          _showPassengerActionSheet(context, passenger);
                                    },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                              // Passenger avatar with status indicator
                                              Stack(
                                                children: [
                                                  Container(
                                                    width: 60,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 2,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.1),
                                                          blurRadius: 10,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(30),
                                                      child: passenger.photoUrl.isNotEmpty
                                                          ? Image.network(
                                            passenger.photoUrl,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (_, __, ___) => const Icon(
                                                                Icons.person,
                                                                size: 30,
                                                                color: Apptheme.primary,
                                                              ),
                                                            )
                                                          : Container(
                                                              color: Apptheme.mist.withOpacity(0.5),
                                                              child: const Icon(
                                                                Icons.person,
                                                                size: 30,
                                                                color: Apptheme.primary,
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 0,
                                                    bottom: 0,
                                                    child: Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        color: _getStatusColor(passenger.status),
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.white,
                                                          width: 2,
                                                        ),
                                                      ),
                                          ),
                                        ),
                                      ],
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      passenger.name.isEmpty ? 'Passenger' : passenger.name,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: 'Outfit',
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.phone_android,
                                                          size: 14,
                                                          color: Colors.black.withOpacity(0.5),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          passenger.phoneNumber.isEmpty ? 'No phone' : passenger.phoneNumber,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.black.withOpacity(0.6),
                                                            fontFamily: 'Outfit',
                                    ),
                                  ),
                                ],
                              ),
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: _getStatusColor(passenger.status).withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        _formatStatus(passenger.status),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          fontFamily: 'Outfit',
                                                          color: _getStatusColor(passenger.status),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Apptheme.mist.withOpacity(0.3),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.arrow_forward_ios_rounded,
                                                  size: 14,
                                                  color: Apptheme.noir.withOpacity(0.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Action buttons for upcoming rides
                          if (widget.ride.rideStatus == 'Upcoming')
                            Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                // Title with icon
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Apptheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.settings,
                                        color: Apptheme.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Ride Actions',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                
                                // Complete Ride Button - Only show when there are passengers
                                if (widget.ride.passengers.isNotEmpty)
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.green.shade500,
                                        Colors.green.shade700,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: completeRide,
                                      borderRadius: BorderRadius.circular(16),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Complete Ride',
                                              style: TextStyle(
                                        fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Outfit',
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 15),
                                
                                // Cancel Ride Button
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.red.shade300,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: cancelRide,
                                      borderRadius: BorderRadius.circular(16),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade50,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.red.shade600,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                      'Cancel Ride',
                                      style: TextStyle(
                                                fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                                fontFamily: 'Outfit',
                                                color: Colors.red.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Loading overlay
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.4),
            height: screenHeight,
            width: screenWidth,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Apptheme.primary),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Processing...',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Helper method for route detail items
  Widget _buildRouteDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool isWide = false,
  }) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 10 : 0,
        vertical: isWide ? 10 : 0,
      ),
      child: Column(
        children: [
          Icon(
              icon,
              color: Apptheme.primary,
            size: 22,
            ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
                              ),
                            ),
                        ],
                      ),
    );
  }

  // Helper method for vehicle details
  Widget _buildVehicleDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontFamily: 'Outfit',
          ),
        ),
      ],
    );
  }
  
  // Helper method to get vehicle icon
  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'bike':
        return Icons.motorcycle;
      case 'auto':
        return Icons.electric_rickshaw;
      default:
        return Icons.directions_car;
    }
  }
  
  // Helper method to format time string
  String _formatTimeString(String timeString) {
    if (timeString.isEmpty) {
      return 'Time not available';
    }
    
    try {
      final DateTime dateTime = DateTime.parse(timeString);
      final String day = dateTime.day.toString();
      final String month = _getMonthName(dateTime.month);
      final String year = dateTime.year.toString();
      final String time = _formatTime(dateTime.hour, dateTime.minute);
      
      return '$day $month, $year at $time';
    } catch (e) {
      print('Error parsing date: $e');
      return timeString;
    }
  }
  
  // Helper for month name
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
  
  // Helper for formatting time
  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    final formattedMinute = minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute $period';
  }

  // Method to build the address details bottom sheet
  Widget _buildAddressDetails(
    String pickupName, 
    String pickupAddress, 
    String destinationName, 
    String destinationAddress
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Full Address Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 20),
          
          // Pickup full details
          Text(
            'Pickup Location',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.green,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pickupName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          if (pickupAddress.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              pickupAddress,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontFamily: 'Outfit',
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Destination full details
          Text(
            'Destination Location',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            destinationName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          if (destinationAddress.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              destinationAddress,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontFamily: 'Outfit',
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Close button
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Apptheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Apptheme.primary),
                ),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  void launchPhoneDialer(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      print('Could not launch dialer: $e');
    }
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper method to format status text
  String _formatStatus(String status) {
    if (status.isEmpty) return 'Unknown';
    
    // Capitalize first letter
    return status.substring(0, 1).toUpperCase() + status.substring(1).toLowerCase();
  }

  // Method to show passenger action sheet
  void _showPassengerActionSheet(BuildContext context, Passenger passenger) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Apptheme.primary,
                  child: Icon(Icons.phone, color: Colors.white),
                ),
                title: const Text(
                  'Call Passenger',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  passenger.phoneNumber.isEmpty ? 'No phone number available' : passenger.phoneNumber,
                  style: const TextStyle(fontFamily: 'Outfit'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  launchPhoneDialer(passenger.phoneNumber);
                },
              ),
              const Divider(),
              if (widget.ride.rideStatus == 'Upcoming' && passenger.status.toLowerCase() == 'confirmed')
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade50,
                    child: Icon(Icons.cancel_outlined, color: Colors.red),
                  ),
                  title: const Text(
                    'Cancel Passenger',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  subtitle: const Text(
                    'Remove this passenger from your ride',
                    style: TextStyle(fontFamily: 'Outfit'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Add cancel passenger logic here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('This feature is coming soon')),
                    );
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

