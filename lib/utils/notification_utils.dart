import 'package:flutter/material.dart';

/// Utility class for displaying notifications throughout the app
class NotificationUtils {
  /// Display a custom snackbar with the specified message and type
  static void showSnackbar(
    BuildContext context, {
    required String message,
    required SnackbarType type,
    Duration? duration,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Dismiss any existing snackbars to prevent stacking
    scaffoldMessenger.hideCurrentSnackBar();
    
    // Show the new snackbar
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_getIconForType(type), color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: _getColorForType(type),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        duration: duration ?? const Duration(seconds: 3),
      ),
    );
  }
  
  /// Display a success snackbar
  static void showSuccess(
    BuildContext context, 
    String message, {
    Duration? duration,
  }) {
    showSnackbar(
      context, 
      message: message, 
      type: SnackbarType.success,
      duration: duration,
    );
  }
  
  /// Display an error snackbar
  static void showError(
    BuildContext context, 
    String message, {
    Duration? duration,
  }) {
    showSnackbar(
      context, 
      message: message, 
      type: SnackbarType.error,
      duration: duration,
    );
  }
  
  /// Display an info snackbar
  static void showInfo(
    BuildContext context, 
    String message, {
    Duration? duration,
  }) {
    showSnackbar(
      context, 
      message: message, 
      type: SnackbarType.info,
      duration: duration,
    );
  }
  
  /// Display a warning snackbar
  static void showWarning(
    BuildContext context, 
    String message, {
    Duration? duration,
  }) {
    showSnackbar(
      context, 
      message: message, 
      type: SnackbarType.warning,
      duration: duration,
    );
  }
  
  // Private helper methods
  
  /// Get the appropriate icon based on the snackbar type
  static IconData _getIconForType(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle;
      case SnackbarType.error:
        return Icons.error;
      case SnackbarType.info:
        return Icons.info;
      case SnackbarType.warning:
        return Icons.warning;
    }
  }
  
  /// Get the appropriate color based on the snackbar type
  static Color _getColorForType(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Colors.green;
      case SnackbarType.error:
        return Colors.red.shade700;
      case SnackbarType.info:
        return Colors.blue;
      case SnackbarType.warning:
        return Colors.orange;
    }
  }
}

/// Enum representing different types of snackbars
enum SnackbarType {
  success,
  error,
  info,
  warning,
} 