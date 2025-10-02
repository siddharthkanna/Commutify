import 'package:commutify/config/config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../components/pageview.dart';
import 'dart:convert';
import '../config/supabase_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../screens/auth/details.dart';
import '../screens/auth/login.dart';

final authProvider =
    ChangeNotifierProvider<AuthService>((ref) => AuthService());

class AuthService extends ChangeNotifier {
  // Initialize GoogleSignIn with scopes and no server client ID
  // We're only using the client API for Android
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: dotenv.env['GOOGLE_CLIENT_ID']
  );
  
  bool _loading = false;
  String _error = '';

  bool get loading => _loading;
  String get error => _error;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  // Sign in with Google
  Future<void> signInWithGoogle(BuildContext context) async {
    setLoading(true);
    setError(''); // Clear any previous errors

    try {
      // Sign out from previous sessions to ensure we get a fresh sign-in dialog
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        // No previous session
      }

      // Show Google Sign-In UI - this should display the account selection
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        setError('Sign-in was cancelled');
        setLoading(false);
        return;
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.idToken == null) {
        setError('Failed to get authentication tokens');
        setLoading(false);
        return;
      }

      // Sign in to Supabase with Google ID token
      final AuthResponse response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google, 
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
      
      if (response.user == null) {
        setError('Authentication failed');
        setLoading(false);
        return;
      }
      
      await loginUser(context);
    } catch (e) {
      setError('Sign-in error: $e');
    }

    setLoading(false);
  }

  // Authenticate with our backend API
  Future<void> loginUser(BuildContext context) async {
    setLoading(true);

    try {
      print('[loginUser] Attempting to get current user...');
      final user = getCurrentUser();
      if (user == null) {
        print('[loginUser] No authenticated user found');
        setError('No authenticated user found');
        setLoading(false);
        return;
      }
      print('[loginUser] Current user: id=${user.id}, email=${user.email}');
      
      // Check if API URL is configured
      if (apiUrl == null || apiUrl!.isEmpty) {
        print('[loginUser] API_URL not configured, skipping API call');
        // For now, assume existing users and go to main screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PageViewScreen(),
          ),
        );
        setLoading(false);
        return;
      }
      
      final url = Uri.parse('$apiUrl/auth/login');
      final Map<String, dynamic> requestBody = {
        'uid': user.id,
        'email': user.email,
      };
      print('[loginUser] Sending POST to $url with body: $requestBody');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      print('[loginUser] Received response: statusCode=${response.statusCode}, body=${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('[loginUser] Response data: $responseData');
        final bool isNewUser = responseData['isNewUser'] ?? false;
        print('[loginUser] isNewUser: $isNewUser');
        
        if (isNewUser) {
          print('[loginUser] Navigating to DetailsPage');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DetailsPage(),
            ),
          );
        } else {
          print('[loginUser] Navigating to PageViewScreen');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PageViewScreen(),
            ),
          );
        }
      } else {
        print('[loginUser] Login failed with status: ${response.statusCode}');
        final errorData = json.decode(response.body);
        print('[loginUser] Error data: $errorData');
        final errorMessage = errorData['message'] ?? 'Authentication failed. Please try again.';
        setError(errorMessage);
      }
    } catch (e) {
      print('[loginUser] Failed to login. Please try again: $e');
      setError('Failed to login. Please try again: $e');
    }

    setLoading(false);
    print('[loginUser] Finished loginUser');
  }

  // Sign out
  Future<void> signOut(BuildContext context) async {
    setLoading(true);
    setError('');

    try {
      await Future.wait([
        supabaseClient.auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      }
    } catch (e) {
      setError('Failed to sign out. Please try again: $e');
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      }
    } finally {
      setLoading(false);
    }
  }

  // Get the current user
  User? getCurrentUser() {
    return supabaseClient.auth.currentUser;
  }
}
