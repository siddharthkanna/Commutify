// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/common/loading.dart';
import 'package:commutify/screens/Passenger/ride_booked.dart';
import 'package:commutify/services/ride_api.dart';
import '../../models/ride_modal.dart';
import 'package:intl/intl.dart';

class RideCard extends StatefulWidget {
  final Ride ride;

  const RideCard({super.key, required this.ride});

  @override
  _RideCardState createState() => _RideCardState();
}

class _RideCardState extends State<RideCard> {
  bool isBooking = false;
  
  String _formatTime(String timeString) {
    if (timeString.isEmpty) return '';
    try {
      final DateTime time = DateTime.parse(timeString);
      return DateFormat('h:mm a').format(time); // Format as 10:30 AM
    } catch (e) {
      return timeString;
    }
  }
  
  String _getVehicleIcon(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'suv':
        return '🚙';
      case 'sedan':
        return '🚗';
      case 'hatchback':
        return '🚙';
      case 'bike':
      case 'motorcycle':
        return '🏍️';
      default:
        return '🚗';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Show detailed ride information in a modal bottom sheet
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => _buildRideDetails(context),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ride info row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Driver profile pic
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Apptheme.primary.withOpacity(0.1),
                    backgroundImage: widget.ride.driverPhotoUrl.isNotEmpty ? 
                      NetworkImage(widget.ride.driverPhotoUrl) : null,
                    child: widget.ride.driverPhotoUrl.isEmpty ? 
                      Icon(Icons.person, color: Apptheme.primary.withOpacity(0.7)) : null,
                  ),
                  const SizedBox(width: 16),
                  
                  // Ride details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Driver name and rating
                        Row(
                          children: [
                            Text(
                              widget.ride.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Apptheme.noir,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Apptheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '₹${widget.ride.price}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Vehicle info
                        Row(
                          children: [
                            Text(
                              '${_getVehicleIcon(widget.ride.vehicle.vehicleType)} ${widget.ride.vehicle.vehicleName}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTime(widget.ride.time),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              
              // Route information
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route indicators
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Apptheme.success.withOpacity(0.2),
                          border: Border.all(color: Apptheme.success, width: 2),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 30,
                        color: Colors.grey.shade300,
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Apptheme.error.withOpacity(0.2),
                          border: Border.all(color: Apptheme.error, width: 2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Addresses
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getShortPlaceName(widget.ride.pickupLocation.placeName),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _getShortPlaceName(widget.ride.destinationLocation.placeName),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Available seats and book button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event_seat_outlined,
                          size: 16,
                          color: Apptheme.noir,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.ride.availableSeats} seats',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Apptheme.noir,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  isBooking
                    ? const SizedBox(width: 24, height: 24, child: Loader())
                    : ElevatedButton(
                        onPressed: _bookRide,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Apptheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRideDetails(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // Header
                    const Text(
                      'Ride Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Apptheme.noir,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Driver information
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Apptheme.primary.withOpacity(0.1),
                          backgroundImage: widget.ride.driverPhotoUrl.isNotEmpty ? 
                            NetworkImage(widget.ride.driverPhotoUrl) : null,
                          child: widget.ride.driverPhotoUrl.isEmpty ? 
                            Icon(Icons.person, color: Apptheme.primary.withOpacity(0.7), size: 32) : null,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.ride.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Apptheme.noir,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.ride.driverNumber,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Ride information
                    _buildDetailItem(
                      icon: Icons.calendar_today,
                      title: 'Time',
                      value: _formatTime(widget.ride.time),
                    ),
                    _buildDetailItem(
                      icon: Icons.directions_car,
                      title: 'Vehicle',
                      value: '${widget.ride.vehicle.vehicleName} (${widget.ride.vehicle.vehicleNumber})',
                    ),
                    _buildDetailItem(
                      icon: Icons.event_seat,
                      title: 'Available Seats',
                      value: '${widget.ride.availableSeats}',
                    ),
                    _buildDetailItem(
                      icon: Icons.attach_money,
                      title: 'Price',
                      value: '₹${widget.ride.price}',
                    ),
                    if (widget.ride.estimatedDistance != null)
                      _buildDetailItem(
                        icon: Icons.route,
                        title: 'Distance',
                        value: '${widget.ride.estimatedDistance!.toStringAsFixed(1)} km',
                      ),
                    if (widget.ride.estimatedDuration != null)
                      _buildDetailItem(
                        icon: Icons.timer,
                        title: 'Duration',
                        value: '${widget.ride.estimatedDuration!.toInt()} mins',
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Route details
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Apptheme.success.withOpacity(0.2),
                                border: Border.all(color: Apptheme.success, width: 2),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 50,
                              color: Colors.grey.shade300,
                            ),
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Apptheme.error.withOpacity(0.2),
                                border: Border.all(color: Apptheme.error, width: 2),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PICKUP',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Apptheme.success,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.ride.pickupLocation.placeName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 32),
                              const Text(
                                'DROP-OFF',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Apptheme.error,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.ride.destinationLocation.placeName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Book button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _bookRide();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Apptheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isBooking
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Book This Ride',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Apptheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Apptheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Apptheme.noir,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _bookRide() async {
    if (isBooking) return;
    
    setState(() {
      isBooking = true;
    });

    try {
      final bool success = await RideApi.bookRide(widget.ride.id);

      if (mounted) {
        setState(() {
          isBooking = false;
        });
      }

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Ridebooked(),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to book the ride. Please try again later.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isBooking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

String _getShortPlaceName(String placeName) {
  if (placeName.isEmpty) return '';
  // Split the place name by a delimiter (e.g., comma) and take the first part
  List<String> parts = placeName.split(',');
  return parts[0].trim();
}
