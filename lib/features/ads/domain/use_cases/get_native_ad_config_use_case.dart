import 'package:quick_uninstaller/core/base/base_export.dart';
import 'package:quick_uninstaller/features/ads/domain/entities/native_ad_config_entity.dart';
import 'package:quick_uninstaller/features/ads/domain/repositories/ad_settings_repository.dart';

class GetNativeAdConfigUseCase {
  final AdSettingsRepository _repository;

  GetNativeAdConfigUseCase(this._repository);

  Stream<Either<String, NativeAdConfigEntity?>> execute() {
    return _repository.getNativeAdConfig();
  }
}
