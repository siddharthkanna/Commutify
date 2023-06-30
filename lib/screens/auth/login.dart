import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlritpool/common/error.dart';
import 'package:mlritpool/common/loading.dart';
import 'package:mlritpool/screens/auth/details.dart';
import '../../components/carousel.dart';
import '../../Themes/app_theme.dart';
import '../../providers/auth_provider.dart';

class Login extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final loading = auth.loading;

    return Scaffold(
      backgroundColor: Apptheme.primaryColor,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'MLRITPOOL',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 36.0,
                        color: Apptheme.fourthColor,
                      ),
                    ),
                    const SizedBox(height: 60.0),
                    CarouselWidget(),
                    const SizedBox(height: 60.0),
                    SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () async {
                          await auth.signInWithGoogle();
                          final user = auth.getCurrentUser();
                          if (user != null) {
                            // User signed in successfully, handle the next steps
                            // save user data, navigate to next screen
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const DetailsPage(),
                              ),
                            );
                          } else {
                            final error = auth.error;
                            ErrorDialog.showErrorDialog(context, error);

                            // Error occurred during sign-in
                            // Handle the error or show a message to the user
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 16.0,
                          ),
                          minimumSize: const Size.fromHeight(
                              50), // Adjust the height as needed
                          backgroundColor: Apptheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: const BorderSide(color: Apptheme.fourthColor),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/GoogleLogo.png',
                              width: 24.0, // Adjust the width as needed
                              height: 24.0, // Adjust the height as needed
                            ),
                            const SizedBox(
                                width:
                                    10.0), // Add spacing between the image and text
                            const Text(
                              'Sign in with Google',
                              style: TextStyle(fontFamily: 'Outfit'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
          ),
          if (loading) const Loader(),
        ],
      ),
    );
  }
}
