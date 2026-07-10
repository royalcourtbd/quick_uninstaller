import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/di/service_locator.dart';
import 'package:quick_uninstaller/core/widgets/presentable_widget_builder.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';
import 'package:quick_uninstaller/features/main/presentation/presenter/main_presenter.dart';
import 'package:quick_uninstaller/features/main/presentation/widgets/double_tap_back_to_exit_app.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/presenter/uninstaller_presenter.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/presenter/uninstaller_ui_state.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/presenter/uninstaller_view_state.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/ui/about_page.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/ui/privacy_policy_page.dart';
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
import 'package:quick_uninstaller/features/uninstaller/presentation/widgets/uninstaller_drawer.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/widgets/uninstaller_tab_bar.dart';
import 'package:quick_uninstaller/shared/components/banner_ad_widget.dart';
import 'package:quick_uninstaller/core/utility/logger_utility.dart';

class UninstallerPage extends StatefulWidget {
  const UninstallerPage({super.key});

  @override
  State<UninstallerPage> createState() => _UninstallerPageState();
}

class _UninstallerPageState extends State<UninstallerPage>
    with WidgetsBindingObserver {
  final UninstallerPresenter _presenter = locate<UninstallerPresenter>();
  final MainPresenter _mainPresenter = locate<MainPresenter>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UninstallerViewState _viewState = const UninstallerViewState();

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
    return DoubleTapBackToExitApp(
      mainPresenter: _mainPresenter,
      onBackPressed: _handleBackPress,
      child: PresentableWidgetBuilder(
        presenter: _presenter,
        builder: () {
          final state = _presenter.currentUiState;
          final bannerConfig = _mainPresenter.currentUiState.bannerAdConfig;
          logDebugStatic(
            'Building page: bannerConfig=$bannerConfig',
            'UninstallerPage',
          );
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: context.color.scaffoldBackgroundColor,
            drawer: UninstallerDrawer(
              selectedDestination: _viewState.destination,
              formattedMemory: state.formattedFreeMemory,
              freeBytes: state.freeBytes,
              totalBytes: state.totalBytes,
              onDestinationSelected: _changeDestination,
              onPrivacyPolicyTap: () =>
                  _openDrawerPage(const PrivacyPolicyPage()),
              onAboutTap: () => _openDrawerPage(const AboutPage()),
            ),
            body: Column(
              children: [
                _buildAppBar(state),
                if (!_viewState.isRecentlyInstalled)
                  UninstallerTabBar(
                    userAppCount: state.filteredUserApps.length,
                    systemAppCount: state.filteredSystemApps.length,
                    isSystemAppsLoading:
                        state.isSystemAppsLoading && !state.hasLoadedSystemApps,
                    selectedTabIndex: state.selectedTabIndex,
                    onTabChanged: _presenter.changeTab,
                  ),
                Expanded(child: _buildBody(state)),
                if (bannerConfig case final config? when config.isActive)
                  BannerAdWidget(
                    adUnitId: config.adUnitId,
                    isTestMode: config.isTestMode,
                    onAdClicked: _mainPresenter.onBannerAdClicked,
                    onAdImpression: _mainPresenter.onBannerAdImpression,
                  ),
                MemoryBar(
                  formattedMemory: state.formattedFreeMemory,
                  totalBytes: state.totalBytes,
                ),
              ],
            ),
            floatingActionButton: _buildFab(state),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(UninstallerUiState state) {
    if (state.isSelectionMode) {
      final visibleApps = _viewState.visibleApps(state);
      return SelectionAppBar(
        selectedCount: state.selectedPackages.length,
        onClose: _presenter.clearSelection,
        onSelectAll: _viewState.isRecentlyInstalled
            ? () => _presenter.selectPackages(
                visibleApps.map((app) => app.packageName),
              )
            : _presenter.selectAll,
      );
    }
    final isRecent = _viewState.isRecentlyInstalled;
    return UninstallerAppBar(
      totalAppCount: isRecent
          ? _viewState.recentApps(state).length
          : state.totalAppCount,
      title: isRecent ? 'Recently Installed' : 'Uninstaller',
      countLabel: isRecent ? 'IN LAST 30 DAYS' : 'APPS',
      showSort: !isRecent,
      onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
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
    if (!_viewState.isRecentlyInstalled &&
        state.selectedTabIndex == 1 &&
        state.isSystemAppsLoading &&
        !state.hasLoadedSystemApps) {
      return const AppListShimmer();
    }

    final apps = _viewState.visibleApps(state);

    final listView = AppListView(
      apps: apps,
      selectedPackages: state.selectedPackages,
      isSelectionMode: state.isSelectionMode,
      hasSearchQuery: state.searchQuery.isNotEmpty,
      onMoreTap: (app) => AppActionsBottomSheet.show(
        context,
        app: app,
        onUninstall: () => _presenter.uninstallApp(app.packageName),
        onLaunch: () => _presenter.launchApp(app.packageName),
        onDetails: () => _presenter.openAppDetails(app.packageName),
        onPlayStore: () => _presenter.openInPlayStore(app.packageName),
        onShortcut: () => _presenter.addShortcut(app.packageName),
      ),
      onLongPress: _presenter.toggleAppSelection,
      onTap: (packageName) {
        if (state.isSelectionMode) {
          _presenter.toggleAppSelection(packageName);
        }
      },
      onIconNeeded: _presenter.loadAppIcon,
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

  void _changeDestination(UninstallerDestination destination) {
    Navigator.pop(context);
    if (_viewState.destination == destination) return;
    _presenter.clearSelection();
    if (destination == UninstallerDestination.recentlyInstalled) {
      _presenter.changeTab(0);
    }
    setState(() {
      _viewState = _viewState.copyWith(destination: destination);
    });
  }

  void _openDrawerPage(Widget page) {
    Navigator.pop(context);
    context.navigatorPush(page);
  }

  Future<bool> _handleBackPress() async {
    final scaffoldState = _scaffoldKey.currentState;
    if (scaffoldState?.isDrawerOpen ?? false) {
      scaffoldState?.closeDrawer();
      return true;
    }

    if (_presenter.currentUiState.isSelectionMode) {
      _presenter.clearSelection();
      return true;
    }

    if (_viewState.isRecentlyInstalled) {
      setState(() {
        _viewState = _viewState.copyWith(
          destination: UninstallerDestination.allApps,
        );
      });
      return true;
    }

    return false;
  }

  Widget _buildFab(UninstallerUiState state) {
    if (state.isSelectionMode || state.isUninstalling) {
      return UninstallFab(
        selectedCount: state.selectedPackages.length,
        isUninstalling: state.isUninstalling,
        uninstallProgress: state.uninstallProgress,
        uninstallTotal: state.uninstallTotal,
        onPressed: _presenter.uninstallSelectedApps,
      );
    }
    return SearchFab(
      hasSearchQuery: state.searchQuery.isNotEmpty,
      onPressed: () => _presenter.updateSearchQuery(' '),
    );
  }
}
