import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';

class SelectionAppBar extends StatelessWidget {
  const SelectionAppBar({
    super.key,
    required this.selectedCount,
    required this.onClose,
    required this.onSelectAll,
  });

  final int selectedCount;
  final VoidCallback onClose;
  final VoidCallback onSelectAll;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.close, color: context.color.titleColor),
              onPressed: onClose,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$selectedCount selected',
                style: TextStyle(
                  color: context.color.titleColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: onSelectAll,
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
}
