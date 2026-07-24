enum UpdateType { none, optional, force }

extension UpdateTypeExtension on UpdateType {
  bool get shouldShowNotice => this != UpdateType.none;
  bool get isMandatory => this == UpdateType.force;
}
