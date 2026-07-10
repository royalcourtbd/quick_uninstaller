import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';

class UninstallerAppBar extends StatelessWidget {
  const UninstallerAppBar({
    super.key,
    required this.totalAppCount,
    required this.onSortTap,
    required this.onRefreshTap,
    required this.onMenuTap,
    this.title = 'Uninstaller',
    this.countLabel = 'APPS',
    this.showSort = true,
  });

  final int totalAppCount;
  final VoidCallback onSortTap;
  final VoidCallback onRefreshTap;
  final VoidCallback onMenuTap;
  final String title;
  final String countLabel;
  final bool showSort;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            IconButton(
              padding: const EdgeInsets.all(4),
              icon: const _DrawerBrandIcon(),
              onPressed: onMenuTap,
              tooltip: 'Open navigation menu',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: context.color.titleColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$totalAppCount $countLabel',
                    style: TextStyle(
                      color: context.color.subTitleColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (showSort)
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

class _DrawerBrandIcon extends StatelessWidget {
  const _DrawerBrandIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.color.cardColor,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: context.color.accentColor.withOpacityPercent(45),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Transform.scale(
          scale: 1.7,
          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
        ),
      ),
    );
  }
}
