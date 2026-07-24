import 'package:flutter/services.dart';
import 'package:quick_uninstaller/core/utility/navigation_helpers.dart';
import 'package:quick_uninstaller/core/services/time_service.dart';
import 'package:quick_uninstaller/features/main/presentation/presenter/main_ui_state.dart';
import 'package:quick_uninstaller/core/base/base_export.dart';
import 'package:quick_uninstaller/core/services/ad_analytics_service.dart';
import 'package:quick_uninstaller/core/services/app_info_service.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/banner_ad_config_entity.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/native_ad_config_entity.dart';
import 'package:quick_uninstaller/features/ads/domain/use_cases/get_banner_ad_config_use_case.dart';
import 'package:quick_uninstaller/features/ads/domain/use_cases/get_native_ad_config_use_case.dart';
import 'package:quick_uninstaller/features/app_update/domain/entities/app_update_config_entity.dart';
import 'package:quick_uninstaller/features/app_update/domain/entities/update_type.dart';
import 'package:quick_uninstaller/features/app_update/domain/use_cases/get_app_update_config_use_case.dart';
import 'package:quick_uninstaller/core/utility/logger_utility.dart';
import 'package:quick_uninstaller/core/utility/version_comparator.dart';

class MainPresenter extends BasePresenter<MainUiState> {
  final Obs<MainUiState> uiState = Obs<MainUiState>(MainUiState.empty());
  MainUiState get currentUiState => uiState.value;

  final TimeService _timeService;
  final GetBannerAdConfigUseCase _getBannerAdConfigUseCase;
  final GetNativeAdConfigUseCase _getNativeAdConfigUseCase;
  final AdAnalyticsService _adAnalyticsService;
  final GetAppUpdateConfigUseCase _getAppUpdateConfigUseCase;
  StreamSubscription<Either<String, BannerAdConfigEntity?>>?
  _bannerAdSubscription;
  StreamSubscription<Either<String, NativeAdConfigEntity?>>?
  _nativeAdSubscription;
  StreamSubscription<Either<String, AppUpdateConfigEntity?>>?
  _appUpdateSubscription;
  int _updateEvaluationGeneration = 0;

  MainPresenter(
    this._timeService,
    this._getBannerAdConfigUseCase,
    this._getNativeAdConfigUseCase,
    this._adAnalyticsService,
    this._getAppUpdateConfigUseCase,
  );

  @override
  void onInit() {
    super.onInit();
    _subscribeToAppUpdateConfig();
    logDebugStatic('Subscribing to banner config', 'MainPresenter');
    _bannerAdSubscription = _getBannerAdConfigUseCase.execute().listen(
      (result) => result.fold(
        (message) {
          logErrorStatic('Banner config error: $message', 'MainPresenter');
          addUserMessage(message);
        },
        (config) {
          logDebugStatic(
            'Banner config delivered to presenter: $config',
            'MainPresenter',
          );
          if (config != null) {
            uiState.value = currentUiState.copyWith(bannerAdConfig: config);
          }
        },
      ),
      onError: (Object error, StackTrace stackTrace) {
        logErrorStatic(
          'Banner subscription failed: $error\n$stackTrace',
          'MainPresenter',
        );
        addUserMessage(error.toString());
      },
    );
    _subscribeToNativeAdConfig();
  }

  void _subscribeToNativeAdConfig() {
    _nativeAdSubscription = _getNativeAdConfigUseCase.execute().listen(
      (result) => result.fold(
        (message) {
          logErrorStatic('Native ad config error: $message', 'MainPresenter');
        },
        (config) {
          if (config == null) return;
          uiState.value = currentUiState.copyWith(nativeAdConfig: config);
        },
      ),
      onError: (Object error, StackTrace stackTrace) {
        logErrorStatic(
          'Native ad subscription failed: $error\n$stackTrace',
          'MainPresenter',
        );
      },
    );
  }

  void _subscribeToAppUpdateConfig() {
    _appUpdateSubscription = _getAppUpdateConfigUseCase.execute().listen(
      (result) => result.fold(
        (message) {
          logErrorStatic('App update config error: $message', 'MainPresenter');
        },
        (config) {
          if (config == null) return;
          unawaited(_evaluateAppUpdate(config));
        },
      ),
      onError: (Object error, StackTrace stackTrace) {
        logErrorStatic(
          'App update subscription failed: $error\n$stackTrace',
          'MainPresenter',
        );
      },
    );
  }

  Future<void> _evaluateAppUpdate(AppUpdateConfigEntity config) async {
    final generation = ++_updateEvaluationGeneration;
    final currentVersion = await currentAppVersion;
    if (generation != _updateEvaluationGeneration) return;

    final minimumComparison = VersionComparator.compare(
      currentVersion,
      config.minSupportedVersion,
    );
    final latestComparison = VersionComparator.compare(
      currentVersion,
      config.latestVersion,
    );
    final thresholdComparison = VersionComparator.compare(
      config.minSupportedVersion,
      config.latestVersion,
    );
    final hasValidThresholds =
        minimumComparison != null &&
        latestComparison != null &&
        thresholdComparison != null &&
        thresholdComparison <= 0;

    final updateType = !hasValidThresholds
        ? UpdateType.none
        : minimumComparison < 0
        ? UpdateType.force
        : latestComparison < 0
        ? UpdateType.optional
        : UpdateType.none;

    if (!hasValidThresholds) {
      logErrorStatic(
        'Ignoring invalid app update versions: '
            'current=$currentVersion, '
            'minimum=${config.minSupportedVersion}, '
            'latest=${config.latestVersion}',
        'MainPresenter',
      );
    }
    logDebugStatic(
      'App update evaluated: current=$currentVersion, '
          'minimum=${config.minSupportedVersion}, '
          'latest=${config.latestVersion}, type=$updateType',
      'MainPresenter',
    );
    final shouldResetNotice =
        currentUiState.appUpdateConfig?.latestVersion != config.latestVersion ||
        (!currentUiState.updateType.isMandatory && updateType.isMandatory);
    uiState.value = currentUiState.copyWith(
      appUpdateConfig: config,
      updateType: updateType,
      hasShownUpdateNotice: shouldResetNotice
          ? false
          : currentUiState.hasShownUpdateNotice,
    );
  }

  bool get shouldShowUpdateNotice =>
      currentUiState.updateType.shouldShowNotice &&
      currentUiState.appUpdateConfig != null &&
      !currentUiState.hasShownUpdateNotice;

  bool get isForceUpdate => currentUiState.updateType.isMandatory;

  void markUpdateNoticeShown() {
    uiState.value = currentUiState.copyWith(hasShownUpdateNotice: true);
  }

  void onBannerAdClicked() {
    final config = currentUiState.bannerAdConfig;
    if (config == null) return;
    logDebugStatic('Banner clicked: ${config.adUnitId}', 'MainPresenter');
    _adAnalyticsService.logBannerAdClicked(adUnitId: config.adUnitId);
  }

  void onBannerAdImpression() {
    final config = currentUiState.bannerAdConfig;
    if (config == null) return;
    logDebugStatic('Banner impression: ${config.adUnitId}', 'MainPresenter');
    _adAnalyticsService.logBannerAdImpression(adUnitId: config.adUnitId);
  }

  void onNativeAdClicked() {
    final config = currentUiState.nativeAdConfig;
    if (config == null) return;
    _adAnalyticsService.logNativeAdClicked(adUnitId: config.adUnitId);
  }

  void onNativeAdImpression() {
    final config = currentUiState.nativeAdConfig;
    if (config == null) return;
    _adAnalyticsService.logNativeAdImpression(adUnitId: config.adUnitId);
  }

  void changeNavigationIndex(int index) {
    uiState.value = currentUiState.copyWith(selectedBottomNavIndex: index);
  }

  Future<void> handleBackPress() async {
    if (currentUiState.selectedBottomNavIndex != 0) {
      changeNavigationIndex(0);
      return;
    }

    final DateTime now = _timeService.currentTime;
    final DateTime? lastPressed = currentUiState.lastBackPressTime;

    if (lastPressed == null ||
        now.difference(lastPressed) > const Duration(seconds: 2)) {
      updateLastBackPressTime(now);
      addUserMessage('Press back again to exit');
      return;
    }

    await SystemNavigator.pop();
  }

  void updateLastBackPressTime(DateTime time) {
    uiState.value = currentUiState.copyWith(lastBackPressTime: time);
  }

  @override
  void onClose() {
    _updateEvaluationGeneration++;
    logDebugStatic('Cancelling banner config subscription', 'MainPresenter');
    _bannerAdSubscription?.cancel();
    _nativeAdSubscription?.cancel();
    _appUpdateSubscription?.cancel();
    super.onClose();
  }

  ///=======================================

  @override
  Future<void> addUserMessage(String message) async {
    uiState.value = currentUiState.copyWith(userMessage: message);
    showMessage(message: currentUiState.userMessage);
  }

  @override
  Future<void> toggleLoading({required bool loading}) async {
    uiState.value = currentUiState.copyWith(isLoading: loading);
  }
}
