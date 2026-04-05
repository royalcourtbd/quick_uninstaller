import 'package:quick_uninstaller/core/base/base_presenter.dart';
import 'package:quick_uninstaller/core/utility/navigation_helpers.dart';
import 'package:quick_uninstaller/features/home/presentation/presenter/home_ui_state.dart';

class HomePresenter extends BasePresenter<HomeUiState> {
  final Obs<HomeUiState> uiState = Obs<HomeUiState>(HomeUiState.empty());
  HomeUiState get currentUiState => uiState.value;

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
