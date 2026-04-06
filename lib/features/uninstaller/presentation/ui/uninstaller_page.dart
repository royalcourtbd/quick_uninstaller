import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/di/service_locator.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';
import 'package:quick_uninstaller/core/widgets/presentable_widget_builder.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/entities/app_info_entity.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/presenter/uninstaller_presenter.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/presenter/uninstaller_ui_state.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/widgets/app_list_shimmer.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/widgets/app_list_tile.dart';

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
        final UninstallerUiState state = _presenter.currentUiState;
        return Scaffold(
          backgroundColor: context.color.scaffoldBackgroundColor,
          body: Column(
            children: [
              state.isSelectionMode
                  ? _buildSelectionAppBar(context, state)
                  : _buildAppBar(context, state),
              _buildTabBar(context, state),
              Expanded(child: _buildBody(context, state)),
              _buildMemoryBar(context, state),
            ],
          ),
          floatingActionButton: state.isSelectionMode
              ? _buildUninstallFab(context, state)
              : _buildSearchFab(context, state),
        );
      },
    );
  }

  // --- Selection Mode App Bar ---

  Widget _buildSelectionAppBar(
      BuildContext context, UninstallerUiState state) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.close, color: context.color.titleColor),
              onPressed: _presenter.clearSelection,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${state.selectedPackages.length} selected',
                style: TextStyle(
                  color: context.color.titleColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: _presenter.selectAll,
              child: Text(
                'Select All',
                style: TextStyle(
                  color: context.color.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Normal App Bar ---

  Widget _buildAppBar(BuildContext context, UninstallerUiState state) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.delete_sweep, color: context.color.titleColor, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Uninstaller',
                    style: TextStyle(
                      color: context.color.titleColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${state.totalAppCount} APPS',
                    style: TextStyle(
                      color: context.color.subTitleColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.sort, color: context.color.titleColor),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: context.color.titleColor),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, UninstallerUiState state) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.color.blackColor200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _buildTab(
            context: context,
            icon: Icons.person,
            label: 'USER APPS: ${state.filteredUserApps.length}',
            isSelected: state.selectedTabIndex == 0,
            onTap: () => _presenter.changeTab(0),
          ),
          _buildTab(
            context: context,
            icon: Icons.android,
            label: 'SYSTEM APPS: ${state.filteredSystemApps.length}',
            isSelected: state.selectedTabIndex == 1,
            onTap: () => _presenter.changeTab(1),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? context.color.accentColor
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? context.color.titleColor
                    : context.color.subTitleColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? context.color.titleColor
                      : context.color.subTitleColor,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, UninstallerUiState state) {
    if (state.isLoading) {
      return const AppListShimmer();
    }

    if (state.searchQuery.isNotEmpty) {
      return _buildSearchHeader(context, state);
    }

    return _buildAppList(context, state);
  }

  Widget _buildSearchHeader(BuildContext context, UninstallerUiState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            autofocus: true,
            style: TextStyle(color: context.color.titleColor),
            decoration: InputDecoration(
              hintText: 'Search apps...',
              hintStyle: TextStyle(color: context.color.captionColor),
              prefixIcon:
                  Icon(Icons.search, color: context.color.subTitleColor),
              suffixIcon: IconButton(
                icon: Icon(Icons.close, color: context.color.subTitleColor),
                onPressed: () => _presenter.updateSearchQuery(''),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: context.color.cardColor,
            ),
            onChanged: _presenter.updateSearchQuery,
          ),
        ),
        Expanded(child: _buildAppList(context, state)),
      ],
    );
  }

  Widget _buildAppList(BuildContext context, UninstallerUiState state) {
    final apps = state.selectedTabIndex == 0
        ? state.filteredUserApps
        : state.filteredSystemApps;

    if (apps.isEmpty) {
      return Center(
        child: Text(
          state.searchQuery.isNotEmpty ? 'No apps found' : 'No apps',
          style: TextStyle(color: context.color.subTitleColor, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return AppListTile(
          app: app,
          isSelected: state.selectedPackages.contains(app.packageName),
          isSelectionMode: state.isSelectionMode,
          onMoreTap: () => _showUninstallDialog(context, app),
          onLongPress: () => _presenter.toggleAppSelection(app.packageName),
          onTap: () {
            if (state.isSelectionMode) {
              _presenter.toggleAppSelection(app.packageName);
            }
          },
        );
      },
    );
  }

  // --- Uninstall Dialog ---

  void _showUninstallDialog(BuildContext context, AppInfoEntity app) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.color.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.color.captionColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                // App info header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: app.appIcon != null
                              ? Image.memory(app.appIcon!, fit: BoxFit.cover)
                              : Icon(Icons.android,
                                  color: context.color.subTitleColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.appName,
                              style: TextStyle(
                                color: context.color.titleColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              app.formattedSize,
                              style: TextStyle(
                                color: context.color.subTitleColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: context.color.blackColor200, height: 1),
                // Uninstall option
                ListTile(
                  leading: Icon(Icons.delete_outline,
                      color: context.color.errorColor),
                  title: Text(
                    'Uninstall',
                    style: TextStyle(
                      color: context.color.errorColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _presenter.uninstallApp(app.packageName);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Bottom Bar ---

  Widget _buildMemoryBar(BuildContext context, UninstallerUiState state) {
    if (state.totalBytes == 0) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        color: context.color.surfaceColor,
        child: Text(
          state.formattedFreeMemory,
          textAlign: TextAlign.center,
          style: TextStyle(color: context.color.subTitleColor, fontSize: 13),
        ),
      ),
    );
  }

  // --- FABs ---

  Widget _buildUninstallFab(BuildContext context, UninstallerUiState state) {
    return FloatingActionButton.extended(
      backgroundColor: context.color.errorColor,
      onPressed: state.isUninstalling
          ? null
          : () => _presenter.uninstallSelectedApps(),
      icon: state.isUninstalling
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.color.whiteColor,
              ),
            )
          : Icon(Icons.delete, color: context.color.whiteColor),
      label: Text(
        state.isUninstalling
            ? 'Uninstalling...'
            : 'Uninstall (${state.selectedPackages.length})',
        style: TextStyle(
          color: context.color.whiteColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSearchFab(BuildContext context, UninstallerUiState state) {
    if (state.searchQuery.isNotEmpty) return const SizedBox.shrink();
    return FloatingActionButton(
      backgroundColor: context.color.accentColor,
      onPressed: () => _presenter.updateSearchQuery(' '),
      child: Icon(Icons.search, color: context.color.whiteColor),
    );
  }
}
