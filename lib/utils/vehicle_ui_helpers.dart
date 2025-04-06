import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';

/// Helper class for vehicle-related UI utilities
class VehicleUIHelpers {
  /// Returns the appropriate icon for a given vehicle type
  static IconData getVehicleIcon(String vehicleType) {
    final type = vehicleType.toLowerCase();
    if (type.contains('car')) {
      return Icons.directions_car_outlined;
    } else if (type.contains('bike') || type.contains('motorcycle')) {
      return Icons.motorcycle_outlined;
    } else if (type.contains('bus')) {
      return Icons.directions_bus_outlined;
    } else if (type.contains('truck')) {
      return Icons.local_shipping_outlined;
    } else {
      return Icons.commute_outlined;
    }
  }
  
  /// Returns the appropriate theme color for a given vehicle type
  static Color getVehicleColor(String vehicleType) {
    final type = vehicleType.toLowerCase();
    if (type.contains('car')) {
      return Apptheme.primary;
    } else if (type.contains('bike') || type.contains('motorcycle')) {
      return Colors.orange;
    } else if (type.contains('bus')) {
      return Colors.blue;
    } else if (type.contains('truck')) {
      return Colors.purple;
    } else {
      return Apptheme.primary;
    }
  }
  
  /// Builds a specification chip for vehicle attributes
  static Widget buildSpecChip({
    required BuildContext context, 
    required IconData icon, 
    required String label, 
    Color? color, 
    bool isPrimary = false
  }) {
    final themeColor = color ?? Colors.black54;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: themeColor,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: themeColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
} 