import 'package:quick_uninstaller/core/base/base_entity.dart';

class NativeAdConfigEntity extends BaseEntity {
  final String adUnitId;
  final bool isActive;
  final bool isTestMode;

  const NativeAdConfigEntity({
    required this.adUnitId,
    required this.isActive,
    required this.isTestMode,
  });

  @override
  List<Object?> get props => [adUnitId, isActive, isTestMode];
}
