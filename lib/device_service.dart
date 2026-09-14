import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceService {
  static Future<String> getDeviceId() async {
    return _getRealDeviceId();
  }

  static Future<String> getSelectedUserId() async {
    return getDeviceId();
  }

  static Future<String> _getRealDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      return 'web_user';
    }

    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo =
      await deviceInfo.androidInfo;

      return androidInfo.id;
    }

    if (Platform.isIOS) {
      final IosDeviceInfo iosInfo =
      await deviceInfo.iosInfo;

      return iosInfo.identifierForVendor ?? 'unknown_ios';
    }

    return 'unknown_device';
  }
}