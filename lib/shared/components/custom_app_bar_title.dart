import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/config/app_screen.dart';

class CustomAppBarTitle extends StatelessWidget {
  const CustomAppBarTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.bodyMedium!.copyWith(
        fontSize: eighteenPx,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
