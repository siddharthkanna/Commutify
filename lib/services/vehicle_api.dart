import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../models/vehicle_modal.dart';
import '../services/user_api.dart';

class VehicleApi {
  static Future<List<Vehicle>> fetchVehicles() async {
    List<Vehicle> vehicleList = [];
    try {
      final response = await http.get(Uri.parse('$fetchVehiclesUrl/$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final vehicleDataList = data['vehicles'] as List<dynamic>;

        vehicleList = vehicleDataList
            .map((vehicleData) =>
                Vehicle.fromJson(vehicleData as Map<String, dynamic>))
            .toList();

        return vehicleList;
      } else if (response.statusCode == 404) {
        return vehicleList;
      } else {
        return vehicleList;
      }
    } catch (error) {
      return vehicleList;
    }
  }

  static Future<bool> createVehicle(
      String name, String number, String type) async {
    try {
      final response = await http.post(
        Uri.parse("$addVehicleUrl/$userId"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'vehicleName': name,
          'vehicleNumber': number,
          'vehicleType': type,
        }),
      );

      if (response.statusCode == 201) {
        return true; // Vehicle added successfully
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }

  static Future<void> updateVehicle(
    String vehicleId,
    String vehicleName,
    String vehicleNumber,
    String vehicleType,
  ) async {
    final apiUrl = '$updateVehicleUrl/$userId/$vehicleId/';

    await http.post(
      Uri.parse(apiUrl),
      body: {
        'vehicleName': vehicleName,
        'vehicleNumber': vehicleNumber,
        'vehicleType': vehicleType,
      },
    );
  }

  static Future<bool> deleteVehicle(String vehicleId) async {
    if (userId == null) {
      return false;
    }

    final response = await http.post(
      Uri.parse("$deleteVehicleUrl/$userId/$vehicleId"),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
