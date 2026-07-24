import 'package:quick_uninstaller/core/static/constants.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/interstitial_ad_config_entity.dart';

class InterstitialAdConfigModel extends InterstitialAdConfigEntity {
  const InterstitialAdConfigModel({
    required super.adUnitId,
    required super.isActive,
    required super.isTestMode,
  });

  factory InterstitialAdConfigModel.fromJson(Map<String, dynamic> json) {
    final interstitial = json['interstitial_ads_id'];
    return InterstitialAdConfigModel(
      adUnitId:
          interstitial is List &&
              interstitial.isNotEmpty &&
              interstitial.first is String
          ? interstitial.first as String
          : interstitialAdUnitId,
      isActive:
          interstitial is List &&
              interstitial.length > 1 &&
              interstitial[1] is bool
          ? interstitial[1] as bool
          : true,
      isTestMode: json['is_test_mode'] as bool? ?? false,
    );
  }
}
