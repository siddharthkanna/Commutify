import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import '../../models/ride_modal.dart';

class PublishedCard extends StatelessWidget {
  final Ride ride;

  const PublishedCard({Key? key, required this.ride}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    // Get shorter location names for better display, with null safety
    final String pickupLocationShort = _getShortPlaceName(ride.pickupLocation.placeName);
    final String destinationLocationShort = _getShortPlaceName(ride.destinationLocation.placeName);
    
    // Format time string to be more user-friendly
    final String formattedTime = _formatTimeString(ride.time);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: Apptheme.mist.withOpacity(0.5),
          width: 1,
        ),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(screenSize.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status indicator and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.03,
                      vertical: screenSize.width * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: getStatusColor(ride.rideStatus).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: getStatusColor(ride.rideStatus),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          ride.rideStatus.isEmpty ? 'Unknown' : ride.rideStatus,
                          style: TextStyle(
                            fontSize: screenSize.width * 0.03,
                            fontWeight: FontWeight.w600,
                            color: getStatusColor(ride.rideStatus),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Price tag
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.03,
                      vertical: screenSize.width * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: Apptheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "₹${ride.price}",
                      style: TextStyle(
                        fontSize: screenSize.width * 0.035,
                        fontWeight: FontWeight.bold,
                        color: Apptheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: screenSize.width * 0.04),
              
              // Route information
              Row(
                children: [
                  // Route icons and line
                  Column(
                    children: [
                      Icon(
                        Icons.circle_outlined,
                        size: 16,
                        color: Colors.green,
                      ),
                      Container(
                        height: 25,
                        width: 1,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.red,
                      ),
                    ],
                  ),
                  SizedBox(width: 12),
                  // Locations
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pickupLocationShort,
                          style: TextStyle(
                            fontSize: screenSize.width * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          destinationLocationShort,
                          style: TextStyle(
                            fontSize: screenSize.width * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: screenSize.width * 0.04),
              
              // Divider
              Divider(color: Colors.grey.withOpacity(0.3), height: 1),
              
              SizedBox(height: screenSize.width * 0.03),
              
              // Time and vehicle info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Time info
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 4),
                      Text(
                        formattedTime,
                        style: TextStyle(
                          fontSize: screenSize.width * 0.035,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  
                  // Vehicle info
                  Text(
                    ride.vehicle.vehicleType.isEmpty
                        ? "Vehicle"
                        : "${ride.vehicle.vehicleType} • ${ride.vehicle.vehicleName}",
                    style: TextStyle(
                      fontSize: screenSize.width * 0.035,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: screenSize.width * 0.03),
              
              // Passenger count and seats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Passenger count
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "${ride.passengers.length} passenger${ride.passengers.length != 1 ? 's' : ''}",
                        style: TextStyle(
                          fontSize: screenSize.width * 0.035,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  
                  // Available seats
                  Row(
                    children: [
                      Icon(
                        Icons.airline_seat_recline_normal,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "${ride.availableSeats} seat${ride.availableSeats != 1 ? 's' : ''} available",
                        style: TextStyle(
                          fontSize: screenSize.width * 0.035,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // Add passenger avatars if there are any
              if (ride.passengers.isNotEmpty) ...[
                SizedBox(height: screenSize.width * 0.03),
                Row(
                  children: [
                    Text(
                      "Passengers: ",
                      style: TextStyle(
                        fontSize: screenSize.width * 0.035,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8),
                    // Show up to 3 passenger avatars
                    for (int i = 0; i < ride.passengers.length && i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: CircleAvatar(
                          radius: screenSize.width * 0.03,
                          backgroundImage: NetworkImage(ride.passengers[i].photoUrl),
                          backgroundColor: Apptheme.mist.withOpacity(0.5),
                          child: ride.passengers[i].photoUrl.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: screenSize.width * 0.03,
                                  color: Apptheme.primary,
                                )
                              : null,
                        ),
                      ),
                    // Show count if more than 3 passengers
                    if (ride.passengers.length > 3)
                      Text(
                        "+${ride.passengers.length - 3}",
                        style: TextStyle(
                          fontSize: screenSize.width * 0.035,
                          color: Colors.grey.shade700,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to safely get a shortened place name
  String _getShortPlaceName(String fullPlaceName) {
    if (fullPlaceName.isEmpty) {
      return "Unknown location";
    }
    
    final parts = fullPlaceName.split(',');
    return parts.isNotEmpty ? parts[0].trim() : fullPlaceName;
  }
  
  // Helper method to format time strings from ISO to readable format
  String _formatTimeString(String timeStr) {
    if (timeStr.isEmpty) {
      return "Time not set";
    }
    
    try {
      // Try to parse as ISO date string
      final DateTime dateTime = DateTime.tryParse(timeStr) ?? DateTime.now();
      
      // Format to a readable time
      final String period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final int displayHour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final String formattedHour = displayHour == 0 ? '12' : displayHour.toString();
      final String formattedMinute = dateTime.minute.toString().padLeft(2, '0');
      
      return '$formattedHour:$formattedMinute $period, ${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      // If parsing fails, return the original string
      return timeStr;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'active':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
