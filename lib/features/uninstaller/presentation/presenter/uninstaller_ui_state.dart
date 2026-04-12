import 'package:quick_uninstaller/core/base/base_ui_state.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/entities/app_info_entity.dart';

enum SortType {
  nameAsc('Name (A-Z)'),
  nameDesc('Name (Z-A)'),
  sizeDesc('Size (Largest)'),
  sizeAsc('Size (Smallest)'),
  dateDesc('Date (Newest)'),
  dateAsc('Date (Oldest)');

  const SortType(this.label);
  final String label;
}

class UninstallerUiState extends BaseUiState {
  const UninstallerUiState({
    required super.isLoading,
    required super.userMessage,
    required this.userApps,
    required this.systemApps,
    required this.selectedTabIndex,
    required this.searchQuery,
    required this.freeBytes,
    required this.totalBytes,
    required this.selectedPackages,
    required this.isUninstalling,
    required this.uninstallProgress,
    required this.uninstallTotal,
    required this.sortType,
  });

  factory UninstallerUiState.empty() {
    return const UninstallerUiState(
      isLoading: false,
      userMessage: '',
      userApps: [],
      systemApps: [],
      selectedTabIndex: 0,
      searchQuery: '',
      freeBytes: 0,
      totalBytes: 0,
      selectedPackages: {},
      isUninstalling: false,
      uninstallProgress: 0,
      uninstallTotal: 0,
      sortType: SortType.nameAsc,
    );
  }

  final List<AppInfoEntity> userApps;
  final List<AppInfoEntity> systemApps;
  final int selectedTabIndex;
  final String searchQuery;
  final int freeBytes;
  final int totalBytes;
  final Set<String> selectedPackages;
  final bool isUninstalling;
  final int uninstallProgress;
  final int uninstallTotal;
  final SortType sortType;

  // Selection mode is only meaningful on the user apps tab, since system
  // apps cannot be uninstalled. Selection state is preserved across tab
  // switches, but the selection UI hides while viewing system apps.
  bool get isSelectionMode =>
      selectedPackages.isNotEmpty && selectedTabIndex == 0;

  List<AppInfoEntity> get filteredUserApps {
    if (searchQuery.isEmpty) return userApps;
    final query = searchQuery.toLowerCase();
    return userApps
        .where((app) => app.appName.toLowerCase().contains(query))
        .toList();
  }

  List<AppInfoEntity> get filteredSystemApps {
    if (searchQuery.isEmpty) return systemApps;
    final query = searchQuery.toLowerCase();
    return systemApps
        .where((app) => app.appName.toLowerCase().contains(query))
        .toList();
  }

  int get totalAppCount => userApps.length + systemApps.length;

  String get formattedFreeMemory {
    final freeGB = (freeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1);
    final totalGB = (totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(0);
    return 'Free memory: $freeGB GB / $totalGB GB';
  }

  @override
  List<Object?> get props => [
        isLoading,
        userMessage,
        userApps,
        systemApps,
        selectedTabIndex,
        searchQuery,
        freeBytes,
        totalBytes,
        selectedPackages,
        isUninstalling,
        uninstallProgress,
        uninstallTotal,
        sortType,
      ];

  UninstallerUiState copyWith({
    bool? isLoading,
    String? userMessage,
    List<AppInfoEntity>? userApps,
    List<AppInfoEntity>? systemApps,
    int? selectedTabIndex,
    String? searchQuery,
    int? freeBytes,
    int? totalBytes,
    Set<String>? selectedPackages,
    bool? isUninstalling,
    int? uninstallProgress,
    int? uninstallTotal,
    SortType? sortType,
  }) {
    return UninstallerUiState(
      isLoading: isLoading ?? this.isLoading,
      userMessage: userMessage ?? this.userMessage,
      userApps: userApps ?? this.userApps,
      systemApps: systemApps ?? this.systemApps,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      freeBytes: freeBytes ?? this.freeBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      selectedPackages: selectedPackages ?? this.selectedPackages,
      isUninstalling: isUninstalling ?? this.isUninstalling,
      uninstallProgress: uninstallProgress ?? this.uninstallProgress,
      uninstallTotal: uninstallTotal ?? this.uninstallTotal,
      sortType: sortType ?? this.sortType,
    );
  }
}
