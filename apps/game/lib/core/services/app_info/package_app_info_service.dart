import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/app_info/app_info_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Real [AppInfoService] over `package_info_plus` (m3-design §10.2, D79).
@LazySingleton(as: AppInfoService, env: [AppEnv.real])
class PackageAppInfoService implements AppInfoService {
  Future<AppInfo>? _loading;

  @override
  Future<AppInfo> load() => _loading ??= _load();

  Future<AppInfo> _load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return AppInfo(version: info.version, buildNumber: info.buildNumber);
    } on Object catch (error, stack) {
      developer.log(
        'package info unavailable; the footer hides it',
        name: 'nesty.appinfo',
        error: error,
        stackTrace: stack,
      );
      // developer.log never reaches the `flutter run` terminal.
      if (kDebugMode) debugPrint('[nesty.appinfo] load failed: $error');
      return const AppInfo(version: '', buildNumber: '');
    }
  }
}
