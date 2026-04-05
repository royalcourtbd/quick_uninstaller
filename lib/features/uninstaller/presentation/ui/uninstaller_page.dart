import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/di/service_locator.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';
import 'package:quick_uninstaller/core/widgets/presentable_widget_builder.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/presenter/uninstaller_presenter.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/presenter/uninstaller_ui_state.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/widgets/app_list_tile.dart';

class UninstallerPage extends StatelessWidget {
  UninstallerPage({super.key});

  final UninstallerPresenter _presenter = locate<UninstallerPresenter>();

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
              _buildAppBar(context, state),
              _buildTabBar(context, state),
              Expanded(child: _buildBody(context, state)),
              _buildMemoryBar(context, state),
            ],
          ),
          floatingActionButton: _buildSearchFab(context, state),
        );
      },
    );
  }

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
      return Center(
        child: CircularProgressIndicator(color: context.color.accentColor),
      );
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
              prefixIcon: Icon(Icons.search, color: context.color.subTitleColor),
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
      padding: EdgeInsets.zero,
      itemCount: apps.length,
      itemBuilder: (context, index) {
        return AppListTile(app: apps[index]);
      },
    );
  }

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

  Widget _buildSearchFab(BuildContext context, UninstallerUiState state) {
    if (state.searchQuery.isNotEmpty) return const SizedBox.shrink();
    return FloatingActionButton(
      backgroundColor: context.color.accentColor,
      onPressed: () => _presenter.updateSearchQuery(' '),
      child: Icon(Icons.search, color: context.color.whiteColor),
    );
  }
}
