import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/utils/app_text.dart';

class LocationPermissionHandler {
  /// Check if location permission is granted
  static Future<bool> checkAndRequest(BuildContext context) async {
    final lang = context.read<LanguageProvider>().isEnglish;

    PermissionStatus status = await Permission.location.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      PermissionStatus newStatus = await Permission.location.request();
      if (newStatus.isGranted) return true;
      if (newStatus.isPermanentlyDenied) {
        _showPermissionDialog(context, lang);
        return false;
      }
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDialog(context, lang);
      return false;
    }

    return false;
  }

  /// Show dialog to open app settings
  static void _showPermissionDialog(BuildContext context, bool lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppText.locationPermissionTitle(lang)),
        content: Text(AppText.locationPermissionMessage(lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppText.cancel(lang)),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: Text(AppText.openSettings(lang)),
          ),
        ],
      ),
    );
  }
}