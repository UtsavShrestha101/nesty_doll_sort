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
      lastDate: LocalDate(2026, 9, 25),
      freezes: 1,
      freezeWeek: 202639,
      done: [LocalDate(2026, 9, 24)],
      frozen: [LocalDate(2026, 9, 25)],
      noticeDate: LocalDate(2026, 9, 25),
      chestPending: true,
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
    ),
    adCounters: const AdCounters(winsSinceInterstitial: 1, lastAdAt: 5),
    stats: const SaveStats(wins: 23, moves: 612, boostersUsed: {'hint': 2}),
    seenIntros: const ['towers'],
    tutorialDone: true,
    bonus: const BonusProgress(next: 3),
    playerId: '7F3A-21C9',
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
    expect(keys.sublist(keys.length - 3), ['playerId', 'alpha', 'zeta']);
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
    expect(SaveDocumentCodec.encode(read.document)['schema'], 1);
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
}
