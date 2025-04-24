import 'package:flutter/material.dart';
import 'package:commutify/utils/notification_utils.dart';
import 'package:commutify/utils/dialog_utils.dart';

class ErrorDialog {
  static void showErrorDialog(BuildContext context, String message) {
    DialogUtils.showInfoDialog(
      context: context,
      title: 'Error',
      message: message,
    );
  }
}

class Snackbar {
  static void showSnackbar(BuildContext context, String message, {bool isError = false}) {
    if (isError) {
      NotificationUtils.showError(context, message);
    } else {
      NotificationUtils.showSuccess(context, message);
    }
  }
  
  static void showSuccessSnackbar(BuildContext context, String message) {
    NotificationUtils.showSuccess(context, message);
  }
  
  static void showErrorSnackbar(BuildContext context, String message) {
    NotificationUtils.showError(context, message);
  }
  
  static void showInfoSnackbar(BuildContext context, String message) {
    NotificationUtils.showInfo(context, message);
  }
  
  static void showWarningSnackbar(BuildContext context, String message) {
    NotificationUtils.showWarning(context, message);
  }
}
