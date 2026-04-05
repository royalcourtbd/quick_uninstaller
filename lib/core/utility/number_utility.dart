// Utility extension for converting numbers to Duration
extension DurationExtensions on num {
  Duration get inMilliseconds => Duration(milliseconds: round());

  Duration get inSeconds => Duration(seconds: round());

  Duration get inMinutes =>
      Duration(seconds: (this * Duration.secondsPerMinute).round());

  Duration get inHours =>
      Duration(minutes: (this * Duration.minutesPerHour).round());

  Duration get inDays => Duration(hours: (this * Duration.hoursPerDay).round());
}

// Number validation functions
bool isEnglishNumber({required String text}) {
  try {
    final RegExp numericRegex = RegExp(r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$');
    return numericRegex.hasMatch(text);
  } catch (e) {
    return false;
  }
}

bool isBanglaNumber({required String text}) {
  try {
    final RegExp numericRegex = RegExp(r'^[০-৯]+$');
    return numericRegex.hasMatch(text);
  } catch (e) {
    return false;
  }
}

// Additional utility functions
String convertBanglaToEnglish(String banglaNumber) {
  const Map<String, String> banglaToEnglish = {
    '০': '0',
    '১': '1',
    '২': '2',
    '৩': '3',
    '৪': '4',
    '৫': '5',
    '৬': '6',
    '৭': '7',
    '৮': '8',
    '৯': '9',
  };

  String result = banglaNumber;
  banglaToEnglish.forEach((bangla, english) {
    result = result.replaceAll(bangla, english);
  });
  return result;
}

String convertEnglishToBangla(String englishNumber) {
  const Map<String, String> englishToBangla = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };

  String result = englishNumber;
  englishToBangla.forEach((english, bangla) {
    result = result.replaceAll(english, bangla);
  });
  return result;
}
