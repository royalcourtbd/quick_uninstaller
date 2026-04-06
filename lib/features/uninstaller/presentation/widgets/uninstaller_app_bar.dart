import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';

class UninstallerAppBar extends StatelessWidget {
  const UninstallerAppBar({
    super.key,
    required this.totalAppCount,
    required this.onSortTap,
    required this.onRefreshTap,
  });

  final int totalAppCount;
  final VoidCallback onSortTap;
  final VoidCallback onRefreshTap;

  @override
  Widget build(BuildContext context) {
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
                    '$totalAppCount APPS',
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
              onPressed: onSortTap,
            ),
            IconButton(
              icon: Icon(Icons.refresh, color: context.color.titleColor),
              onPressed: onRefreshTap,
            ),
          ],
        ),
      ),
    );
  }
}
