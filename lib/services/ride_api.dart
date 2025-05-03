import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../models/ride_modal.dart';
import '../models/ride_stats_model.dart';
import '../config/supabase_client.dart';

class RideApi {
  static Map<String, String> _getHeaders() {
    final session = supabaseClient.auth.currentSession;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${session?.accessToken ?? ""}',
    };
  }

  static Future<bool> publishRide(Map<String, dynamic> rideData) async {
    try {
      final response = await http.post(
        Uri.parse(publishRideUrl),
        headers: _getHeaders(),
        body: jsonEncode(rideData),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Ride>> fetchPublishedRides() async {
    try {
      final response = await http.get(
        Uri.parse(fetchPublishedRidesUrl),
        headers: _getHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        final rides = data.map((item) {
          try {
            return Ride.fromJson(item);
          } catch (parseError) {
            return null;
          }
        })
        .where((ride) => ride != null)
        .cast<Ride>()
        .toList();
        
        return rides;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

static Future<List<Ride>> fetchBookedRides() async {
  try {
    final response = await http.get(
      Uri.parse(fetchBookedRidesUrl),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final rides = data.map((item) {
        try {
          return Ride.fromJson(item);
        } catch (parseError) {
          return null;
        }
      })
      .where((ride) => ride != null)
      .cast<Ride>()
      .toList();

      return rides;
    } else {
      return [];
    }
  } catch (e) {
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
      // Build the query parameters
      final Map<String, String> queryParams = {};
      
      if (maxPrice != null) {
        queryParams['maxPrice'] = maxPrice.toString();
      }
      
      if (date != null) {
        queryParams['date'] = date.toIso8601String();
      }
      
      if (requiredSeats != null) {
        queryParams['requiredSeats'] = requiredSeats.toString();
      }
      
      if (pickupLocation != null) {
        queryParams['pickupLocation'] = pickupLocation;
      }
      
      if (destinationLocation != null) {
        queryParams['destinationLocation'] = destinationLocation;
      }
      
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
      
      final Uri uri = Uri.parse(fetchAvailableRidesUrl).replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        List<dynamic> ridesData = [];
        
        if (responseData is Map && responseData.containsKey('success') && responseData['success'] == true) {
          ridesData = responseData['data'] ?? [];
        } else if (responseData is List) {
          ridesData = responseData;
        }
        
        final rides = ridesData.map((item) => Ride.fromJson(item))
            .toList();
        
        return rides;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<bool> bookRide(String rideId) async {
    final Map<String, dynamic> requestData = {
      'rideId': rideId,
    };
    try {
      final response = await http.post(
        Uri.parse('$bookRideUrl/$rideId'),
        body: jsonEncode(requestData),
        headers: _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> completeRide(String rideId) async {
    try {
      final response = await http.post(
        Uri.parse('$completeRideUrl/$rideId'),
        headers: _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> cancelRide(String rideId, {String? role}) async {
    try {
      final Map<String, dynamic> requestData = {};
      if (role != null) {
        requestData['role'] = role;
      }
      final response = await http.post(
        Uri.parse('$cancelRideUrl/$rideId'),
        headers: _getHeaders(),
        body: jsonEncode(requestData),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseData['message'],
          'cancelledBy': responseData['cancelledBy']
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to cancel ride'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error cancelling ride: $e'
      };
    }
  }

  static Future<RideStats?> fetchRideStats() async {
    try {
      final response = await http.get(
        Uri.parse('$rideUrl/ride-stats'),
        headers: _getHeaders(),
      );

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      final statsData = data['data'] ?? data;
      return RideStats.fromJson(statsData);
    } catch (e) {
      return null;
    }
  }
}
