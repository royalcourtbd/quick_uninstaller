import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:quick_uninstaller/core/utility/trial_utility.dart';

/// Retrieves the device information asynchronously.
///
/// Example usage:
///
/// ```dart
/// String deviceInfo = await getDeviceInfo();
/// print(deviceInfo);
/// ```
///
/// Rationale:
///
/// - The `getDeviceInfo` function provides a convenient way to retrieve device information
/// asynchronously.
/// - Utilizes the `catchAndReturnFuture` method to handle any errors that
/// might occur during the execution of the asynchronous code.
Future<String> getDeviceInfo() async {
  final String? deviceInfo = await catchAndReturnFuture(() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceModel = "";

    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceModel = androidInfo.model;
    }

    if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceModel = "${iosInfo.utsname.machine}-${iosInfo.model}";
    }

    return "OS: ${Platform.operatingSystem}\n"
        "OS Version: ${Platform.operatingSystemVersion}\n"
        "Device Model: $deviceModel\n";
  });

  return deviceInfo ?? "";
}
