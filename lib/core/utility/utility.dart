import 'package:flutter/material.dart';
import 'utility_export.dart';
import 'package:responsive_sizer/responsive_sizer.dart' as rs;

bool get isMobile => rs.Device.screenType == rs.ScreenType.mobile;

/// Checks the internet connection asynchronously.
///
///
/// Example usage:
///
/// ```dart
/// bool isConnected = await checkInternetConnection();
/// if (isConnected) {
///   logDebug('Internet connection is available.');
/// } else {
///   logDebug('No internet connection.');
/// }
/// ```
///
/// Rationale:
///
/// The `checkInternetConnection` function provides a straightforward way to determine
/// the availability of an internet connection within your Flutter application. By performing
/// a lookup for a well-known URL, it checks if the device can successfully resolve the URL's
/// IP address, indicating an active internet connection.
///

// /// Returns the file path for the given [fileName] in the specified [directoryPath].
// ///
// /// If the file does not exist, it returns an empty string.
// Future<bool> fileExists(
//     {required String directoryPath, required String fileName}) async {
//   final String filePath = '$directoryPath/$fileName';
//   final bool isFileExists = await File(filePath).exists();
//   return isFileExists;
// }

// /// get application directory path
Future<String> getApplicationDirectoryPath() async {
  final Directory directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

String get suitableAppStoreUrl =>
    Platform.isAndroid ? playStoreUrl : appStoreUrl;

void closeKeyboard() => FocusManager.instance.primaryFocus?.unfocus();
// Future<void> disposeKeyboard(
//     BuildContext context, TextEditingController editingController) async {
//   editingController.clear();
//   KeyboardService.dismiss(context: context);
// }

Null Function(Object _)? doNothing(_) => null;

// Future<String> getDatabaseFilePath(String fileName) async {
//   final directoryPath = await getApplicationDirectoryPath();
//   return join(directoryPath, fileName);
// }

/// this function will check the fileName
/// if fileName mached with the file then it will return true else false
bool isNonDefaultTafseer(String fileName) {
  return [
    "bn_fmazid",
    "bn_kathir",
    "bn_tafsir_kathir_mujibor",
  ].contains(fileName);
}

// Future<void> updateTime({
//   required BuildContext context,
//   required String timeType,
//   required SettingsPresenter settingsPresenter,
// }) async {
//   final ThemeData theme = context.theme;
//   final TimeOfDay? newTime = await showTimePicker(
//     context: context,
//     initialEntryMode: TimePickerEntryMode.dialOnly,
//     initialTime: (timeType == 'startTime')
//         ? settingsPresenter.currentUiState.startTime
//         : settingsPresenter.currentUiState.endTime,
//     builder: (BuildContext context, Widget? child) {
//       return MediaQuery(
//         data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
//         child: Theme(
//           data: context.theme.copyWith(
//             timePickerTheme: TimePickerThemeData(
//               backgroundColor: theme.scaffoldBackgroundColor,
//               dialHandColor: theme.colorScheme.primary,
//               dialTextColor: WidgetStateColor.resolveWith((state) {
//                 if (state.contains(WidgetState.selected)) {
//                   return Colors.white;
//                 }
//                 return theme.textTheme.bodyMedium!.color!;
//               }),
//               dayPeriodColor: theme.colorScheme.primary,
//               hourMinuteColor: WidgetStateColor.resolveWith((state) {
//                 if (state.contains(WidgetState.selected)) {
//                   return theme.primaryColor;
//                 }
//                 return theme.cardColor;
//               }),
//               hourMinuteTextColor: WidgetStateColor.resolveWith((state) {
//                 if (state.contains(WidgetState.selected)) {
//                   return Colors.white;
//                 }
//                 return theme.textTheme.bodyMedium!.color!;
//               }),
//               dayPeriodTextColor: WidgetStateColor.resolveWith((state) {
//                 if (state.contains(WidgetState.selected)) {
//                   return Colors.white;
//                 }
//                 return theme.textTheme.bodyMedium!.color!;
//               }),
//               shape: RoundedRectangleBorder(
//                 borderRadius: radius10,
//               ),
//             ),
//           ),
//           child: child!,
//         ),
//       );
//     },
//   );

//   if (newTime != null) {
//     if (timeType == 'startTime') {
//       await settingsPresenter.updateSettings(startTime: newTime);
//     } else {
//       await settingsPresenter.updateSettings(endTime: newTime);
//     }
//   }
// }
