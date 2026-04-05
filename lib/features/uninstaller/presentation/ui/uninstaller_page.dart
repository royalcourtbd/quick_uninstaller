import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/di/service_locator.dart';
import 'package:quick_uninstaller/core/widgets/presentable_widget_builder.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/presenter/uninstaller_presenter.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/presenter/uninstaller_ui_state.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/widgets/app_list_tile.dart';

class UninstallerPage extends StatelessWidget {
  UninstallerPage({super.key});

  final UninstallerPresenter _presenter = locate<UninstallerPresenter>();

  static const Color _primaryGreen = Color(0xFF4CAF50);
  static const Color _darkGreen = Color(0xFF388E3C);

  @override
  Widget build(BuildContext context) {
    return PresentableWidgetBuilder(
      presenter: _presenter,
      builder: () {
        final UninstallerUiState state = _presenter.currentUiState;
        return Scaffold(
          backgroundColor: _primaryGreen,
          body: Column(
            children: [
              _buildAppBar(state),
              _buildTabBar(state),
              Expanded(child: _buildBody(state)),
              _buildMemoryBar(state),
            ],
          ),
          floatingActionButton: _buildSearchFab(state),
        );
      },
    );
  }

  Widget _buildAppBar(UninstallerUiState state) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.delete_sweep, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Uninstaller',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${state.totalAppCount} APPS',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.sort, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(UninstallerUiState state) {
    return Row(
      children: [
        _buildTab(
          icon: Icons.person,
          label: 'USER APPS: ${state.filteredUserApps.length}',
          isSelected: state.selectedTabIndex == 0,
          onTap: () => _presenter.changeTab(0),
        ),
        _buildTab(
          icon: Icons.android,
          label: 'SYSTEM APPS: ${state.filteredSystemApps.length}',
          isSelected: state.selectedTabIndex == 1,
          onTap: () => _presenter.changeTab(1),
        ),
      ],
    );
  }

  Widget _buildTab({
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
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: isSelected ? 1.0 : 0.7),
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

  Widget _buildBody(UninstallerUiState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (state.searchQuery.isNotEmpty) {
      return _buildSearchHeader(state);
    }

    return _buildAppList(state);
  }

  Widget _buildSearchHeader(UninstallerUiState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search apps...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => _presenter.updateSearchQuery(''),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.2),
            ),
            onChanged: _presenter.updateSearchQuery,
          ),
        ),
        Expanded(child: _buildAppList(state)),
      ],
    );
  }

  Widget _buildAppList(UninstallerUiState state) {
    final apps = state.selectedTabIndex == 0
        ? state.filteredUserApps
        : state.filteredSystemApps;

    if (apps.isEmpty) {
      return Center(
        child: Text(
          state.searchQuery.isNotEmpty ? 'No apps found' : 'No apps',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 16,
          ),
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

  Widget _buildMemoryBar(UninstallerUiState state) {
    if (state.totalBytes == 0) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        color: _darkGreen,
        child: Text(
          state.formattedFreeMemory,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildSearchFab(UninstallerUiState state) {
    if (state.searchQuery.isNotEmpty) return const SizedBox.shrink();
    return FloatingActionButton(
      backgroundColor: Colors.orange,
      onPressed: () => _presenter.updateSearchQuery(' '),
      child: const Icon(Icons.search, color: Colors.white),
    );
  }
}
