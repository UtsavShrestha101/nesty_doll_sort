import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

/// One forward migration: the raw JSON of schema `v` to schema `v + 1`. It
/// must not throw on odd input (reads stay lenient, m3-design §3.3): leave
/// what it doesn't understand for the decoder's defaults.
typedef SaveMigration = Map<String, Object?> Function(Map<String, Object?> raw);

/// The save document's migration registry (spec §13.3 "a schema version and
/// migrations"; docs/plans/m3-design.md §3.2).
///
/// [steps] maps a schema `v` to the migration from `v` to `v + 1`. Schema 0
/// means "no document": a fresh install (M2 never persisted a save, D13), so
/// step 0 only stamps schema 1 and the decoder fills every default. Step 1
/// is M7's (docs/plans/m7-design.md §3.3): it derives the gentle streak's
/// `daily.lit` and `daily.run` and the records a schema-1 save already
/// implies; `save_migrations_test` migrates a real schema-1 document.
abstract final class SaveMigrations {
  /// The schema an absent document counts as.
  static const int noDocument = 0;

  /// `v` → the migration from `v` to `v + 1`, for every `v` below
  /// `SaveDocument.currentSchema`.
  static final Map<int, SaveMigration> steps = Map.unmodifiable({
    noDocument: (Map<String, Object?> raw) => {...raw, 'schema': 1},
    1: _schema1To2,
  });

  /// Schema 1 → 2 (m7-design §3.3). Schema 1's `daily.streak` was the
  /// unbroken run (a miss with no freeze reset it to 0), so it becomes the
  /// gentle streak's count, the current run and the longest run; the flame
  /// is lit while it is above 0 (the next refresh pauses it if a day was
  /// missed meanwhile, m7-design §8). `records.dailies` is the dates in
  /// `daily.done` (at most 31 are kept, so a long-time player starts from
  /// that). Everything else M7 adds starts empty: `levelBests`, the other
  /// records, the badges (the ones the save already implies are granted
  /// on load, §12), `chests` and `race`, and phase 3's star and solve
  /// fields (m7-design P3.4): `levelStars` empty (filled by the load-time
  /// backfill, `SaveService.backfillLevelStars`, Q120), `starTipShown`
  /// false, `daily.lastSolve` null and `inProgress.hinted` false. Those
  /// four are the decoder's defaults, so this step writes nothing for
  /// them. Never throws: an unreadable value counts as 0 and the decoder
  /// fills the rest.
  static Map<String, Object?> _schema1To2(Map<String, Object?> raw) {
    final dailyValue = raw['daily'];
    final daily = dailyValue is Map
        ? {
            for (final MapEntry(:key, :value) in dailyValue.entries)
              if (key is String) key: value,
          }
        : <String, Object?>{};
    final streakValue = daily['streak'];
    final streak = streakValue is int && streakValue > 0
        ? streakValue
        : streakValue is double &&
              streakValue.isFinite &&
              streakValue == streakValue.truncateToDouble() &&
              streakValue > 0 &&
              streakValue <= 9007199254740991
        ? streakValue.toInt()
        : 0;
    final done = daily['done'];
    // Distinct readable dates, as the decoder keeps them.
    final dailies = done is List
        ? <LocalDate>{for (final date in done) ?LocalDate.tryParse(date)}.length
        : 0;
    return {
      ...raw,
      'schema': 2,
      'daily': {...daily, 'lit': streak > 0, 'run': streak},
      'records': {
        'families': 0,
        'dolls': 0,
        'dailies': dailies,
        'longestRun': streak,
        'badges': const <String>[],
      },
    };
  }

  /// [raw], of schema [from], migrated step by step to
  /// `SaveDocument.currentSchema`. A document already at (or past) it comes
  /// back unchanged. Throws a [StateError] if a step is missing, which
  /// `save_migrations_test` rules out for every schema below the current.
  static Map<String, Object?> migrate(Map<String, Object?> raw, int from) {
    var doc = raw;
    for (var v = from; v < SaveDocument.currentSchema; v++) {
      final step = steps[v];
      if (step == null) throw StateError('No save migration from schema $v');
      doc = step(doc);
    }
    return doc;
  }
}
