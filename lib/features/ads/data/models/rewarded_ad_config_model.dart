import 'package:quick_uninstaller/core/static/constants.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/rewarded_ad_config_entity.dart';

class RewardedAdConfigModel extends RewardedAdConfigEntity {
  const RewardedAdConfigModel({
    required super.adUnitId,
    required super.isActive,
    required super.isTestMode,
  });

  factory RewardedAdConfigModel.fromJson(Map<String, dynamic> json) {
    final videoAd = json['video_ads_id'];
    return RewardedAdConfigModel(
      adUnitId: videoAd is List && videoAd.isNotEmpty && videoAd.first is String
          ? videoAd.first as String
          : rewardedAdUnitId,
      isActive: videoAd is List && videoAd.length > 1 && videoAd[1] is bool
          ? videoAd[1] as bool
          : true,
      isTestMode: json['is_test_mode'] as bool? ?? false,
    );
  }
}
