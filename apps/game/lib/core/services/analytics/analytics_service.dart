/// Analytics (spec §14.4). Fire-and-forget: implementations never throw and
/// drop events silently when offline or not initialised (CLAUDE.md rule 3).
///
/// TODO(M4): add `FirebaseAnalyticsService` (firebase_analytics) for the real
/// env, plus typed helpers for the §14.4 events (`level_start`,
/// `level_win`, ...) so event names never get mistyped at call sites.
abstract interface class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object> parameters});
}
