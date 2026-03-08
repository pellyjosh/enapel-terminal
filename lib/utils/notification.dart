import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationService {
  /// Show an error notification
  static void showError({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      duration: duration,
    );
  }

  /// Show a success notification
  static void showSuccess({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      duration: duration,
    );
  }

  /// Show a warning notification
  static void showWarning({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.orange,
      textColor: Colors.black,
      duration: duration,
    );
  }

  /// General method to display a notification at the **top-right corner**
  static void _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    required Color textColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlayContext = Get.overlayContext;
    if (overlayContext == null) return;

    final screenWidth = MediaQuery.of(overlayContext).size.width;

    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: backgroundColor,
        duration: duration,
        borderRadius: 8,
        margin: EdgeInsets.only(top: 10, right: 10, left: screenWidth * 0.8),
        snackStyle: SnackStyle.FLOATING,
        maxWidth: 300,
        isDismissible: true,
        forwardAnimationCurve: Curves.easeOutBack,
        mainButton: TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("Dismiss", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
