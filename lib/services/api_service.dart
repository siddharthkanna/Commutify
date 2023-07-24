import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ride_modal.dart';

Future<bool> createUser(Map<String, dynamic> userData) async {
  try {
    final url = Uri.parse(
        'http://192.168.0.103:3000/auth/'); // Specify the correct route for creating a user
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

Future<List<String>> fetchVehicles(String uid) async {
  try {
    final response = await http
        .get(Uri.parse('http://192.168.0.103:3000/auth/vehicles/$uid'));
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

Future<bool> publishRide(Map<String, dynamic> rideData) async {
  const String url =
      'http://192.168.0.103:3000/ride/publishride'; // Replace this with your backend API URL

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

Future<List<Ride>> fetchPublishedRides() async {
  try {
    final response = await http.get(Uri.parse(
        'http://192.168.0.103:3000/ride/fetchPublishedRides?driverId=alSrXu1NxRWCEoecxsZ6HPncKex1'));

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
