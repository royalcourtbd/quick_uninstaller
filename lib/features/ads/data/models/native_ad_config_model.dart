import 'package:quick_uninstaller/core/static/constants.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/native_ad_config_entity.dart';

class NativeAdConfigModel extends NativeAdConfigEntity {
  const NativeAdConfigModel({
    required super.adUnitId,
    required super.isActive,
    required super.isTestMode,
  });

  factory NativeAdConfigModel.fromJson(Map<String, dynamic> json) {
    final native = json['native_ads_id'];
    return NativeAdConfigModel(
      adUnitId: native is List && native.isNotEmpty && native.first is String
          ? native.first as String
          : nativeAdUnitId,
      isActive: native is List && native.length > 1 && native[1] is bool
          ? native[1] as bool
          : true,
      isTestMode: json['is_test_mode'] as bool? ?? false,
    );
  }
}
