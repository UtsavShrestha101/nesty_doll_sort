import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/app_info/app_info_service.dart';

/// [AppInfoService] for tests and the fake env: a fixed "1.0.0" build "42"
/// (m3-design §10.2).
@LazySingleton(as: AppInfoService, env: [AppEnv.fake])
class FakeAppInfoService implements AppInfoService {
  @override
  Future<AppInfo> load() async =>
      const AppInfo(version: '1.0.0', buildNumber: '42');
}
