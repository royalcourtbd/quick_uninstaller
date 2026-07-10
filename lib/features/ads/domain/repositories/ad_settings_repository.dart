import 'package:quick_uninstaller/core/base/base_export.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/banner_ad_config_entity.dart';

abstract class AdSettingsRepository {
  Stream<Either<String, BannerAdConfigEntity?>> getBannerAdConfig();
}
