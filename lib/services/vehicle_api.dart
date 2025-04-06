import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../models/vehicle_modal.dart';
import '../services/user_api.dart';

class VehicleApi {
  static Future<List<Vehicle>> fetchVehicles() async {
    List<Vehicle> vehicleList = [];
    try {
      if (userId == null) {
        return vehicleList;
      }
      
      final response = await http.get(Uri.parse('$fetchVehiclesUrl/$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final vehicleDataList = data['data']['vehicles'] as List<dynamic>;

          vehicleList = vehicleDataList
              .map((vehicleData) =>
                  Vehicle.fromJson(vehicleData as Map<String, dynamic>))
              .toList();
        }
        return vehicleList;
      } else {
        return vehicleList;
      }
    } catch (error) {
      print('Error fetching vehicles: $error');
      return vehicleList;
    }
  }

  static Future<bool> createVehicle(Vehicle vehicle) async {
    try {
      if (userId == null) {
        return false;
      }
      
      final response = await http.post(
        Uri.parse("$addVehicleUrl/$userId"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(vehicle.toJson()),
      );

      if (response.statusCode == 201) {
        return true; // Vehicle added successfully
      } else {
        final errorData = json.decode(response.body);
        print('Failed to add vehicle: ${errorData['message'] ?? 'Unknown error'}');
        return false;
      }
    } catch (error) {
      print('Error adding vehicle: $error');
      return false;
    }
  }

  static Future<bool> updateVehicle(String vehicleId, Vehicle updatedVehicle) async {
    try {
      if (userId == null) {
        return false;
      }
      
      final response = await http.post(
        Uri.parse("$updateVehicleUrl/$userId/$vehicleId"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedVehicle.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        print('Failed to update vehicle: ${errorData['message'] ?? 'Unknown error'}');
        return false;
      }
    } catch (error) {
      print('Error updating vehicle: $error');
      return false;
    }
  }

  static Future<bool> deleteVehicle(String vehicleId) async {
    try {
      if (userId == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse("$deleteVehicleUrl/$userId/$vehicleId"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        print('Failed to delete vehicle: ${errorData['message'] ?? 'Unknown error'}');
        return false;
      }
    } catch (error) {
      print('Error deleting vehicle: $error');
      return false;
    }
  }
  
  // Helper methods for specific vehicle operations
  
  static Future<bool> addVehicle({
    required String vehicleName,
    required String vehicleNumber,
    required String vehicleType,
    int capacity = 4,
    String? color,
    String? make,
    String? model,
    String? year,
    String? fuelType,
    String? fuelEfficiency,
    List<String>? features,
  }) async {
    final vehicle = Vehicle(
      vehicleName: vehicleName,
      vehicleNumber: vehicleNumber,
      vehicleType: vehicleType,
      capacity: capacity,
      color: color,
      make: make,
      model: model,
      year: year,
      fuelType: fuelType,
      fuelEfficiency: fuelEfficiency,
      features: features,
    );
    
    return await createVehicle(vehicle);
  }
  
  static Future<bool> setVehicleActiveStatus(String vehicleId, bool isActive) async {
    try {
      if (userId == null) {
        return false;
      }
      
      // First, get the current vehicle details
      final vehicleList = await fetchVehicles();
      final vehicle = vehicleList.firstWhere(
        (v) => v.id == vehicleId,
        orElse: () => throw Exception('Vehicle not found'),
      );
      
      // Create a new vehicle with updated isActive status
      final updatedVehicle = Vehicle(
        id: vehicle.id,
        vehicleName: vehicle.vehicleName,
        vehicleNumber: vehicle.vehicleNumber,
        vehicleType: vehicle.vehicleType,
        capacity: vehicle.capacity,
        color: vehicle.color,
        make: vehicle.make,
        model: vehicle.model,
        year: vehicle.year,
        fuelType: vehicle.fuelType,
        fuelEfficiency: vehicle.fuelEfficiency,
        features: vehicle.features,
        photos: vehicle.photos,
        isActive: isActive,
      );
      
      return await updateVehicle(vehicleId, updatedVehicle);
    } catch (error) {
      print('Error setting vehicle active status: $error');
      return false;
    }
  }
}
