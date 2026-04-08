import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/utils/app_text.dart';

class CameraPermissionHandler {
  /// Check and request camera permission
  static Future<bool> checkAndRequest(BuildContext context) async {
    final lang = context.read<LanguageProvider>().isEnglish;

    PermissionStatus status = await Permission.camera.status;

    if (status.isGranted) return true;

    final newStatus = await Permission.camera.request();

    if (newStatus.isGranted) return true;

    if (!context.mounted) return false;

    // Show dialog if denied (permanent or not)
    _showPermissionDialog(context, lang);
    return false;
  }

  /// Show dialog to open app settings
  static void _showPermissionDialog(BuildContext context, bool lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppText.cameraPermissionTitle(lang)),
        content: Text(AppText.cameraPermissionMessage(lang)),
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