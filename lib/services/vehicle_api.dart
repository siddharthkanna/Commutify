import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../models/vehicle_modal.dart';
import '../config/supabase_client.dart';

class VehicleApi {
  // Helper method to get headers with JWT token
  static Map<String, String> _getHeaders() {
    final session = supabaseClient.auth.currentSession;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${session?.accessToken ?? ""}',
    };
  }

  static Future<List<Vehicle>> fetchVehicles() async {
    List<Vehicle> vehicleList = [];
    try {
      final response = await http.get(
        Uri.parse(fetchVehiclesUrl),
        headers: _getHeaders(),
      );
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
      return vehicleList;
    }
  }

static Future<bool> createVehicle(Vehicle vehicle) async {
  final url = Uri.parse(addVehicleUrl);
  final headers = _getHeaders();
  final body = jsonEncode(vehicle.toJson());

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  } catch (error) {
    return false;
  }
}

  static Future<bool> updateVehicle(String vehicleId, Vehicle updatedVehicle) async {
    final url = Uri.parse("$updateVehicleUrl/$vehicleId");
    final headers = _getHeaders();
    final body = jsonEncode(updatedVehicle.toJson());

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  static Future<bool> deleteVehicle(String vehicleId) async {
    try {
      final response = await http.post(
        Uri.parse("$deleteVehicleUrl/$vehicleId"),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
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
      final vehicleList = await fetchVehicles();
      final vehicle = vehicleList.firstWhere(
        (v) => v.id == vehicleId,
        orElse: () => throw Exception('Vehicle not found'),
      );
      
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
      return false;
    }
  }
}
