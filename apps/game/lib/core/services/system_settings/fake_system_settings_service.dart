import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/system_settings/system_settings_service.dart';

/// The fake [SystemSettingsService] (the fake env and tests): it opens
/// nothing, counts the calls and answers [next].
@LazySingleton(as: SystemSettingsService, env: [AppEnv.fake])
class FakeSystemSettingsService implements SystemSettingsService {
  /// What the next call answers (true: a settings page "opened").
  bool next = true;

  /// How many times [openNotificationSettings] was called.
  int openCalls = 0;

  @override
  Future<bool> openNotificationSettings() async {
    openCalls++;
    return next;
  }
}
