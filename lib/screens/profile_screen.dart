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
          style: TextStyle(
              color: Apptheme.noir, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: screenSize.width * 0.2,
                  backgroundImage: NetworkImage(image),
                ),
                SizedBox(height: screenSize.width * 0.03),
                Text(
                  name,
                  style: TextStyle(
                      fontSize: screenSize.width * 0.055,
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(height: screenSize.width * 0.12),

                sectionButton(
                  screenSize: screenSize,
                  icon: Icons.person,
                  title: 'Personal Info',
                  onPressed: () {
                    // Handle Personal Info section tap
                  },
                ),
                SizedBox(height: screenSize.width * 0.05),

                sectionButton(
                  screenSize: screenSize,
                  icon: Icons.directions_car,
                  title: 'Vehicle Details',
                  onPressed: () {},
                ),
                SizedBox(height: screenSize.width * 0.05),

                // Rides Section
                sectionButton(
                  screenSize: screenSize,
                  icon: Icons.car_rental,
                  title: 'Rides',
                  onPressed: () {},
                ),
                SizedBox(height: screenSize.width * 0.05),

                // Logout Section
                sectionButton(
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

  Widget sectionButton({
    required Size screenSize,
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    final bool showArrowIcon = title != 'Logout';

    return SizedBox(
      width: screenSize.width * 0.85,
      height: screenSize.width * 0.18,
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
                size: screenSize.width * 0.055,
                color: Apptheme.noir,
              ),
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: screenSize.width * 0.042,
                  color: title == 'Logout' ? Colors.red : Apptheme.noir,
                ),
              ),
            ),
            if (showArrowIcon)
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: screenSize.width * 0.055,
                  color: Apptheme.noir,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
