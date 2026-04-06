import 'package:quick_uninstaller/core/base/base_presenter.dart';
import 'package:quick_uninstaller/core/services/local_cache_service.dart';
import 'package:quick_uninstaller/core/utility/navigation_helpers.dart';
import 'package:quick_uninstaller/features/uninstaller/data/datasource/uninstaller_local_data_source.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/entities/app_info_entity.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/usecase/get_installed_apps_use_case.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/presenter/uninstaller_ui_state.dart';

class UninstallerPresenter extends BasePresenter<UninstallerUiState> {
  UninstallerPresenter(
    this._getInstalledAppsUseCase,
    this._localDataSource,
    this._cacheService,
  );

  final GetInstalledAppsUseCase _getInstalledAppsUseCase;
  final UninstallerLocalDataSource _localDataSource;
  final LocalCacheService _cacheService;

  bool _pendingUninstallCheck = false;
  String? _singleUninstallTarget;
  final List<String> _batchQueue = [];

  final Obs<UninstallerUiState> uiState =
      Obs<UninstallerUiState>(UninstallerUiState.empty());
  UninstallerUiState get currentUiState => uiState.value;

  @override
  void onInit() {
    super.onInit();
    _loadSavedSortType();
    loadApps();
    _loadMemoryInfo();
  }

  // --- Load Apps ---

  Future<void> loadApps() async {
    await parseDataFromEitherWithUserMessage(
      task: () => _getInstalledAppsUseCase.execute(),
      showLoading: true,
      onDataLoaded: (apps) {
        final sortType = currentUiState.sortType;
        final userApps = _applySortTo(
          apps.where((app) => !app.isSystemApp).toList(),
          sortType,
        );
        final systemApps = _applySortTo(
          apps.where((app) => app.isSystemApp).toList(),
          sortType,
        );

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

  // --- Sort ---

  void _loadSavedSortType() {
    final savedIndex = _cacheService.getData<int>(key: CacheKeys.sortType);
    if (savedIndex != null && savedIndex < SortType.values.length) {
      uiState.value = currentUiState.copyWith(
        sortType: SortType.values[savedIndex],
      );
    }
  }

  void changeSortType(SortType sortType) {
    _cacheService.saveData(key: CacheKeys.sortType, value: sortType.index);
    final sorted = _applySortTo(currentUiState.userApps, sortType);
    final sortedSystem = _applySortTo(currentUiState.systemApps, sortType);
    uiState.value = currentUiState.copyWith(
      sortType: sortType,
      userApps: sorted,
      systemApps: sortedSystem,
    );
  }

  List<AppInfoEntity> _applySortTo(List<AppInfoEntity> apps, SortType type) {
    final list = List<AppInfoEntity>.from(apps);
    switch (type) {
      case SortType.nameAsc:
        list.sort((a, b) =>
            a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));
      case SortType.nameDesc:
        list.sort((a, b) =>
            b.appName.toLowerCase().compareTo(a.appName.toLowerCase()));
      case SortType.sizeDesc:
        list.sort((a, b) => b.appSize.compareTo(a.appSize));
      case SortType.sizeAsc:
        list.sort((a, b) => a.appSize.compareTo(b.appSize));
      case SortType.dateDesc:
        list.sort((a, b) => b.installDate.compareTo(a.installDate));
      case SortType.dateAsc:
        list.sort((a, b) => a.installDate.compareTo(b.installDate));
    }
    return list;
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
    _batchQueue.clear();
    uiState.value = currentUiState.copyWith(
      selectedPackages: {},
      isUninstalling: false,
    );
  }

  void selectAll() {
    final apps = currentUiState.selectedTabIndex == 0
        ? currentUiState.filteredUserApps
        : currentUiState.filteredSystemApps;
    final allPackages = apps.map((a) => a.packageName).toSet();
    uiState.value = currentUiState.copyWith(selectedPackages: allPackages);
  }

  // --- App Actions ---

  Future<void> launchApp(String packageName) async {
    try {
      await _localDataSource.launchApp(packageName);
    } catch (_) {}
  }

  Future<void> openAppDetails(String packageName) async {
    try {
      await _localDataSource.openAppDetails(packageName);
    } catch (_) {}
  }

  Future<void> openInPlayStore(String packageName) async {
    try {
      await _localDataSource.openInPlayStore(packageName);
    } catch (_) {}
  }

  Future<void> addShortcut(String packageName) async {
    try {
      final success = await _localDataSource.addShortcut(packageName);
      if (success) {
        addUserMessage('Shortcut added');
      } else {
        addUserMessage('Shortcut not supported');
      }
    } catch (_) {
      addUserMessage('Failed to add shortcut');
    }
  }

  // --- Uninstall ---

  Future<void> uninstallApp(String packageName) async {
    _pendingUninstallCheck = true;
    _singleUninstallTarget = packageName;
    try {
      await _localDataSource.uninstallApp(packageName);
    } catch (_) {}
  }

  Future<void> uninstallSelectedApps() async {
    _batchQueue
      ..clear()
      ..addAll(currentUiState.selectedPackages);
    uiState.value = currentUiState.copyWith(isUninstalling: true);
    _fireNextInQueue();
  }

  void _fireNextInQueue() {
    if (_batchQueue.isEmpty) {
      uiState.value = currentUiState.copyWith(isUninstalling: false);
      return;
    }
    final next = _batchQueue.removeAt(0);
    _pendingUninstallCheck = true;
    _singleUninstallTarget = next;
    try {
      _localDataSource.uninstallApp(next);
    } catch (_) {}
  }

  Future<void> onAppResumed() async {
    if (!_pendingUninstallCheck) return;
    _pendingUninstallCheck = false;

    final target = _singleUninstallTarget;
    _singleUninstallTarget = null;

    // Check if the target was actually uninstalled
    bool wasRemoved = false;
    if (target != null) {
      final installed = await _localDataSource.isAppInstalled(target);
      wasRemoved = !installed;
    }

    // If batch queue has more items, fire next regardless of cancel
    if (_batchQueue.isNotEmpty) {
      if (wasRemoved) {
        // Remove from selection
        final selected = Set<String>.from(currentUiState.selectedPackages)
          ..remove(target);
        uiState.value = currentUiState.copyWith(selectedPackages: selected);
      }
      _fireNextInQueue();
      return;
    }

    // Batch done or single uninstall
    uiState.value = currentUiState.copyWith(isUninstalling: false);

    if (!wasRemoved) return;

    // Clean up selection
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
