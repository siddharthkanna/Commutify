import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/services/ride_api.dart';
import '../../models/ride_modal.dart';
import 'package:url_launcher/url_launcher.dart';

class RideDetailsBooked extends ConsumerStatefulWidget {
  final Ride ride;
  const RideDetailsBooked({super.key, required this.ride});

  @override
  _RideDetailsBookedState createState() => _RideDetailsBookedState();
}

class _RideDetailsBookedState extends ConsumerState<RideDetailsBooked> with SingleTickerProviderStateMixin {
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String currentStatus = '';

  @override
  void initState() {
    super.initState();
    // Initialize status based on ride data
    currentStatus = widget.ride.passengerStatus.isNotEmpty
        ? widget.ride.passengerStatus
        : (widget.ride.rideStatus == 'Cancelled' ? 'Cancelled' : 'Pending');
    
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper method to format datetime
  String _formatDateTime(String timeStr) {
    if (timeStr.isEmpty) {
      return "Time not set";
    }
    
    try {
      final DateTime dateTime = DateTime.tryParse(timeStr) ?? DateTime.now();
      
      final int dayNum = dateTime.day;
      final String day = dayNum.toString();
      final String suffix = _daySuffix(dayNum);
      final String month = _getMonthName(dateTime.month);
      final String year = dateTime.year.toString();
      
      final String period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final int displayHour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final String formattedHour = displayHour.toString();
      final String formattedMinute = dateTime.minute.toString().padLeft(2, '0');
      
      return '$day$suffix $month $year, $formattedHour:$formattedMinute $period';
    } catch (e) {
      return timeStr;
    }
  }
  
  // Helper method to get month name
  String _getMonthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return month >= 1 && month <= 12 ? months[month] : '';
  }

  // Helper method to get day suffix (st, nd, rd, th)
  String _daySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }
  
  // Helper method to format duration
  String _formatDuration(double minutes) {
    if (minutes < 60) {
      return '${minutes.round()} min';
    } else {
      int hours = (minutes / 60).floor();
      int mins = (minutes % 60).round();
      return '$hours h ${mins > 0 ? '$mins min' : ''}';
    }
  }
  
  // Helper method to get vehicle icon
  IconData _getVehicleIcon(String vehicleType) {
    String type = vehicleType.toLowerCase();
    if (type.contains('bike') || type.contains('scooter') || type.contains('motorcycle')) {
      return Icons.two_wheeler;
    } else if (type.contains('bus')) {
      return Icons.directions_bus;
    } else {
      return Icons.directions_car;
    }
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Apptheme.warning.withOpacity(0.3);
      case 'completed':
        return Apptheme.success.withOpacity(0.3);
      case 'cancelled':
        return Apptheme.error.withOpacity(0.3);
      default:
        return Colors.grey.withOpacity(0.3);
      }
    }

  // Helper method to build consistent cards
  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      padding: const EdgeInsets.all(20.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Apptheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
  
  // Helper method to format trip info items
  Widget _buildTripInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Apptheme.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Apptheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Method to handle ride cancellation
  Future<void> _cancelRide() async {
      setState(() {
        isLoading = true;
      });

      final result = await RideApi.cancelRide(widget.ride.id, role: 'passenger');

      if (mounted) {
        if (result['success']) {
          setState(() {
            currentStatus = 'Cancelled';
            isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
                content: Text('Ride cancelled successfully!'),
                backgroundColor: Apptheme.success),
          );
          
          // Navigate back after showing the message
        Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to cancel the ride: ${result['message']}'),
                backgroundColor: Apptheme.error),
          );
          
          setState(() {
            isLoading = false;
          });
        }
      }
    }

  @override
  Widget build(BuildContext context) {
    // Format the ride status for display
    final String displayStatus = 
        currentStatus.isNotEmpty 
        ? currentStatus[0].toUpperCase() + currentStatus.substring(1)
        : 'Pending';

    // Parse location info
    final pickupParts = widget.ride.pickupLocation.placeName.split(',');
    final pickupPlaceName = pickupParts[0].trim();
    final pickupAddress = pickupParts.length > 1 ? pickupParts.sublist(1).join(',').trim() : '';

    final destinationParts = widget.ride.destinationLocation.placeName.split(',');
    final destinationPlaceName = destinationParts[0].trim();
    final destinationAddress = destinationParts.length > 1 ? destinationParts.sublist(1).join(',').trim() : '';

    // Format distance and duration
    final estimatedDistance = widget.ride.estimatedDistance != null 
        ? '${widget.ride.estimatedDistance!.toStringAsFixed(1)} km' 
        : 'N/A';
    
    final estimatedDuration = widget.ride.estimatedDuration != null 
        ? _formatDuration(widget.ride.estimatedDuration!) 
        : 'N/A';

    return Scaffold(
      backgroundColor: Apptheme.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Apptheme.primary,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Apptheme.surface),
        title: const Text(
          'Ride Details',
          style: TextStyle(
            color: Apptheme.surface,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
                  _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 16,
                            color: Apptheme.textSecondary,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                                color: _getStatusColor(currentStatus),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: Text(
                            displayStatus,
                            style: TextStyle(
                                  color: currentStatus.toLowerCase() == 'cancelled' ? Apptheme.error : Apptheme.text,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: Apptheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                    Text(
                              _formatDateTime(widget.ride.time),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Apptheme.text,
                      ),
                    ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.payments_rounded,
                              color: Apptheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                    Text(
                              '₹${widget.ride.price}',
                      style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Apptheme.text,
                              ),
                            ),
                          ],
                    ),
                  ],
                ),
              ),
              
              // Route Card
                  _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Route',
                      style: TextStyle(
                        fontSize: 16,
                        color: Apptheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Apptheme.success,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Apptheme.surface,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.circle,
                                    color: Apptheme.surface,
                                    size: 10,
                                  ),
                                ),
                                Container(
                                  height: 70,
                                  width: 2,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Apptheme.success,
                                        Apptheme.error,
                                      ],
                                    ),
                                  ),
                                ),
                            Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Apptheme.error,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Apptheme.surface,
                              width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.circle,
                                    color: Apptheme.surface,
                                    size: 10,
                                  ),
                                ),
                              ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pickupPlaceName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Apptheme.text,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    pickupAddress,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Apptheme.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                                  const SizedBox(height: 40),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    destinationPlaceName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Apptheme.text,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    destinationAddress,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Apptheme.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        
                        // Trip information
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTripInfoItem(
                              icon: Icons.straighten_rounded,
                              label: 'Distance',
                              value: estimatedDistance,
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            _buildTripInfoItem(
                              icon: Icons.timer_outlined,
                              label: 'Duration',
                              value: estimatedDuration,
                            ),
                          ],
                        ),
                  ],
                ),
              ),

              // Driver Card
                  _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Driver',
                      style: TextStyle(
                        fontSize: 16,
                        color: Apptheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Apptheme.primary.withOpacity(0.2),
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 28,
                          backgroundImage: NetworkImage(widget.ride.driverPhotoUrl),
                                onBackgroundImageError: (_, __) {},
                                child: widget.ride.driverPhotoUrl.isEmpty
                                  ? const Icon(Icons.person, color: Apptheme.primary)
                                  : null,
                              ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.ride.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        _getVehicleIcon(widget.ride.vehicle.vehicleType),
                                        size: 16,
                                        color: Apptheme.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                              Text(
                                '${widget.ride.vehicle.vehicleName} • ${widget.ride.vehicle.vehicleNumber}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Apptheme.textSecondary,
                                ),
                                      ),
                                    ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                              onTap: () => _launchPhoneDialer(widget.ride.driverNumber),
                          child: Container(
                                padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                  color: Apptheme.primary,
                              borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Apptheme.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                            ),
                            child: const Icon(
                              Icons.phone,
                                  color: Apptheme.surface,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

                  // Available Seats
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Capacity',
                          style: TextStyle(
                            fontSize: 16,
                            color: Apptheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.people_alt_rounded,
                              color: Apptheme.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${widget.ride.availableSeats} available seats',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Cancel button - only shown for rides that can be cancelled
                  if (currentStatus.toLowerCase() != 'cancelled' && 
                      currentStatus.toLowerCase() != 'completed')
                Container(
                      margin: const EdgeInsets.only(bottom: 40.0, top: 8.0),
                  width: double.infinity,
                  child: ElevatedButton(
                        onPressed: isLoading ? null : _cancelRide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Apptheme.error.withOpacity(0.1),
                      foregroundColor: Apptheme.error,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Apptheme.error),
                            ),
                          )
                          : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                Icon(Icons.cancel_outlined, size: 20),
                                SizedBox(width: 8),
                                Text(
                            'Cancel Ride',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                                  ),
                                ],
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
        ),
      ),
    );
  }

  void _launchPhoneDialer(String phoneNumber) async {
    final Uri phoneUrl = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(phoneUrl)) {
        await launchUrl(phoneUrl);
      } 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone dialer')),
      );
    }
  }
}
