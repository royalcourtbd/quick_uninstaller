import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/utility/extensions.dart';

class UninstallFab extends StatelessWidget {
  const UninstallFab({
    super.key,
    required this.selectedCount,
    required this.isUninstalling,
    required this.uninstallProgress,
    required this.uninstallTotal,
    required this.onPressed,
  });

  final int selectedCount;
  final bool isUninstalling;
  final int uninstallProgress;
  final int uninstallTotal;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: context.color.errorColor,
      onPressed: isUninstalling ? null : onPressed,
      icon: isUninstalling
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.color.whiteColor,
              ),
            )
          : Icon(Icons.delete, color: context.color.whiteColor),
      label: Text(
        isUninstalling
            ? 'Uninstalling ($uninstallProgress/$uninstallTotal)...'
            : 'Uninstall ($selectedCount)',
        style: TextStyle(
          color: context.color.whiteColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
