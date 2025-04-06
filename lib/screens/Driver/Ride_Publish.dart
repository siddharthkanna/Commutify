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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
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
      backgroundColor: Apptheme.backgroundblue,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final isSmallScreen = screenWidth < 600;
            final imageSize = isSmallScreen ? screenWidth * 0.7 : screenWidth * 0.5;
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeInAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                        width: imageSize,
                        height: imageSize * 0.75,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                      image: AssetImage('assets/ride_post.png'),
                            fit: BoxFit.contain,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
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
                          color: Colors.black.withOpacity(0.9),
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
                          color: Colors.black.withOpacity(0.6),
                          height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                      ),
                      if (widget.estimatedDistance != null && widget.estimatedDuration != null) ...[
                        SizedBox(height: screenHeight * 0.025),
                        _buildRouteDetails(isSmallScreen),
                      ],
                      SizedBox(height: screenHeight * 0.06),
                      _buildButton(context, isSmallScreen),
                    ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Apptheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Apptheme.primary.withOpacity(0.2),
          width: 1.5,
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
            color: Apptheme.primary.withOpacity(0.2),
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
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Apptheme.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: isSmallScreen ? 16 : 18,
            color: Apptheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 22,
            fontWeight: FontWeight.w600,
            fontFamily: 'Outfit',
            color: Apptheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Outfit',
            color: Colors.black.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Apptheme.noir.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
              builder: (context) => const PageViewScreen(initialPage: 1),
            ),
            (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
          minimumSize: Size(isSmallScreen ? 220 : 260, 58),
                    backgroundColor: Apptheme.noir,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32),
                    shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'View My Rides',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Outfit',
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
