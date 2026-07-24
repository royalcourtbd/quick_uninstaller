import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quick_uninstaller/core/base/base_presenter.dart';
import 'package:quick_uninstaller/core/services/ad_analytics_service.dart';
import 'package:quick_uninstaller/core/services/device_info_service.dart';
import 'package:quick_uninstaller/core/services/local_cache_service.dart';
import 'package:quick_uninstaller/core/static/constants.dart';
import 'package:quick_uninstaller/core/utility/logger_utility.dart';
import 'package:quick_uninstaller/core/utility/navigation_helpers.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/rewarded_ad_config_entity.dart';
import 'package:quick_uninstaller/features/ads/domain/use_cases/get_rewarded_ad_config_use_case.dart';
import 'package:quick_uninstaller/features/support/presentation/presenter/support_ui_state.dart';

class SupportPresenter extends BasePresenter<SupportUiState> {
  SupportPresenter(
    this._getRewardedAdConfigUseCase,
    this._adAnalyticsService,
    this._localCacheService,
    this._deviceInfoService,
  );

  final GetRewardedAdConfigUseCase _getRewardedAdConfigUseCase;
  final AdAnalyticsService _adAnalyticsService;
  final LocalCacheService _localCacheService;
  final DeviceInfoService _deviceInfoService;

  static const int _maxRetryAttempts = 3;

  final Obs<SupportUiState> uiState = Obs<SupportUiState>(
    SupportUiState.empty(),
  );
  SupportUiState get currentUiState => uiState.value;

  RewardedAdConfigEntity _config = const RewardedAdConfigEntity(
    adUnitId: rewardedAdUnitId,
    isActive: true,
    isTestMode: false,
  );
  StreamSubscription<Either<String, RewardedAdConfigEntity?>>?
  _configSubscription;
  RewardedAd? _rewardedAd;
  Timer? _retryTimer;
  bool _isAdLoading = false;
  bool _showRewardedAdOnLoad = false;
  bool _rewardEarned = false;
  bool _isDisposed = false;
  int _retryAttempt = 0;
  int _loadGeneration = 0;

  String get _effectiveAdUnitId {
    if (kDebugMode || _config.isTestMode) return testRewardedAdUnitId;
    return _config.adUnitId.trim();
  }

  bool get _isAdAvailable => _config.isActive && _effectiveAdUnitId.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _loadAdWatchCount();
    _preloadRewardedAd();
    _subscribeToConfig();
  }

  void _loadAdWatchCount() {
    final count =
        _localCacheService.getData<int>(key: CacheKeys.supportAdWatchCount) ??
        0;
    uiState.value = currentUiState.copyWith(adWatchCount: count);
    unawaited(_refreshRegisteredWatchVideoCount());
  }

  Future<void> _incrementAdWatchCount() async {
    final newCount = currentUiState.adWatchCount + 1;
    await _localCacheService.saveData<int>(
      key: CacheKeys.supportAdWatchCount,
      value: newCount,
    );
    if (_isDisposed) return;
    uiState.value = currentUiState.copyWith(adWatchCount: newCount);
    final syncedCount = await _deviceInfoService.recordRewardedAdCompleted(
      localWatchVideoCount: newCount,
    );
    if (_isDisposed || syncedCount <= currentUiState.adWatchCount) return;

    await _localCacheService.saveData<int>(
      key: CacheKeys.supportAdWatchCount,
      value: syncedCount,
    );
    if (_isDisposed) return;
    uiState.value = currentUiState.copyWith(adWatchCount: syncedCount);
  }

  Future<void> _refreshRegisteredWatchVideoCount() async {
    final syncedCount = await _deviceInfoService.getRegisteredWatchVideoCount();
    if (_isDisposed || syncedCount <= currentUiState.adWatchCount) return;

    await _localCacheService.saveData<int>(
      key: CacheKeys.supportAdWatchCount,
      value: syncedCount,
    );
    if (_isDisposed) return;
    uiState.value = currentUiState.copyWith(adWatchCount: syncedCount);
  }

  void _subscribeToConfig() {
    _configSubscription = _getRewardedAdConfigUseCase.execute().listen(
      (result) => result.fold(
        (message) {
          logErrorStatic(
            'Rewarded ad config error: $message',
            'SupportPresenter',
          );
        },
        (config) {
          if (config != null) _updateConfig(config);
        },
      ),
      onError: (Object error, StackTrace stackTrace) {
        logErrorStatic(
          'Rewarded ad config subscription failed: $error\n$stackTrace',
          'SupportPresenter',
        );
      },
    );
  }

  void _updateConfig(RewardedAdConfigEntity config) {
    final hasChanged =
        config.adUnitId != _config.adUnitId ||
        config.isActive != _config.isActive ||
        config.isTestMode != _config.isTestMode;
    if (!hasChanged || _isDisposed) return;

    _config = config;
    _loadGeneration++;
    _retryTimer?.cancel();
    _retryAttempt = 0;
    _isAdLoading = false;
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _showRewardedAdOnLoad = false;

    uiState.value = currentUiState.copyWith(
      isAdAvailable: _isAdAvailable,
      isRewardedAdLoaded: false,
      isRewardedAdLoading: false,
    );

    if (_isAdAvailable) _preloadRewardedAd();
  }

  void _preloadRewardedAd() {
    if (_isDisposed || !_isAdAvailable || _isAdLoading || _rewardedAd != null) {
      return;
    }

    final requestAdUnitId = _effectiveAdUnitId;
    final requestGeneration = _loadGeneration;
    _isAdLoading = true;

    RewardedAd.load(
      adUnitId: requestAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (_isDisposed ||
              requestGeneration != _loadGeneration ||
              requestAdUnitId != _effectiveAdUnitId ||
              !_isAdAvailable) {
            ad.dispose();
            return;
          }

          _isAdLoading = false;
          _retryAttempt = 0;
          _rewardedAd = ad;
          uiState.value = currentUiState.copyWith(
            isRewardedAdLoaded: true,
            isRewardedAdLoading: false,
          );

          if (_showRewardedAdOnLoad) {
            _showRewardedAdOnLoad = false;
            _showRewardedAd();
          }
        },
        onAdFailedToLoad: (error) {
          if (_isDisposed || requestGeneration != _loadGeneration) return;

          _isAdLoading = false;
          final shouldNotifyUser = _showRewardedAdOnLoad;
          _showRewardedAdOnLoad = false;
          uiState.value = currentUiState.copyWith(
            isRewardedAdLoaded: false,
            isRewardedAdLoading: false,
          );
          logErrorStatic(
            'Rewarded ad failed to load: ${error.message}',
            'SupportPresenter',
          );

          if (shouldNotifyUser) {
            addUserMessage(
              'The video is not available right now. Please try again later.',
            );
          } else {
            _scheduleRetry();
          }
        },
      ),
    );
  }

  void onWatchVideoAdClicked() {
    if (!_isAdAvailable) {
      addUserMessage('Video support is not available right now.');
      return;
    }

    _adAnalyticsService.logRewardedAdClicked(adUnitId: _effectiveAdUnitId);

    if (_rewardedAd != null) {
      _showRewardedAd();
      return;
    }

    _showRewardedAdOnLoad = true;
    uiState.value = currentUiState.copyWith(isRewardedAdLoading: true);
    addUserMessage('Preparing the video…');

    if (!_isAdLoading && _retryAttempt >= _maxRetryAttempts) {
      _retryAttempt = 0;
    }
    _preloadRewardedAd();
  }

  void _showRewardedAd() {
    final ad = _rewardedAd;
    if (ad == null || _isDisposed || !_isAdAvailable) return;

    final shownAdUnitId = _effectiveAdUnitId;
    _rewardedAd = null;
    _rewardEarned = false;
    uiState.value = currentUiState.copyWith(
      isRewardedAdLoaded: false,
      isRewardedAdLoading: false,
    );

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdImpression: (_) {
        _adAnalyticsService.logRewardedAdImpression(adUnitId: shownAdUnitId);
      },
      onAdDismissedFullScreenContent: (dismissedAd) {
        dismissedAd.dispose();
        if (_isDisposed) return;

        if (_rewardEarned) {
          _rewardEarned = false;
          addUserMessage('Thank you for supporting Quick Uninstaller!');
        }
        _preloadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        failedAd.dispose();
        if (_isDisposed) return;

        logErrorStatic(
          'Rewarded ad failed to show: ${error.message}',
          'SupportPresenter',
        );
        addUserMessage('The video could not be shown. Please try again later.');
        _preloadRewardedAd();
      },
    );

    try {
      ad.show(
        onUserEarnedReward: (_, _) {
          _adAnalyticsService.logRewardedAdCompleted(adUnitId: shownAdUnitId);
          _rewardEarned = true;
          unawaited(_incrementAdWatchCount());
        },
      );
    } catch (error, stackTrace) {
      logErrorStatic(
        'Rewarded ad show threw an error: $error\n$stackTrace',
        'SupportPresenter',
      );
      ad.dispose();
      addUserMessage('The video could not be shown. Please try again later.');
      _preloadRewardedAd();
    }
  }

  void _scheduleRetry() {
    if (_isDisposed || !_isAdAvailable || _retryAttempt >= _maxRetryAttempts) {
      return;
    }

    final delaySeconds = 1 << _retryAttempt;
    _retryAttempt++;
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: delaySeconds), _preloadRewardedAd);
  }

  @override
  void onClose() {
    _isDisposed = true;
    _loadGeneration++;
    _configSubscription?.cancel();
    _retryTimer?.cancel();
    _rewardedAd?.dispose();
    _rewardedAd = null;
    super.onClose();
  }

  @override
  Future<void> addUserMessage(String message) async {
    if (_isDisposed) return;
    uiState.value = currentUiState.copyWith(userMessage: message);
    showMessage(message: currentUiState.userMessage);
  }

  @override
  Future<void> toggleLoading({required bool loading}) async {
    if (_isDisposed) return;
    uiState.value = currentUiState.copyWith(isLoading: loading);
  }
}
