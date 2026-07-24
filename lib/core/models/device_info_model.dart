class DeviceInfoModel {
  const DeviceInfoModel({
    required this.token,
    required this.platform,
    required this.deviceId,
    required this.watchVideoCount,
    this.deviceModel,
    this.legacyDeviceId,
    this.brand,
    this.manufacturer,
    this.osVersion,
    this.sdkVersion,
    this.isPhysicalDevice,
    this.hardware,
    this.product,
    this.deviceCodeName,
    this.supportedAbis,
    this.appVersion,
    this.appBuildNumber,
  });

  static const String tokenKey = 'token';
  static const String platformKey = 'platform';
  static const String deviceModelKey = 'device_model';
  static const String deviceIdKey = 'device_id';
  static const String legacyDeviceIdKey = 'legacy_device_id';
  static const String brandKey = 'brand';
  static const String manufacturerKey = 'manufacturer';
  static const String osVersionKey = 'os_version';
  static const String sdkVersionKey = 'sdk_version';
  static const String isPhysicalDeviceKey = 'is_physical_device';
  static const String deviceTypeKey = 'device_type';
  static const String hardwareKey = 'hardware';
  static const String productKey = 'product';
  static const String deviceCodeNameKey = 'device_code_name';
  static const String supportedAbisKey = 'supported_abis';
  static const String appVersionKey = 'app_version';
  static const String appBuildNumberKey = 'app_build_number';
  static const String watchVideoCountKey = 'watch_video_count';
  static const String createdAtKey = 'created_at';
  static const String updatedAtKey = 'updated_at';
  static const String lastSeenAtKey = 'last_seen_at';
  static const String lastRewardedAdAtKey = 'last_rewarded_ad_at';

  final String token;
  final String platform;
  final String deviceId;
  final String? deviceModel;
  final String? legacyDeviceId;
  final String? brand;
  final String? manufacturer;
  final String? osVersion;
  final int? sdkVersion;
  final bool? isPhysicalDevice;
  final String? hardware;
  final String? product;
  final String? deviceCodeName;
  final List<String>? supportedAbis;
  final String? appVersion;
  final String? appBuildNumber;
  final int watchVideoCount;

  String get documentId => deviceId.trim();

  String? get legacyDocumentId {
    final id = legacyDeviceId?.trim();
    if (id == null || id.isEmpty || id == documentId) return null;
    return id;
  }

  String get deviceType {
    if (isPhysicalDevice == null) return 'unknown';
    return isPhysicalDevice! ? 'physical' : 'emulator';
  }

  DeviceInfoModel copyWith({
    String? token,
    String? platform,
    String? deviceId,
    String? deviceModel,
    String? legacyDeviceId,
    String? brand,
    String? manufacturer,
    String? osVersion,
    int? sdkVersion,
    bool? isPhysicalDevice,
    String? hardware,
    String? product,
    String? deviceCodeName,
    List<String>? supportedAbis,
    String? appVersion,
    String? appBuildNumber,
    int? watchVideoCount,
  }) {
    return DeviceInfoModel(
      token: token ?? this.token,
      platform: platform ?? this.platform,
      deviceId: deviceId ?? this.deviceId,
      deviceModel: deviceModel ?? this.deviceModel,
      legacyDeviceId: legacyDeviceId ?? this.legacyDeviceId,
      brand: brand ?? this.brand,
      manufacturer: manufacturer ?? this.manufacturer,
      osVersion: osVersion ?? this.osVersion,
      sdkVersion: sdkVersion ?? this.sdkVersion,
      isPhysicalDevice: isPhysicalDevice ?? this.isPhysicalDevice,
      hardware: hardware ?? this.hardware,
      product: product ?? this.product,
      deviceCodeName: deviceCodeName ?? this.deviceCodeName,
      supportedAbis: supportedAbis ?? this.supportedAbis,
      appVersion: appVersion ?? this.appVersion,
      appBuildNumber: appBuildNumber ?? this.appBuildNumber,
      watchVideoCount: watchVideoCount ?? this.watchVideoCount,
    );
  }

  Map<String, Object?> toCreateJson({
    Object? createdAt,
    Object? updatedAt,
    Object? lastSeenAt,
    Object? lastRewardedAdAt,
  }) {
    final data = <String, Object?>{
      platformKey: platform,
      deviceIdKey: deviceId,
      deviceTypeKey: deviceType,
      watchVideoCountKey: watchVideoCount,
      createdAtKey: createdAt,
      updatedAtKey: updatedAt,
      lastSeenAtKey: lastSeenAt,
    };

    _putIfNotEmpty(data, tokenKey, token);
    _putIfNotNull(data, deviceModelKey, deviceModel);
    _putIfNotNull(data, legacyDeviceIdKey, legacyDeviceId);
    _putIfNotNull(data, brandKey, brand);
    _putIfNotNull(data, manufacturerKey, manufacturer);
    _putIfNotNull(data, osVersionKey, osVersion);
    _putIfNotNull(data, sdkVersionKey, sdkVersion);
    _putIfNotNull(data, isPhysicalDeviceKey, isPhysicalDevice);
    _putIfNotNull(data, hardwareKey, hardware);
    _putIfNotNull(data, productKey, product);
    _putIfNotNull(data, deviceCodeNameKey, deviceCodeName);
    _putIfNotNull(data, supportedAbisKey, supportedAbis);
    _putIfNotNull(data, appVersionKey, appVersion);
    _putIfNotNull(data, appBuildNumberKey, appBuildNumber);
    _putIfNotNull(data, lastRewardedAdAtKey, lastRewardedAdAt);

    return data;
  }

  Map<String, Object?> toUpdateJson({
    Object? updatedAt,
    Object? lastSeenAt,
    Object? lastRewardedAdAt,
  }) {
    final data = <String, Object?>{
      platformKey: platform,
      deviceIdKey: deviceId,
      deviceTypeKey: deviceType,
      watchVideoCountKey: watchVideoCount,
      updatedAtKey: updatedAt,
      lastSeenAtKey: lastSeenAt,
    };

    _putIfNotEmpty(data, tokenKey, token);
    _putIfNotNull(data, deviceModelKey, deviceModel);
    _putIfNotNull(data, legacyDeviceIdKey, legacyDeviceId);
    _putIfNotNull(data, brandKey, brand);
    _putIfNotNull(data, manufacturerKey, manufacturer);
    _putIfNotNull(data, osVersionKey, osVersion);
    _putIfNotNull(data, sdkVersionKey, sdkVersion);
    _putIfNotNull(data, isPhysicalDeviceKey, isPhysicalDevice);
    _putIfNotNull(data, hardwareKey, hardware);
    _putIfNotNull(data, productKey, product);
    _putIfNotNull(data, deviceCodeNameKey, deviceCodeName);
    _putIfNotNull(data, supportedAbisKey, supportedAbis);
    _putIfNotNull(data, appVersionKey, appVersion);
    _putIfNotNull(data, appBuildNumberKey, appBuildNumber);
    _putIfNotNull(data, lastRewardedAdAtKey, lastRewardedAdAt);

    return data;
  }

  static void _putIfNotNull(
    Map<String, Object?> data,
    String key,
    Object? value,
  ) {
    if (value != null) data[key] = value;
  }

  static void _putIfNotEmpty(
    Map<String, Object?> data,
    String key,
    String value,
  ) {
    final trimmedValue = value.trim();
    if (trimmedValue.isNotEmpty) data[key] = trimmedValue;
  }
}
