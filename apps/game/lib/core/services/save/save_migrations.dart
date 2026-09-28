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
/// step 0 only stamps schema 1 and the decoder fills every default. A later
/// schema adds `steps[1]`, raises `SaveDocument.currentSchema`, and adds a
/// test that migrates a real schema-1 document.
abstract final class SaveMigrations {
  /// The schema an absent document counts as.
  static const int noDocument = 0;

  /// `v` → the migration from `v` to `v + 1`, for every `v` below
  /// `SaveDocument.currentSchema`.
  static final Map<int, SaveMigration> steps = Map.unmodifiable({
    noDocument: (Map<String, Object?> raw) => {...raw, 'schema': 1},
  });

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
