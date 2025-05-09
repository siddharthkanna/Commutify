import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../config/config.dart';
import '../config/supabase_client.dart';

final uidProvider = Provider<String?>((ref) {
  final authService = ref.watch(authProvider);
  final user = authService.getCurrentUser();
  return user?.id;
});

final String? userId = ProviderContainer().read(uidProvider);

class UserApi {
  static Map<String, String> _getHeaders() {
    final session = supabaseClient.auth.currentSession;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${session?.accessToken ?? ""}',
    };
  }

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
      return false;
    }
  }

  static Future<bool> createNewUser(Map<String, dynamic> userData) async {
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
        headers: _getHeaders(),
        body: jsonEncode({
          'name': newName,
          'mobileNumber': newPhoneNumber,
          if (newBio != null) 'bio': newBio,
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
        Uri.parse(getUserDetailsUrl),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final userData = jsonResponse['data']['user'];
          
          var roles = userData['roles'];
          String roleString;
          
          if (roles is List) {
            roleString = roles.isNotEmpty ? (roles.length == 1 ? roles[0].toString() : roles.join(',')) : 'PASSENGER';
          } else if (roles is String) {
            roleString = roles;
          } else {
            roleString = 'PASSENGER';
          }
          
          return {
            'uid': userData['uid'],
            'id': userData['id'],
            'email': userData['email'],
            'name': userData['name'],
            'mobileNumber': userData['mobileNumber'],
            'photoUrl': userData['photoUrl'],
            'roles': roleString,
            'bio': userData['bio'],
          };
        }
        return {};
      }
      return {};
    } catch (error) {
      return {};
    }
  }
}
