import 'package:quick_uninstaller/core/base/base_entity.dart';

class BannerAdConfigEntity extends BaseEntity {
  final String adUnitId;
  final bool isActive;
  final bool isTestMode;

  const BannerAdConfigEntity({
    required this.adUnitId,
    required this.isActive,
    required this.isTestMode,
  });

  @override
  List<Object?> get props => [adUnitId, isActive, isTestMode];
}
