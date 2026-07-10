import 'package:quick_uninstaller/core/base/base_export.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/banner_ad_config_entity.dart';
import 'package:quick_uninstaller/features/ads/domain/repositories/ad_settings_repository.dart';

class GetBannerAdConfigUseCase {
  final AdSettingsRepository _repository;

  GetBannerAdConfigUseCase(this._repository);

  Stream<Either<String, BannerAdConfigEntity?>> execute() {
    return _repository.getBannerAdConfig();
  }
}
