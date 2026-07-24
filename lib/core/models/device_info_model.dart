class DeviceInfoModel {
  const DeviceInfoModel({
    required this.token,
    required this.platform,
    required this.watchVideoCount,
    this.deviceModel,
    this.deviceId,
    this.brand,
    this.osVersion,
    this.sdkVersion,
    this.isPhysicalDevice,
    this.appVersion,
  });

  static const String tokenKey = 'token';
  static const String platformKey = 'platform';
  static const String deviceModelKey = 'device_model';
  static const String deviceIdKey = 'device_id';
  static const String brandKey = 'brand';
  static const String osVersionKey = 'os_version';
  static const String sdkVersionKey = 'sdk_version';
  static const String isPhysicalDeviceKey = 'is_physical_device';
  static const String appVersionKey = 'app_version';
  static const String watchVideoCountKey = 'watch_video_count';
  static const String createdAtKey = 'created_at';
  static const String updatedAtKey = 'updated_at';

  final String token;
  final String platform;
  final String? deviceModel;
  final String? deviceId;
  final String? brand;
  final String? osVersion;
  final int? sdkVersion;
  final bool? isPhysicalDevice;
  final String? appVersion;
  final int watchVideoCount;

  String get documentId {
    final trimmedDeviceId = deviceId?.trim();
    if (trimmedDeviceId != null && trimmedDeviceId.isNotEmpty) {
      return trimmedDeviceId;
    }
    return token;
  }

  DeviceInfoModel copyWith({
    String? token,
    String? platform,
    String? deviceModel,
    String? deviceId,
    String? brand,
    String? osVersion,
    int? sdkVersion,
    bool? isPhysicalDevice,
    String? appVersion,
    int? watchVideoCount,
  }) {
    return DeviceInfoModel(
      token: token ?? this.token,
      platform: platform ?? this.platform,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceId: deviceId ?? this.deviceId,
      brand: brand ?? this.brand,
      osVersion: osVersion ?? this.osVersion,
      sdkVersion: sdkVersion ?? this.sdkVersion,
      isPhysicalDevice: isPhysicalDevice ?? this.isPhysicalDevice,
      appVersion: appVersion ?? this.appVersion,
      watchVideoCount: watchVideoCount ?? this.watchVideoCount,
    );
  }

  Map<String, Object?> toCreateJson({Object? createdAt, Object? updatedAt}) {
    return {
      tokenKey: token,
      platformKey: platform,
      deviceModelKey: deviceModel,
      deviceIdKey: deviceId,
      brandKey: brand,
      osVersionKey: osVersion,
      sdkVersionKey: sdkVersion,
      isPhysicalDeviceKey: isPhysicalDevice,
      appVersionKey: appVersion,
      watchVideoCountKey: watchVideoCount,
      createdAtKey: createdAt,
      updatedAtKey: updatedAt,
    };
  }

  Map<String, Object?> toUpdateJson({Object? updatedAt}) {
    final data = <String, Object?>{
      tokenKey: token,
      platformKey: platform,
      appVersionKey: appVersion,
      watchVideoCountKey: watchVideoCount,
      updatedAtKey: updatedAt,
    };

    _putIfNotNull(data, deviceModelKey, deviceModel);
    _putIfNotNull(data, deviceIdKey, deviceId);
    _putIfNotNull(data, brandKey, brand);
    _putIfNotNull(data, osVersionKey, osVersion);
    _putIfNotNull(data, sdkVersionKey, sdkVersion);
    _putIfNotNull(data, isPhysicalDeviceKey, isPhysicalDevice);

    return data;
  }

  static void _putIfNotNull(
    Map<String, Object?> data,
    String key,
    Object? value,
  ) {
    if (value != null) data[key] = value;
  }
}
