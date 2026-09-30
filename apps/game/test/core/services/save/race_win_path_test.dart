import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart' show DifficultyCurve;
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

/// The vs Computer save API (spec-prop §7.7, §7.8; docs/plans/m7-design.md
/// P2.7): [SaveService.beginRace] and [SaveService.recordRaceWin], every
/// branch, in one document update each, plus how every other save method
/// treats a race (never saved, never the level win path).
void main() {
  FakeSaveService saveWith({List<RivalProgress>? rivals, int? highestLevel}) =>
      FakeSaveService(
        initial: SaveDocument(
          currentLevel: highestLevel ?? 1,
          highestLevel: highestLevel ?? 1,
          race: RaceProgress(rivals: rivals ?? RaceProgress.defaultRivals),
        ),
      );

  /// Listens to [save.changes] and counts them, cancelled on tear down.
  Future<int> Function() changeCounter(SaveService save) {
    var count = 0;
    final subscription = save.changes.listen((_) => count++);
    addTearDown(subscription.cancel);
    return () async {
      await pumpEventQueue();
      final result = count;
      count = 0;
      return result;
    };
  }

  group('beginRace', () {
    test('stores raceNo + 1 for an unlocked rival, in one update and one '
        'changes event', () async {
      final save = saveWith();
      final changes = changeCounter(save);

      final raceNo = save.beginRace(1);

      expect(raceNo, 1);
      expect(save.document.race.rivals[0].raceNo, 1);
      expect(await changes(), 1);

      final second = save.beginRace(1);
      expect(second, 2);
      expect(save.document.race.rivals[0].raceNo, 2);
      expect(await changes(), 1);
    });

    test('is null, with nothing written, for a rival still locked', () async {
      final save = saveWith(); // rivals 2 and 3 start locked.
      final changes = changeCounter(save);

      expect(save.beginRace(2), isNull);
      expect(save.beginRace(3), isNull);

      expect(save.document.race.rivals[1].raceNo, 0);
      expect(save.document.race.rivals[2].raceNo, 0);
      expect(await changes(), 0);
    });

    test('is null, with nothing written, for a rival outside 1..3', () async {
      final save = saveWith();
      final changes = changeCounter(save);

      expect(save.beginRace(0), isNull);
      expect(save.beginRace(4), isNull);
      expect(save.beginRace(-1), isNull);

      expect(await changes(), 0);
    });

    test('stays at DifficultyCurve.maxRaceNo: New race then replays the '
        'last board (m7-design P2.14 Q126)', () {
      final save = saveWith(
        rivals: const [
          RivalProgress(unlocked: true, raceNo: DifficultyCurve.maxRaceNo),
          RivalProgress(),
          RivalProgress(),
        ],
      );

      expect(save.beginRace(1), DifficultyCurve.maxRaceNo);
      expect(save.document.race.rivals[0].raceNo, DifficultyCurve.maxRaceNo);
    });

    test("doesn't touch the other rivals", () {
      final save = saveWith(
        rivals: const [
          RivalProgress(unlocked: true, raceNo: 4),
          RivalProgress(unlocked: true, wins: 2, raceNo: 9),
          RivalProgress(),
        ],
      );
      save.beginRace(1);
      expect(
        save.document.race.rivals[1],
        const RivalProgress(unlocked: true, wins: 2, raceNo: 9),
      );
      expect(save.document.race.rivals[2], const RivalProgress());
    });
  });

  group('recordRaceWin', () {
    test('pays the reward, counts the win and does everything in one '
        'update and one changes event', () async {
      final save = saveWith(
        rivals: const [
          RivalProgress(unlocked: true, raceNo: 1),
          RivalProgress(),
          RivalProgress(),
        ],
        highestLevel: 25,
      );
      final changes = changeCounter(save);

      final outcome = save.recordRaceWin(
        const RaceWinRecord(
          rival: 1,
          raceNo: 1,
          rewardCoins: 20,
          moves: 15,
          families: 2,
          dolls: 6,
        ),
      );

      expect(save.coins, 20);
      expect(save.document.race.rivals[0].wins, 1);
      expect(save.document.stats.wins, 1);
      expect(save.document.stats.moves, 15);
      expect(save.document.records.families, 2);
      expect(save.document.records.dolls, 6);
      expect(outcome.coins, 20);
      expect(outcome.wins, 1);
      expect(await changes(), 1);
    });

    test('unlocks the next rival strictly in order, reported once', () {
      final save = saveWith();
      final firstWin = save.recordRaceWin(
        const RaceWinRecord(rival: 1, raceNo: 1, rewardCoins: 20),
      );
      expect(firstWin.unlockedRival, 2);
      expect(save.document.race.rivals[1].unlocked, isTrue);
      expect(save.document.race.rivals[2].unlocked, isFalse);

      // A rival already unlocked stays that way, and isn't reported again.
      final secondWinAgainstRival1 = save.recordRaceWin(
        const RaceWinRecord(rival: 1, raceNo: 2, rewardCoins: 20),
      );
      expect(secondWinAgainstRival1.unlockedRival, isNull);

      final secondRivalWin = save.recordRaceWin(
        const RaceWinRecord(rival: 2, raceNo: 1, rewardCoins: 30),
      );
      expect(secondRivalWin.unlockedRival, 3);
      expect(save.document.race.rivals[2].unlocked, isTrue);
    });

    test('rival 3 unlocks nothing', () {
      final save = saveWith(
        rivals: const [
          RivalProgress(unlocked: true, wins: 4),
          RivalProgress(unlocked: true, wins: 1),
          RivalProgress(unlocked: true),
        ],
      );
      final outcome = save.recordRaceWin(
        const RaceWinRecord(rival: 3, raceNo: 1, rewardCoins: 40),
      );
      expect(outcome.unlockedRival, isNull);
    });

    test('a Rematch win pays again (m7-design P2.14 Q124)', () {
      final save = saveWith();
      save.recordRaceWin(
        const RaceWinRecord(rival: 1, raceNo: 3, rewardCoins: 20),
      );
      final again = save.recordRaceWin(
        const RaceWinRecord(rival: 1, raceNo: 3, rewardCoins: 20),
      );
      expect(save.coins, 40);
      expect(again.wins, 2);
    });

    test('first_race grants once, across every rival', () {
      final save = saveWith();
      final first = save.recordRaceWin(
        const RaceWinRecord(rival: 1, raceNo: 1, rewardCoins: 20),
      );
      // A first win of any kind also grants first_family (BadgeRules.
      // derivable: stats.wins >= 1); first_race is the race-specific one.
      expect(first.newBadges, [BadgeId.firstFamily, BadgeId.firstRace]);
      expect(save.document.records.has(BadgeId.firstRace), isTrue);

      final second = save.recordRaceWin(
        const RaceWinRecord(rival: 1, raceNo: 2, rewardCoins: 20),
      );
      expect(second.newBadges, isNot(contains(BadgeId.firstRace)));
      expect(second.newBadges, isNot(contains(BadgeId.firstFamily)));
    });

    test('all_rivals grants on the last rival beaten for the first time', () {
      final save = saveWith(
        rivals: const [
          RivalProgress(unlocked: true, wins: 1),
          RivalProgress(unlocked: true, wins: 1),
          RivalProgress(unlocked: true),
        ],
      );
      final outcome = save.recordRaceWin(
        const RaceWinRecord(rival: 3, raceNo: 1, rewardCoins: 40),
      );
      expect(outcome.newBadges, contains(BadgeId.allRivals));
    });

    test("board badges (RaceWinRecord.boardBadges) are the win's own, "
        'reported once with the derivable ones', () {
      final save = saveWith();
      final outcome = save.recordRaceWin(
        const RaceWinRecord(
          rival: 1,
          raceNo: 1,
          rewardCoins: 20,
          boardBadges: [BadgeId.tallOrder, BadgeId.glassBreaker],
        ),
      );
      // Rivals 2 and 3 are still locked and winless, so all_rivals doesn't
      // grant; first_family does, on any first win.
      expect(outcome.newBadges, [
        BadgeId.firstFamily,
        BadgeId.glassBreaker,
        BadgeId.tallOrder,
        BadgeId.firstRace,
      ]);
      expect(save.document.records.badges, [
        'first_family',
        'glass_breaker',
        'tall_order',
        'first_race',
      ]);
    });

    test('throws a RangeError for a rival outside 1..3', () {
      final save = saveWith();
      expect(
        () => save.recordRaceWin(
          const RaceWinRecord(rival: 0, raceNo: 1, rewardCoins: 20),
        ),
        throwsRangeError,
      );
      expect(
        () => save.recordRaceWin(
          const RaceWinRecord(rival: 4, raceNo: 1, rewardCoins: 20),
        ),
        throwsRangeError,
      );
    });

    test('throws a RangeError for a raceNo outside 1..maxRaceNo', () {
      final save = saveWith();
      expect(
        () => save.recordRaceWin(
          const RaceWinRecord(rival: 1, raceNo: 0, rewardCoins: 20),
        ),
        throwsRangeError,
      );
      expect(
        () => save.recordRaceWin(
          const RaceWinRecord(
            rival: 1,
            raceNo: DifficultyCurve.maxRaceNo + 1,
            rewardCoins: 20,
          ),
        ),
        throwsRangeError,
      );
    });

    test('throws a RangeError for a negative reward', () {
      final save = saveWith();
      expect(
        () => save.recordRaceWin(
          const RaceWinRecord(rival: 1, raceNo: 1, rewardCoins: -1),
        ),
        throwsRangeError,
      );
    });

    test('a loss writes nothing: it has no call at all (spec-prop §7.7 '
        '"leaving it ends it with no reward")', () {
      // recordRaceWin has no loss variant; the absence of a call is the
      // contract. This test documents it: an untouched save stays at its
      // initial coins and wins.
      final save = saveWith();
      expect(save.coins, 0);
      expect(save.document.race.rivals[0].wins, 0);
    });
  });

  group('a race and every other save method', () {
    test('recordLevelWin records nothing for a race and returns an empty '
        'outcome (m7-design P2.7)', () {
      final save = saveWith(highestLevel: 25);
      final before = save.document;
      final outcome = save.recordLevelWin(
        const LevelWinRecord(
          request: PlayRequest.race(rival: 1, raceNo: 1),
          rewardCoins: 999,
          moves: 40,
          families: 5,
          dolls: 10,
          boardBadges: [BadgeId.tallOrder],
        ),
      );
      expect(outcome, const LevelWinOutcome());
      expect(save.document, before);
    });

    test('saveInProgress ignores a race board: nothing is ever stored for '
        'one (m7-design §6, P2.4)', () {
      final save = saveWith();
      save.saveInProgress(
        const InProgressLevel(
          request: PlayRequest.race(rival: 1, raceNo: 1),
          levelId: 'race-1-1',
          levelVersion: 1,
          session: {'format': 1},
        ),
      );
      expect(save.document.inProgress, isNull);
      expect(save.inProgressFor(PlayKind.race), isNull);
    });

    test('saveInProgress for a race never clobbers the main line board '
        'already saved', () {
      final save = saveWith();
      const main = InProgressLevel(
        request: PlayRequest.campaign(3),
        levelId: 'L0003',
        levelVersion: 1,
        session: {'format': 1},
      );
      save
        ..saveInProgress(main)
        ..saveInProgress(
          const InProgressLevel(
            request: PlayRequest.race(rival: 1, raceNo: 1),
            levelId: 'race-1-1',
            levelVersion: 1,
            session: {'format': 1},
          ),
        );
      expect(save.document.inProgress, main);
    });

    test('clearInProgress(race) does nothing: nothing to clear', () {
      final save = saveWith();
      const main = InProgressLevel(
        request: PlayRequest.campaign(3),
        levelId: 'L0003',
        levelVersion: 1,
        session: {'format': 1},
      );
      save.saveInProgress(main);
      save.clearInProgress(PlayKind.race);
      expect(save.document.inProgress, main);
    });

    test('SaveDocument.inProgressOf(race) is always null', () {
      const doc = SaveDocument(
        inProgress: InProgressLevel(
          request: PlayRequest.campaign(3),
          levelId: 'L0003',
          levelVersion: 1,
          session: {'format': 1},
        ),
      );
      expect(doc.inProgressOf(PlayKind.race), isNull);
    });
  });

  group('load-time race badges', () {
    test('a save with race wins already recorded grants first_race and '
        'all_rivals silently on load (m7-design §12)', () async {
      final save = FakeSaveService(
        initial: const SaveDocument(
          race: RaceProgress(
            rivals: [
              RivalProgress(unlocked: true, wins: 3),
              RivalProgress(unlocked: true, wins: 1),
              RivalProgress(unlocked: true, wins: 2),
            ],
          ),
        ),
      );
      await save.load();
      expect(save.document.records.has(BadgeId.firstRace), isTrue);
      expect(save.document.records.has(BadgeId.allRivals), isTrue);
    });

    test('a win against only some rivals grants first_race but not '
        'all_rivals', () async {
      final save = FakeSaveService(
        initial: const SaveDocument(
          race: RaceProgress(
            rivals: [
              RivalProgress(unlocked: true, wins: 1),
              RivalProgress(unlocked: true),
              RivalProgress(),
            ],
          ),
        ),
      );
      await save.load();
      expect(save.document.records.has(BadgeId.firstRace), isTrue);
      expect(save.document.records.has(BadgeId.allRivals), isFalse);
    });

    test('no race wins at all grants neither, silently', () async {
      final save = FakeSaveService();
      await save.load();
      expect(save.document.records.has(BadgeId.firstRace), isFalse);
      expect(save.document.records.has(BadgeId.allRivals), isFalse);
    });
  });
}
