import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';
import 'package:quick_uninstaller/core/utils/date_formatter.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/entities/app_info_entity.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.app,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onMoreTap,
    required this.onLongPress,
    required this.onTap,
  });

  final AppInfoEntity app;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onMoreTap;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? context.color.accentColor.withOpacityPercent(10)
              : context.color.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? context.color.accentColor : Colors.transparent,
            width: .3,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            onLongPress: app.isSystemApp ? null : onLongPress,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // App icon
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.color.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: app.appIcon != null
                          ? Image.memory(app.appIcon!, fit: BoxFit.cover)
                          : Icon(
                              Icons.android,
                              color: context.color.subTitleColor,
                              size: 28,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // App info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.appName,
                          style: TextStyle(
                            color: context.color.titleColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${app.formattedSize}  •  ${app.versionName}',
                          style: TextStyle(
                            color: context.color.subTitleColor,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          getFormattedDate(
                            app.installDate,
                            format: 'EEE, d MMM yyyy',
                          ),
                          style: TextStyle(
                            color: context.color.captionColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // More button (hide in selection mode)
                  if (!isSelectionMode)
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: context.color.subTitleColor,
                        size: 22,
                      ),
                      onPressed: onMoreTap,
                      splashRadius: 20,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
