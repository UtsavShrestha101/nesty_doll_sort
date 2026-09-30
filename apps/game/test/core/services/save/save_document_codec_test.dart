import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/booster.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_document_codec.dart';
import 'package:nesty_game/core/services/save/save_migrations.dart';

/// The save document's JSON (spec §13.3; docs/plans/m3-design.md §3.3):
/// lossless for what the game writes, lenient for anything else.
void main() {
  final full = SaveDocument(
    currentLevel: 24,
    highestLevel: 26,
    coins: 830,
    inventory: const BoosterInventory(hint: 1, slot: 0),
    ownedSkins: const ['classic', 'ocean'],
    selectedSkin: 'ocean',
    ownedThemes: const ['ch01', 'ch05'],
    selectedTheme: 'ch05',
    museum: const ['ch01'],
    museumCollected: {'ch01': LocalDate(2026, 9, 12)},
    daily: DailyProgress(
      streak: 4,
      lit: true,
      run: 3,
      lastDate: LocalDate(2026, 9, 25),
      freezes: 1,
      freezeWeek: 202639,
      done: [LocalDate(2026, 9, 24)],
      frozen: [LocalDate(2026, 9, 25)],
      noticeDate: LocalDate(2026, 9, 25),
      chestPending: true,
      // The share text's and the reminder offer's facts (m7-design P3.4).
      lastSolve: DailySolve(
        date: LocalDate(2026, 9, 24),
        moves: 14,
        families: 4,
        minuteOfDay: 1140,
      ),
      inProgress: const InProgressLevel(
        request: PlayRequest.daily(20260926),
        levelId: 'daily-20260926',
        levelVersion: 1,
        session: {'format': 1},
        level: {'id': 'daily-20260926'},
        tier: Tier.hard,
      ),
    ),
    inProgress: const InProgressLevel(
      request: PlayRequest.campaign(24),
      levelId: 'L0024',
      levelVersion: 2,
      session: {'format': 1, 'undosUsed': 1},
      // A hint since the last Restart (Q116; m7-design P3.6).
      hinted: true,
    ),
    adCounters: const AdCounters(winsSinceInterstitial: 1, lastAdAt: 5),
    stats: const SaveStats(wins: 23, moves: 612, boostersUsed: {'hint': 2}),
    seenIntros: const ['towers'],
    tutorialDone: true,
    bonus: const BonusProgress(next: 3),
    playerId: '7F3A-21C9',
    levelBests: const {'L0024@2': 16, 'L0003@1': 9},
    // The star rating's best per level id (m7-design P3.4).
    levelStars: const {'L0024': 3, 'L0003': 1},
    starTipShown: true,
    records: const SaveRecords(
      families: 212,
      dolls: 780,
      dailies: 12,
      longestRun: 9,
      badges: ['first_family', 'a_future_badge'],
    ),
    chests: const ChestProgress(opened: [10], bonusOpened: [10, 20]),
    race: const RaceProgress(
      rivals: [
        RivalProgress(unlocked: true, wins: 3, raceNo: 5),
        RivalProgress(unlocked: true, raceNo: 1),
        RivalProgress(),
      ],
    ),
    unknown: const {'zeta': 1, 'alpha': 'kept'},
  );

  test('round-trips every field, unknown keys included', () {
    final text = SaveDocumentCodec.write(full);
    final read = SaveDocumentCodec.read(text);
    expect(read.kind, SaveReadKind.current);
    expect(read.needsBackup, isFalse);
    expect(read.document, full);
    expect(SaveDocumentCodec.write(read.document), text);
  });

  test('writes the known keys in order, then the unknown ones sorted', () {
    final keys = SaveDocumentCodec.encode(full).keys.toList();
    expect(keys.first, 'schema');
    expect(keys.sublist(keys.length - 9), [
      'playerId',
      'levelBests',
      // The star rating's two (m7-design P3.4), after levelBests.
      'levelStars',
      'starTipShown',
      'records',
      'chests',
      'race',
      'alpha',
      'zeta',
    ]);
    expect(keys, isNot(contains('settings')));
  });

  test('nothing stored is a fresh install through migration 0', () {
    final read = SaveDocumentCodec.read(null);
    expect(read.kind, SaveReadKind.absent);
    expect(read.storedSchema, SaveMigrations.noDocument);
    expect(read.document, const SaveDocument());
    expect(read.document.inventory.of(BoosterKind.hint), 3);
    expect(read.document.inventory.of(BoosterKind.extraSlot), 2);
  });

  test('text that is not a JSON object gives the defaults, to back up', () {
    for (final text in ['', 'not json', '[1, 2]', '"doc"', 'null']) {
      final read = SaveDocumentCodec.read(text);
      expect(read.kind, SaveReadKind.invalid, reason: text);
      expect(read.needsBackup, isTrue);
      expect(read.document, const SaveDocument());
    }
  });

  test('a newer schema reads what it can, keeping the rest', () {
    final read = SaveDocumentCodec.read(
      jsonEncode({
        'schema': 7,
        'coins': 40,
        'wallet': {'gems': 3},
      }),
    );
    expect(read.kind, SaveReadKind.newer);
    expect(read.storedSchema, 7);
    expect(read.needsBackup, isTrue);
    expect(read.document.coins, 40);
    expect(read.document.unknown, {
      'wallet': {'gems': 3},
    });
    expect(
      SaveDocumentCodec.encode(read.document)['schema'],
      SaveDocument.currentSchema,
    );
  });

  test('wrong types and ranges fall back, field by field', () {
    final read = SaveDocumentCodec.read(
      jsonEncode({
        'schema': 1,
        'currentLevel': 0,
        'coins': -5,
        'inventory': {'hint': 'many', 'slot': 4.0},
        'adsRemoved': 'yes',
        'ownedSkins': ['ocean', 7, 'ocean', ''],
        'selectedSkin': 'space',
        'museum': ['ch01', 'ch02'],
        'museumCollected': {
          'ch01': '2026-09-12',
          'ch02': 'soon',
          'ch09': '2026-01-01',
        },
        'daily': {
          'streak': 3,
          'freezes': 9,
          'done': ['2026-09-24', 'x', '2026-09-24'],
        },
        'inProgress': {
          'kind': 'bonus',
          'number': 2,
          'levelId': 'bonus-32',
          'levelVersion': 1,
          'session': <String, Object?>{},
        },
        'stats': {
          'boostersUsed': {'undo': 2, 'hint': -1, 'slot': 'x'},
        },
        'playerId': 'nope',
        'settings': {'sound': false},
      }),
    );
    final doc = read.document;
    expect(doc.currentLevel, 1);
    expect(doc.coins, 0);
    // A real inventory with a bad count holds 0, never the gift again.
    expect(doc.inventory, const BoosterInventory(hint: 0, slot: 4));
    expect(doc.adsRemoved, isFalse);
    expect(doc.ownedSkins, ['classic', 'ocean']);
    // Not owned, so the default.
    expect(doc.selectedSkin, 'classic');
    expect(doc.museumCollected, {'ch01': LocalDate(2026, 9, 12)});
    expect(doc.daily.freezes, DailyProgress.maxFreezes);
    expect(doc.daily.done, [LocalDate(2026, 9, 24)]);
    // A generated board without its level can't resume.
    expect(doc.inProgress, isNull);
    expect(doc.stats.boostersUsed, {'undo': 2});
    expect(doc.playerId, isNull);
    // The §13.3 settings stay in the settings box (m3-design §3.1).
    expect(doc.unknown, isEmpty);
  });

  test(
    'a daily board is only read from daily, the others only from the top',
    () {
      const board = {
        'kind': 'daily',
        'number': 20260926,
        'levelId': 'daily-20260926',
        'levelVersion': 1,
        'session': {'format': 1},
        'level': {'id': 'daily-20260926'},
      };
      final read = SaveDocumentCodec.read(
        jsonEncode({
          'schema': 1,
          'inProgress': board,
          'daily': {'inProgress': board},
        }),
      );
      expect(read.document.inProgress, isNull);
      expect(
        read.document.daily.inProgress?.request,
        const PlayRequest.daily(20260926),
      );
    },
  );

  test('dates keep the last 31, sorted', () {
    final days = [
      for (var i = 40; i >= 0; i--) LocalDate(2026, 9, 1).addDays(i).toIso(),
    ];
    final read = SaveDocumentCodec.read(
      jsonEncode({
        'schema': 1,
        'daily': {'done': days},
      }),
    );
    final done = read.document.daily.done;
    expect(done, hasLength(DailyProgress.maxDates));
    expect(done.first, LocalDate(2026, 9, 11));
    expect(done.last, LocalDate(2026, 10, 11));
  });

  group('schema 2 (m7-design §3.2)', () {
    SaveDocument readSchema2(Map<String, Object?> fields) =>
        SaveDocumentCodec.read(jsonEncode({'schema': 2, ...fields})).document;

    test('the flame is lit exactly while a run is going', () {
      expect(
        readSchema2({
          'daily': {'streak': 5, 'lit': true, 'run': 2},
        }).daily,
        const DailyProgress(streak: 5, lit: true, run: 2),
      );
      // A missing `lit` follows the run.
      expect(
        readSchema2({
          'daily': {'streak': 5, 'run': 2},
        }).daily.lit,
        isTrue,
      );
      // A pair that disagrees reads as paused.
      for (final daily in [
        {'streak': 5, 'lit': true, 'run': 0},
        {'streak': 5, 'lit': false, 'run': 4},
        {'streak': 5, 'lit': 'yes', 'run': -1},
      ]) {
        final read = readSchema2({'daily': daily}).daily;
        expect(read.lit, isFalse, reason: '$daily');
        expect(read.run, 0, reason: '$daily');
        expect(read.streak, 5, reason: '$daily');
      }
    });

    test('best moves keep readable keys with at least one move', () {
      expect(
        readSchema2({
          'levelBests': {
            'L0001@1': 3,
            'L0002@1': 0,
            'L0003@1': 'nine',
            '': 4,
            'L0004@2': 7.0,
          },
        }).levelBests,
        {'L0001@1': 3, 'L0004@2': 7},
      );
    });

    test('records read leniently, unknown badges kept in order', () {
      expect(
        readSchema2({
          'records': {
            'families': 12,
            'dolls': -3,
            'dailies': 'many',
            'longestRun': 4,
            'badges': ['first_family', 7, 'first_family', 'from_the_future'],
          },
        }).records,
        const SaveRecords(
          families: 12,
          longestRun: 4,
          badges: ['first_family', 'from_the_future'],
        ),
      );
      expect(
        const SaveRecords(badges: ['from_the_future', 'first_family']).earned,
        [BadgeId.firstFamily],
      );
    });

    test('chests keep distinct level numbers, ascending, apart per source', () {
      expect(
        readSchema2({
          'chests': {
            'opened': [30, 10, 30, 0, 'x'],
            'bonusOpened': [20, 10],
          },
        }).chests,
        const ChestProgress(opened: [10, 30], bonusOpened: [10, 20]),
      );
    });

    test('there are always three rivals; rival 1 and any rival with a win '
        'are unlocked', () {
      expect(readSchema2({}).race, const RaceProgress());
      expect(
        readSchema2({
          'race': {
            'rivals': [
              {'unlocked': false, 'wins': 0, 'raceNo': 2},
              {'unlocked': false, 'wins': 1, 'raceNo': 3},
            ],
          },
        }).race.rivals,
        const [
          RivalProgress(unlocked: true, raceNo: 2),
          RivalProgress(unlocked: true, wins: 1, raceNo: 3),
          RivalProgress(),
        ],
      );
      final four = readSchema2({
        'race': {
          'rivals': [
            for (var i = 0; i < 4; i++) {'unlocked': true, 'wins': i},
          ],
        },
      }).race.rivals;
      expect(four, hasLength(RaceProgress.rivalCount));
    });

    // M7 review R31: phase 3's fields (m7-design P3.4) read leniently.
    test('star counts keep readable level ids with an integral 1-3', () {
      expect(
        readSchema2({
          'levelStars': {
            '': 3,
            'L1': 4,
            'L2': 2.0,
            'L3': '3',
            'L4': 0,
            'L5': 1,
            'L6': 2.5,
            'L7': null,
            'L8': -1,
            'L9': true,
            'L10': 3,
          },
        }).levelStars,
        {'L2': 2, 'L5': 1, 'L10': 3},
      );
      for (final value in [
        [3],
        'L1',
        3,
        null,
      ]) {
        expect(
          readSchema2({'levelStars': value}).levelStars,
          isEmpty,
          reason: '$value',
        );
      }
    });

    test('starTipShown is true only for a stored true', () {
      expect(readSchema2({'starTipShown': true}).starTipShown, isTrue);
      for (final value in ['yes', 1, 'true', null, <String, Object?>{}]) {
        expect(
          readSchema2({'starTipShown': value}).starTipShown,
          isFalse,
          reason: '$value',
        );
      }
    });

    test('the last daily solve needs a real date; bad counts read 0 and a '
        'minute outside 0-1439 reads null', () {
      DailySolve? solve(Object? value) => readSchema2({
        'daily': {'lastSolve': value},
      }).daily.lastSolve;
      final date = LocalDate(2026, 9, 24);

      for (final value in [
        null,
        '2026-09-24',
        {'moves': 3, 'families': 2, 'minute': 600},
        {'date': '2026-02-30', 'moves': 3},
        {'date': '2026-9-24'},
        {'date': 20260924},
      ]) {
        expect(solve(value), isNull, reason: '$value');
      }
      expect(
        solve({'date': '2026-09-24', 'moves': 14, 'families': 4, 'minute': 0}),
        DailySolve(date: date, moves: 14, families: 4, minuteOfDay: 0),
      );
      expect(solve({'date': '2026-09-24', 'minute': 1439})!.minuteOfDay, 1439);
      expect(solve({'date': '2026-09-24', 'minute': 600.0})!.minuteOfDay, 600);
      for (final minute in [1440, -1, 600.5, '600', true, null]) {
        expect(
          solve({'date': '2026-09-24', 'minute': minute})!.minuteOfDay,
          isNull,
          reason: '$minute',
        );
      }
      expect(
        solve({'date': '2026-09-24', 'moves': -2, 'families': 'x'}),
        DailySolve(date: date),
      );
    });

    test('an in-progress board is hinted only for a stored true', () {
      Map<String, Object?> board(Object? hinted) => {
        'kind': 'campaign',
        'number': 24,
        'levelId': 'L0024',
        'levelVersion': 2,
        'session': {'format': 1},
        'hinted': ?hinted,
      };
      expect(readSchema2({'inProgress': board(true)}).inProgress!.hinted, true);
      for (final value in ['y', 1, 'true', null]) {
        final level = readSchema2({'inProgress': board(value)}).inProgress;
        expect(level, isNotNull, reason: '$value');
        expect(level!.hinted, isFalse, reason: '$value');
      }
    });

    test('a replay board in progress is never read (a replay is never '
        'saved, m7-design §6)', () {
      final doc = readSchema2({
        'inProgress': {
          'kind': 'replay',
          'number': 3,
          'levelId': 'L0003',
          'levelVersion': 1,
          'session': {'format': 1},
        },
      });
      expect(doc.inProgress, isNull);
    });

    test('a race board in progress is never read (a race is never saved, '
        'm7-design P2.4, P2.13)', () {
      final doc = readSchema2({
        'inProgress': {
          'kind': 'race',
          'number': 1,
          'levelId': 'race-1-1',
          'levelVersion': 1,
          'session': {'format': 1},
        },
      });
      expect(doc.inProgress, isNull);
    });
  });
}
