import 'package:quick_uninstaller/features/ads/domain/entities/banner_ad_config_entity.dart';

class BannerAdConfigModel extends BannerAdConfigEntity {
  const BannerAdConfigModel({
    required super.adUnitId,
    required super.isActive,
    required super.isTestMode,
  });

  factory BannerAdConfigModel.fromJson(Map<String, dynamic> json) {
    final banner = json['banner_ads_id_1'];
    return BannerAdConfigModel(
      adUnitId: banner is List && banner.isNotEmpty && banner.first is String
          ? banner.first as String
          : '',
      isActive: banner is List && banner.length > 1 && banner[1] is bool
          ? banner[1] as bool
          : false,
      isTestMode: json['is_test_mode'] as bool? ?? false,
    );
  }
}
