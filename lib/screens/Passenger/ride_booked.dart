import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/components/pageview.dart';

class Ridebooked extends StatelessWidget {
  const Ridebooked({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Apptheme.backgroundorange,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isSmallScreen = screenWidth < 600;
            final containerWidth = isSmallScreen ? 320.0 : 430.0;
            final containerHeight = isSmallScreen ? 320.0 : 230.0;
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
                      image: AssetImage('assets/ride_publish.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Text(
                  'Booked! Enjoy your ride.',
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
                    'Go to "My Rides section for details of your ride and more options.',
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
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 15,
                    minimumSize: Size(buttonWidth, buttonHeight),
                    backgroundColor: Apptheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('See My Rides',
                      style: TextStyle(fontSize: 22)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
