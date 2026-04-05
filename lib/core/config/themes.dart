import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/config/app_color.dart';
import 'package:quick_uninstaller/core/config/app_theme_color.dart';
import 'package:quick_uninstaller/core/static/font_family.dart';

class AappTheme {
  AappTheme._();

  static ThemeData darkTheme = ThemeData(
    extensions: const [AppThemeColor.dark],
    fontFamily: FontFamily.poppins,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColor.scaffoldBackgroundColor,
    primaryColor: AppColor.primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: AppColor.primaryColor,
      secondary: AppColor.accentOrange,
      surface: AppColor.surfaceColor,
      error: AppColor.errorColor,
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.surfaceColor,
      iconTheme: IconThemeData(color: Colors.white),
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: AppColor.titleColor,
        fontFamily: FontFamily.poppins,
        height: 1.6,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColor.surfaceColor,
      indicatorColor: AppColor.surfaceLightColor,
      height: 80,
      labelTextStyle: WidgetStateTextStyle.resolveWith(
        (states) => TextStyle(
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.normal,
          fontSize: 12,
          color: states.contains(WidgetState.selected)
              ? AppColor.whiteColor
              : AppColor.subTitleColor,
        ),
      ),
    ),
  );
}
