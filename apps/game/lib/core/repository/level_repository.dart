/// Offline-first level source (spec §13.4).
///
/// Skeleton surface only: the splash loads what's available offline.
/// TODO(M2): real bundled implementation reading
/// `assets/levels/bundle.json`, decoding and validating each level with
/// nesty_core's `LevelCodec`/`Validator` (invalid ones skipped with a log
/// entry, spec §5.3) and a lookup by play order returning nesty_core levels.
/// TODO(M4): `levels_cache.json` + background Firestore sync on launch and
/// resume (never blocking, never swapping the level in progress).
abstract interface class LevelRepository {
  /// Loads bundled (and, from M4, cached) levels. Called once by the splash.
  Future<void> load();

  /// Levels available offline. Past the last one the game switches to Bonus
  /// Endless (spec §7.1).
  int get levelCount;
}
