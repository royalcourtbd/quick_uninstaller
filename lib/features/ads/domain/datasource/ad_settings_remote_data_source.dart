import 'package:quick_uninstaller/features/ads/domain/entities/banner_ad_config_entity.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/interstitial_ad_config_entity.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/native_ad_config_entity.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/rewarded_ad_config_entity.dart';

abstract class AdSettingsRemoteDataSource {
  Stream<BannerAdConfigEntity?> getBannerAdConfigStream();

  Stream<InterstitialAdConfigEntity?> getInterstitialAdConfigStream();

  Stream<NativeAdConfigEntity?> getNativeAdConfigStream();

  Stream<RewardedAdConfigEntity?> getRewardedAdConfigStream();
}
