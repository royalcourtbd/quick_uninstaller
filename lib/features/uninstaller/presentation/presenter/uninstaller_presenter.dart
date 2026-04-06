import 'package:quick_uninstaller/core/base/base_presenter.dart';
import 'package:quick_uninstaller/core/utility/navigation_helpers.dart';
import 'package:quick_uninstaller/features/uninstaller/data/datasource/uninstaller_local_data_source.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/usecase/get_installed_apps_use_case.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/presenter/uninstaller_ui_state.dart';

class UninstallerPresenter extends BasePresenter<UninstallerUiState> {
  UninstallerPresenter(this._getInstalledAppsUseCase, this._localDataSource);

  final GetInstalledAppsUseCase _getInstalledAppsUseCase;
  final UninstallerLocalDataSource _localDataSource;

  bool _pendingUninstallCheck = false;

  final Obs<UninstallerUiState> uiState =
      Obs<UninstallerUiState>(UninstallerUiState.empty());
  UninstallerUiState get currentUiState => uiState.value;

  @override
  void onInit() {
    super.onInit();
    loadApps();
    _loadMemoryInfo();
  }

  Future<void> loadApps() async {
    await parseDataFromEitherWithUserMessage(
      task: () => _getInstalledAppsUseCase.execute(),
      showLoading: true,
      onDataLoaded: (apps) {
        final userApps = apps.where((app) => !app.isSystemApp).toList()
          ..sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
        final systemApps = apps.where((app) => app.isSystemApp).toList()
          ..sort((a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

        uiState.value = currentUiState.copyWith(
          userApps: userApps,
          systemApps: systemApps,
        );
      },
    );
  }

  Future<void> _loadMemoryInfo() async {
    try {
      final memInfo = await _localDataSource.getMemoryInfo();
      uiState.value = currentUiState.copyWith(
        freeBytes: memInfo['freeBytes'] ?? 0,
        totalBytes: memInfo['totalBytes'] ?? 0,
      );
    } catch (_) {}
  }

  void changeTab(int index) {
    uiState.value = currentUiState.copyWith(selectedTabIndex: index);
  }

  void updateSearchQuery(String query) {
    uiState.value = currentUiState.copyWith(searchQuery: query);
  }

  // --- Selection ---

  void toggleAppSelection(String packageName) {
    final selected = Set<String>.from(currentUiState.selectedPackages);
    if (selected.contains(packageName)) {
      selected.remove(packageName);
    } else {
      selected.add(packageName);
    }
    uiState.value = currentUiState.copyWith(selectedPackages: selected);
  }

  void clearSelection() {
    uiState.value = currentUiState.copyWith(selectedPackages: {});
  }

  void selectAll() {
    final apps = currentUiState.selectedTabIndex == 0
        ? currentUiState.filteredUserApps
        : currentUiState.filteredSystemApps;
    final allPackages = apps.map((a) => a.packageName).toSet();
    uiState.value = currentUiState.copyWith(selectedPackages: allPackages);
  }

  // --- Uninstall ---

  Future<void> uninstallApp(String packageName) async {
    _pendingUninstallCheck = true;
    try {
      await _localDataSource.uninstallApp(packageName);
    } catch (_) {}
  }

  Future<void> onAppResumed() async {
    if (!_pendingUninstallCheck) return;
    _pendingUninstallCheck = false;

    final selected = currentUiState.selectedPackages;
    if (selected.isNotEmpty) {
      final stillInstalled = <String>{};
      for (final pkg in selected) {
        final installed = await _localDataSource.isAppInstalled(pkg);
        if (installed) stillInstalled.add(pkg);
      }
      uiState.value = currentUiState.copyWith(selectedPackages: stillInstalled);
    }
    await loadApps();
    _loadMemoryInfo();
  }

  Future<void> uninstallSelectedApps() async {
    final packages = currentUiState.selectedPackages.toList();
    uiState.value = currentUiState.copyWith(isUninstalling: true);
    for (final pkg in packages) {
      await uninstallApp(pkg);
      await Future.delayed(const Duration(milliseconds: 500));
    }
    uiState.value = currentUiState.copyWith(isUninstalling: false);
  }

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
