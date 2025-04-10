import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/config.dart';
import '../models/ride_modal.dart';
import '../models/ride_stats_model.dart';
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
        print('Response body: ${response.body}');
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
        return [];
      }
    } catch (e) {
      print('Error fetching published rides: $e');
      return [];
    }
  }

  static Future<List<Ride>> fetchBookedRides() async {
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
      
      print('Fetching booked rides for user ID: $uid');
      
      // Use the new API endpoint format: /users/:userId/passenger-rides
      final response = await http.get(
        Uri.parse('$fetchPublishedRidesUrl/$uid/passenger-rides')
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Successfully fetched ${data.length} booked rides');
        
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
        print('Failed to fetch booked rides: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching booked rides: $e');
      return [];
    }
  }

  static Future<List<Ride>> fetchAvailableRides({
    String? pickupLocation,
    String? destinationLocation,
    double? pickupLat,
    double? pickupLng,
    double? destinationLat,
    double? destinationLng,
    double? maxPrice,
    DateTime? date,
    int? requiredSeats
  }) async {
    try {
      // Create a ProviderContainer to access the authProvider
      final container = ProviderContainer();
      final authService = container.read(authProvider);
      final user = authService.getCurrentUser();
      final String? uid = user?.id;
      
      // Dispose of the container to prevent memory leaks
      container.dispose();

      // Build the query parameters
      final Map<String, String> queryParams = {};
      
      if (uid != null && uid.isNotEmpty) {
        queryParams['userId'] = uid;
      }
      
      if (maxPrice != null) {
        queryParams['maxPrice'] = maxPrice.toString();
      }
      
      if (date != null) {
        queryParams['date'] = date.toIso8601String();
      }
      
      if (requiredSeats != null) {
        queryParams['requiredSeats'] = requiredSeats.toString();
      }
      
      // Add place names for text search
      if (pickupLocation != null) {
        queryParams['pickupLocation'] = pickupLocation;
      }
      
      if (destinationLocation != null) {
        queryParams['destinationLocation'] = destinationLocation;
      }
      
      // Add coordinates for more precise search
      if (pickupLat != null) {
        queryParams['pickupLat'] = pickupLat.toString();
      }
      
      if (pickupLng != null) {
        queryParams['pickupLng'] = pickupLng.toString();
      }
      
      if (destinationLat != null) {
        queryParams['destinationLat'] = destinationLat.toString();
      }
      
      if (destinationLng != null) {
        queryParams['destinationLng'] = destinationLng.toString();
      }
      
      // Construct the URL with query parameters
      final Uri uri = Uri.parse(fetchAvailableRidesUrl).replace(queryParameters: queryParams);
      
      print('Searching for rides with URL: $uri');
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Extract rides data from the response
        List<dynamic> ridesData = [];
        
        if (responseData is Map && responseData.containsKey('success') && responseData['success'] == true) {
          // Handle { "success": true, "data": [...] } format
          ridesData = responseData['data'] ?? [];
        } else if (responseData is List) {
          // Handle direct array format
          ridesData = responseData;
        }
        
        print('Successfully fetched ${ridesData.length} available rides');
        
        // Convert the data to Ride objects
        final rides = ridesData.map((item) => Ride.fromJson(item))
            .toList();
        
        return rides;
      } else {
        print('Failed to fetch available rides: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching available rides: $e');
      return [];
    }
  }

  static Future<bool> bookRide(String rideId) async {
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
        return false;
      }

      final Map<String, dynamic> requestData = {
        'rideId': rideId,
        'passengerId': uid,
      };

      print('Booking ride ID: $rideId for passenger ID: $uid');

      final response = await http.post(
        Uri.parse(bookRideUrl),
        body: jsonEncode(requestData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Ride booked successfully
        final responseData = jsonDecode(response.body);
        print('Ride booked successfully: ${responseData['message'] ?? ""}');
        return true;
      } else {
        final error = jsonDecode(response.body);
        print('Failed to book ride: ${error['message'] ?? error['error']}');
        return false;
      }
    } catch (e) {
      print('Error booking ride: $e');
      return false;
    }
  }

  static Future<bool> completeRide(String rideId) async {
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
        return false;
      }

      final Map<String, dynamic> requestData = {
        'userId': uid,
      };

      print('Completing ride ID: $rideId for user ID: $uid');

      final response = await http.post(
        Uri.parse('$completeRideUrl/$rideId/complete'),
        body: jsonEncode(requestData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Ride completed successfully: ${responseData['message']}');
        return true;
      } else {
        final error = jsonDecode(response.body);
        print('Failed to complete ride: ${error['message'] ?? error['error']}');
        return false;
      }
    } catch (e) {
      print('Error completing ride: $e');
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
      // Create a ProviderContainer to access the authProvider
      final container = ProviderContainer();
      final authService = container.read(authProvider);
      final user = authService.getCurrentUser();
      final String? uid = user?.id;
      
      // Dispose of the container to prevent memory leaks
      container.dispose();

      if (uid == null || uid.isEmpty) {
        print('Error: User ID is null or empty. User may not be authenticated.');
        return false;
      }

      final Map<String, dynamic> requestData = {
        'rideId': rideId,
      };

      print('Passenger cancelling ride ID: $rideId with passenger ID: $uid');

      final response = await http.post(
        Uri.parse('$cancelRidePassengerUrl/$rideId?passengerId=$uid'),
        body: jsonEncode(requestData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Ride cancelled successfully by passenger: ${responseData['message'] ?? ""}');
        return true;
      } else {
        final error = jsonDecode(response.body);
        print('Failed to cancel ride by passenger: ${error['message'] ?? error['error']}');
        return false;
      }
    } catch (e) {
      print('Error cancelling ride by passenger: $e');
      return false;
    }
  }

  // New unified method to cancel a ride (works for both drivers and passengers)
  static Future<Map<String, dynamic>> cancelRide(String rideId, {String? role}) async {
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
        return {
          'success': false,
          'message': 'User not authenticated'
        };
      }
      
      final Map<String, dynamic> requestData = {
        'userId': uid,
      };
      
      // If role is specified, include it in the request
      if (role != null) {
        requestData['role'] = role;
      }
      
      print('Cancelling ride ID: $rideId for user ID: $uid with role: $role');
      
      final response = await http.post(
        Uri.parse('$cancelRideUrl/$rideId/cancel'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );
      
      print('Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Ride cancelled successfully: ${responseData['message']}');
        return {
          'success': true,
          'message': responseData['message'],
          'cancelledBy': responseData['cancelledBy']
        };
      } else {
        final error = jsonDecode(response.body);
        print('Failed to cancel ride: ${error['message'] ?? error['error']}');
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to cancel ride'
        };
      }
    } catch (e) {
      print('Error cancelling ride: $e');
      return {
        'success': false,
        'message': 'Error cancelling ride: $e'
      };
    }
  }

  static Future<RideStats?> fetchRideStats() async {
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
      
      print('Fetching ride statistics for user ID: $uid');
      
      // Use the ride stats API endpoint: /ride/users/:userId/ride-stats
      final response = await http.get(
        Uri.parse('$fetchRideStatsUrl/$uid/ride-stats')
      );

      print('Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Successfully fetched ride statistics');
        
        // Check if the response has data property (from success wrapper)
        final statsData = data['data'] ?? data;
        
        return RideStats.fromJson(statsData);
      } else {
        print('Failed to fetch ride statistics: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching ride statistics: $e');
      return null;
    }
  }
}
