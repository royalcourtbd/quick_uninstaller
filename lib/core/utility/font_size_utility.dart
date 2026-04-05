import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:quick_uninstaller/core/config/app_screen.dart';
import 'package:quick_uninstaller/core/static/constants.dart';
import 'package:quick_uninstaller/shared/model/language_type_enum.dart';

/// Enumeration of all text styles used in the app
enum TextStyleType {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  titleLarge,
  titleMedium,
  titleSmall,
  labelLarge,
  labelMedium,
  labelSmall,
  labelExtraSmall,
  buttonText,
  surahName,
  arabicAyah,
}

/// Font size manager that handles language-specific font sizes
class FontSizeUtility {
  // Private constructor to prevent instantiation
  FontSizeUtility._();

  // Font sizes for English and other languages
  static final Map<TextStyleType, double> _defaultFontSizes = {
    TextStyleType.displayLarge: displayLargeFontSize,
    TextStyleType.displayMedium: displayMediumFontSize,
    TextStyleType.displaySmall: displaySmallFontSize,
    TextStyleType.headlineLarge: headlineLargeFontSize,
    TextStyleType.headlineMedium: headlineMediumFontSize,
    TextStyleType.headlineSmall: headlineSmallFontSize,
    TextStyleType.bodyLarge: bodyLargeFontSize,
    TextStyleType.bodyMedium: bodyMediumFontSize,
    TextStyleType.bodySmall: bodySmallFontSize,
    TextStyleType.titleLarge: titleLargeFontSize,
    TextStyleType.titleMedium: titleMediumFontSize,
    TextStyleType.titleSmall: titleSmallFontSize,
    TextStyleType.labelLarge: labelLargeFontSize,
    TextStyleType.labelMedium: labelMediumFontSize,
    TextStyleType.labelSmall: labelSmallFontSize,
    TextStyleType.labelExtraSmall: labelExtraSmallFontSize,
    TextStyleType.buttonText: buttonTextFontSize,
    TextStyleType.surahName: surahNameFontSize,
    TextStyleType.arabicAyah: arabicAyahFontSize,
  };

  // Font sizes for Bangla
  static final Map<TextStyleType, double> _banglaFontSizes = {
    TextStyleType.displayLarge: 62,
    TextStyleType.displayMedium: 50,
    TextStyleType.displaySmall: 38,
    TextStyleType.headlineLarge: 28,
    TextStyleType.headlineMedium: 22,
    TextStyleType.headlineSmall: 20,
    TextStyleType.bodyLarge: 20,
    TextStyleType.bodyMedium: 18,
    TextStyleType.bodySmall: 16,
    TextStyleType.titleLarge: 150,
    TextStyleType.titleMedium: 18,
    TextStyleType.titleSmall: 16,
    TextStyleType.labelLarge: 20,
    TextStyleType.labelMedium: 18,
    TextStyleType.labelSmall: 16,
    TextStyleType.labelExtraSmall: 14,
    TextStyleType.buttonText: 16,
    TextStyleType.surahName: 32,
    TextStyleType.arabicAyah: 26,
  };
  static final Map<TextStyleType, double> _arabicFontSizes = {
    TextStyleType.displayLarge: 62,
    TextStyleType.displayMedium: 50,
    TextStyleType.displaySmall: 38,
    TextStyleType.headlineLarge: 28,
    TextStyleType.headlineMedium: 22,
    TextStyleType.headlineSmall: 20,
    TextStyleType.bodyLarge: 20,
    TextStyleType.bodyMedium: 18,
    TextStyleType.bodySmall: 16,
    TextStyleType.titleLarge: 50,
    TextStyleType.titleMedium: 18,
    TextStyleType.titleSmall: 16,
    TextStyleType.labelLarge: 20,
    TextStyleType.labelMedium: 18,
    TextStyleType.labelSmall: 16,
    TextStyleType.labelExtraSmall: 14,
    TextStyleType.buttonText: 16,
    TextStyleType.surahName: 32,
    TextStyleType.arabicAyah: 26,
  };

  // Language-specific font size maps
  static final Map<String, Map<TextStyleType, double>> _languageFontSizes = {
    'default': _defaultFontSizes,
    banglaLocaleName: _banglaFontSizes,
    arabicLocaleName: _arabicFontSizes,
    // Add more languages as needed
  };

  /// Get font size for a specific style and language
  static double getFontSize(TextStyleType styleType, BuildContext context) {
    final String currentLanguage = Localizations.localeOf(context).languageCode;

    final String language = currentLanguage == LanguageType.bangla.code
        ? banglaLocaleName
        : currentLanguage == LanguageType.arabic.code
        ? arabicLocaleName
        : 'default';

    // Check if we have specific sizes for this language
    if (_languageFontSizes.containsKey(language)) {
      log('language: $language');
      return _languageFontSizes[language]![styleType] ??
          _defaultFontSizes[styleType]!;
    }

    // Fallback to default sizes
    return _defaultFontSizes[styleType]!;
  }
}

/// Extension for BuildContext to make it easier to access font sizes
extension FontSizeExtension on BuildContext {
  double get displayLargeFontSize =>
      FontSizeUtility.getFontSize(TextStyleType.displayLarge, this);
  double get displayMediumFontSize =>
      FontSizeUtility.getFontSize(TextStyleType.displayMedium, this);
  double get displaySmallFontSize =>
      FontSizeUtility.getFontSize(TextStyleType.displaySmall, this);
  double get headlineLargeFontSize =>
      FontSizeUtility.getFontSize(TextStyleType.headlineLarge, this);
  double get headlineMediumFontSize =>
      FontSizeUtility.getFontSize(TextStyleType.headlineMedium, this);
  double get headlineSmallFontSize =>
      FontSizeUtility.getFontSize(TextStyleType.headlineSmall, this);
  double get bodyLargeFontSize =>
      FontSizeUtility.getFontSize(TextStyleType.bodyLarge, this);
  double get bodyMediumFontSize =>
      FontSizeUtility.getFontSize(TextStyleType.bodyMedium, this);
  double get bodySmallFontSize =>
      FontSizeUtility.getFontSize(TextStyleType.bodySmall, this);
  double get titleLargeFontSize =>
      FontSizeUtility.getFontSize(TextStyleType.titleLarge, this);
  double get titleMediumFontSize =>
      FontSizeUtility.getFontSize(TextStyleType.titleMedium, this);
  double get titleSmallFontSize =>
      FontSizeUtility.getFontSize(TextStyleType.titleSmall, this);
  double get labelLargeFontSize =>
      FontSizeUtility.getFontSize(TextStyleType.labelLarge, this);
  double get labelMediumFontSize =>
      FontSizeUtility.getFontSize(TextStyleType.labelMedium, this);
  double get labelSmallFontSize =>
      FontSizeUtility.getFontSize(TextStyleType.labelSmall, this);
  double get labelExtraSmallFontSize =>
      FontSizeUtility.getFontSize(TextStyleType.labelExtraSmall, this);
  double get buttonTextFontSize =>
      FontSizeUtility.getFontSize(TextStyleType.buttonText, this);
  double get surahNameFontSize =>
      FontSizeUtility.getFontSize(TextStyleType.surahName, this);
  double get arabicAyahFontSize =>
      FontSizeUtility.getFontSize(TextStyleType.arabicAyah, this);
}
