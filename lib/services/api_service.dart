import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ride_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

final uidProvider = Provider<String?>((ref) {
  final authService = ref.watch(authProvider);
  final user = authService.getCurrentUser();
  return user?.uid;
});

class ApiService {
  static Future<bool> createUser(Map<String, dynamic> userData) async {
    try {
      final url = Uri.parse(
          'https://ridesharing-backend-node.onrender.com/auth/'); 
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }

  static Future<List<String>> fetchVehicles(String uid) async {
    try {
      final response = await http.get(Uri.parse(
          'https://ridesharing-backend-node.onrender.com/auth/vehicles/$uid'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final vehicleNames = data['vehicleNames'];
        return List<String>.from(vehicleNames);
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }

  static Future<bool> publishRide(Map<String, dynamic> rideData) async {
    const String url =
        'https://ridesharing-backend-node.onrender.com/ride/publishride'; // Replace this with your backend API URL

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(rideData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        // Ride published successfully
        return true;
      } else {
        // Handle error case
        return false;
      }
    } catch (e) {
      print('Error while publishing ride: $e');
      return false;
    }
  }

  static Future<List<Ride>> fetchPublishedRides() async {
    try {
      final String? uid = ProviderContainer().read(uidProvider);
      print(uid);

      if (uid == null) {
        throw Exception('UID not available. User not authenticated.');
      }
      final response = await http.get(Uri.parse(
          'https://ridesharing-backend-node.onrender.com/ride/fetchPublishedRides?driverId=$uid'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Ride.fromJson(item)).toList();
      } else {
        print(
            'Failed to fetch published rides. Status code: ${response.statusCode}');
        return []; // Return an empty list in case of an error
      }
    } catch (e) {
      print('Error fetching published rides: $e');
      return []; // Return an empty list in case of an error
    }
  }
}
