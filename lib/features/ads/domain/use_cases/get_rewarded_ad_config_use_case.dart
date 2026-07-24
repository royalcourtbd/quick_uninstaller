import 'package:quick_uninstaller/core/base/base_export.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/rewarded_ad_config_entity.dart';
import 'package:quick_uninstaller/features/ads/domain/repositories/ad_settings_repository.dart';

class GetRewardedAdConfigUseCase {
  final AdSettingsRepository _repository;

  GetRewardedAdConfigUseCase(this._repository);

  Stream<Either<String, RewardedAdConfigEntity?>> execute() {
    return _repository.getRewardedAdConfig();
  }
}
