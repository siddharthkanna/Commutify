import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:commutify/services/user_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/config.dart';
import '../models/ride_modal.dart';
import '../providers/auth_provider.dart';

class RideApi {
  static Future<bool> publishRide(Map<String, dynamic> rideData) async {
    try {
      // Format data to match API requirements
      final apiData = {
        'driverId': rideData['driverId'],
        'pickupLocation': rideData['pickupLocation'],
        'destinationLocation': rideData['destinationLocation'],
        'immediateMode': rideData['immediateMode'] ?? false,
        'scheduledMode': rideData['scheduledMode'] ?? true,
        'selectedVehicle': rideData['selectedVehicle'],
        'selectedCapacity': rideData['selectedCapacity'],
        'selectedDate': rideData['selectedDate'],
        'selectedTime': rideData['selectedTime'],
        'price': rideData['price'],
        'pricePerKm': rideData['pricePerKm'] ?? 0, // Default to 0 if not provided
        'estimatedDuration': rideData['estimatedDuration'] ?? 0,
        'estimatedDistance': rideData['estimatedDistance'] ?? 0,
        'isRecurring': rideData['isRecurring'] ?? false,
        'recurringDays': rideData['recurringDays'] ?? [],
        'notes': rideData['notes'] ?? '',
        'waypoints': rideData['waypoints'] ?? [],
      };

      final response = await http.post(
        Uri.parse(publishRideUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(apiData),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('Ride published successfully: ${responseData['rideId']}');
        return true;
      } else {
        final error = jsonDecode(response.body);
        print('Failed to publish ride: ${error['message'] ?? error['error']}');
        return false;
      }
    } catch (e) {
      print('Error publishing ride: $e');
      return false;
    }
  }

  static Future<List<Ride>> fetchPublishedRides() async {
    try {
      // Create a ProviderContainer to access the authProvider
      final container = ProviderContainer();
      final authService = container.read(authProvider);
      final user = authService.getCurrentUser();
      final String? uid = user?.id;
      
      // Dispose of the container to prevent memory leaks
      container.dispose();

      if (uid == null || uid.isEmpty) {
        print('Error: User ID is null or empty. User may not be authenticated.');
        throw Exception('UID not available. User not authenticated.');
      }
      
      print('Fetching published rides for user ID: $uid');
      
      // Use the new API endpoint format: /users/:userId/driver-rides
      final response = await http.get(
        Uri.parse('$fetchPublishedRidesUrl/$uid/driver-rides')
      );

      print('Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Successfully fetched ${data.length} published rides');
        
        final rides = data.map((item) {
          try {
            return Ride.fromJson(item);
          } catch (parseError) {
            print('Error parsing ride: $parseError');
            print('Problematic ride data: $item');
            return null;
          }
        })
        .where((ride) => ride != null)
        .cast<Ride>()
        .toList();
        
        return rides;
      } else {
        print('Failed to fetch published rides: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching published rides: $e');
      return [];
    }
  }

  static Future<List<Ride>> fetchBookedRides() async {
    try {
      final String? uid = userId;

      if (uid == null) {
        throw Exception('UID not available. User not authenticated.');
      }
      final response =
          await http.get(Uri.parse('$fetchBookedRidesUrl?passengerId=$uid'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((item) => Ride.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<Ride>> fetchAvailableRides() async {
    try {
      final String? uid = userId;
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
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<bool> bookRide(String rideId) async {
    final String? passengerId = userId;

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
        return false;
      }
    } catch (e) {
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
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> cancelRidePassenger(String rideId) async {
    try {
      final Map<String, dynamic> requestData = {
        'rideId': rideId,
      };

      final response = await http.post(
        Uri.parse('$cancelRidePassengerUrl/$rideId?passengerId=$userId'),
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
      return false;
    }
  }
}
