import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/entities/app_info_entity.dart';

class AppActionsBottomSheet extends StatelessWidget {
  const AppActionsBottomSheet({
    super.key,
    required this.app,
    required this.onUninstall,
    required this.onLaunch,
    required this.onDetails,
    required this.onPlayStore,
    required this.onShortcut,
  });

  final AppInfoEntity app;
  final VoidCallback onUninstall;
  final VoidCallback onLaunch;
  final VoidCallback onDetails;
  final VoidCallback onPlayStore;
  final VoidCallback onShortcut;

  static void show(
    BuildContext context, {
    required AppInfoEntity app,
    required VoidCallback onUninstall,
    required VoidCallback onLaunch,
    required VoidCallback onDetails,
    required VoidCallback onPlayStore,
    required VoidCallback onShortcut,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.color.surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AppActionsBottomSheet(
        app: app,
        onUninstall: onUninstall,
        onLaunch: onLaunch,
        onDetails: onDetails,
        onPlayStore: onPlayStore,
        onShortcut: onShortcut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
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
            // App header
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
                    child: Text(
                      '${app.appName} ${app.versionName}',
                      style: TextStyle(
                        color: context.color.titleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: context.color.blackColor200, height: 1),
            // Actions
            if (!app.isSystemApp)
              _ActionTile(
                icon: Icons.delete_outline,
                label: 'Uninstall',
                color: context.color.errorColor,
                onTap: () {
                  Navigator.pop(context);
                  onUninstall();
                },
              ),
            _ActionTile(
              icon: Icons.launch,
              label: 'Launch',
              color: context.color.titleColor,
              onTap: () {
                Navigator.pop(context);
                onLaunch();
              },
            ),
            _ActionTile(
              icon: Icons.info_outline,
              label: 'Details',
              color: context.color.titleColor,
              onTap: () {
                Navigator.pop(context);
                onDetails();
              },
            ),
            _ActionTile(
              icon: Icons.shop,
              label: 'Search in Google Play',
              color: context.color.titleColor,
              onTap: () {
                Navigator.pop(context);
                onPlayStore();
              },
            ),
            _ActionTile(
              icon: Icons.add_to_home_screen,
              label: 'Shortcut on Homescreen',
              color: context.color.titleColor,
              onTap: () {
                Navigator.pop(context);
                onShortcut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
