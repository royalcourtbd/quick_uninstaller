import 'package:quick_uninstaller/core/base/base_ui_state.dart';

class AppManagementUiState extends BaseUiState {
  const AppManagementUiState({
    required super.isLoading,
    required super.userMessage,
  });

  factory AppManagementUiState.empty() {
    return AppManagementUiState(isLoading: false, userMessage: '');
  }

  @override
  List<Object?> get props => [isLoading, userMessage];

  //Add more properties to the state

  AppManagementUiState copyWith({bool? isLoading, String? userMessage}) {
    return AppManagementUiState(
      isLoading: isLoading ?? this.isLoading,
      userMessage: userMessage ?? this.userMessage,
    );
  }
}
