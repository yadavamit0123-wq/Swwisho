import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:demandium/utils/app_constants.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

class MetaSdkHelper {
  static final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();

  static Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    if (AppConstants.facebookClientToken == 'REPLACE_WITH_META_CLIENT_TOKEN') {
      debugPrint('Meta SDK: set AppConstants.facebookClientToken before release build.');
    }

    await _facebookAppEvents.setAutoLogAppEventsEnabled(true);
    await _configureAdvertiserTracking();
  }

  static Future<void> _configureAdvertiserTracking() async {
    if (Platform.isIOS) {
      try {
        var status = await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          await Future.delayed(const Duration(milliseconds: 500));
          status = await AppTrackingTransparency.requestTrackingAuthorization();
        }
        await _facebookAppEvents.setAdvertiserTracking(
          enabled: status == TrackingStatus.authorized,
        );
      } catch (e) {
        debugPrint('Meta SDK ATT setup failed: $e');
        await _facebookAppEvents.setAdvertiserTracking(enabled: false);
      }
      return;
    }

    await _facebookAppEvents.setAdvertiserTracking(enabled: true);
  }
}
