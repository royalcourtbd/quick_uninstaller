import 'package:quick_uninstaller/core/base/base_ui_state.dart';

class SupportUiState extends BaseUiState {
  const SupportUiState({
    required super.isLoading,
    required super.userMessage,
    required this.isAdAvailable,
    required this.isRewardedAdLoaded,
    required this.isRewardedAdLoading,
    required this.adWatchCount,
  });

  factory SupportUiState.empty() {
    return const SupportUiState(
      isLoading: false,
      userMessage: '',
      isAdAvailable: true,
      isRewardedAdLoaded: false,
      isRewardedAdLoading: false,
      adWatchCount: 0,
    );
  }

  final bool isAdAvailable;
  final bool isRewardedAdLoaded;
  final bool isRewardedAdLoading;
  final int adWatchCount;

  @override
  List<Object?> get props => [
    isLoading,
    userMessage,
    isAdAvailable,
    isRewardedAdLoaded,
    isRewardedAdLoading,
    adWatchCount,
  ];

  SupportUiState copyWith({
    bool? isLoading,
    String? userMessage,
    bool? isAdAvailable,
    bool? isRewardedAdLoaded,
    bool? isRewardedAdLoading,
    int? adWatchCount,
  }) {
    return SupportUiState(
      isLoading: isLoading ?? this.isLoading,
      userMessage: userMessage ?? this.userMessage,
      isAdAvailable: isAdAvailable ?? this.isAdAvailable,
      isRewardedAdLoaded: isRewardedAdLoaded ?? this.isRewardedAdLoaded,
      isRewardedAdLoading: isRewardedAdLoading ?? this.isRewardedAdLoading,
      adWatchCount: adWatchCount ?? this.adWatchCount,
    );
  }
}
