import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';
import 'package:quick_uninstaller/features/uninstaller/presentation/presenter/uninstaller_ui_state.dart';

class SortBottomSheet extends StatelessWidget {
  const SortBottomSheet({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  final SortType currentSort;
  final ValueChanged<SortType> onSortChanged;

  static void show(
    BuildContext context, {
    required SortType currentSort,
    required ValueChanged<SortType> onSortChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.color.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SortBottomSheet(
        currentSort: currentSort,
        onSortChanged: onSortChanged,
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
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Sort by',
                  style: TextStyle(
                    color: context.color.titleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...SortType.values.map((type) => _SortOption(
                  type: type,
                  isSelected: type == currentSort,
                  onTap: () {
                    Navigator.pop(context);
                    onSortChanged(type);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final SortType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        _iconFor(type),
        color: isSelected
            ? context.color.accentColor
            : context.color.subTitleColor,
        size: 22,
      ),
      title: Text(
        type.label,
        style: TextStyle(
          color: isSelected
              ? context.color.accentColor
              : context.color.titleColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: context.color.accentColor, size: 20)
          : null,
      onTap: onTap,
    );
  }

  IconData _iconFor(SortType type) {
    return switch (type) {
      SortType.nameAsc => Icons.sort_by_alpha,
      SortType.nameDesc => Icons.sort_by_alpha,
      SortType.sizeDesc => Icons.storage,
      SortType.sizeAsc => Icons.storage,
      SortType.dateDesc => Icons.calendar_today,
      SortType.dateAsc => Icons.calendar_today,
    };
  }
}
