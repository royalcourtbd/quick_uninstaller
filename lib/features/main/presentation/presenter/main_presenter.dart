import 'dart:async';
import 'package:flutter/services.dart';
import 'package:quick_uninstaller/core/base/base_presenter.dart';
import 'package:quick_uninstaller/core/utility/navigation_helpers.dart';
import 'package:quick_uninstaller/core/services/time_service.dart';
import 'package:quick_uninstaller/features/main/presentation/presenter/main_ui_state.dart';

class MainPresenter extends BasePresenter<MainUiState> {
  final Obs<MainUiState> uiState = Obs<MainUiState>(MainUiState.empty());
  MainUiState get currentUiState => uiState.value;

  final TimeService _timeService;

  MainPresenter(this._timeService);

  void changeNavigationIndex(int index) {
    uiState.value = currentUiState.copyWith(selectedBottomNavIndex: index);
  }

  Future<void> handleBackPress() async {
    if (currentUiState.selectedBottomNavIndex != 0) {
      changeNavigationIndex(0);
      return;
    }

    final DateTime now = _timeService.currentTime;
    final DateTime lastPressed = currentUiState.lastBackPressTime ?? now;

    if (now.difference(lastPressed) > const Duration(seconds: 2)) {
      updateLastBackPressTime(now);
      addUserMessage('Press back again to exit');
      return;
    }

    await SystemNavigator.pop();
  }

  void updateLastBackPressTime(DateTime time) {
    uiState.value = currentUiState.copyWith(lastBackPressTime: time);
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
