import 'package:flutter/material.dart';
import 'package:mlritpool/Themes/app_theme.dart';
import 'package:mlritpool/components/pageview.dart';

class RidePublished extends StatelessWidget {
  const RidePublished({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Apptheme.backgroundblue,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isSmallScreen = screenWidth < 600;
            final containerWidth = isSmallScreen ? 320.0 : 430.0;
            final containerHeight = isSmallScreen ? 180.0 : 230.0;
            final fontSizeTitle = isSmallScreen ? 28.0 : 36.0;
            final fontSizeText = isSmallScreen ? 18.0 : 22.0;
            final buttonWidth = isSmallScreen ? 210.0 : 280.0;
            final buttonHeight = isSmallScreen ? 55.0 : 55.0;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: containerWidth,
                  height: containerHeight,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/ridepost.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Text(
                  'You are all set!!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: fontSizeTitle,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: 0.6 * screenWidth,
                  child: Text(
                    'Your ride is published & \npassengers can now book & travel with you.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: fontSizeText,
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const PageViewScreen(initialPage: 1)),
                      (route) =>
                          false, // RoutePredicate: Always return false to remove all previous routes.
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 15,
                    minimumSize: Size(buttonWidth, buttonHeight),
                    backgroundColor: Apptheme.noir,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('See My Rides', style: TextStyle(fontSize: 22)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
