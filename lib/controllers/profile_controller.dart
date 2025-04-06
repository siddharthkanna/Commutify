import 'package:flutter/material.dart';
import 'package:commutify/services/user_api.dart';
import 'package:commutify/utils/notification_utils.dart';

/// Controller class for user profile operations
class ProfileController {
  /// Update user details
  static Future<bool> updateUserInfo(
    BuildContext context, {
    required String newName,
    required String newPhoneNumber,
    required String newBio,
    required Function() onLoadingStart,
    required Function() onLoadingEnd,
  }) async {
    onLoadingStart();
    
    try {
      final isSuccess = await UserApi.updateUserInfo(
        newName: newName,
        newPhoneNumber: newPhoneNumber,
        newBio: newBio,
      );

      if (isSuccess) {
        NotificationUtils.showSuccess(context, 'Details updated successfully!');
        return true;
      } else {
        NotificationUtils.showError(
            context, 'Failed to update details. Please try again.');
        return false;
      }
    } catch (e) {
      NotificationUtils.showError(
          context, 'An error occurred. Please try again later.');
      return false;
    } finally {
      onLoadingEnd();
    }
  }
  
  /// Fetch user details
  static Future<Map<String, dynamic>?> fetchUserDetails(
    BuildContext context, {
    required Function() onLoadingStart,
    required Function() onLoadingEnd,
  }) async {
    onLoadingStart();
    
    try {
      final userData = await UserApi.getUserDetails();
      
      if (userData.isNotEmpty) {
        onLoadingEnd();
        return userData;
      } else {
        onLoadingEnd();
        NotificationUtils.showWarning(context, 'No user data found');
        return null;
      }
    } catch (e) {
      onLoadingEnd();
      NotificationUtils.showError(context, 'Failed to load user details. Please try again.');
      return null;
    }
  }
  
  /// Fetch ride statistics for the user
  static Future<Map<String, int>?> fetchRideStats(
    BuildContext context, {
    required Function() onLoadingStart,
    required Function() onLoadingEnd,
  }) async {
    onLoadingStart();
    
    try {
      final userData = await UserApi.getUserDetails();
      
      if (userData.isNotEmpty) {
        final passengerRides = userData['ridesAsPasssenger'] ?? 0;
        final driverRides = userData['ridesAsDriver'] ?? 0;
        
        onLoadingEnd();
        return {
          'ridesAsPassenger': passengerRides,
          'ridesAsDriver': driverRides,
        };
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