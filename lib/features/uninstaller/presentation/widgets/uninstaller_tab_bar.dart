import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';

class UninstallerTabBar extends StatelessWidget {
  const UninstallerTabBar({
    super.key,
    required this.userAppCount,
    required this.systemAppCount,
    required this.selectedTabIndex,
    required this.onTabChanged,
  });

  final int userAppCount;
  final int systemAppCount;
  final int selectedTabIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.color.blackColor200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _TabItem(
            icon: Icons.person,
            label: 'USER APPS: $userAppCount',
            isSelected: selectedTabIndex == 0,
            onTap: () => onTabChanged(0),
          ),
          _TabItem(
            icon: Icons.android,
            label: 'SYSTEM APPS: $systemAppCount',
            isSelected: selectedTabIndex == 1,
            onTap: () => onTabChanged(1),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? context.color.accentColor
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? context.color.titleColor
                    : context.color.subTitleColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? context.color.titleColor
                      : context.color.subTitleColor,
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
}
