import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../config/config.dart';

final uidProvider = Provider<String?>((ref) {
  final authService = ref.watch(authProvider);
  final user = authService.getCurrentUser();
  return user?.id;
});

final String? userId = ProviderContainer().read(uidProvider);

class UserApi {
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
        return false;
      }
    } catch (error) {
      print('Error: $error');
      return false;
    }
  }

  static Future<bool> createNewUser(Map<String, dynamic> userData) async {
    try {
      final url = Uri.parse("http://192.168.29.98:5000/auth/create");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        print('Failed to create user: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Error creating user: $error');
      return false;
    }
  }

  static Future<bool> updateUserInfo({
    required String newName,
    required String newPhoneNumber,
    String? newBio,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(updateUserUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': userId,
          'newName': newName,
          'newMobileNumber': newPhoneNumber,
          if (newBio != null) 'newBio': newBio,
        }),
      );

      return response.statusCode == 200;
    } catch (error) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getUserDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$getUserDetailsUrl/$userId'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        // Check if the response has the expected structure
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final userData = jsonResponse['data']['user'];
          
          // Return user data in the expected format
          return {
            'uid': userData['uid'],
            'id': userData['id'],
            'email': userData['email'],
            'name': userData['name'],
            'mobileNumber': userData['mobileNumber'],
            'photoUrl': userData['photoUrl'],
            'roles': userData['roles'],
            'bio': userData['bio'],
            // Include additional fields as needed
          };
        }
        return {};
      }
      return {};
    } catch (error) {
      print('Error fetching user details: $error');
      return {};
    }
  }
}
