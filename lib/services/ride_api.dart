import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:commutify/services/user_api.dart';
import '../config/config.dart';
import '../models/ride_modal.dart';

class RideApi {
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
      return false;
    }
  }

  static Future<List<Ride>> fetchPublishedRides() async {
    try {
      final String? uid = userId;

      if (uid == null) {
        throw Exception('UID not available. User not authenticated.');
      }
      final response =
          await http.get(Uri.parse('$fetchPublishedRidesUrl?driverId=$uid'));

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
