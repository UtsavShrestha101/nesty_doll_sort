import 'dart:developer' as developer;

import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';

/// [AnalyticsService] that only writes to the developer log. It keeps no
/// history, so it can't grow memory over a long session in the real env.
///
/// Until then, tests that assert on events use a mocktail mock
/// (.claude/rules/services.md).
///
/// TODO(M4): drop `AppEnv.real` from `env` once `FirebaseAnalyticsService`
/// exists, then record events in memory (`events` list plus `clear()`) so
/// tests can read them; that is only safe once release builds stop using
/// this class.
@LazySingleton(as: AnalyticsService, env: [AppEnv.fake, AppEnv.real])
class FakeAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object> parameters = const {},
  }) async {
    developer.log('$name $parameters', name: 'nesty.analytics');
  }
}
