import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';
import 'package:quick_uninstaller/core/utils/date_formatter.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/entities/app_info_entity.dart';

class AppListTile extends StatefulWidget {
  const AppListTile({
    super.key,
    required this.app,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onMoreTap,
    required this.onLongPress,
    required this.onTap,
    required this.onIconNeeded,
  });

  final AppInfoEntity app;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onMoreTap;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final VoidCallback onIconNeeded;

  @override
  State<AppListTile> createState() => _AppListTileState();
}

class _AppListTileState extends State<AppListTile> {
  @override
  void initState() {
    super.initState();
    _requestIconIfNeeded();
  }

  @override
  void didUpdateWidget(covariant AppListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.app.packageName != widget.app.packageName ||
        widget.app.appIcon == null) {
      _requestIconIfNeeded();
    }
  }

  void _requestIconIfNeeded() {
    if (widget.app.appIcon != null) return;
    widget.onIconNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? context.color.accentColor.withOpacityPercent(10)
              : context.color.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isSelected
                ? context.color.accentColor
                : Colors.transparent,
            width: .3,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onTap,
            onLongPress: widget.app.isSystemApp ? null : widget.onLongPress,
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
                      child: widget.app.appIcon != null
                          ? Image.memory(widget.app.appIcon!, fit: BoxFit.cover)
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
                          widget.app.appName,
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
                          '${widget.app.formattedSize}  •  ${widget.app.versionName}',
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
                            widget.app.installDate,
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
                  if (!widget.isSelectionMode)
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: context.color.subTitleColor,
                        size: 22,
                      ),
                      onPressed: widget.onMoreTap,
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
