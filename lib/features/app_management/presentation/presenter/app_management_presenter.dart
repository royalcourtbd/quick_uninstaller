import 'dart:async';
import 'package:quick_uninstaller/core/base/base_presenter.dart';
import 'package:quick_uninstaller/core/utility/navigation_helpers.dart';
import 'package:quick_uninstaller/features/app_management/presentation/presenter/app_management_ui_state.dart';

class AppManagementPresenter extends BasePresenter<AppManagementUiState> {
  final Obs<AppManagementUiState> uiState = Obs<AppManagementUiState>(
    AppManagementUiState.empty(),
  );
  AppManagementUiState get currentUiState => uiState.value;

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
