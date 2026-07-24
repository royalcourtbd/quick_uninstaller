import 'package:quick_uninstaller/core/base/base_ui_state.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/banner_ad_config_entity.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/native_ad_config_entity.dart';
import 'package:quick_uninstaller/features/app_update/domain/entities/app_update_config_entity.dart';
import 'package:quick_uninstaller/features/app_update/domain/entities/update_type.dart';

class MainUiState extends BaseUiState {
  const MainUiState({
    required super.isLoading,
    required super.userMessage,
    required this.selectedBottomNavIndex,
    this.lastBackPressTime,
    this.bannerAdConfig,
    this.nativeAdConfig,
    this.appUpdateConfig,
    required this.updateType,
    required this.hasShownUpdateNotice,
  });

  factory MainUiState.empty() {
    return MainUiState(
      isLoading: false,
      userMessage: '',
      selectedBottomNavIndex: 0,
      lastBackPressTime: null,
      updateType: UpdateType.none,
      hasShownUpdateNotice: false,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    userMessage,
    selectedBottomNavIndex,
    lastBackPressTime,
    bannerAdConfig,
    nativeAdConfig,
    appUpdateConfig,
    updateType,
    hasShownUpdateNotice,
  ];

  //Add more properties to the state
  final int selectedBottomNavIndex;
  final DateTime? lastBackPressTime;
  final BannerAdConfigEntity? bannerAdConfig;
  final NativeAdConfigEntity? nativeAdConfig;
  final AppUpdateConfigEntity? appUpdateConfig;
  final UpdateType updateType;
  final bool hasShownUpdateNotice;

  MainUiState copyWith({
    bool? isLoading,
    String? userMessage,
    int? selectedBottomNavIndex,
    DateTime? lastBackPressTime,
    BannerAdConfigEntity? bannerAdConfig,
    NativeAdConfigEntity? nativeAdConfig,
    AppUpdateConfigEntity? appUpdateConfig,
    UpdateType? updateType,
    bool? hasShownUpdateNotice,
  }) {
    return MainUiState(
      isLoading: isLoading ?? this.isLoading,
      userMessage: userMessage ?? this.userMessage,
      selectedBottomNavIndex:
          selectedBottomNavIndex ?? this.selectedBottomNavIndex,
      lastBackPressTime: lastBackPressTime ?? this.lastBackPressTime,
      bannerAdConfig: bannerAdConfig ?? this.bannerAdConfig,
      nativeAdConfig: nativeAdConfig ?? this.nativeAdConfig,
      appUpdateConfig: appUpdateConfig ?? this.appUpdateConfig,
      updateType: updateType ?? this.updateType,
      hasShownUpdateNotice: hasShownUpdateNotice ?? this.hasShownUpdateNotice,
    );
  }
}
