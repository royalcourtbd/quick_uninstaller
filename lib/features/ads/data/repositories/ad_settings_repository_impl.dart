import 'package:quick_uninstaller/core/base/base_export.dart';
import 'package:quick_uninstaller/features/ads/domain/datasource/ad_settings_remote_data_source.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/banner_ad_config_entity.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/interstitial_ad_config_entity.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/rewarded_ad_config_entity.dart';
import 'package:quick_uninstaller/features/ads/domain/repositories/ad_settings_repository.dart';

class AdSettingsRepositoryImpl implements AdSettingsRepository {
  final AdSettingsRemoteDataSource _remoteDataSource;

  AdSettingsRepositoryImpl(this._remoteDataSource);

  @override
  Stream<Either<String, BannerAdConfigEntity?>> getBannerAdConfig() {
    return _remoteDataSource
        .getBannerAdConfigStream()
        .map((config) => right<String, BannerAdConfigEntity?>(config))
        .handleError((error) {
          return left<String, BannerAdConfigEntity?>(error.toString());
        });
  }

  @override
  Stream<Either<String, InterstitialAdConfigEntity?>>
  getInterstitialAdConfig() {
    return _remoteDataSource
        .getInterstitialAdConfigStream()
        .map((config) => right<String, InterstitialAdConfigEntity?>(config))
        .handleError((error) {
          return left<String, InterstitialAdConfigEntity?>(error.toString());
        });
  }

  @override
  Stream<Either<String, RewardedAdConfigEntity?>> getRewardedAdConfig() {
    return _remoteDataSource
        .getRewardedAdConfigStream()
        .map((config) => right<String, RewardedAdConfigEntity?>(config))
        .handleError((error) {
          return left<String, RewardedAdConfigEntity?>(error.toString());
        });
  }
}
