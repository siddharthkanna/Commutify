import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlritpool/Themes/app_theme.dart';
import 'package:mlritpool/screens/auth/login.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authProvider);
    final user = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Screen'),
      ),
      body: Container(
        color: Apptheme.fourthColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to the Profile Screen',
                style: TextStyle(fontSize: 24, color: Apptheme.primaryColor),
              ),
              const SizedBox(height: 20),
              Text(
                'User Name: ${user?.displayName ?? "N/A"}', // Display the user's name or "N/A" if not available
                style:
                    const TextStyle(fontSize: 18, color: Apptheme.primaryColor),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  authService
                      .signOut(); // Call the signOut method from the AuthService
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => Login()),
                  ); // Navigate to the login screen
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
