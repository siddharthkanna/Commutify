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

  static Future<bool> updateUserInfo({
    required String newName,
    required String newPhoneNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(updateUserUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': userId,
          'newName': newName,
          'newMobileNumber': newPhoneNumber,
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
        final userData = json.decode(response.body);
        return userData;
      } else {
        return {};
      }
    } catch (error) {
      return {};
    }
  }
}
