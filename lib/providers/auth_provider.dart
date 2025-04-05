import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../components/pageview.dart';
import 'dart:convert';
import '../config/supabase_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    print("Starting Google Sign-In process...");

    try {
      // Sign out from previous sessions to ensure we get a fresh sign-in dialog
      try {
        await _googleSignIn.signOut();
        print("Signed out from previous Google session");
      } catch (e) {
        print("No previous Google session: $e");
      }

      // Show Google Sign-In UI - this should display the account selection
      print("Attempting to show Google Sign-In UI...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print("Google Sign-In was cancelled by user");
        setError('Sign-in was cancelled');
        setLoading(false);
        return;
      }
      
      print("Successfully signed in with Google: ${googleUser.email}");
      print("Getting authentication tokens...");
      
      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print("ID Token available: ${googleAuth.idToken != null}");
      print("Access Token available: ${googleAuth.accessToken != null}");
      
      if (googleAuth.idToken == null) {
        print("Error: ID token is null");
        setError('Failed to get authentication tokens');
        setLoading(false);
        return;
      }

      // Sign in to Supabase with Google ID token
      print("Signing in to Supabase with ID token...");
      final AuthResponse response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google, 
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
      print(response.user);
      print("Supabase auth response received");
      
      if (response.user == null) {
        print("Supabase sign-in failed: No user returned");
        setError('Authentication failed');
        setLoading(false);
        return;
      }
      print("User ID: ${response.user!.id}");
      print("Successfully signed in to Supabase: ${response.user!.email}");
      
      // After successful sign-in, authenticate with our backend
      await loginUser(context);
    } catch (e) {
      print("Error during Google Sign-In: $e");
      setError('Sign-in error: $e');
    }

    setLoading(false);
  }

  // Authenticate with our backend API
  Future<void> loginUser(BuildContext context) async {
    setLoading(true);

    try {
      final user = getCurrentUser();
      if (user == null) {
        setError('No authenticated user found');
        setLoading(false);
        return;
      }
      
      final url = Uri.parse('http://192.168.29.98:5000/auth/login');
      final Map<String, dynamic> requestBody = {
        'uid': user.id,
        'email': user.email,
        'name': user.userMetadata?['full_name'] ?? user.email?.split('@')[0],
        'photoUrl': user.userMetadata?['avatar_url']
      };
      
      print("Logging in with backend: $requestBody");
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print("Login response status: ${response.statusCode}");
      print("Login response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Regardless of whether the user is new or existing, redirect to the main app
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PageViewScreen(),
          ),
        );
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Authentication failed. Please try again.';
        setError(errorMessage);
      }
    } catch (e) {
      print("Error during login: $e");
      setError('Failed to login. Please try again: $e');
    }

    setLoading(false);
  }

  // Sign out
  Future<void> signOut() async {
    setLoading(true);
    setError('');

    try {
      await supabaseClient.auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      setError('Failed to sign out. Please try again: $e');
    }

    setLoading(false);
  }

  // Get the current user
  User? getCurrentUser() {
    return supabaseClient.auth.currentUser;
  }
}
