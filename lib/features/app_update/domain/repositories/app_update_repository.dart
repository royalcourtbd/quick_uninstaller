import 'package:fpdart/fpdart.dart';
import 'package:quick_uninstaller/features/app_update/domain/entities/app_update_config_entity.dart';

abstract class AppUpdateRepository {
  Stream<Either<String, AppUpdateConfigEntity?>> getAppUpdateConfig();
}
