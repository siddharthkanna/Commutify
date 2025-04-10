import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/services/user_api.dart';
import '../../models/ride_modal.dart';

class BookedCard extends StatelessWidget {
  final Ride ride;

  const BookedCard({Key? key, required this.ride}) : super(key: key);

  String _formatTime(String timeStr) {
    if (timeStr.isEmpty) {
      return "Time not set";
    }
    
    try {
      // Try to parse as ISO date string
      final DateTime dateTime = DateTime.tryParse(timeStr) ?? DateTime.now();
      
      // Format the date
      final int dayNum = dateTime.day;
      final String day = dayNum.toString();
      final String suffix = daySuffix(dayNum);
      final String month = _getMonthName(dateTime.month);
      
      // Format the time
      final String period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final int displayHour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
      final String formattedHour = displayHour == 0 ? '12' : displayHour.toString();
      final String formattedMinute = dateTime.minute.toString().padLeft(2, '0');
      
      return '$day$suffix $month, $formattedHour:$formattedMinute $period';
    } catch (e) {
      // If parsing fails, return the original string
      return timeStr;
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'January';
      case 2: return 'February';
      case 3: return 'March';
      case 4: return 'April';
      case 5: return 'May';
      case 6: return 'June';
      case 7: return 'July';
      case 8: return 'August';
      case 9: return 'September';
      case 10: return 'October';
      case 11: return 'November';
      case 12: return 'December';
      default: return '';
    }
  }

  String daySuffix(int day) {
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    // Get shorter location names for better display
    final String pickupLocationShort = _getShortPlaceName(ride.pickupLocation.placeName);
    final String destinationLocationShort = _getShortPlaceName(ride.destinationLocation.placeName);
    
    // Handle null or empty passengerStatus
    final String statusText = ride.passengerStatus.isNotEmpty ? ride.passengerStatus : 'Pending';
    final Color statusColor = getStatusColor(statusText);
    
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
                      color: statusColor.withOpacity(0.15),
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
                            color: statusColor,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: screenSize.width * 0.03,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Price
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
              
              // Time and date, vehicle info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Time and date
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 4),
                      Text(
                        _formatTime(ride.time),
                        style: TextStyle(
                          fontSize: screenSize.width * 0.035,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  
                  // Vehicle info
                  Text(
                    "${ride.vehicle.vehicleType} • ${ride.vehicle.vehicleName}",
                    style: TextStyle(
                      fontSize: screenSize.width * 0.035,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: screenSize.width * 0.03),
              
              // Driver info
              Row(
                children: [
                  // Driver avatar
                  CircleAvatar(
                    radius: screenSize.width * 0.04,
                    backgroundImage: NetworkImage(ride.driverPhotoUrl),
                    backgroundColor: Apptheme.mist.withOpacity(0.5),
                    child: ride.driverPhotoUrl.isEmpty
                        ? Icon(
                            Icons.person,
                            size: screenSize.width * 0.04,
                            color: Apptheme.primary,
                          )
                        : null,
                  ),
                  SizedBox(width: 8),
                  
                  // Driver name
                  Expanded(
                    child: Text(
                      "Driver: ${ride.name}",
                      style: TextStyle(
                        fontSize: screenSize.width * 0.035,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Call icon
                  Container(
                    padding: EdgeInsets.all(screenSize.width * 0.02),
                    decoration: BoxDecoration(
                      color: Apptheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.phone,
                      size: screenSize.width * 0.04,
                      color: Apptheme.primary,
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

  Color getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return Colors.amber.shade700;
      case 'Completed':
        return Colors.green.shade700;
      case 'Cancelled':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }
}

String _getShortPlaceName(String placeName) {
  // Split the place name by a delimiter (e.g., comma) and take the first part
  List<String> parts = placeName.split(',');
  return parts[0].trim();
}
