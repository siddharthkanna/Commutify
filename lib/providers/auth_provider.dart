import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../components/pageview.dart';
import '../screens/auth/details.dart';
import 'dart:convert';

final authProvider =
    ChangeNotifierProvider<AuthService>((ref) => AuthService());

class AuthService extends ChangeNotifier {
  late final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn = GoogleSignIn();
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

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);

      // After successful sign-in, check if the user exists in the backend
      await checkUserExistence(context);
    } catch (e) {
      setError('Failed to sign in with Google. Please try again.: $e');
    }

    setLoading(false);
  }

  // Check if the user exists in the backend
  // Check if the user exists in the backend
  Future<void> checkUserExistence(BuildContext context) async {
    setLoading(true);

    try {
      final user = _firebaseAuth.currentUser;
      final uid = user?.uid;

      final url = Uri.parse('http://192.168.0.103:3000/auth/exists');
      final response = await http.post(
        url,
        body: {
          'uid': uid,
        },
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final exists = data['exists'] ?? false;

        if (exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PageViewScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DetailsPage(),
            ),
          );
        }
      } else {
        setError('Failed to check user existence. Please try again.');
      }
    } catch (e) {
      setError('Failed to check user existence. Please try again.: $e');
    }

    setLoading(false);
  }

  // Sign out
  Future<void> signOut() async {
    setLoading(true);
    setError('');

    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      setError('Failed to sign out. Please try again.: $e');
    }

    setLoading(false);
  }

  // Get the current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
