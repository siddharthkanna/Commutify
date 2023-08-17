import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlritpool/common/loading.dart';
import '../../components/carousel.dart';
import '../../Themes/app_theme.dart';
import '../../providers/auth_provider.dart';

class Login extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final loading = auth.loading;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Apptheme.navy,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.all(screenSize.width * 0.04),
              child: Padding(
                padding: EdgeInsets.only(top: screenSize.height * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Commutify',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 42.0,
                        color: Apptheme.ivory,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.08),
                    CarouselWidget(),
                    SizedBox(height: screenSize.height * 0.08),
                    SizedBox(
                      width: screenSize.width * 0.7,
                      child: ElevatedButton(
                        onPressed: () async {
                          await auth.signInWithGoogle(context);
                        },
                        style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: screenSize.width * 0.04,
                          ),
                          minimumSize:
                              Size.fromHeight(screenSize.height * 0.06),
                          backgroundColor: Apptheme.ivory,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(screenSize.width * 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/GoogleLogo.png',
                              width: screenSize.width * 0.06,
                              height: screenSize.width * 0.06,
                            ),
                            SizedBox(width: screenSize.width * 0.02),
                            const Text(
                              'Sign in with Google',
                              style: TextStyle(
                                  fontFamily: 'Outfit', color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (loading) const LoaderAnimated(),
        ],
      ),
    );
  }
}
