import 'dart:async';

import 'package:flutter/services.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/entities/app_info_entity.dart';

class UninstallerLocalDataSource {
  static const MethodChannel _channel = MethodChannel(
    'com.amatullah.quickuninstaller/apps',
  );

  final StreamController<String> _packageRemovedController =
      StreamController<String>.broadcast();

  UninstallerLocalDataSource() {
    _channel.setMethodCallHandler(_handleNativeMethodCall);
  }

  Stream<String> get packageRemovedStream => _packageRemovedController.stream;

  Future<void> _handleNativeMethodCall(MethodCall call) async {
    if (call.method != 'packageRemoved') return;

    final arguments = call.arguments;
    if (arguments is! Map) return;

    final packageName = arguments['packageName'];
    if (packageName is String && packageName.isNotEmpty) {
      _packageRemovedController.add(packageName);
    }
  }

  Future<List<AppInfoEntity>> getInstalledApps({
    required String appType,
  }) async {
    final List<dynamic> result = await _channel.invokeMethod(
      'getInstalledAppsMetadata',
      {'appType': appType},
    );

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
        appIcon: _bytesFromPlatformValue(map['appIcon']),
      );
    }).toList();
  }

  Future<Uint8List?> getAppIcon(String packageName) async {
    final result = await _channel.invokeMethod<dynamic>('getAppIcon', {
      'packageName': packageName,
    });
    return _bytesFromPlatformValue(result);
  }

  Future<Map<String, int>> getMemoryInfo() async {
    final Map<dynamic, dynamic> result = await _channel.invokeMethod(
      'getMemoryInfo',
    );
    return {
      'totalBytes': (result['totalBytes'] as num).toInt(),
      'freeBytes': (result['freeBytes'] as num).toInt(),
    };
  }

  Future<bool> launchApp(String packageName) async {
    final result = await _channel.invokeMethod<bool>('launchApp', {
      'packageName': packageName,
    });
    return result ?? false;
  }

  Future<bool> openAppDetails(String packageName) async {
    final result = await _channel.invokeMethod<bool>('openAppDetails', {
      'packageName': packageName,
    });
    return result ?? false;
  }

  Future<bool> openInPlayStore(String packageName) async {
    final result = await _channel.invokeMethod<bool>('openInPlayStore', {
      'packageName': packageName,
    });
    return result ?? false;
  }

  Future<bool> addShortcut(String packageName) async {
    final result = await _channel.invokeMethod<bool>('addShortcut', {
      'packageName': packageName,
    });
    return result ?? false;
  }

  Future<bool> uninstallApp(String packageName) async {
    final result = await _channel.invokeMethod<bool>('uninstallApp', {
      'packageName': packageName,
    });
    return result ?? false;
  }

  Future<bool> isAppInstalled(String packageName) async {
    final result = await _channel.invokeMethod<bool>('isAppInstalled', {
      'packageName': packageName,
    });
    return result ?? false;
  }

  Uint8List? _bytesFromPlatformValue(dynamic value) {
    if (value == null) return null;
    if (value is Uint8List) return value;
    if (value is List) return Uint8List.fromList(List<int>.from(value));
    return null;
  }
}
