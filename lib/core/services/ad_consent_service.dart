import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quick_uninstaller/core/utility/logger_utility.dart';
import 'package:quick_uninstaller/core/utility/trial_utility.dart';

class AdConsentService {
  static final ConsentInformation _consentInformation =
      ConsentInformation.instance;

  static Future<void> requestConsent() async {
    await catchFutureOrVoid(() async {
      final completer = Completer<void>();

      _consentInformation.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          await _loadAndShowFormIfRequired();
          completer.complete();
        },
        (error) {
          logErrorStatic(
            'Consent info update failed: ${error.message}',
            'AdConsentService',
          );
          completer.complete();
        },
      );

      await completer.future;
    });
  }

  static Future<void> _loadAndShowFormIfRequired() {
    final completer = Completer<void>();
    ConsentForm.loadAndShowConsentFormIfRequired((error) {
      if (error != null) {
        logErrorStatic(
          'Consent form error: ${error.message}',
          'AdConsentService',
        );
      }
      completer.complete();
    });
    return completer.future;
  }

  static Future<bool> canRequestAds() {
    return _consentInformation.canRequestAds();
  }
}
