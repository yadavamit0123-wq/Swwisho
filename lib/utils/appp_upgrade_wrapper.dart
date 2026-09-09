import 'dart:io';
import 'package:demandium/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpgradeWrapper extends StatelessWidget {
  final Widget child;
  const AppUpgradeWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
/*    return UpgradeAlert(
      upgrader: Upgrader(
        debugDisplayAlways: false,
        debugDisplayOnce: false,
        debugLogging: true,
        durationUntilAlertAgain: const Duration(days: 0),
        minAppVersion: '2.5.0',
        // minAppVersion: AppConstants.appVersion,
        willDisplayUpgrade: (
            {required bool display,
            String? installedVersion,
            UpgraderVersionInfo? versionInfo}) {
          debugPrint('Will display: $display');
          debugPrint('Installed: $installedVersion');
          debugPrint('Available: ${versionInfo?.appStoreVersion}');
        },
      ),
      key: const ValueKey('upgrader_key'),
      barrierDismissible: true,
      navigatorKey: Get.key,
      dialogStyle: UpgradeDialogStyle.material,
      showIgnore: false,
      showLater: false,
      onUpdate: () {
        _openStore();
        return false;
      },
      child: child,
    );*/
  }

  Future<void> _openStore() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    final String packageName = info.packageName;

    final Uri storeUrl = Platform.isAndroid
        ? Uri.parse('market://details?id=$packageName')
        : Uri.parse('https://apps.apple.com/app/id$packageName');

    if (await canLaunchUrl(storeUrl)) {
      await launchUrl(storeUrl, mode: LaunchMode.externalApplication);
    } else {
      final Uri webUrl = Uri.parse(
        'https://play.google.com/store/apps/details?id=$packageName',
      );
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }
}
