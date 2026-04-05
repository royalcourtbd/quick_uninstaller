import 'package:quick_uninstaller/core/base/base_ui_state.dart';

class HomeUiState extends BaseUiState {
  const HomeUiState({required super.isLoading, required super.userMessage});

  factory HomeUiState.empty() {
    return HomeUiState(isLoading: false, userMessage: '');
  }

  @override
  List<Object?> get props => [isLoading, userMessage];

  //Add more properties to the state

  HomeUiState copyWith({bool? isLoading, String? userMessage}) {
    return HomeUiState(
      isLoading: isLoading ?? this.isLoading,
      userMessage: userMessage ?? this.userMessage,
    );
  }
}
