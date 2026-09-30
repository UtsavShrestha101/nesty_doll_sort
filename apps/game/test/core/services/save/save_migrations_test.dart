import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_document_codec.dart';
import 'package:nesty_game/core/services/save/save_migrations.dart';

/// A schema-1 document as the M3 app wrote it (m3-design §3.1's key order):
/// Level 24 mid-board, six days into a streak with a frozen Friday.
String schema1Document() => File(
  'test/core/services/save/fixtures/schema1_document.json',
).readAsStringSync().trim();

/// The migration registry (spec §13.3; docs/plans/m3-design.md §3.2;
/// docs/plans/m7-design.md §3.3).
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

  test('step 0 (no document) stamps schema 1, keeping what it has', () {
    expect(
      SaveMigrations.steps[SaveMigrations.noDocument]!(const {'coins': 5}),
      {'coins': 5, 'schema': 1},
    );
  });

  test('no document migrates to a fresh schema-2 one', () {
    final migrated = SaveMigrations.migrate(
      const {},
      SaveMigrations.noDocument,
    );
    expect(migrated['schema'], SaveDocument.currentSchema);
    expect(SaveDocumentCodec.decode(migrated), const SaveDocument());
  });

  test('a current or newer document is left alone', () {
    const doc = {'schema': 2, 'coins': 5};
    expect(SaveMigrations.migrate(doc, 2), same(doc));
    expect(SaveMigrations.migrate(doc, 4), same(doc));
  });

  group('schema 1 → 2 (m7-design §3.3)', () {
    test('a real schema-1 document: the streak becomes the gentle streak, '
        'the run and the longest run; the dailies count the solved dates; '
        'everything else M7 adds starts empty', () {
      final raw = jsonDecode(schema1Document()) as Map<String, Object?>;
      final migrated = SaveMigrations.migrate(raw, 1);
      expect(migrated['schema'], 2);
      final doc = SaveDocumentCodec.decode(migrated);

      expect(doc.daily.streak, 6);
      expect(doc.daily.lit, isTrue);
      expect(doc.daily.run, 6);
      expect(doc.daily.lastDate, LocalDate(2026, 9, 27));
      expect(doc.daily.frozen, [LocalDate(2026, 9, 25)]);
      expect(doc.records.longestRun, 6);
      expect(doc.records.dailies, 6);
      expect(doc.records.families, 0);
      expect(doc.records.dolls, 0);
      expect(doc.records.badges, isEmpty);
      expect(doc.levelBests, isEmpty);
      // The star rating's fields (m7-design P3.4): schema 1 predates stars,
      // so a plain migration leaves them at their defaults; the load-time
      // backfill (`SaveService.backfillLevelStars`, Q120) fills `levelStars`
      // afterwards, not this step.
      expect(doc.levelStars, isEmpty);
      expect(doc.starTipShown, isFalse);
      expect(doc.daily.lastSolve, isNull);
      expect(doc.inProgress?.hinted, isFalse);
      expect(doc.chests, const ChestProgress());
      expect(doc.race, const RaceProgress());
      expect(doc.race.rivals.first.unlocked, isTrue);

      // What schema 1 had is kept as it was.
      expect(doc.currentLevel, 24);
      expect(doc.coins, 830);
      expect(doc.selectedSkin, 'ocean');
      expect(doc.museum, ['ch01']);
      expect(doc.inProgress?.levelId, 'L0024');
      expect(doc.stats.wins, 23);
      expect(doc.playerId, '7F3A-21C9');
      expect(doc.unknown, isEmpty);
    });

    test('a schema-1 save with no streak stays unlit, with no run', () {
      final migrated = SaveMigrations.migrate(const {
        'schema': 1,
        'daily': {'streak': 0, 'done': <String>[]},
      }, 1);
      final doc = SaveDocumentCodec.decode(migrated);
      expect(doc.daily.lit, isFalse);
      expect(doc.daily.run, 0);
      expect(doc.records.longestRun, 0);
      expect(doc.records.dailies, 0);
    });

    test('odd input never throws: a missing or unreadable daily counts as '
        'no streak', () {
      for (final daily in <Object?>[
        null,
        'x',
        {'streak': 'three', 'done': 'no'},
        {
          'streak': -2,
          'done': ['2026-09-24', 7, '2026-09-24', 'soon'],
        },
      ]) {
        final migrated = SaveMigrations.migrate({
          'schema': 1,
          'daily': ?daily,
        }, 1);
        final doc = SaveDocumentCodec.decode(migrated);
        expect(doc.daily.run, 0, reason: '$daily');
        expect(doc.daily.lit, isFalse, reason: '$daily');
        expect(
          doc.records.dailies,
          daily is Map && daily['done'] is List ? 1 : 0,
          reason: '$daily',
        );
      }
    });

    test('read through the codec, a schema-1 document is "migrated" and '
        'needs its backup', () {
      final read = SaveDocumentCodec.read(schema1Document());
      expect(read.kind, SaveReadKind.migrated);
      expect(read.storedSchema, 1);
      expect(read.needsBackup, isTrue);
      expect(read.document.daily.run, 6);
    });
  });
}
