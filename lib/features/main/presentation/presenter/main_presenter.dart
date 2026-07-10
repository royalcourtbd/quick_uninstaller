import 'package:flutter/services.dart';
import 'package:quick_uninstaller/core/utility/navigation_helpers.dart';
import 'package:quick_uninstaller/core/services/time_service.dart';
import 'package:quick_uninstaller/features/main/presentation/presenter/main_ui_state.dart';
import 'package:quick_uninstaller/core/base/base_export.dart';
import 'package:quick_uninstaller/core/services/ad_analytics_service.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/banner_ad_config_entity.dart';
import 'package:quick_uninstaller/features/ads/domain/use_cases/get_banner_ad_config_use_case.dart';
import 'package:quick_uninstaller/core/utility/logger_utility.dart';

class MainPresenter extends BasePresenter<MainUiState> {
  final Obs<MainUiState> uiState = Obs<MainUiState>(MainUiState.empty());
  MainUiState get currentUiState => uiState.value;

  final TimeService _timeService;
  final GetBannerAdConfigUseCase _getBannerAdConfigUseCase;
  final AdAnalyticsService _adAnalyticsService;
  StreamSubscription<Either<String, BannerAdConfigEntity?>>? _adSubscription;

  MainPresenter(
    this._timeService,
    this._getBannerAdConfigUseCase,
    this._adAnalyticsService,
  );

  @override
  void onInit() {
    super.onInit();
    logDebugStatic('Subscribing to banner config', 'MainPresenter');
    _adSubscription = _getBannerAdConfigUseCase.execute().listen(
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
    logDebugStatic('Cancelling banner config subscription', 'MainPresenter');
    _adSubscription?.cancel();
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
