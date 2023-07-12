import 'package:flutter/material.dart';
import 'package:mlritpool/Themes/app_theme.dart';
import 'package:mlritpool/components/pageview.dart';

class RidePublished extends StatelessWidget {
  const RidePublished({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Apptheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 430,
              height: 230,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/ridepost.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(height: 50),
            const Text(
              'You are all set!!',
              style: TextStyle(
                color: Colors.black,
                fontSize: 36,
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 50),
            const SizedBox(
              width: 240,
              child: Text(
                'Your ride is published & \npassengers can now book & travel with you.',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 100),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PageViewScreen(initialPage : 1)),
                );
              },
              style: ElevatedButton.styleFrom(
                  elevation: 15,
                  minimumSize: const Size(280, 55),
                  backgroundColor: Apptheme.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0))),
              child: const Text('See My Rides', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}
