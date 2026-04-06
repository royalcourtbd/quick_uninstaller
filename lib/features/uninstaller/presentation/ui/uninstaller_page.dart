import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/di/service_locator.dart';
import 'package:quick_uninstaller/core/widgets/presentable_widget_builder.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/presenter/uninstaller_presenter.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/presenter/uninstaller_ui_state.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/widgets/app_list_shimmer.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/widgets/app_list_view.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/widgets/memory_bar.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/widgets/search_fab.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/widgets/search_header.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/widgets/selection_app_bar.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/widgets/uninstall_bottom_sheet.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/widgets/uninstall_fab.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/widgets/sort_bottom_sheet.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/widgets/uninstaller_app_bar.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/widgets/uninstaller_tab_bar.dart';

class UninstallerPage extends StatefulWidget {
  const UninstallerPage({super.key});

  @override
  State<UninstallerPage> createState() => _UninstallerPageState();
}

class _UninstallerPageState extends State<UninstallerPage>
    with WidgetsBindingObserver {
  final UninstallerPresenter _presenter = locate<UninstallerPresenter>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _presenter.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PresentableWidgetBuilder(
      presenter: _presenter,
      builder: () {
        final state = _presenter.currentUiState;
        return Scaffold(
          backgroundColor: context.color.scaffoldBackgroundColor,
          body: Column(
            children: [
              _buildAppBar(state),
              UninstallerTabBar(
                userAppCount: state.filteredUserApps.length,
                systemAppCount: state.filteredSystemApps.length,
                selectedTabIndex: state.selectedTabIndex,
                onTabChanged: _presenter.changeTab,
              ),
              Expanded(child: _buildBody(state)),
              MemoryBar(
                formattedMemory: state.formattedFreeMemory,
                totalBytes: state.totalBytes,
              ),
            ],
          ),
          floatingActionButton: _buildFab(state),
        );
      },
    );
  }

  Widget _buildAppBar(UninstallerUiState state) {
    if (state.isSelectionMode) {
      return SelectionAppBar(
        selectedCount: state.selectedPackages.length,
        onClose: _presenter.clearSelection,
        onSelectAll: _presenter.selectAll,
      );
    }
    return UninstallerAppBar(
      totalAppCount: state.totalAppCount,
      onSortTap: () => SortBottomSheet.show(
        context,
        currentSort: state.sortType,
        onSortChanged: _presenter.changeSortType,
      ),
      onRefreshTap: _presenter.loadApps,
    );
  }

  Widget _buildBody(UninstallerUiState state) {
    if (state.isLoading) return const AppListShimmer();

    final apps = state.selectedTabIndex == 0
        ? state.filteredUserApps
        : state.filteredSystemApps;

    final listView = AppListView(
      apps: apps,
      selectedPackages: state.selectedPackages,
      isSelectionMode: state.isSelectionMode,
      hasSearchQuery: state.searchQuery.isNotEmpty,
      onMoreTap: (app) => UninstallBottomSheet.show(
        context,
        app: app,
        onUninstall: () => _presenter.uninstallApp(app.packageName),
      ),
      onLongPress: _presenter.toggleAppSelection,
      onTap: (packageName) {
        if (state.isSelectionMode) {
          _presenter.toggleAppSelection(packageName);
        }
      },
    );

    if (state.searchQuery.isNotEmpty) {
      return SearchHeader(
        onChanged: _presenter.updateSearchQuery,
        onClear: () => _presenter.updateSearchQuery(''),
        child: listView,
      );
    }

    return listView;
  }

  Widget _buildFab(UninstallerUiState state) {
    if (state.isSelectionMode) {
      return UninstallFab(
        selectedCount: state.selectedPackages.length,
        isUninstalling: state.isUninstalling,
        onPressed: _presenter.uninstallSelectedApps,
      );
    }
    return SearchFab(
      hasSearchQuery: state.searchQuery.isNotEmpty,
      onPressed: () => _presenter.updateSearchQuery(' '),
    );
  }
}
