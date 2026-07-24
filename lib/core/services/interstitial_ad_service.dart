import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quick_uninstaller/core/services/ad_analytics_service.dart';
import 'package:quick_uninstaller/core/static/constants.dart';
import 'package:quick_uninstaller/core/utility/logger_utility.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/interstitial_ad_config_entity.dart';

class InterstitialAdService {
  final AdAnalyticsService _adAnalyticsService;

  InterstitialAdService(this._adAnalyticsService);

  static const int _maxRetryAttempts = 3;

  InterstitialAdConfigEntity _config = const InterstitialAdConfigEntity(
    adUnitId: interstitialAdUnitId,
    isActive: true,
    isTestMode: false,
  );

  InterstitialAd? _interstitialAd;
  Timer? _retryTimer;
  bool _isAdLoading = false;
  bool _isAdShowing = false;
  bool _showWhenLoaded = false;
  int _retryAttempt = 0;
  int _loadGeneration = 0;

  String get _effectiveAdUnitId {
    if (kDebugMode || _config.isTestMode) return testInterstitialAdUnitId;
    return _config.adUnitId.trim();
  }

  bool get _isActive =>
      _config.isActive && _effectiveAdUnitId.trim().isNotEmpty;

  void updateConfig(InterstitialAdConfigEntity config) {
    final hasChanged =
        config.adUnitId != _config.adUnitId ||
        config.isActive != _config.isActive ||
        config.isTestMode != _config.isTestMode;
    if (!hasChanged) return;

    _config = config;
    _loadGeneration++;
    _retryTimer?.cancel();
    _retryAttempt = 0;
    _isAdLoading = false;
    _interstitialAd?.dispose();
    _interstitialAd = null;

    if (!_isActive) {
      _showWhenLoaded = false;
      logDebugStatic(
        'Interstitial ads disabled by Firebase config',
        'InterstitialAdService',
      );
      return;
    }

    preload();
  }

  void preload() {
    if (_isAdLoading || _isAdShowing || _interstitialAd != null || !_isActive) {
      return;
    }

    final requestAdUnitId = _effectiveAdUnitId;
    final requestGeneration = _loadGeneration;
    _isAdLoading = true;

    logDebugStatic(
      'Loading interstitial ad: id=$requestAdUnitId, '
          'attempt=${_retryAttempt + 1}',
      'InterstitialAdService',
    );

    InterstitialAd.load(
      adUnitId: requestAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (requestGeneration != _loadGeneration ||
              requestAdUnitId != _effectiveAdUnitId ||
              !_isActive) {
            ad.dispose();
            return;
          }

          _isAdLoading = false;
          _retryAttempt = 0;
          _interstitialAd = ad;
          logDebugStatic(
            'Interstitial ad loaded successfully',
            'InterstitialAdService',
          );

          if (_showWhenLoaded) {
            _showWhenLoaded = false;
            _showLoadedAd();
          }
        },
        onAdFailedToLoad: (error) {
          if (requestGeneration != _loadGeneration) return;

          _isAdLoading = false;
          logErrorStatic(
            'Interstitial ad failed to load: ${error.message}',
            'InterstitialAdService',
          );
          _scheduleRetry();
        },
      ),
    );
  }

  bool showAfterSuccessfulUninstall() {
    if (!_isActive || _isAdShowing) return false;

    if (_interstitialAd == null) {
      _showWhenLoaded = true;
      if (!_isAdLoading && _retryAttempt >= _maxRetryAttempts) {
        _retryAttempt = 0;
      }
      preload();
      return false;
    }

    return _showLoadedAd();
  }

  bool _showLoadedAd() {
    final ad = _interstitialAd;
    if (ad == null || !_isActive || _isAdShowing) return false;

    final shownAdUnitId = _effectiveAdUnitId;
    _interstitialAd = null;
    _isAdShowing = true;
    _showWhenLoaded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        logDebugStatic('Interstitial ad shown', 'InterstitialAdService');
        _adAnalyticsService.logInterstitialAdImpression(
          adUnitId: shownAdUnitId,
        );
      },
      onAdImpression: (_) {
        logDebugStatic(
          'Interstitial impression recorded',
          'InterstitialAdService',
        );
      },
      onAdClicked: (_) {
        _adAnalyticsService.logInterstitialAdClicked(adUnitId: shownAdUnitId);
      },
      onAdDismissedFullScreenContent: (dismissedAd) {
        _adAnalyticsService.logInterstitialAdDismissed(adUnitId: shownAdUnitId);
        dismissedAd.dispose();
        _isAdShowing = false;
        preload();
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        logErrorStatic(
          'Interstitial ad failed to show: ${error.message}',
          'InterstitialAdService',
        );
        failedAd.dispose();
        _isAdShowing = false;
        preload();
      },
    );

    try {
      ad.show();
      return true;
    } catch (error, stackTrace) {
      logErrorStatic(
        'Interstitial ad show threw an error: $error\n$stackTrace',
        'InterstitialAdService',
      );
      ad.dispose();
      _isAdShowing = false;
      preload();
      return false;
    }
  }

  void _scheduleRetry() {
    if (!_isActive || _retryAttempt >= _maxRetryAttempts) return;

    final delaySeconds = 1 << _retryAttempt;
    _retryAttempt++;
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: delaySeconds), preload);
  }

  void dispose() {
    _loadGeneration++;
    _retryTimer?.cancel();
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoading = false;
    _isAdShowing = false;
    _showWhenLoaded = false;
    _retryAttempt = 0;
  }
}
