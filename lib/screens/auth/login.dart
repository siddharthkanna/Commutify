import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:commutify/common/loading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Themes/app_theme.dart';
import '../../providers/auth_provider.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> with SingleTickerProviderStateMixin {
  // Animation controller for the floating elements
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Set up the animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final loading = auth.loading;
    final error = auth.error;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Apptheme.primary,
      body: Container(
        // Clean gradient background
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Apptheme.primary,
              Color.lerp(Apptheme.primary, Apptheme.secondary, 0.2)!,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.08,
            ),
            child: Column(
              children: [
                const Spacer(flex: 3),
                
                // App name and tagline
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // App name
                      Text(
                        'Commutify',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 52.0,
                          color: Apptheme.surface,
                          letterSpacing: 0.2,
                          height: 1.1,
                        ),
                      ),
                      
                      SizedBox(height: screenSize.height * 0.012),
                      
                      // Tagline
                      Text(
                        'Shared rides, shared journeys',
                        style: TextStyle(
                          color: Apptheme.surface.withOpacity(0.75),
                          fontSize: screenSize.width * 0.04,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 4),
                
                // Sign in button
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Apptheme.noir.withOpacity(0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: loading ? null : () async {
                        await auth.signInWithGoogle(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Apptheme.noir,
                        backgroundColor: Apptheme.surface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/GoogleLogo.svg',
                            width: 22,
                            height: 22,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Continue with Google',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              color: Apptheme.noir,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Error message
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Apptheme.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Apptheme.error.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: Apptheme.error.withOpacity(0.8),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              error,
                              style: TextStyle(
                                color: Apptheme.surface,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
      // Loading overlay
      extendBodyBehindAppBar: true,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: loading ? const LoaderAnimated() : null,
    );
  }
}
