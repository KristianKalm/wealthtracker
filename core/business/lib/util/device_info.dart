import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Gets a human-readable device name/description for token identification
/// Examples: "Pixel 9", "Brave Browser", "Chrome on Windows", etc.
Future<String> getDeviceName() async {
  final deviceInfo = DeviceInfoPlugin();

  try {
    if (kIsWeb) {
      // Web browser
      final webInfo = await deviceInfo.webBrowserInfo;
      final browser = webInfo.browserName.name;
      final platform = webInfo.platform ?? 'Web';

      // Return browser name with capitalization
      String browserName = browser[0].toUpperCase() + browser.substring(1);
      return '$browserName Browser on $platform';
    } else if (Platform.isAndroid) {
      // Android device
      final androidInfo = await deviceInfo.androidInfo;
      final manufacturer = androidInfo.manufacturer;
      final model = androidInfo.model;

      // Capitalize manufacturer name
      String manufacturerName = manufacturer[0].toUpperCase() + manufacturer.substring(1);

      // If model already contains manufacturer, just return model
      if (model.toLowerCase().contains(manufacturer.toLowerCase())) {
        return model;
      }

      return '$manufacturerName $model';
    } else if (Platform.isIOS) {
      // iOS device
      final iosInfo = await deviceInfo.iosInfo;
      final name = iosInfo.name; // e.g., "John's iPhone"
      final model = iosInfo.model; // e.g., "iPhone"

      // Use the user-assigned name if available, otherwise use model
      if (name.isNotEmpty && name != model) {
        return name;
      }
      return model;
    } else if (Platform.isLinux) {
      // Linux desktop
      final linuxInfo = await deviceInfo.linuxInfo;
      final prettyName = linuxInfo.prettyName; // e.g., "Ubuntu 22.04"
      return 'Linux Desktop ($prettyName)';
    } else if (Platform.isWindows) {
      // Windows desktop
      final windowsInfo = await deviceInfo.windowsInfo;
      final productName = windowsInfo.productName; // e.g., "Windows 11 Pro"
      return 'Windows Desktop ($productName)';
    } else if (Platform.isMacOS) {
      // macOS desktop
      final macInfo = await deviceInfo.macOsInfo;
      final model = macInfo.model; // e.g., "MacBookPro18,1"
      final computerName = macInfo.computerName; // e.g., "John's MacBook Pro"

      // Use computer name if available
      if (computerName.isNotEmpty) {
        return computerName;
      }
      return 'Mac ($model)';
    }

    // Fallback
    return 'Unknown Device';
  } catch (e) {
    // If we can't get device info, return a basic fallback
    if (kIsWeb) {
      return 'Web Browser';
    } else if (Platform.isAndroid) {
      return 'Android Device';
    } else if (Platform.isIOS) {
      return 'iOS Device';
    } else if (Platform.isLinux) {
      return 'Linux Desktop';
    } else if (Platform.isWindows) {
      return 'Windows Desktop';
    } else if (Platform.isMacOS) {
      return 'Mac Desktop';
    }
    return 'Unknown Device';
  }
}
