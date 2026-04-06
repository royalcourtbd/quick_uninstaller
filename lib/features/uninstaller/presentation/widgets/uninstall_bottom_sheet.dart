import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/entities/app_info_entity.dart';

class UninstallBottomSheet extends StatelessWidget {
  const UninstallBottomSheet({
    super.key,
    required this.app,
    required this.onUninstall,
  });

  final AppInfoEntity app;
  final VoidCallback onUninstall;

  static void show(
    BuildContext context, {
    required AppInfoEntity app,
    required VoidCallback onUninstall,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.color.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => UninstallBottomSheet(
        app: app,
        onUninstall: onUninstall,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.color.captionColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
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
                          : Icon(
                              Icons.android,
                              color: context.color.subTitleColor,
                            ),
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
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: context.color.errorColor,
              ),
              title: Text(
                'Uninstall',
                style: TextStyle(
                  color: context.color.errorColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onUninstall();
              },
            ),
          ],
        ),
      ),
    );
  }
}
