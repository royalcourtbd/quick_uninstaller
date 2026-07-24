import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:quick_uninstaller/core/models/device_info_model.dart';
import 'package:quick_uninstaller/core/services/backend_as_a_service.dart';
import 'package:quick_uninstaller/core/services/local_cache_service.dart';
import 'package:quick_uninstaller/core/utility/logger_utility.dart';
import 'package:quick_uninstaller/core/utility/trial_utility.dart';
import 'package:synchronized/synchronized.dart';

class DeviceInfoService {
  DeviceInfoService(this._backendService, this._cacheService);

  final BackendAsAService _backendService;
  final LocalCacheService _cacheService;
  final Lock _initializeLock = Lock();

  bool _isInitialized = false;

  Future<void> initialize() async {
    await _initializeLock.synchronized(() async {
      if (_isInitialized) return;

      await catchFutureOrVoid(() async {
        await _backendService.listenToDeviceToken(
          onTokenFound: _handleTokenFound,
        );
        _isInitialized = true;
      });
    });
  }

  Future<int> syncWatchVideoCount({required int watchVideoCount}) async {
    return await catchAndReturnFuture<int>(() async {
          final token = _cacheService.getData<String>(
            key: CacheKeys.fcmDeviceToken,
          );

          if (token == null || token.trim().isEmpty) {
            await initialize();
            return watchVideoCount;
          }

          return _storeDeviceInfo(
            token: token,
            watchVideoCount: watchVideoCount,
          );
        }) ??
        watchVideoCount;
  }

  Future<void> _handleTokenFound(String token) async {
    await catchFutureOrVoid(() async {
      await _cacheService.saveData<String>(
        key: CacheKeys.fcmDeviceToken,
        value: token,
      );

      final watchVideoCount =
          _cacheService.getData<int>(key: CacheKeys.supportAdWatchCount) ?? 0;
      await _storeDeviceInfo(token: token, watchVideoCount: watchVideoCount);
    });
  }

  Future<int> _storeDeviceInfo({
    required String token,
    required int watchVideoCount,
  }) async {
    if (token.trim().isEmpty) return watchVideoCount;

    return await catchAndReturnFuture<int>(() async {
          final deviceInfo = await _buildDeviceInfo(
            token: token,
            watchVideoCount: watchVideoCount,
          );
          final syncedCount = await _backendService.storeDeviceInfo(deviceInfo);
          if (syncedCount > watchVideoCount) {
            await _cacheService.saveData<int>(
              key: CacheKeys.supportAdWatchCount,
              value: syncedCount,
            );
          }
          return syncedCount;
        }) ??
        watchVideoCount;
  }

  Future<DeviceInfoModel> _buildDeviceInfo({
    required String token,
    required int watchVideoCount,
  }) async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return DeviceInfoModel(
        token: token,
        platform: 'android',
        deviceModel: androidInfo.model,
        deviceId: androidInfo.id,
        brand: androidInfo.brand,
        osVersion: androidInfo.version.release,
        sdkVersion: androidInfo.version.sdkInt,
        isPhysicalDevice: androidInfo.isPhysicalDevice,
        watchVideoCount: watchVideoCount,
      );
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return DeviceInfoModel(
        token: token,
        platform: 'ios',
        deviceModel: iosInfo.model,
        deviceId: iosInfo.identifierForVendor,
        brand: 'Apple',
        osVersion: iosInfo.systemVersion,
        isPhysicalDevice: iosInfo.isPhysicalDevice,
        watchVideoCount: watchVideoCount,
      );
    }

    logDebugStatic(
      'Using generic device metadata for ${Platform.operatingSystem}',
      'DeviceInfoService',
    );
    return DeviceInfoModel(
      token: token,
      platform: Platform.operatingSystem,
      watchVideoCount: watchVideoCount,
    );
  }
}
