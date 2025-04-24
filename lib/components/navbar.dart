import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:commutify/Themes/app_theme.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;

  const NavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    //final screenSize = MediaQuery.of(context).size;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // Ensure no content extends beyond the rounded corners
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Apptheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(35),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.directions_car_rounded, 'Rides'),
              _buildNavItem(2, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          HapticFeedback.lightImpact();
          onTabChanged(index);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Apptheme.primary : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected 
              ? [
                  BoxShadow(
                    color: Apptheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 3),
                  ),
                ] 
              : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Apptheme.surface : Apptheme.textSecondary,
                size: 24,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                width: isSelected ? 8 : 0,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                child: SizedBox(
                  width: isSelected ? null : 0,
                  child: isSelected 
                    ? Text(
                        label,
                        style: const TextStyle(
                          color: Apptheme.surface,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      )
                    : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
