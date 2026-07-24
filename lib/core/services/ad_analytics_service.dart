import 'package:quick_uninstaller/core/services/backend_as_a_service.dart';

class AdAnalyticsService {
  final BackendAsAService _backendService;

  AdAnalyticsService(this._backendService);

  Future<void> logBannerAdClicked({required String adUnitId}) {
    return _backendService.logEvent(
      name: 'banner_ad_clicked',
      parameters: {'ad_unit_id': adUnitId},
    );
  }

  Future<void> logBannerAdImpression({required String adUnitId}) {
    return _backendService.logEvent(
      name: 'banner_ad_impression',
      parameters: {'ad_unit_id': adUnitId},
    );
  }

  Future<void> logInterstitialAdClicked({required String adUnitId}) {
    return _backendService.logEvent(
      name: 'interstitial_ad_clicked',
      parameters: {'ad_unit_id': adUnitId},
    );
  }

  Future<void> logInterstitialAdImpression({required String adUnitId}) {
    return _backendService.logEvent(
      name: 'interstitial_ad_impression',
      parameters: {'ad_unit_id': adUnitId},
    );
  }

  Future<void> logInterstitialAdDismissed({required String adUnitId}) {
    return _backendService.logEvent(
      name: 'interstitial_ad_dismissed',
      parameters: {'ad_unit_id': adUnitId},
    );
  }

  Future<void> logRewardedAdClicked({required String adUnitId}) {
    return _backendService.logEvent(
      name: 'rewarded_ad_clicked',
      parameters: {'ad_unit_id': adUnitId},
    );
  }

  Future<void> logRewardedAdImpression({required String adUnitId}) {
    return _backendService.logEvent(
      name: 'rewarded_ad_impression',
      parameters: {'ad_unit_id': adUnitId},
    );
  }

  Future<void> logRewardedAdCompleted({required String adUnitId}) {
    return _backendService.logEvent(
      name: 'rewarded_ad_completed',
      parameters: {'ad_unit_id': adUnitId},
    );
  }
}
