import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> createUser(Map<String, dynamic> userData) async {
  try {
    final url = Uri.parse('http://192.168.0.103:3000/auth/'); // Specify the correct route for creating a user
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

