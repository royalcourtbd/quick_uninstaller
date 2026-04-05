import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:quick_uninstaller/core/config/app_theme_color.dart';
import 'package:quick_uninstaller/core/utility/logger_utility.dart';

extension ContextExtensions on BuildContext {
  Future<T?> navigatorPush<T>(Widget page) async {
    try {
      if (!mounted) return null;
      final CupertinoPageRoute<T> route = CupertinoPageRoute<T>(
        builder: (context) => page,
      );
      return Navigator.push<T>(this, route);
    } catch (e) {
      logError('Failed to navigate to ${e.runtimeType} -> $e');
      return null;
    }
  }

  Future<T?> navigatorPushReplacement<T>(Widget page) async {
    try {
      if (!mounted) return null;
      final CupertinoPageRoute<T> route = CupertinoPageRoute<T>(
        builder: (context) => page,
      );
      return Navigator.pushReplacement(this, route);
    } catch (e) {
      logError('Failed to navigate to ${e.runtimeType} -> $e');
      return null;
    }
  }

  Future<T?> showBottomSheetLegacy<T>(Widget bottomSheet) async {
    return Get.bottomSheet<T>(
      bottomSheet,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );
  }

  Future<T?> showBottomSheet<T>(
    Widget bottomSheet,
    BuildContext context,
  ) async {
    if (!mounted) return null;
    final T? result = await showModalBottomSheet<T>(
      context: context,
      builder: (context) => bottomSheet,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );
    return result;
  }

  void navigatorPop<T>({T? result}) {
    if (!mounted) return;
    Navigator.pop(this, result);
  }
}

/// Helper extension for convenient theme access from BuildContext.
///
/// Usage examples:
/// ```dart
/// // Access custom colors
/// Container(color: context.color.primary)
///
/// // Access text themes
/// Text('Hello', style: context.text.headlineLarge)
///
/// // Check dark mode
/// if (context.isDarkMode) { ... }
/// ```
extension ThemeContextExtension on BuildContext {
  AppThemeColor get color {
    return Theme.of(this).extension<AppThemeColor>()!;
  }

  TextTheme get text {
    return Theme.of(this).textTheme;
  }

  bool get isDarkMode {
    return Theme.of(this).brightness == Brightness.dark;
  }
}

/// Extension on Color that adds utility methods for color manipulation.
///
/// Usage examples:
/// ```dart
/// Color semiTransparent = Colors.blue.withOpacityPercent(50);
/// Container(color: Colors.red.withOpacityPercent(25))
/// ```
extension ColorExtensions on Color {
  /// Set opacity using percentage (0-100)
  Color withOpacityPercent(int percentage) {
    assert(percentage >= 0 && percentage <= 100);
    return withValues(alpha: percentage / 100.0);
  }
}

/// Extension on nullable int for timestamp to DateTime conversion.
///
/// Usage examples:
/// ```dart
/// int? timestamp = 1640995200000;
/// DateTime date = timestamp.fromTimestampToDateTime;
///
/// // Returns current time if null
/// int? nullValue = null;
/// DateTime now = nullValue.fromTimestampToDateTime;
/// ```

extension IntDateExtension on int? {
  DateTime get fromTimestampToDateTime {
    if (this == null) return DateTime.now();
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(this!);
    return date;
  }
}

/// Extension on DateTime for easy timestamp conversion.
///
/// Usage: `DateTime.now().toTimestamp` returns milliseconds since epoch.
extension DateTimeExtension on DateTime {
  /// Converts DateTime to millisecond timestamp.
  int get toTimestamp => millisecondsSinceEpoch;
}
