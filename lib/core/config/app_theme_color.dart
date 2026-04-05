import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/config/app_color.dart';

class AppThemeColor extends ThemeExtension<AppThemeColor> {
  final Color scaffoldBackgroundColor;
  final Color primaryColor;
  final Color whiteColor;
  final Color backgroundColor;
  final Color titleColor;
  final Color subTitleColor;
  final Color bodyColor;
  final Color captionColor;
  final Color placeHolderColor;
  final Color disableColor;
  final Color errorColor;
  final Color successColor;
  final Color warningColor;
  final Color buttonBgColor;
  final Color buttonColor;
  final Color accentColor;
  final Color cardColor;
  final Color surfaceColor;

  // Neutral shades (backward compat with context.color.blackColorXXX)
  final Color blackColor50;
  final Color blackColor100;
  final Color blackColor200;
  final Color blackColor300;

  // Primary shades (backward compat with context.color.primaryColorXXX)
  final Color primaryColor50;
  final Color primaryColor900;

  const AppThemeColor({
    required this.scaffoldBackgroundColor,
    required this.primaryColor,
    required this.whiteColor,
    required this.backgroundColor,
    required this.titleColor,
    required this.subTitleColor,
    required this.bodyColor,
    required this.captionColor,
    required this.placeHolderColor,
    required this.disableColor,
    required this.errorColor,
    required this.successColor,
    required this.warningColor,
    required this.buttonBgColor,
    required this.buttonColor,
    required this.accentColor,
    required this.cardColor,
    required this.surfaceColor,
    required this.blackColor50,
    required this.blackColor100,
    required this.blackColor200,
    required this.blackColor300,
    required this.primaryColor50,
    required this.primaryColor900,
  });

  @override
  AppThemeColor copyWith({
    Color? scaffoldBackgroundColor,
    Color? primaryColor,
    Color? whiteColor,
    Color? backgroundColor,
    Color? titleColor,
    Color? subTitleColor,
    Color? bodyColor,
    Color? captionColor,
    Color? placeHolderColor,
    Color? disableColor,
    Color? errorColor,
    Color? successColor,
    Color? warningColor,
    Color? buttonBgColor,
    Color? buttonColor,
    Color? accentColor,
    Color? cardColor,
    Color? surfaceColor,
    Color? blackColor50,
    Color? blackColor100,
    Color? blackColor200,
    Color? blackColor300,
    Color? primaryColor50,
    Color? primaryColor900,
  }) {
    return AppThemeColor(
      scaffoldBackgroundColor:
          scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
      primaryColor: primaryColor ?? this.primaryColor,
      whiteColor: whiteColor ?? this.whiteColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      titleColor: titleColor ?? this.titleColor,
      subTitleColor: subTitleColor ?? this.subTitleColor,
      bodyColor: bodyColor ?? this.bodyColor,
      captionColor: captionColor ?? this.captionColor,
      placeHolderColor: placeHolderColor ?? this.placeHolderColor,
      disableColor: disableColor ?? this.disableColor,
      errorColor: errorColor ?? this.errorColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      buttonBgColor: buttonBgColor ?? this.buttonBgColor,
      buttonColor: buttonColor ?? this.buttonColor,
      accentColor: accentColor ?? this.accentColor,
      cardColor: cardColor ?? this.cardColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      blackColor50: blackColor50 ?? this.blackColor50,
      blackColor100: blackColor100 ?? this.blackColor100,
      blackColor200: blackColor200 ?? this.blackColor200,
      blackColor300: blackColor300 ?? this.blackColor300,
      primaryColor50: primaryColor50 ?? this.primaryColor50,
      primaryColor900: primaryColor900 ?? this.primaryColor900,
    );
  }

  @override
  ThemeExtension<AppThemeColor> lerp(
    ThemeExtension<AppThemeColor>? other,
    double t,
  ) {
    if (other is! AppThemeColor) return this;
    return AppThemeColor(
      scaffoldBackgroundColor: Color.lerp(
          scaffoldBackgroundColor, other.scaffoldBackgroundColor, t)!,
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      whiteColor: Color.lerp(whiteColor, other.whiteColor, t)!,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      titleColor: Color.lerp(titleColor, other.titleColor, t)!,
      subTitleColor: Color.lerp(subTitleColor, other.subTitleColor, t)!,
      bodyColor: Color.lerp(bodyColor, other.bodyColor, t)!,
      captionColor: Color.lerp(captionColor, other.captionColor, t)!,
      placeHolderColor:
          Color.lerp(placeHolderColor, other.placeHolderColor, t)!,
      disableColor: Color.lerp(disableColor, other.disableColor, t)!,
      errorColor: Color.lerp(errorColor, other.errorColor, t)!,
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      buttonBgColor: Color.lerp(buttonBgColor, other.buttonBgColor, t)!,
      buttonColor: Color.lerp(buttonColor, other.buttonColor, t)!,
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
      cardColor: Color.lerp(cardColor, other.cardColor, t)!,
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t)!,
      blackColor50: Color.lerp(blackColor50, other.blackColor50, t)!,
      blackColor100: Color.lerp(blackColor100, other.blackColor100, t)!,
      blackColor200: Color.lerp(blackColor200, other.blackColor200, t)!,
      blackColor300: Color.lerp(blackColor300, other.blackColor300, t)!,
      primaryColor50: Color.lerp(primaryColor50, other.primaryColor50, t)!,
      primaryColor900: Color.lerp(primaryColor900, other.primaryColor900, t)!,
    );
  }

  static const dark = AppThemeColor(
    scaffoldBackgroundColor: AppColor.scaffoldBackgroundColor,
    primaryColor: AppColor.primaryColor,
    whiteColor: AppColor.whiteColor,
    backgroundColor: AppColor.backgroundColor,
    titleColor: AppColor.titleColor,
    subTitleColor: AppColor.subTitleColor,
    bodyColor: AppColor.bodyColor,
    captionColor: AppColor.captionColor,
    placeHolderColor: AppColor.placeHolderColor,
    disableColor: AppColor.disableColor,
    errorColor: AppColor.errorColor,
    successColor: AppColor.successColor,
    warningColor: AppColor.warningColor,
    buttonBgColor: AppColor.buttonBgColor,
    buttonColor: AppColor.buttonColor,
    accentColor: AppColor.accentOrange,
    cardColor: AppColor.cardColor,
    surfaceColor: AppColor.surfaceColor,
    blackColor50: AppColor.neutralColor50,
    blackColor100: AppColor.neutralColor100,
    blackColor200: AppColor.neutralColor200,
    blackColor300: AppColor.neutralColor300,
    primaryColor50: AppColor.surfaceLightColor,
    primaryColor900: AppColor.accentOrange,
  );
}
