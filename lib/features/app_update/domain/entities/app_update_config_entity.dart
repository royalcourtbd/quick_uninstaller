import 'package:quick_uninstaller/core/base/base_entity.dart';

class AppUpdateConfigEntity extends BaseEntity {
  const AppUpdateConfigEntity({
    required this.changeLogs,
    required this.latestVersion,
    required this.minSupportedVersion,
    required this.storeUrl,
    required this.title,
  });

  final String changeLogs;
  final String latestVersion;
  final String minSupportedVersion;
  final String storeUrl;
  final String title;

  @override
  List<Object?> get props => [
    changeLogs,
    latestVersion,
    minSupportedVersion,
    storeUrl,
    title,
  ];
}
