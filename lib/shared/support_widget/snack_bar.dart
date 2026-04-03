import 'package:flutter/material.dart';

class CustomSnackbar {
  static void show(BuildContext context, String message, Color textColor, Color backgroundColor) {
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: textColor),),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}