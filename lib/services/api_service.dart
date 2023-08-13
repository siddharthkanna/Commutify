import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ride_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../config/config.dart';

final uidProvider = Provider<String?>((ref) {
  final authService = ref.watch(authProvider);
  final user = authService.getCurrentUser();
  return user?.uid;
});

final String? passengerId = ProviderContainer().read(uidProvider);

class ApiService {
  static Future<bool> createUser(Map<String, dynamic> userData) async {
    try {
      final url = Uri.parse(createUserUrl);
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
      final response = await http.get(Uri.parse('$fetchVehiclesUrl/$uid'));
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
    try {
      final response = await http.post(
        Uri.parse(publishRideUrl),
        body: jsonEncode(rideData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        return true;
      } else {
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

      if (uid == null) {
        throw Exception('UID not available. User not authenticated.');
      }
      final response =
          await http.get(Uri.parse('$fetchPublishedRidesUrl?driverId=$uid'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((item) => Ride.fromJson(item)).toList();
      } else {
        print(
            'Failed to fetch published rides. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching published rides: $e');
      return [];
    }
  }

  static Future<List<Ride>> fetchBookedRides() async {
    try {
      final String? uid = ProviderContainer().read(uidProvider);

      if (uid == null) {
        throw Exception('UID not available. User not authenticated.');
      }
      final response =
          await http.get(Uri.parse('$fetchBookedRidesUrl?passengerId=$uid'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((item) => Ride.fromJson(item)).toList();
      } else {
        print(
            'Failed to fetch Booked rides. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching published rides: $e');
      return [];
    }
  }

  static Future<List<Ride>> fetchAvailableRides() async {
    try {
      final String? uid = ProviderContainer().read(uidProvider);
      print(uid);

      if (uid == null) {
        throw Exception('UID not available. User not authenticated.');
      }
      final response =
          await http.get(Uri.parse('$fetchAvailableRidesUrl?driverId=$uid'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((item) => Ride.fromJson(item)).toList();
      } else {
        print(
            'Failed to fetch published rides. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching published rides: $e');
      return [];
    }
  }

  static Future<bool> bookRide(String rideId) async {
    final String? passengerId = ProviderContainer().read(uidProvider);

    try {
      final Map<String, dynamic> requestData = {
        'rideId': rideId,
        'passengerId': passengerId,
      };

      final response = await http.post(
        Uri.parse(bookRideUrl),
        body: jsonEncode(requestData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Ride booked successfully
        return true;
      } else {
        // Handle error case
        return false;
      }
    } catch (e) {
      print('Error while booking ride: $e');
      return false;
    }
  }

  static Future<bool> completeRide(String rideId) async {
    try {
      final Map<String, dynamic> requestData = {
        'rideId': rideId,
      };

      final response = await http.post(
        Uri.parse('$completeRideUrl/$rideId'),
        body: jsonEncode(requestData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Ride completed successfully
        return true;
      } else {
        // Handle error case
        return false;
      }
    } catch (e) {
      print('Error while completing ride: $e');
      return false;
    }
  }

  static Future<bool> cancelRideDriver(String rideId) async {
    try {
      final Map<String, dynamic> requestData = {
        'rideId': rideId,
      };

      final response = await http.post(
        Uri.parse('$cancelRideDriverUrl/$rideId'),
        body: jsonEncode(requestData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Ride completed successfully
        return true;
      } else {
        // Handle error case
        return false;
      }
    } catch (e) {
      print('Error while completing ride: $e');
      return false;
    }
  }

  static Future<bool> cancelRidePassenger(String rideId) async {
    try {
      final Map<String, dynamic> requestData = {
        'rideId': rideId,
      };

      final response = await http.post(
        Uri.parse('$cancelRidePassengerUrl/$rideId?passengerId=$passengerId'),
        body: jsonEncode(requestData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Ride completed successfully
        return true;
      } else {
        // Handle error case
        return false;
      }
    } catch (e) {
      print('Error while completing ride: $e');
      return false;
    }
  }
}
