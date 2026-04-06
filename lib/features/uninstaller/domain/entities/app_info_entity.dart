import 'dart:typed_data';

import 'package:quick_uninstaller/core/base/base_export.dart';

class AppInfoEntity extends BaseEntity {
  const AppInfoEntity({
    required this.packageName,
    required this.appName,
    required this.versionName,
    required this.appSize,
    required this.installDate,
    required this.isSystemApp,
    this.appIcon,
  });

  final String packageName;
  final String appName;
  final String versionName;
  final int appSize;
  final DateTime installDate;
  final bool isSystemApp;
  final Uint8List? appIcon;

  String get formattedSize {
    if (appSize < 1024) return '$appSize B';
    if (appSize < 1024 * 1024) {
      return '${(appSize / 1024).toStringAsFixed(1)} kB';
    }
    if (appSize < 1024 * 1024 * 1024) {
      return '${(appSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(appSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  AppInfoEntity copyWith({Uint8List? appIcon}) {
    return AppInfoEntity(
      packageName: packageName,
      appName: appName,
      versionName: versionName,
      appSize: appSize,
      installDate: installDate,
      isSystemApp: isSystemApp,
      appIcon: appIcon ?? this.appIcon,
    );
  }

  @override
  List<Object?> get props => [packageName];
}
