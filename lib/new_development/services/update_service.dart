import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  static const String _iosBundleId = 'com.yourcompany.yourapp';

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      if (!context.mounted) return;
      _showForceUpdateDialog(context);
    } catch (e) {
      debugPrint('Update check error: $e');
    }
  }


  static Future<void> _checkAndroidUpdate(BuildContext context) async {
    final updateInfo = await InAppUpdate.checkForUpdate();

    if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
      if (updateInfo.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
      } else if (updateInfo.flexibleUpdateAllowed) {
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
      }
    }
  }

  static Future<void> _checkIOSUpdate(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    final response = await http.get(
      Uri.parse('https://itunes.apple.com/lookup?bundleId=$_iosBundleId'),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) return;

    final data = json.decode(response.body);
    if (data['resultCount'] == 0) return;

    final latestVersion = data['results'][0]['version'] as String;
    final storeUrl = data['results'][0]['trackViewUrl'] as String;

    if (_isUpdateRequired(currentVersion, latestVersion)) {
      if (!context.mounted) return;
      _showForceUpdateDialog(context, );
    }
  }

  static bool _isUpdateRequired(String current, String latest) {
    return true;
  }

  static void _showForceUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Update Required'),
          content: const Text(
            'App ka naya version available hai.\n'
                'Aage jaane ke liye please update karein.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => launchUrl(
                Uri.parse('https://play.google.com/store'),
                mode: LaunchMode.externalApplication,
              ),
              child: const Text('Update Now'),
            ),
          ],
        ),
      ),
    );
  }
}