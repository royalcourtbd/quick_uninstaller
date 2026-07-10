import 'package:quick_uninstaller/features/uninstaller/domain/entities/app_info_entity.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/presenter/uninstaller_ui_state.dart';

enum UninstallerDestination { allApps, recentlyInstalled }

class UninstallerViewState {
  const UninstallerViewState({
    this.destination = UninstallerDestination.allApps,
  });

  final UninstallerDestination destination;

  bool get isRecentlyInstalled =>
      destination == UninstallerDestination.recentlyInstalled;

  List<AppInfoEntity> recentApps(UninstallerUiState state) {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final apps = state.userApps
        .where((app) => !app.installDate.isBefore(cutoff))
        .toList();
    apps.sort((a, b) => b.installDate.compareTo(a.installDate));
    return apps;
  }

  List<AppInfoEntity> visibleApps(UninstallerUiState state) {
    if (isRecentlyInstalled) {
      final query = state.searchQuery.trim().toLowerCase();
      return recentApps(state).where((app) {
        if (query.isEmpty) return true;
        return app.appName.toLowerCase().contains(query) ||
            app.packageName.toLowerCase().contains(query);
      }).toList();
    }

    return state.selectedTabIndex == 0
        ? state.filteredUserApps
        : state.filteredSystemApps;
  }

  UninstallerViewState copyWith({UninstallerDestination? destination}) {
    return UninstallerViewState(destination: destination ?? this.destination);
  }
}
