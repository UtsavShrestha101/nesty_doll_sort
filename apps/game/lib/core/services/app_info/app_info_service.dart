import 'package:flutter/foundation.dart';

/// The app's version and build number (pubspec `version`, e.g. `1.0.0+42`
/// split into "1.0.0" and "42"): the Settings footer (frame 8.1) "Nesty:
/// Doll Sort · v1.0.0 (build 42) · Player ID …".
@immutable
final class AppInfo {
  const AppInfo({required this.version, required this.buildNumber});

  final String version;
  final String buildNumber;

  @override
  bool operator ==(Object other) =>
      other is AppInfo &&
      other.version == version &&
      other.buildNumber == buildNumber;

  @override
  int get hashCode => Object.hash(version, buildNumber);

  @override
  String toString() => 'AppInfo($version+$buildNumber)';
}

/// The running app's identity (docs/plans/m3-design.md §10.2).
///
/// `PackageAppInfoService` (real env) reads it once from `package_info_plus`
/// and caches it; `FakeAppInfoService` (fake env) answers "1.0.0"/"42".
abstract interface class AppInfoService {
  /// The version and build number, read once. Never throws: a platform
  /// failure gives version "" and build "" (rule 3), and the footer then
  /// simply shows an empty segment.
  Future<AppInfo> load();
}
