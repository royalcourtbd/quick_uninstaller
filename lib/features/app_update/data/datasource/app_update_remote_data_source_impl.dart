import 'package:quick_uninstaller/core/services/backend_as_a_service.dart';
import 'package:quick_uninstaller/features/app_update/data/models/app_update_config_model.dart';
import 'package:quick_uninstaller/features/app_update/domain/datasource/app_update_remote_data_source.dart';
import 'package:quick_uninstaller/features/app_update/domain/entities/app_update_config_entity.dart';

class AppUpdateRemoteDataSourceImpl implements AppUpdateRemoteDataSource {
  AppUpdateRemoteDataSourceImpl(this._backendService);

  final BackendAsAService _backendService;

  @override
  Stream<AppUpdateConfigEntity?> getAppUpdateConfigStream() {
    return _backendService.getAppUpdateConfigStream().map((data) {
      if (data == null) return null;
      return AppUpdateConfigModel.fromJson(data);
    });
  }
}
