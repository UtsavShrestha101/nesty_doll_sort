import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_migrations.dart';

/// The migration registry (spec §13.3; docs/plans/m3-design.md §3.2).
void main() {
  test('every schema below the current one has a step', () {
    for (
      var v = SaveMigrations.noDocument;
      v < SaveDocument.currentSchema;
      v++
    ) {
      expect(SaveMigrations.steps, contains(v), reason: 'schema $v');
    }
  });

  test('schema 0 (no document) becomes schema 1, keeping what it has', () {
    expect(
      SaveMigrations.migrate(const {'coins': 5}, SaveMigrations.noDocument),
      {'coins': 5, 'schema': 1},
    );
  });

  test('a current or newer document is left alone', () {
    const doc = {'schema': 1, 'coins': 5};
    expect(SaveMigrations.migrate(doc, 1), same(doc));
    expect(SaveMigrations.migrate(doc, 4), same(doc));
  });
}
