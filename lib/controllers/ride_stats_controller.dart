import 'package:flutter/material.dart';
import 'package:commutify/services/ride_api.dart';
import 'package:commutify/models/ride_stats_model.dart';
import 'package:commutify/utils/notification_utils.dart';

/// Controller class for ride statistics operations
class RideStatsController {
  /// Fetch comprehensive ride statistics for the user
  static Future<RideStats?> fetchRideStats(
    BuildContext context, {
    required Function() onLoadingStart,
    required Function() onLoadingEnd,
  }) async {
    onLoadingStart();
    
    try {
      final rideStats = await RideApi.fetchRideStats();
      
      if (rideStats != null) {
        onLoadingEnd();
        return rideStats;
      } else {
        onLoadingEnd();
        NotificationUtils.showWarning(context, 'No ride statistics found');
        return null;
      }
    } catch (e) {
      onLoadingEnd();
      NotificationUtils.showError(context, 'Failed to load ride statistics. Please try again.');
      return null;
    }
  }
}