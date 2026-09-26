/// Injectable environment names that pick service implementations.
///
/// These are orthogonal to build flavors (dev/stg/prod): every flavor runs
/// [real] unless a debug build opts into [fake]. See `di.dart` for how a later
/// milestone swaps a real implementation in without touching callers.
abstract final class AppEnv {
  /// Production wiring. Uses real implementations where they exist and the
  /// offline fakes for services whose real version lands in a later milestone.
  static const real = 'real';

  /// Everything in-memory / offline: tests, and debug builds started with
  /// `--dart-define=NESTY_FAKE_SERVICES=true` (CLAUDE.md rule 4).
  static const fake = 'fake';
}
