import 'package:flutter/material.dart';

class SnackbarUtils {
  // Show a simple info message
  static void showInfo(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.blueAccent);
  }

  // Show a success message
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.green);
  }

  // Show an error message
  static void showError(BuildContext context, String message) {
    _showSnackBar(context, message, Colors.redAccent);
  }

  // Private helper to display the snackbar
  static void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontFamily: 'OpenSans Regular',
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
