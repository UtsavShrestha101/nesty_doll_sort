import 'package:nesty_core/nesty_core.dart';

/// Offline-first level source (spec §13.4).
///
/// The real implementation is `BundledLevelRepository` (`bundle.json`,
/// decoded by nesty_core's `LevelBundleCodec`, each level checked by
/// `Validator` rules 1–7; invalid ones skipped with a log entry, spec
/// §5.3). Tests and the fake env use `FakeLevelRepository`.
/// TODO(M4): `levels_cache.json` + background Firestore sync on launch and
/// resume (never blocking, never swapping the level in progress).
abstract interface class LevelRepository {
  /// Loads bundled (and, from M4, cached) levels. Called once by the splash.
  /// A bundle that fails to load entirely throws
  /// `AppException(AppExceptionKind.content)`; single bad levels are
  /// skipped.
  Future<void> load();

  /// The last play order available offline: past it the game switches to
  /// Bonus Endless (spec §7.1). It equals the number of levels unless a bad
  /// level was skipped. 0 before [load].
  int get levelCount;

  /// The level at global play [order] (1-based, continuous, spec §7.1)
  /// with its play metadata (chapter, tier, version, reward), or null past
  /// [levelCount] or before [load]. In memory, so synchronous.
  ///
  /// When the level at [order] was skipped as invalid, this is the next
  /// level after it (spec §5.3 "skipped"), so a bad level never blocks
  /// progress: callers advance from the returned entry's `order`.
  LevelBundleEntry? entryAt(int order);
}
