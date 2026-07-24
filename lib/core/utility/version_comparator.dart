class VersionComparator {
  const VersionComparator._();

  static int? compare(String first, String second) {
    final firstParts = _parse(first);
    final secondParts = _parse(second);
    if (firstParts == null || secondParts == null) return null;

    final length = firstParts.length > secondParts.length
        ? firstParts.length
        : secondParts.length;
    for (var index = 0; index < length; index++) {
      final firstPart = index < firstParts.length ? firstParts[index] : 0;
      final secondPart = index < secondParts.length ? secondParts[index] : 0;
      if (firstPart != secondPart) return firstPart.compareTo(secondPart);
    }
    return 0;
  }

  static List<int>? _parse(String version) {
    var normalized = version.trim();
    if (normalized.startsWith('v') || normalized.startsWith('V')) {
      normalized = normalized.substring(1);
    }
    normalized = normalized.split(RegExp(r'[-+]')).first;
    if (normalized.isEmpty) return null;

    final parts = <int>[];
    for (final component in normalized.split('.')) {
      final value = int.tryParse(component);
      if (value == null || value < 0) return null;
      parts.add(value);
    }
    return parts.isEmpty ? null : parts;
  }
}
