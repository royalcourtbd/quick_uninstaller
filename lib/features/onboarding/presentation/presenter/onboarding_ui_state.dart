import 'package:quick_uninstaller/core/base/base_ui_state.dart';

class OnboardingUiState extends BaseUiState {
  const OnboardingUiState({
    required super.isLoading,
    required super.userMessage,
  });

  factory OnboardingUiState.empty() {
    return OnboardingUiState(isLoading: false, userMessage: '');
  }

  @override
  List<Object?> get props => [isLoading, userMessage];

  //Add more properties to the state

  OnboardingUiState copyWith({bool? isLoading, String? userMessage}) {
    return OnboardingUiState(
      isLoading: isLoading ?? this.isLoading,
      userMessage: userMessage ?? this.userMessage,
    );
  }
}
