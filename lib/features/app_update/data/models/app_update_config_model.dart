import 'package:quick_uninstaller/features/app_update/domain/entities/app_update_config_entity.dart';

class AppUpdateConfigModel extends AppUpdateConfigEntity {
  const AppUpdateConfigModel({
    required super.changeLogs,
    required super.latestVersion,
    required super.minSupportedVersion,
    required super.storeUrl,
    required super.title,
  });

  factory AppUpdateConfigModel.fromJson(Map<String, dynamic> json) {
    return AppUpdateConfigModel(
      changeLogs: _readString(json, 'change_logs'),
      latestVersion: _readString(json, 'latest_version'),
      minSupportedVersion: _readString(json, 'min_supported_version'),
      storeUrl: _readString(json, 'store_url'),
      title: _readString(json, 'title', fallback: 'A new update is available'),
    );
  }

  static String _readString(
    Map<String, dynamic> json,
    String key, {
    String fallback = '',
  }) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) return fallback;
    return value.trim();
  }
}
