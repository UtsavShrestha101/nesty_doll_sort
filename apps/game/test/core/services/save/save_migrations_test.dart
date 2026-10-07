import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_document_codec.dart';
import 'package:nesty_game/core/services/save/save_migrations.dart';

/// A schema-1 document as the M3 app wrote it (m3-design §3.1's key order):
/// Level 24 mid-board, six days into a streak with a frozen Friday.
String schema1Document() => File(
  'test/core/services/save/fixtures/schema1_document.json',
).readAsStringSync().trim();

/// A schema-2 document as the M7 app wrote it (m7-design §3.1's key order):
/// Level 47 with a real board in progress, a 12-day gentle streak (run 4,
/// a freeze held and one used), two figurines, two chests, rival 1 beaten
/// twice, stars and bests, and the badges its load granted.
///
/// Made, not hand-typed: a throwaway flutter test run from `apps/game`
/// against git HEAD's (schema-2) `SaveDocument` and `SaveDocumentCodec`,
/// before the 2 → 3 bump, built that `SaveDocument` (the board: bundle
/// entry 47 after three legal moves and one undo, through
/// `GameSessionCodec.encode`), applied `BadgeRules.withDerivable` as
/// `SaveService.load` does, and wrote `SaveDocumentCodec.write` of it here.
String schema2Document() => File(
  'test/core/services/save/fixtures/schema2_document.json',
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

  test('no document migrates to a fresh document of the current schema', () {
    final migrated = SaveMigrations.migrate(
      const {},
      SaveMigrations.noDocument,
    );
    expect(migrated['schema'], SaveDocument.currentSchema);
    expect(SaveDocumentCodec.decode(migrated), const SaveDocument());
  });

  test('a current or newer document is left alone', () {
    expect(SaveDocument.currentSchema, 3);
    const doc = {'schema': 3, 'coins': 5};
    expect(SaveMigrations.migrate(doc, 3), same(doc));
    expect(SaveMigrations.migrate(doc, 4), same(doc));
    expect(SaveMigrations.migrate(doc, 9), same(doc));
  });

  test('every step is pure: it never changes the map it is given', () {
    final raw = jsonDecode(schema2Document()) as Map<String, Object?>;
    final before = jsonEncode(raw);
    for (var v = 0; v < SaveDocument.currentSchema; v++) {
      SaveMigrations.steps[v]!(raw);
    }
    expect(jsonEncode(raw), before);
  });

  group('schema 1 → 2 (m7-design §3.3)', () {
    test('a real schema-1 document: the streak becomes the gentle streak, '
        'the run and the longest run; the dailies count the solved dates; '
        'everything else M7 adds starts empty', () {
      final raw = jsonDecode(schema1Document()) as Map<String, Object?>;
      // Step 1 alone writes schema 2; the chain goes on to the current one.
      expect(SaveMigrations.steps[1]!(raw)['schema'], 2);
      final migrated = SaveMigrations.migrate(raw, 1);
      expect(migrated['schema'], SaveDocument.currentSchema);
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
      // Schema 3's daily gift (plan-login-gift §7.5b): not claimed yet.
      expect(doc.loginGift, const LoginGiftProgress());

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

  group('schema 2 → 3 (plan-login-gift §7.5b; D268)', () {
    test('the step only stamps schema 3, keeping every key as it was', () {
      final raw = jsonDecode(schema2Document()) as Map<String, Object?>;
      expect(raw['schema'], 2);
      final stepped = SaveMigrations.steps[2]!(raw);
      expect(stepped, {...raw, 'schema': 3});
      expect(stepped.keys.toList(), raw.keys.toList());
      // Odd input never throws: there is nothing to read.
      expect(SaveMigrations.steps[2]!(const {}), {'schema': 3});
      expect(SaveMigrations.steps[2]!(const {'loginGift': 'x'}), {
        'loginGift': 'x',
        'schema': 3,
      });
    });

    test('a real schema-2 document: every schema-2 field is kept, and the '
        'daily gift starts fresh at Day 1', () {
      final raw = jsonDecode(schema2Document()) as Map<String, Object?>;
      final migrated = SaveMigrations.migrate(raw, 2);
      expect(migrated['schema'], 3);
      final doc = SaveDocumentCodec.decode(migrated);

      // No claim yet and no date seen: the next claim pays Day 1.
      expect(doc.loginGift, const LoginGiftProgress());
      expect(doc.loginGift.claims, 0);
      expect(doc.unknown, isEmpty);

      // Written back, it is the schema-2 text key for key and value, plus
      // `loginGift` right after `race` (every schema-2 field survived).
      final written = SaveDocumentCodec.encode(doc);
      expect(written['schema'], 3);
      expect(
        {...written}
          ..remove('schema')
          ..remove('loginGift'),
        {...raw}..remove('schema'),
      );
      expect(written.keys.toList(), [...raw.keys, 'loginGift']);
      expect(written['loginGift'], {
        'claims': 0,
        'lastClaim': null,
        'latestSeen': null,
      });

      // A few by name, so a failure says what was lost.
      expect(doc.currentLevel, 47);
      expect(doc.highestLevel, 47);
      expect(doc.coins, 1240);
      expect(doc.inventory, const BoosterInventory(hint: 2, slot: 1));
      expect(doc.selectedSkin, 'ocean');
      expect(doc.ownedThemes, ['ch01', 'ch05']);
      expect(doc.museum, ['ch01', 'ch02']);
      expect(doc.museumCollected['ch02'], LocalDate(2026, 9, 26));
      expect(doc.daily.streak, 12);
      expect(doc.daily.lit, isTrue);
      expect(doc.daily.run, 4);
      expect(doc.daily.freezes, 1);
      expect(doc.daily.frozen, [LocalDate(2026, 9, 29)]);
      expect(doc.daily.lastSolve?.date, LocalDate(2026, 10, 3));
      expect(doc.daily.lastSolve?.minuteOfDay, 1205);
      expect(doc.inProgress?.levelId, 'L0047');
      expect(doc.inProgress?.levelVersion, 1);
      expect(doc.inProgress?.hinted, isTrue);
      expect(doc.levelBests['L0046@1'], 13);
      expect(doc.levelStars, {'L0044': 3, 'L0045': 2, 'L0046': 3});
      expect(doc.starTipShown, isTrue);
      expect(doc.records.families, 233);
      expect(doc.records.badges, ['first_family', 'dailies_7', 'first_race']);
      expect(doc.chests, const ChestProgress(opened: [10, 30]));
      expect(
        doc.race.rivals[0],
        const RivalProgress(unlocked: true, wins: 2, raceNo: 3),
      );
      expect(doc.race.rivals[1].unlocked, isTrue);
      expect(doc.race.rivals[2].unlocked, isFalse);
      expect(doc.stats.wins, 61);
      expect(doc.playerId, '4C1E-9B07');
    });

    test('the board in progress still resumes after the migration (spec '
        '§13.3: its level and levelVersion are unchanged)', () {
      final doc = SaveDocumentCodec.read(schema2Document()).document;
      final board = doc.inProgress!;
      final bundle = LevelBundleCodec.decodeString(
        File('assets/levels/bundle.json').readAsStringSync(),
      ).bundle!;
      final entry = bundle.levels.firstWhere((e) => e.order == 47);
      expect(board.levelId, entry.level.id);
      expect(board.levelVersion, entry.version);
      final resumed = GameSessionCodec.decode(board.session, entry.level);
      expect(resumed.issues, isEmpty);
      expect(resumed.session?.undosUsed, 1);
      expect(resumed.session?.history, hasLength(2));
    });

    test('read through the codec, a schema-2 document is "migrated" and '
        'needs its backup', () {
      final read = SaveDocumentCodec.read(schema2Document());
      expect(read.kind, SaveReadKind.migrated);
      expect(read.storedSchema, 2);
      expect(read.needsBackup, isTrue);
      expect(read.document.loginGift, const LoginGiftProgress());
      expect(read.document.coins, 1240);
      // Written again, it reads as current: nothing more to back up.
      final again = SaveDocumentCodec.read(
        SaveDocumentCodec.write(read.document),
      );
      expect(again.kind, SaveReadKind.current);
      expect(again.needsBackup, isFalse);
      expect(again.document, read.document);
    });

    test('a loginGift a schema-2 app kept as an unknown key (a downgrade '
        'from schema 3) survives the step and is read leniently', () {
      // What the M7 app writes after reading a schema-3 save: its own
      // schema and keys, then the unknown `loginGift`, as it was.
      final raw = jsonDecode(schema2Document()) as Map<String, Object?>;
      final read = SaveDocumentCodec.read(
        jsonEncode({
          ...raw,
          'loginGift': {
            'claims': 3,
            'lastClaim': '2026-10-04',
            'latestSeen': '2026-10-05',
          },
        }),
      );
      expect(read.kind, SaveReadKind.migrated);
      expect(
        read.document.loginGift,
        LoginGiftProgress(
          claims: 3,
          lastClaim: LocalDate(2026, 10, 4),
          latestSeen: LocalDate(2026, 10, 5),
        ),
      );
      expect(read.document.unknown, isEmpty);
    });
  });
}
