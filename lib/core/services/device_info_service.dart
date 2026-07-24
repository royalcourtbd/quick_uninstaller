import 'dart:async';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
  DeviceInfoModel? _cachedDeviceInfo;
  Future<int>? _registrationFuture;

  Future<void> initialize() async {
    await _initializeLock.synchronized(() async {
      if (_isInitialized) return;
      _isInitialized = true;

      await catchFutureOrVoid(() async {
        await _backendService.listenToDeviceToken(
          onTokenFound: _handleTokenFound,
        );
      });
    });
  }

  Future<int> registerDevice() {
    return _registrationFuture ??= _registerDevice();
  }

  Future<int> getRegisteredWatchVideoCount() async {
    final registrationFuture = _registrationFuture;
    if (registrationFuture != null) return registrationFuture;

    return _cacheService.getData<int>(key: CacheKeys.supportAdWatchCount) ?? 0;
  }

  Future<int> _registerDevice() {
    final watchVideoCount =
        _cacheService.getData<int>(key: CacheKeys.supportAdWatchCount) ?? 0;
    return _syncWatchVideoCount(
      watchVideoCount: watchVideoCount,
      incrementWatchVideoCount: false,
    );
  }

  Future<int> recordRewardedAdCompleted({
    required int localWatchVideoCount,
  }) async {
    return _syncWatchVideoCount(
      watchVideoCount: localWatchVideoCount,
      incrementWatchVideoCount: true,
    );
  }

  Future<int> _syncWatchVideoCount({
    required int watchVideoCount,
    required bool incrementWatchVideoCount,
  }) async {
    return await catchAndReturnFuture<int>(() async {
          unawaited(initialize());
          final token =
              _cacheService.getData<String>(key: CacheKeys.fcmDeviceToken) ??
              '';

          return _storeDeviceInfo(
            token: token,
            watchVideoCount: watchVideoCount,
            incrementWatchVideoCount: incrementWatchVideoCount,
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
      await _storeDeviceInfo(
        token: token,
        watchVideoCount: watchVideoCount,
        incrementWatchVideoCount: false,
      );
    });
  }

  Future<int> _storeDeviceInfo({
    required String token,
    required int watchVideoCount,
    required bool incrementWatchVideoCount,
  }) async {
    return await catchAndReturnFuture<int>(() async {
          final deviceInfo = await _buildDeviceInfo(
            token: token,
            watchVideoCount: watchVideoCount,
          );
          if (deviceInfo.documentId.isEmpty) return watchVideoCount;

          final syncedCount = await _backendService.storeDeviceInfo(
            deviceInfo,
            incrementWatchVideoCount: incrementWatchVideoCount,
          );
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
    final cachedDeviceInfo = _cachedDeviceInfo;
    if (cachedDeviceInfo != null) {
      return cachedDeviceInfo.copyWith(
        token: token,
        watchVideoCount: watchVideoCount,
      );
    }

    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    late final DeviceInfoModel result;

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      const androidIdPlugin = AndroidId();
      final androidId = await androidIdPlugin.getId();
      result = DeviceInfoModel(
        token: token,
        platform: 'android',
        deviceModel: androidInfo.model,
        deviceId: androidId ?? '',
        legacyDeviceId: androidInfo.id,
        brand: androidInfo.brand,
        manufacturer: androidInfo.manufacturer,
        osVersion: androidInfo.version.release,
        sdkVersion: androidInfo.version.sdkInt,
        isPhysicalDevice: androidInfo.isPhysicalDevice,
        hardware: androidInfo.hardware,
        product: androidInfo.product,
        deviceCodeName: androidInfo.device,
        supportedAbis: androidInfo.supportedAbis,
        appVersion: packageInfo.version,
        appBuildNumber: packageInfo.buildNumber,
        watchVideoCount: watchVideoCount,
      );
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      result = DeviceInfoModel(
        token: token,
        platform: 'ios',
        deviceModel: iosInfo.model,
        deviceId: iosInfo.identifierForVendor ?? token,
        brand: 'Apple',
        manufacturer: 'Apple',
        osVersion: iosInfo.systemVersion,
        isPhysicalDevice: iosInfo.isPhysicalDevice,
        hardware: iosInfo.utsname.machine,
        appVersion: packageInfo.version,
        appBuildNumber: packageInfo.buildNumber,
        watchVideoCount: watchVideoCount,
      );
    } else {
      logDebugStatic(
        'Using generic device metadata for ${Platform.operatingSystem}',
        'DeviceInfoService',
      );
      result = DeviceInfoModel(
        token: token,
        platform: Platform.operatingSystem,
        deviceId: token,
        appVersion: packageInfo.version,
        appBuildNumber: packageInfo.buildNumber,
        watchVideoCount: watchVideoCount,
      );
    }

    _cachedDeviceInfo = result;
    return result;
  }
}
