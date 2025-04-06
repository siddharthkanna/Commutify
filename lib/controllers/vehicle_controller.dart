import 'package:flutter/material.dart';
import 'package:commutify/models/vehicle_modal.dart';
import 'package:commutify/services/vehicle_api.dart';
import 'package:commutify/screens/Profile/add_vehicle.dart';
import 'package:commutify/screens/Profile/edit_vehicle.dart';

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
          onSuccess("Vehicle added successfully!");
        } else {
          onError("Failed to add the vehicle!");
        }
      } catch (e) {
        onError("An error occurred. Please try again.");
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
          onSuccess("Vehicle updated successfully!");
        } else {
          onError("Failed to update the vehicle");
        }
      } catch (e) {
        onError("Failed to update the vehicle: $e");
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Vehicle", 
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Are you sure you want to delete '$vehicleName'?",
          style: const TextStyle(
            color: Colors.black87,
            height: 1.3,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              onLoadingStart();
              
              try {
                final isSuccess = await VehicleApi.deleteVehicle(vehicleId);

                if (isSuccess) {
                  await VehicleApi.fetchVehicles();
                  onSuccess("Vehicle deleted successfully");
                } else {
                  onError("Failed to delete the vehicle");
                }
              } catch (e) {
                onError("An error occurred. Please try again.");
              } finally {
                onLoadingEnd();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Delete",
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Display a success snackbar
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  /// Display an error snackbar
  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }
} 