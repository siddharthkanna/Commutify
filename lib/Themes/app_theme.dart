import 'package:flutter/material.dart';

class Apptheme {
  // Primary colors
  static const Color primary = Color(0xff323846);    // Rich charcoal with blue undertone
  static const Color secondary = Color(0xff7F5A83);  // Muted purple accent
  
  // Neutral colors
  static const Color background = Color(0xffF8F9FA); // Off-white background
  static const Color surface = Color(0xffFFFFFF);    // Pure white surface
  static const Color text = Color(0xff212529);       // Dark text for readability
  static const Color textSecondary = Color(0xff6C757D); // Secondary text
  
  // Supporting colors
  static const Color success = Color(0xff38B000);    // Green for success states
  static const Color error = Color(0xffDC3545);      // Red for errors
  static const Color warning = Color(0xffFFC107);    // Yellow for warnings
  
  // Legacy colors (keeping for backward compatibility)
  static const Color mist = Color(0xffadb8bb);
  static const Color noir = Color(0xff232a2f);
  static const Color navy = Color(0xff153147);
  static const Color almond = Color(0xffedeae4);
  static const Color ivory = Color(0xfff8f9fa); // Updated to match background
  static const Color backgroundblue = Color(0xffCFEBF9);
  static const Color backgroundorange = Color(0xffe8bb63);
}
