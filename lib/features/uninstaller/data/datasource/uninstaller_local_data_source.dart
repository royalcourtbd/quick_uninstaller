import 'package:flutter/services.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/entities/app_info_entity.dart';

class UninstallerLocalDataSource {
  static const MethodChannel _channel =
      MethodChannel('com.amatullah.quickuninstaller/apps');

  Future<List<AppInfoEntity>> getInstalledApps() async {
    final List<dynamic> result = await _channel.invokeMethod('getInstalledApps');

    return result.map((app) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(app as Map);
      return AppInfoEntity(
        packageName: map['packageName'] as String,
        appName: map['appName'] as String,
        versionName: map['versionName'] as String,
        appSize: (map['appSize'] as num).toInt(),
        installDate: DateTime.fromMillisecondsSinceEpoch(
          (map['installDate'] as num).toInt(),
        ),
        isSystemApp: map['isSystemApp'] as bool,
        appIcon: map['appIcon'] != null
            ? Uint8List.fromList(List<int>.from(map['appIcon'] as List))
            : null,
      );
    }).toList();
  }

  Future<Map<String, int>> getMemoryInfo() async {
    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('getMemoryInfo');
    return {
      'totalBytes': (result['totalBytes'] as num).toInt(),
      'freeBytes': (result['freeBytes'] as num).toInt(),
    };
  }

  Future<bool> launchApp(String packageName) async {
    final result = await _channel.invokeMethod<bool>(
      'launchApp',
      {'packageName': packageName},
    );
    return result ?? false;
  }

  Future<bool> openAppDetails(String packageName) async {
    final result = await _channel.invokeMethod<bool>(
      'openAppDetails',
      {'packageName': packageName},
    );
    return result ?? false;
  }

  Future<bool> openInPlayStore(String packageName) async {
    final result = await _channel.invokeMethod<bool>(
      'openInPlayStore',
      {'packageName': packageName},
    );
    return result ?? false;
  }

  Future<bool> addShortcut(String packageName) async {
    final result = await _channel.invokeMethod<bool>(
      'addShortcut',
      {'packageName': packageName},
    );
    return result ?? false;
  }

  Future<bool> uninstallApp(String packageName) async {
    final result = await _channel.invokeMethod<bool>(
      'uninstallApp',
      {'packageName': packageName},
    );
    return result ?? false;
  }

  Future<bool> isAppInstalled(String packageName) async {
    final result = await _channel.invokeMethod<bool>(
      'isAppInstalled',
      {'packageName': packageName},
    );
    return result ?? false;
  }
}
