// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';
import 'package:commutify/components/pageview.dart';

class RidePublished extends StatefulWidget {
  final double? estimatedDistance;
  final double? estimatedDuration;

  const RidePublished({
    super.key, 
    this.estimatedDistance,
    this.estimatedDuration,
  });

  @override
  State<RidePublished> createState() => _RidePublishedState();
}

class _RidePublishedState extends State<RidePublished> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Apptheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final isSmallScreen = screenWidth < 600;
            final imageSize = isSmallScreen ? screenWidth * 0.65 : screenWidth * 0.45;
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: imageSize,
                          height: imageSize * 0.75,
                          decoration: const BoxDecoration(
                            image:  DecorationImage(
                              image: AssetImage('assets/ride_post.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        Text(
                          'Ride Published Successfully!',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 26 : 32,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Outfit',
                            letterSpacing: -0.5,
                            color: Apptheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        Text(
                          'Your ride is now visible to passengers who can book and travel with you.',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Outfit',
                            color: Apptheme.textSecondary,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (widget.estimatedDistance != null && widget.estimatedDuration != null) ...[
                          SizedBox(height: screenHeight * 0.035),
                          _buildRouteDetails(isSmallScreen),
                        ],
                        SizedBox(height: screenHeight * 0.06),
                        _buildButton(context, isSmallScreen),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRouteDetails(bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Apptheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Apptheme.primary.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDetailItem(
            icon: Icons.route,
            value: '${widget.estimatedDistance?.toStringAsFixed(1) ?? "0"} km',
            label: 'Distance',
            isSmallScreen: isSmallScreen,
          ),
          Container(
            height: 40,
            width: 1,
            color: Apptheme.primary.withOpacity(0.1),
          ),
          _buildDetailItem(
            icon: Icons.timer,
            value: '${widget.estimatedDuration?.toStringAsFixed(0) ?? "0"} min',
            label: 'Duration',
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String value,
    required String label,
    required bool isSmallScreen,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Apptheme.primary.withOpacity(0.07),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: isSmallScreen ? 18 : 20,
            color: Apptheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 22,
            fontWeight: FontWeight.w600,
            fontFamily: 'Outfit',
            color: Apptheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 15,
            fontWeight: FontWeight.w400,
            fontFamily: 'Outfit',
            color: Apptheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, bool isSmallScreen) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Apptheme.primary,
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const PageViewScreen(initialPage: 1),
            ),
            (route) => false,
          );
        },
        child: Container(
          width: isSmallScreen ? 220 : 260,
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'View My Rides',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Outfit',
                  letterSpacing: 0.2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_rounded, 
                size: 20,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
