import 'package:flutter/material.dart';
import 'package:commutify/models/vehicle_modal.dart';
import 'package:commutify/services/vehicle_api.dart';
import 'package:commutify/screens/Profile/add_vehicle.dart';
import 'package:commutify/screens/Profile/edit_vehicle.dart';
import 'package:commutify/utils/notification_utils.dart';
import 'package:commutify/utils/dialog_utils.dart';

/// Controller class for vehicle operations
class VehicleController {
  /// Add a new vehicle using a dialog and handle the response
  static Future<void> addVehicle(BuildContext context, {
    required Function() onLoadingStart,
    required Function() onLoadingEnd,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return const AddVehicleDialog();
      },
    );

    if (result != null && result.containsKey('vehicle') && result.containsKey('success')) {
      final bool isSuccess = result['success'];
      
      onLoadingStart();
      
      try {
        if (isSuccess) {
          // Re-fetch vehicles to update the list
          await VehicleApi.fetchVehicles();
          const message = "Vehicle added successfully!";
          onSuccess(message);
          NotificationUtils.showSuccess(context, message);
        } else {
          const message = "Failed to add the vehicle!";
          onError(message);
          NotificationUtils.showError(context, message);
        }
      } catch (e) {
        const message = "An error occurred. Please try again.";
        onError(message);
        NotificationUtils.showError(context, message);
      } finally {
        onLoadingEnd();
      }
    }
  }

  /// Edit an existing vehicle using a dialog and handle the response
  static Future<void> editVehicle(BuildContext context, Vehicle vehicle, {
    required Function() onLoadingStart,
    required Function() onLoadingEnd,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    final updatedVehicle = await showDialog<Vehicle>(
      context: context,
      builder: (BuildContext context) {
        return EditVehicleDialog(vehicle: vehicle);
      },
    );

    if (updatedVehicle != null) {
      onLoadingStart();
      
      try {
        final isSuccess = await VehicleApi.updateVehicle(
          updatedVehicle.id!,
          updatedVehicle
        );
        
        if (isSuccess) {
          await VehicleApi.fetchVehicles();
          const message = "Vehicle updated successfully!";
          onSuccess(message);
          NotificationUtils.showSuccess(context, message);
        } else {
          const message = "Failed to update the vehicle";
          onError(message);
          NotificationUtils.showError(context, message);
        }
      } catch (e) {
        final message = "Failed to update the vehicle: $e";
        onError(message);
        NotificationUtils.showError(context, message);
      } finally {
        onLoadingEnd();
      }
    }
  }

  /// Delete a vehicle with confirmation dialog
  static Future<void> deleteVehicle(
    BuildContext context,
    String vehicleId,
    String vehicleName, {
    required Function() onLoadingStart,
    required Function() onLoadingEnd,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    final confirmDelete = await DialogUtils.showDeleteConfirmationDialog(
      context: context,
      itemName: vehicleName,
      title: "Delete Vehicle",
    );
    
    if (confirmDelete) {
      onLoadingStart();
      
      try {
        final isSuccess = await VehicleApi.deleteVehicle(vehicleId);

        if (isSuccess) {
          await VehicleApi.fetchVehicles();
          const message = "Vehicle deleted successfully";
          onSuccess(message);
          NotificationUtils.showSuccess(context, message);
        } else {
          const message = "Failed to delete the vehicle";
          onError(message);
          NotificationUtils.showError(context, message);
        }
      } catch (e) {
        const message = "An error occurred. Please try again.";
        onError(message);
        NotificationUtils.showError(context, message);
      } finally {
        onLoadingEnd();
      }
    }
  }
  
  /// Display a success snackbar
  static void showSuccessSnackbar(BuildContext context, String message) {
    NotificationUtils.showSuccess(context, message);
  }
  
  /// Display an error snackbar
  static void showErrorSnackbar(BuildContext context, String message) {
    NotificationUtils.showError(context, message);
  }
} 