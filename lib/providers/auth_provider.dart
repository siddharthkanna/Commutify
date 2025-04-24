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
      };
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        // Parse the response to check if user is new
        final responseData = json.decode(response.body);
        final bool isNewUser = responseData['isNewUser'] ?? false;
        
        if (isNewUser) {
          // User is new, redirect to the details page for onboarding
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DetailsPage(),
            ),
          );
        } else {
          // Existing user, redirect to the main app
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PageViewScreen(),
            ),
          );
        }
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Authentication failed. Please try again.';
        setError(errorMessage);
      }
    } catch (e) {
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
