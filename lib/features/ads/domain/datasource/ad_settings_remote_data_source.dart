import 'package:quick_uninstaller/features/ads/domain/entities/banner_ad_config_entity.dart';

abstract class AdSettingsRemoteDataSource {
  Stream<BannerAdConfigEntity?> getBannerAdConfigStream();
}
