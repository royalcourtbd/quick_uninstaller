import 'dart:async';
import 'dart:typed_data';

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
  int _batchSuccessCount = 0;
  StreamSubscription<String>? _packageRemovedSubscription;
  final Set<String> _iconRequestsInFlight = {};
  final Map<String, DateTime> _iconRetryAfter = {};
  static const Duration _iconRetryDelay = Duration(seconds: 5);
  int _systemLoadGeneration = 0;

  final Obs<UninstallerUiState> uiState = Obs<UninstallerUiState>(
    UninstallerUiState.empty(),
  );
  UninstallerUiState get currentUiState => uiState.value;

  @override
  void onInit() {
    super.onInit();
    _loadSavedSortType();
    _packageRemovedSubscription = _localDataSource.packageRemovedStream.listen(
      _onPackageRemoved,
    );
    loadApps();
    _loadMemoryInfo();
  }

  // --- Load Apps ---

  Future<void> loadApps() async {
    _systemLoadGeneration++;
    uiState.value = currentUiState.copyWith(
      systemApps: [],
      isSystemAppsLoading: false,
      hasLoadedSystemApps: false,
    );
    await _loadUserApps(showLoading: true);
    unawaited(_loadSystemApps(forceReload: true));
  }

  Future<void> _loadUserApps({required bool showLoading}) async {
    await parseDataFromEitherWithUserMessage(
      task: () => _getInstalledAppsUseCase.execute(appType: 'user'),
      showLoading: showLoading,
      onDataLoaded: (apps) {
        // Hide this app from the list — users should not uninstall themselves.
        const ownPackage = 'com.amatullah.quickuninstaller';
        final sortType = currentUiState.sortType;
        final userApps = _mergeKnownIcons(
          _applySortTo(
            apps
                .where(
                  (app) => !app.isSystemApp && app.packageName != ownPackage,
                )
                .toList(),
            sortType,
          ),
        );
        final visibleUserPackages = userApps.map((a) => a.packageName).toSet();
        final selectedPackages = currentUiState.selectedPackages
            .where(visibleUserPackages.contains)
            .toSet();

        uiState.value = currentUiState.copyWith(
          userApps: userApps,
          selectedPackages: selectedPackages,
        );
      },
    );
  }

  Future<void> _loadSystemApps({bool forceReload = false}) async {
    if (currentUiState.isSystemAppsLoading && !forceReload) return;
    if (currentUiState.hasLoadedSystemApps && !forceReload) return;

    final generation = ++_systemLoadGeneration;
    uiState.value = currentUiState.copyWith(
      isSystemAppsLoading: true,
      hasLoadedSystemApps: forceReload
          ? false
          : currentUiState.hasLoadedSystemApps,
    );

    await parseDataFromEitherWithUserMessage(
      task: () => _getInstalledAppsUseCase.execute(appType: 'system'),
      onDataLoaded: (apps) {
        if (generation != _systemLoadGeneration) return;
        final systemApps = _mergeKnownIcons(
          _applySortTo(
            apps.where((app) => app.isSystemApp).toList(),
            currentUiState.sortType,
          ),
        );
        uiState.value = currentUiState.copyWith(
          systemApps: systemApps,
          hasLoadedSystemApps: true,
        );
      },
    );

    if (generation == _systemLoadGeneration) {
      uiState.value = currentUiState.copyWith(isSystemAppsLoading: false);
    }
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
    if (index == 1) unawaited(_loadSystemApps());
  }

  void updateSearchQuery(String query) {
    uiState.value = currentUiState.copyWith(searchQuery: query);
  }

  Future<void> loadAppIcon(String packageName) async {
    final app = _findLoadedApp(packageName);
    if (app == null || app.appIcon != null) return;
    if (_iconRequestsInFlight.contains(packageName)) {
      return;
    }
    final retryAfter = _iconRetryAfter[packageName];
    if (retryAfter != null && DateTime.now().isBefore(retryAfter)) return;

    _iconRequestsInFlight.add(packageName);
    try {
      final icon = await _localDataSource.getAppIcon(packageName);
      if (icon == null) {
        _iconRetryAfter[packageName] = DateTime.now().add(_iconRetryDelay);
        return;
      }
      _iconRetryAfter.remove(packageName);
      _attachIcon(packageName, icon);
    } catch (_) {
      _iconRetryAfter[packageName] = DateTime.now().add(_iconRetryDelay);
    } finally {
      _iconRequestsInFlight.remove(packageName);
    }
  }

  AppInfoEntity? _findLoadedApp(String packageName) {
    for (final app in currentUiState.userApps) {
      if (app.packageName == packageName) return app;
    }
    for (final app in currentUiState.systemApps) {
      if (app.packageName == packageName) return app;
    }
    return null;
  }

  List<AppInfoEntity> _mergeKnownIcons(List<AppInfoEntity> apps) {
    final iconByPackage = <String, Uint8List>{};
    for (final app in [
      ...currentUiState.userApps,
      ...currentUiState.systemApps,
    ]) {
      final icon = app.appIcon;
      if (icon != null) iconByPackage[app.packageName] = icon;
    }

    return apps.map((app) {
      final icon = iconByPackage[app.packageName];
      if (icon == null) return app;
      return app.copyWith(appIcon: icon);
    }).toList();
  }

  void _attachIcon(String packageName, Uint8List icon) {
    bool changed = false;
    final userApps = currentUiState.userApps.map((app) {
      if (app.packageName != packageName || app.appIcon != null) return app;
      changed = true;
      return app.copyWith(appIcon: icon);
    }).toList();
    final systemApps = currentUiState.systemApps.map((app) {
      if (app.packageName != packageName || app.appIcon != null) return app;
      changed = true;
      return app.copyWith(appIcon: icon);
    }).toList();

    if (!changed) return;
    uiState.value = currentUiState.copyWith(
      userApps: userApps,
      systemApps: systemApps,
    );
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
        list.sort(
          (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
        );
      case SortType.nameDesc:
        list.sort(
          (a, b) => b.appName.toLowerCase().compareTo(a.appName.toLowerCase()),
        );
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
    // Block interaction while a batch uninstall is running.
    if (currentUiState.isUninstalling) return;

    // System apps cannot be uninstalled, so they must not be selectable.
    final isSystem = currentUiState.systemApps.any(
      (app) => app.packageName == packageName,
    );
    if (isSystem) return;

    final selected = Set<String>.from(currentUiState.selectedPackages);
    if (selected.contains(packageName)) {
      selected.remove(packageName);
    } else {
      selected.add(packageName);
    }
    uiState.value = currentUiState.copyWith(selectedPackages: selected);
  }

  void clearSelection() {
    if (currentUiState.isUninstalling) return;
    _batchQueue.clear();
    _batchSuccessCount = 0;
    uiState.value = currentUiState.copyWith(
      selectedPackages: {},
      isUninstalling: false,
      uninstallProgress: 0,
      uninstallTotal: 0,
    );
  }

  void selectAll() {
    if (currentUiState.isUninstalling) return;
    // Only user apps can be selected; system apps cannot be uninstalled.
    if (currentUiState.selectedTabIndex != 0) return;
    final allPackages = currentUiState.filteredUserApps
        .map((a) => a.packageName)
        .toSet();
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
    // Defensively drop any system apps so the batch never tries to uninstall
    // something the OS will reject.
    final systemPackages = currentUiState.systemApps
        .map((a) => a.packageName)
        .toSet();
    final packages = currentUiState.selectedPackages
        .where((p) => !systemPackages.contains(p))
        .toList();
    _batchQueue
      ..clear()
      ..addAll(packages);
    _batchSuccessCount = 0;
    uiState.value = currentUiState.copyWith(
      isUninstalling: true,
      uninstallProgress: 0,
      uninstallTotal: packages.length,
    );
    await _fireNextInQueue();
  }

  Future<void> _fireNextInQueue() async {
    if (_batchQueue.isEmpty) {
      uiState.value = currentUiState.copyWith(
        isUninstalling: false,
        uninstallProgress: 0,
        uninstallTotal: 0,
      );
      return;
    }
    final next = _batchQueue.removeAt(0);
    _pendingUninstallCheck = true;
    _singleUninstallTarget = next;
    try {
      await _localDataSource.uninstallApp(next);
    } catch (_) {}
  }

  void _removeAppFromCache(String packageName) {
    _iconRequestsInFlight.remove(packageName);
    _iconRetryAfter.remove(packageName);
    final userApps = currentUiState.userApps
        .where((a) => a.packageName != packageName)
        .toList();
    final systemApps = currentUiState.systemApps
        .where((a) => a.packageName != packageName)
        .toList();
    final selected = Set<String>.from(currentUiState.selectedPackages)
      ..remove(packageName);
    uiState.value = currentUiState.copyWith(
      userApps: userApps,
      systemApps: systemApps,
      selectedPackages: selected,
    );
    _loadMemoryInfo();
  }

  void _onPackageRemoved(String packageName) {
    if (currentUiState.userApps.any((a) => a.packageName == packageName) ||
        currentUiState.systemApps.any((a) => a.packageName == packageName) ||
        currentUiState.selectedPackages.contains(packageName)) {
      _removeAppFromCache(packageName);
    }
  }

  Future<void> _refreshAfterPackageChanges() async {
    final shouldRefreshSystemApps =
        currentUiState.hasLoadedSystemApps ||
        currentUiState.selectedTabIndex == 1;
    if (shouldRefreshSystemApps) _systemLoadGeneration++;
    await _loadUserApps(showLoading: false);
    if (shouldRefreshSystemApps) {
      unawaited(_loadSystemApps(forceReload: true));
    }
    await _loadMemoryInfo();
  }

  Future<void> onAppResumed() async {
    if (!_pendingUninstallCheck) {
      await _refreshAfterPackageChanges();
      return;
    }
    _pendingUninstallCheck = false;

    final target = _singleUninstallTarget;
    _singleUninstallTarget = null;

    bool wasRemoved = false;
    if (target != null) {
      final installed = await _localDataSource.isAppInstalled(target);
      if (!installed) {
        wasRemoved = true;
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 700));
        wasRemoved = !await _localDataSource.isAppInstalled(target);
      }
    }

    final isBatch = currentUiState.uninstallTotal > 0;

    // Update cache and counters
    if (wasRemoved && target != null) {
      if (isBatch) _batchSuccessCount++;
      _removeAppFromCache(target);
    }

    // Update progress for batch
    if (isBatch) {
      uiState.value = currentUiState.copyWith(
        uninstallProgress: currentUiState.uninstallProgress + 1,
      );
    }

    // If batch queue has more items, fire next
    if (_batchQueue.isNotEmpty) {
      await _fireNextInQueue();
      return;
    }

    // Batch done or single uninstall
    if (isBatch) {
      final total = currentUiState.uninstallTotal;
      final skipped = total - _batchSuccessCount;
      uiState.value = currentUiState.copyWith(
        selectedPackages: {},
        isUninstalling: false,
        uninstallProgress: 0,
        uninstallTotal: 0,
      );
      await _refreshAfterPackageChanges();
      if (_batchSuccessCount == 0) {
        addUserMessage('No apps were uninstalled');
      } else if (skipped == 0) {
        final s = _batchSuccessCount == 1 ? '' : 's';
        addUserMessage('$_batchSuccessCount app$s uninstalled');
      } else {
        addUserMessage('$_batchSuccessCount uninstalled, $skipped skipped');
      }
      _batchSuccessCount = 0;
    } else {
      uiState.value = currentUiState.copyWith(isUninstalling: false);
      await _refreshAfterPackageChanges();
      if (!wasRemoved) {
        addUserMessage('Uninstall cancelled');
      }
    }
  }

  @override
  void onClose() {
    _packageRemovedSubscription?.cancel();
    super.onClose();
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
