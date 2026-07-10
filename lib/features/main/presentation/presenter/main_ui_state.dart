import 'package:quick_uninstaller/core/base/base_ui_state.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/banner_ad_config_entity.dart';

class MainUiState extends BaseUiState {
  const MainUiState({
    required super.isLoading,
    required super.userMessage,
    required this.selectedBottomNavIndex,
    this.lastBackPressTime,
    this.bannerAdConfig,
  });

  factory MainUiState.empty() {
    return MainUiState(
      isLoading: false,
      userMessage: '',
      selectedBottomNavIndex: 0,
      lastBackPressTime: null,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    userMessage,
    selectedBottomNavIndex,
    lastBackPressTime,
    bannerAdConfig,
  ];

  //Add more properties to the state
  final int selectedBottomNavIndex;
  final DateTime? lastBackPressTime;
  final BannerAdConfigEntity? bannerAdConfig;

  MainUiState copyWith({
    bool? isLoading,
    String? userMessage,
    int? selectedBottomNavIndex,
    DateTime? lastBackPressTime,
    BannerAdConfigEntity? bannerAdConfig,
  }) {
    return MainUiState(
      isLoading: isLoading ?? this.isLoading,
      userMessage: userMessage ?? this.userMessage,
      selectedBottomNavIndex:
          selectedBottomNavIndex ?? this.selectedBottomNavIndex,
      lastBackPressTime: lastBackPressTime ?? this.lastBackPressTime,
      bannerAdConfig: bannerAdConfig ?? this.bannerAdConfig,
    );
  }
}
