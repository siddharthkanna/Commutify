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
    String image = user?.photoURL ?? '';
    String name = user?.displayName ?? '';

    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Apptheme.mist,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Apptheme.mist,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Apptheme.noir, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          // Add padding to move content a little bit to the top
          padding: const EdgeInsets.only(bottom: 80),
          // Wrap the SingleChildScrollView with Center
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the content vertically
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: screenSize.width *
                      0.2, // Adjust the radius based on screen width
                  backgroundImage: NetworkImage(image),
                ),
                SizedBox(
                    height: screenSize.width *
                        0.03), // Adjust the height based on screen width
                Text(
                  name,
                  style: TextStyle(
                    fontSize: screenSize.width *
                        0.065, // Adjust the font size based on screen width
                  ),
                ),
                SizedBox(
                    height: screenSize.width *
                        0.12), // Adjust the height based on screen width

                // Personal Info Section
                buildSectionButton(
                  screenSize: screenSize,
                  icon: Icons.person,
                  title: 'Personal Info',
                  onPressed: () {
                    // Handle Personal Info section tap
                  },
                ),
                SizedBox(
                    height: screenSize.width *
                        0.05), // Adjust the height based on screen width

                // Vehicle Details Section
                buildSectionButton(
                  screenSize: screenSize,
                  icon: Icons.directions_car,
                  title: 'Vehicle Details',
                  onPressed: () {
                    // Handle Vehicle Details section tap
                  },
                ),
                SizedBox(
                    height: screenSize.width *
                        0.05), // Adjust the height based on screen width

                // Rides Section
                buildSectionButton(
                  screenSize: screenSize,
                  icon: Icons.car_rental,
                  title: 'Rides',
                  onPressed: () {
                    // Handle Rides section tap
                  },
                ),
                SizedBox(
                    height: screenSize.width *
                        0.05), // Adjust the height based on screen width

                // Logout Section
                buildSectionButton(
                  screenSize: screenSize,
                  icon: Icons.logout,
                  title: 'Logout',
                  onPressed: () async {
                    authService.signOut();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSectionButton({
    required Size screenSize,
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: screenSize.width * 0.85, // Adjust the width based on screen width
      height:
          screenSize.width * 0.18, // Adjust the height based on screen width
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Apptheme.ivory),
          side: MaterialStateBorderSide.resolveWith(
            (states) => BorderSide(
              color: Apptheme.noir,
              width: 1,
              style: states.contains(MaterialState.disabled)
                  ? BorderStyle.none
                  : BorderStyle.solid,
            ),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                icon,
                size: screenSize.width *
                    0.06, // Adjust the icon size based on screen width
                color: Apptheme.noir,
              ),
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: screenSize.width *
                      0.055, // Adjust the font size based on screen width
                  color: title == 'Logout' ? Colors.red : Apptheme.noir,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.arrow_forward_ios,
                size: screenSize.width *
                    0.065, // Adjust the icon size based on screen width
                color: Apptheme.noir,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
