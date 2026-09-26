/// The player's save document (spec §13.3).
///
/// Skeleton surface only: the splash loads it once, Home reads the current
/// level. TODO(M3): the full document (coins, inventory, adsRemoved, skins,
/// themes, museum, daily, inProgress + undo, adCounters, stats), schema
/// version + migrations, save-on-every-move and on app pause, and
/// restore-on-resume when `levelVersion` still matches. Whether it lives in a
/// Hive box or the spec's atomic JSON file is an open M3 decision
/// (docs/PROGRESS.md).
abstract interface class SaveService {
  /// Loads the save into memory (spec §10.2 #1). Called once by the splash.
  /// A missing save is not an error: it means a fresh install.
  Future<void> load();

  /// Spec §13.3 `currentLevel`: the 1-based global play order of the level
  /// the Home play button starts.
  int get currentLevel;
}
