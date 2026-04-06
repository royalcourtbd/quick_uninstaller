import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/entities/app_info_entity.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/widgets/app_list_tile.dart';

class AppListView extends StatelessWidget {
  const AppListView({
    super.key,
    required this.apps,
    required this.selectedPackages,
    required this.isSelectionMode,
    required this.hasSearchQuery,
    required this.onMoreTap,
    required this.onLongPress,
    required this.onTap,
  });

  final List<AppInfoEntity> apps;
  final Set<String> selectedPackages;
  final bool isSelectionMode;
  final bool hasSearchQuery;
  final void Function(AppInfoEntity app) onMoreTap;
  final void Function(String packageName) onLongPress;
  final void Function(String packageName) onTap;

  @override
  Widget build(BuildContext context) {
    if (apps.isEmpty) {
      return Center(
        child: Text(
          hasSearchQuery ? 'No apps found' : 'No apps',
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
          isSelected: selectedPackages.contains(app.packageName),
          isSelectionMode: isSelectionMode,
          onMoreTap: () => onMoreTap(app),
          onLongPress: () => onLongPress(app.packageName),
          onTap: () => onTap(app.packageName),
        );
      },
    );
  }
}
