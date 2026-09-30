import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/fake_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fake_level_resolver.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/features/museum/cubit/museum_cubit.dart';

import '../../helpers/level_fixtures.dart';

/// `MuseumCubit` over the bundled 10-chapter catalog (docs/plans/
/// m3-design.md §10.6): earned/next/locked, the collected date, and the
/// live refresh through `SaveService.changes` when a win completes a
/// chapter while the tab stays mounted.
void main() {
  final catalog = FakeCatalogRepository();

  /// A campaign entry at every play order up to [currentLevel], so
  /// `FakeLevelResolver.homeRequest` resolves to `campaign(currentLevel)`.
  FakeLevelRepository levelsThrough(int currentLevel) {
    final level = levelFrom(tutorialLevelJson);
    return FakeLevelRepository(
      entries: [
        for (var order = 1; order <= currentLevel; order++)
          entryFor(level, order: order),
      ],
    );
  }

  ({MuseumCubit cubit, FakeSaveService save}) build({
    required SaveDocument document,
  }) {
    final save = FakeSaveService(initial: document);
    final resolver = FakeLevelResolver(
      levelsThrough(document.currentLevel),
      save,
      FakeRemoteConfigService(),
    );
    return (cubit: MuseumCubit(save, catalog, resolver), save: save);
  }

  test(
    'load reads coins, totals and each chapter\'s earned/next/locked state',
    () async {
      final built = build(
        document: SaveDocument(
          coins: 90,
          currentLevel: 36,
          museum: const ['ch01'],
          museumCollected: {'ch01': LocalDate(2026, 9, 12)},
        ),
      );
      expect(built.cubit.state, const AsyncValue<MuseumState>.initial());
      final states = <AsyncValue<MuseumState>>[];
      final sub = built.cubit.stream.listen(states.add);
      await built.cubit.load();
      await sub.cancel();

      expect(states.first, const AsyncValue<MuseumState>.loading());
      final data = built.cubit.state.data!;
      expect(data.coins, 90);
      expect(data.collectedCount, 1);
      expect(data.totalChapters, 10);
      expect(data.entries, hasLength(10));
      expect(data.homeLevelNumber, 36);
      expect(data.homeRequest, const PlayRequest.campaign(36));

      final ch01 = data.entries[0];
      expect(ch01.chapterId, 'ch01');
      expect(ch01.figurineId, 'classic');
      expect(ch01.earned, isTrue);
      expect(ch01.isNext, isFalse);
      expect(ch01.done, 20);
      expect(ch01.total, 20);
      expect(ch01.collectedOn, LocalDate(2026, 9, 12));

      final ch02 = data.entries[1];
      expect(ch02.figurineId, 'sailor');
      expect(ch02.earned, isFalse);
      expect(ch02.isNext, isTrue);
      expect(ch02.done, 15);
      expect(ch02.total, 20);
      expect(ch02.collectedOn, isNull);

      final ch03 = data.entries[2];
      expect(ch03.earned, isFalse);
      expect(ch03.isNext, isFalse);
      expect(ch03.done, 0);

      expect(data.next, ch02);
      expect(data.allCollected, isFalse);
    },
  );

  test(
    'an earned chapter with no recorded date shows a null collectedOn',
    () async {
      final built = build(
        document: const SaveDocument(currentLevel: 25, museum: ['ch01']),
      );
      await built.cubit.load();
      final ch01 = built.cubit.state.data!.entries[0];
      expect(ch01.earned, isTrue);
      expect(ch01.collectedOn, isNull);
    },
  );

  test('D111: a chapter whose levels are all won never reads "soon", even '
      'before `museum` catches up (the dev "Jump to a level" bug)', () async {
    // The dev picker (or anything else moving currentLevel/highestLevel
    // without a normal win) can leave `museum` behind: chapters 1 and 2
    // are both fully played here ("Classic · soon" with a 20/20 badge
    // was seen this way), but only chapter 1 was ever actually recorded.
    final built = build(
      document: const SaveDocument(currentLevel: 41, museum: ['ch01']),
    );
    await built.cubit.load();
    final data = built.cubit.state.data!;

    final ch01 = data.entries[0];
    expect(ch01.earned, isTrue); // from `museum`, unchanged

    final ch02 = data.entries[1];
    expect(ch02.done, 20);
    expect(ch02.total, 20);
    expect(ch02.earned, isTrue, reason: 'all 20 levels won: never "soon"');
    expect(ch02.isNext, isFalse);

    final ch03 = data.entries[2];
    expect(ch03.done, 0);
    expect(ch03.earned, isFalse);
    expect(ch03.isNext, isTrue, reason: 'the real next chapter, not ch02');

    // The collection card's "N / 10" counts every earned chapter,
    // including the derived one, so it never disagrees with the cabinet.
    expect(data.collectedCount, 2);
  });

  test('every chapter collected has no next and reads allCollected', () async {
    final allIds = [
      for (var n = 1; n <= 10; n++) 'ch${n.toString().padLeft(2, '0')}',
    ];
    final built = build(
      document: SaveDocument(currentLevel: 200, museum: allIds),
    );
    await built.cubit.load();
    final data = built.cubit.state.data!;
    expect(data.next, isNull);
    expect(data.allCollected, isTrue);
    expect(data.entries.every((e) => e.earned), isTrue);
  });

  test('a coin change refreshes through the save\'s changes stream', () async {
    final built = build(document: const SaveDocument(coins: 10));
    await built.cubit.load();
    built.save.addCoins(15);
    await Future<void>.delayed(Duration.zero);
    expect(built.cubit.state.data!.coins, 25);
  });

  test(
    'a win that completes a chapter updates the cabinet without a spinner',
    () async {
      final built = build(
        document: const SaveDocument(currentLevel: 20, museum: []),
      );
      await built.cubit.load();
      expect(built.cubit.state.data!.entries[0].earned, isFalse);

      built.save.recordLevelWin(
        LevelWinRecord(
          request: const PlayRequest.campaign(20),
          rewardCoins: 10,
          completedChapterId: 'ch01',
          chapterReward: 150,
          date: LocalDate(2026, 9, 27),
        ),
      );
      final states = <AsyncValue<MuseumState>>[];
      final sub = built.cubit.stream.listen(states.add);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      // Every emission carries data: the cabinet never shows a spinner for
      // a live refresh (`MuseumCubit._refresh`'s `AsyncValue.loading(data:)`
      // is never used here since the load already has data).
      expect(states, isNotEmpty);
      for (final value in states) {
        expect(value.data, isNotNull);
      }
      final data = built.cubit.state.data!;
      expect(data.coins, 160);
      expect(data.entries[0].earned, isTrue);
      expect(data.entries[0].collectedOn, LocalDate(2026, 9, 27));
      expect(data.homeLevelNumber, 21);
    },
  );

  test('close cancels the save subscription', () async {
    final built = build(document: const SaveDocument());
    await built.cubit.load();
    await built.cubit.close();
    // No error: a change after close is ignored (BaseAsyncCubit.isClosed).
    built.save.addCoins(5);
    await Future<void>.delayed(Duration.zero);
  });
}
