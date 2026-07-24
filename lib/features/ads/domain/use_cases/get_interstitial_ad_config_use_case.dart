import 'package:quick_uninstaller/core/base/base_export.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/interstitial_ad_config_entity.dart';
import 'package:quick_uninstaller/features/ads/domain/repositories/ad_settings_repository.dart';

class GetInterstitialAdConfigUseCase {
  final AdSettingsRepository _repository;

  GetInterstitialAdConfigUseCase(this._repository);

  Stream<Either<String, InterstitialAdConfigEntity?>> execute() {
    return _repository.getInterstitialAdConfig();
  }
}
