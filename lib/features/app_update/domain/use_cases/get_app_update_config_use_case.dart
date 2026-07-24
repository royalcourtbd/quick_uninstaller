import 'package:fpdart/fpdart.dart';
import 'package:quick_uninstaller/features/app_update/domain/entities/app_update_config_entity.dart';
import 'package:quick_uninstaller/features/app_update/domain/repositories/app_update_repository.dart';

class GetAppUpdateConfigUseCase {
  GetAppUpdateConfigUseCase(this._repository);

  final AppUpdateRepository _repository;

  Stream<Either<String, AppUpdateConfigEntity?>> execute() {
    return _repository.getAppUpdateConfig();
  }
}
