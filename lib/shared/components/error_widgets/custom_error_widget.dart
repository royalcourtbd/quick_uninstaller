import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/config/app_screen.dart';
import 'package:quick_uninstaller/core/static/ui_const.dart';

class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget({super.key, required this.errorDetails});

  final FlutterErrorDetails errorDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 40),
          gapH16,
          Text(
            'Whoops! We hit a snag',
            style: theme.textTheme.titleMedium!.copyWith(
              fontSize: twentyFourPx,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.error,
            ),
          ),
          gapH8,
          Padding(
            padding: padding20,
            child: Text(
              errorDetails.exceptionAsString(),
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
