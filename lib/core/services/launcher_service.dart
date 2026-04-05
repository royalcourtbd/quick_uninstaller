import 'dart:io';

import 'package:quick_uninstaller/core/services/throttle_service.dart';
import 'package:quick_uninstaller/core/static/constants.dart';
import 'package:quick_uninstaller/core/utility/logger_utility.dart';
import 'package:quick_uninstaller/core/utility/navigation_helpers.dart';
import 'package:quick_uninstaller/core/utility/number_utility.dart';
import 'package:quick_uninstaller/core/utility/trial_utility.dart';
import 'package:url_launcher/url_launcher.dart';

const String _fileName = "launcher_service.dart";

/// Launches the Facebook page of the app or opens a fallback URL in a browser
/// if the Facebook app is not installed on the user's device.
///
/// First checks if the user's device is an iOS device or not and then
/// generates a protocol URL to launch the Facebook page.
/// If the URL can be launched, it is launched, else it opens the fallback URL.
///
/// This function makes use of openUrl() function to launch the URL, and the
/// fallback URL is set to the official Facebook page URL of the app.
///
/// If the URL can be launched, it opens the Facebook page in the Facebook app,
/// otherwise, it opens the fallback URL in a browser.
Future<void> launchFacebookPage() async {
  final String fbProtocolUrl = Platform.isIOS
      ? 'fb://profile/153267368647572'
      : 'fb://page/579001025294960';
  await openUrl(url: fbProtocolUrl, fallbackUrl: facebookPageUrl);
}

Future<void> launchFacebookGroup() async {
  const String fbProtocolUrl = 'fb://group/irdofficial';
  await openUrl(url: fbProtocolUrl, fallbackUrl: facebookGroupUrl);
}

Future<void> launchYoutube() async {
  const String channelId = 'UCnVaqAxLkEz9uCqkvJlPK8A';
  final String youtubeProtocolUrl = Platform.isIOS
      ? 'youtube://channel/$channelId'
      : 'https://www.youtube.com/channel/$channelId';
  const String fallbackUrl = 'https://www.youtube.com/channel/$channelId';
  await openUrl(url: youtubeProtocolUrl, fallbackUrl: fallbackUrl);
}

Future<void> launchTwitter() async {
  await launchUrl(Uri.parse(twitterUrl));
}

Future<void> launchLinkedInProfile() async {
  const String companyId = "oratiq";

  const String linkedInProtocolUrl = 'linkedin://company/$companyId';
  const String fallbackUrl = 'https://www.linkedin.com/company/$companyId/';

  await openUrl(url: linkedInProtocolUrl, fallbackUrl: fallbackUrl);
}

Future<void> launchMessenger() async {
  const String facebookId = "153267368647572";

  final String fbProtocolUrl = Platform.isAndroid
      ? 'fb-messenger://user/$facebookId'
      : 'https://m.me/$facebookId';

  await openUrl(url: fbProtocolUrl, fallbackUrl: facebookPageUrl);
}

/// Opens a URL asynchronously with optional fallback URL.
///
/// Example usage:
///
/// ```dart
/// await openUrl(url: 'https://facebook.com/irdfoundation');
/// ```
///
/// Rationale:
///
/// - provides a convenient way to open a URL asynchronously with an
/// optional fallback URL.
/// - utilizes the `Throttle` class to throttle multiple invocations
/// within a specified time interval, ensuring that the function is not called too frequently.
///
Future<void> openUrl({required String? url, String fallbackUrl = ""}) async {
  Throttle.throttle("openUrlThrottle", 1.inSeconds, () async {
    await catchFutureOrVoid(() async {
      if (url == null) return;
      if (url.trim().isEmpty) return;

      final Uri? uri = Uri.tryParse(url);
      final Uri? fallbackUri = Uri.tryParse(fallbackUrl);

      final bool validFallbackUri = fallbackUri != null;
      final bool validUri = uri != null;

      const String errorMessage = "Failed to open the URL";

      try {
        final bool canLaunch =
            validUri && (Platform.isAndroid || await canLaunchUrl(uri));

        if (canLaunch) {
          bool isLaunched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (isLaunched) return;

          isLaunched = await launchUrl(uri);
          if (isLaunched) return;
        }

        if (!validUri) {
          await showMessage(message: errorMessage);
          return;
        }

        validFallbackUri
            ? await launchUrl(fallbackUri, mode: LaunchMode.externalApplication)
            : await showMessage(message: errorMessage);
      } catch (e) {
        logErrorStatic(e, _fileName);
        validFallbackUri
            ? await launchUrl(fallbackUri)
            : await showMessage(message: errorMessage);
      }
    });
  });
}
