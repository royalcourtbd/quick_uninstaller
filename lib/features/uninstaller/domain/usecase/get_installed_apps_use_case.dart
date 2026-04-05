import 'package:quick_uninstaller/core/base/base_export.dart';
import 'package:quick_uninstaller/core/services/error_message_handler.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/entities/app_info_entity.dart';
import 'package:quick_uninstaller/features/uninstaller/domain/repositories/uninstaller_repository.dart';

class GetInstalledAppsUseCase extends BaseUseCase<List<AppInfoEntity>> {
  GetInstalledAppsUseCase(this._repository, ErrorMessageHandler handler)
      : super(handler);

  final UninstallerRepository _repository;

  Future<Either<String, List<AppInfoEntity>>> execute() {
    return mapResultToEither(() => _repository.getInstalledApps());
  }
}
