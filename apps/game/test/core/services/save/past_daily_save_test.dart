import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/database/hive_database_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/hive_save_service.dart';
import 'package:nesty_game/core/services/save/in_memory_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_document_codec.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

/// The past dailies' in-progress routing (plan-local-habits §3, §7.5c), on
/// both save services: a past day's board lives in `dailyArchive.inProgress`
/// beside today's daily and the main line, and a second one replaces it.
InProgressLevel board(PlayRequest request) => InProgressLevel(
  request: request,
  levelId: 'L${request.number}',
  levelVersion: 1,
  session: const {'format': 1},
  level: request.isGenerated ? const {'id': 'gen'} : null,
);

void contract(String name, Future<SaveService> Function() make) {
  group('$name: a past day\'s board', () {
    late SaveService save;
    setUp(() async {
      save = await make();
      await save.load();
    });
    tearDown(() => save.dispose());

    test('goes to dailyArchive.inProgress, never daily.inProgress', () {
      save.saveInProgress(board(const PlayRequest.pastDaily(20261005)));
      expect(
        save.inProgressFor(PlayKind.pastDaily)?.request,
        const PlayRequest.pastDaily(20261005),
      );
      expect(save.document.dailyArchive.inProgress?.levelId, 'L20261005');
      expect(save.document.daily.inProgress, isNull);
      expect(save.document.inProgress, isNull);
      expect(save.inProgressFor(PlayKind.daily), isNull);
    });

    test('coexists with today\'s daily board and the main line', () {
      save.saveInProgress(board(const PlayRequest.campaign(7)));
      save.saveInProgress(board(const PlayRequest.daily(20261008)));
      save.saveInProgress(board(const PlayRequest.pastDaily(20261005)));
      expect(save.inProgressFor(PlayKind.campaign)?.levelId, 'L7');
      expect(save.inProgressFor(PlayKind.daily)?.levelId, 'L20261008');
      expect(save.inProgressFor(PlayKind.pastDaily)?.levelId, 'L20261005');

      // Clearing one leaves the others.
      save.clearInProgress(PlayKind.pastDaily);
      expect(save.inProgressFor(PlayKind.pastDaily), isNull);
      expect(save.inProgressFor(PlayKind.daily)?.levelId, 'L20261008');
      expect(save.inProgressFor(PlayKind.campaign)?.levelId, 'L7');
      save.saveInProgress(board(const PlayRequest.pastDaily(20261005)));
      save.clearInProgress(PlayKind.daily);
      expect(save.inProgressFor(PlayKind.daily), isNull);
      expect(save.inProgressFor(PlayKind.pastDaily)?.levelId, 'L20261005');
      expect(save.inProgressFor(PlayKind.campaign)?.levelId, 'L7');
    });

    test('a second past day\'s board replaces the first', () {
      save.saveInProgress(board(const PlayRequest.pastDaily(20261005)));
      save.saveInProgress(board(const PlayRequest.pastDaily(20261004)));
      expect(
        save.inProgressFor(PlayKind.pastDaily)?.request,
        const PlayRequest.pastDaily(20261004),
      );
    });

    test('saving today\'s daily leaves the past day\'s board alone', () {
      save.saveInProgress(board(const PlayRequest.pastDaily(20261005)));
      save.saveInProgress(board(const PlayRequest.daily(20261008)));
      save.clearInProgress(PlayKind.daily);
      expect(save.inProgressFor(PlayKind.pastDaily)?.levelId, 'L20261005');
    });
  });
}

void main() {
  contract(
    'InMemorySaveService',
    () async => InMemorySaveService(
      FakeRemoteConfigService(),
      unlimitedBoosters: false,
    ),
  );

  group('HiveSaveService', () {
    late Directory directory;
    setUp(() async {
      directory = await Directory.systemTemp.createTemp('nesty_past_daily_');
    });
    tearDown(() async {
      await Hive.close();
      if (directory.existsSync()) await directory.delete(recursive: true);
    });

    contract('HiveSaveService', () async {
      final database = await HiveDatabaseService.open(
        directory: directory.path,
      );
      return HiveSaveService(database, FakeRemoteConfigService());
    });

    test('a past day\'s board and today\'s survive a reload, each in its '
        'own slot', () async {
      final first = await HiveDatabaseService.open(directory: directory.path);
      final save = HiveSaveService(first, FakeRemoteConfigService());
      await save.load();
      // A real-shaped board: the codec drops one it can't resume.
      save.saveInProgress(board(const PlayRequest.daily(20261008)));
      save.saveInProgress(board(const PlayRequest.pastDaily(20261005)));
      await save.flush();
      final raw = jsonDecode(first.readSaveDocument()!) as Map<String, Object?>;
      expect(raw['schema'], 4);
      expect(
        ((raw['dailyArchive']! as Map)['inProgress']! as Map)['kind'],
        'pastDaily',
      );
      expect(((raw['daily']! as Map)['inProgress']! as Map)['kind'], 'daily');
      expect(raw['inProgress'], isNull);
      await save.dispose();
      await Hive.close();

      final second = await HiveDatabaseService.open(directory: directory.path);
      final again = HiveSaveService(second, FakeRemoteConfigService());
      await again.load();
      expect(again.inProgressFor(PlayKind.pastDaily)?.levelId, 'L20261005');
      expect(again.inProgressFor(PlayKind.daily)?.levelId, 'L20261008');
      await again.dispose();
    });
  });

  group('SaveDocumentCodec dailyArchive', () {
    final withArchive = SaveDocument(
      dailyArchive: DailyArchive(
        played: [LocalDate(2026, 10, 2), LocalDate(2026, 10, 5)],
        inProgress: board(const PlayRequest.pastDaily(20261004)),
      ),
    );

    test('round-trips the played days and the board', () {
      final text = SaveDocumentCodec.write(withArchive);
      final read = SaveDocumentCodec.read(text);
      expect(read.kind, SaveReadKind.current);
      expect(read.document, withArchive);
      expect(SaveDocumentCodec.write(read.document), text);
    });

    test('a malformed archive reads as empty, never a crash', () {
      for (final bad in <Object?>['x', 7, <Object?>[], null, true]) {
        final read = SaveDocumentCodec.read(
          jsonEncode({'schema': 4, 'coins': 9, 'dailyArchive': bad}),
        );
        expect(read.document.dailyArchive, const DailyArchive());
        expect(read.document.coins, 9);
      }
    });

    test('bad parts are dropped one by one', () {
      final read = SaveDocumentCodec.read(
        jsonEncode({
          'schema': 4,
          'dailyArchive': {
            'played': ['2026-10-05', 'nope', 3, '2026-10-05', '2026-10-01'],
            'inProgress': {'kind': 'pastDaily', 'number': 'x'},
          },
        }),
      );
      expect(read.document.dailyArchive.played, [
        LocalDate(2026, 10, 1),
        LocalDate(2026, 10, 5),
      ]);
      expect(read.document.dailyArchive.inProgress, isNull);
    });

    test('keeps 62 played dates and trims the oldest beyond', () {
      final days = [
        for (var i = 70; i >= 0; i--) LocalDate(2026, 9, 1).addDays(i).toIso(),
      ];
      final read = SaveDocumentCodec.read(
        jsonEncode({
          'schema': 4,
          'dailyArchive': {'played': days},
        }),
      );
      final played = read.document.dailyArchive.played;
      expect(played, hasLength(DailyProgress.maxDates));
      expect(played.first, LocalDate(2026, 9, 10));
      expect(played.last, LocalDate(2026, 11, 10));
    });

    test('a past day\'s board is only read from dailyArchive', () {
      final board = {
        'kind': 'pastDaily',
        'number': 20261004,
        'levelId': 'daily-20261004',
        'levelVersion': 1,
        'session': {'format': 1},
        'level': {'id': 'daily-20261004'},
      };
      final read = SaveDocumentCodec.read(
        jsonEncode({
          'schema': 4,
          'inProgress': board,
          'daily': {'inProgress': board},
          'dailyArchive': {'inProgress': board},
        }),
      );
      expect(read.document.inProgress, isNull);
      expect(read.document.daily.inProgress, isNull);
      expect(
        read.document.dailyArchive.inProgress?.request,
        const PlayRequest.pastDaily(20261004),
      );
      // And today's daily board isn't read from the archive.
      final reverse = SaveDocumentCodec.read(
        jsonEncode({
          'schema': 4,
          'dailyArchive': {
            'inProgress': {...board, 'kind': 'daily'},
          },
        }),
      );
      expect(reverse.document.dailyArchive.inProgress, isNull);
    });

    test('a newer schema keeps its unknown keys beside the archive', () {
      final read = SaveDocumentCodec.read(
        jsonEncode({
          'schema': 9,
          'aFutureKey': 1,
          'dailyArchive': {
            'played': ['2026-10-05'],
          },
        }),
      );
      expect(read.kind, SaveReadKind.newer);
      expect(read.document.unknown, {'aFutureKey': 1});
      expect(read.document.dailyArchive.played, [LocalDate(2026, 10, 5)]);
    });
  });
}
