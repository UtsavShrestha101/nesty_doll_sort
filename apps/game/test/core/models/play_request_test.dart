import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/intro_mechanic.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/models/reduce_motion_mode.dart';

import '../../helpers/level_fixtures.dart';

/// The requests the router, the bloc and the save share
/// (docs/plans/m3-design.md §6.1), and the intro-card mechanics (§10.4).
void main() {
  test('a request knows its kind and number, and compares by value', () {
    expect(const PlayRequest.campaign(24).kind, PlayKind.campaign);
    expect(const PlayRequest.bonus(3).number, 3);
    expect(const PlayRequest.daily(20260926).number, 20260926);
    expect(const PlayRequest.daily(20260926).isGenerated, isTrue);
    expect(const PlayRequest.campaign(1).isGenerated, isFalse);
    expect(const PlayRequest.bonus(2), const PlayRequest.bonus(2));
    expect(const PlayRequest.bonus(2), isNot(const PlayRequest.campaign(2)));
  });

  test('tryCreate refuses what no request can be', () {
    expect(
      PlayRequest.tryCreate(PlayKind.campaign, 5),
      const PlayRequest.campaign(5),
    );
    expect(PlayRequest.tryCreate(PlayKind.bonus, 0), isNull);
    expect(PlayRequest.tryCreate(PlayKind.daily, 7), isNull);
    expect(PlayKind.tryFromId('daily'), PlayKind.daily);
    expect(PlayKind.tryFromId('weekly'), isNull);
  });

  test('a replay is a bundled level of its own kind, never generated '
      '(m7-design §6)', () {
    const replay = PlayRequest.replay(12);
    expect(replay.kind, PlayKind.replay);
    expect(replay.number, 12);
    expect(replay.isReplay, isTrue);
    expect(replay.isBundled, isTrue);
    expect(replay.isGenerated, isFalse);
    expect(replay, isNot(const PlayRequest.campaign(12)));
    expect(const PlayRequest.campaign(12).isBundled, isTrue);
    expect(const PlayRequest.bonus(1).isBundled, isFalse);
    expect(PlayRequest.tryCreate(PlayKind.replay, 12), replay);
    expect(PlayRequest.tryCreate(PlayKind.replay, 0), isNull);
    expect(PlayKind.tryFromId('replay'), PlayKind.replay);
  });

  test('reduce motion resolves against the system flag and reads '
      'leniently (m7-design §14)', () {
    for (final system in [true, false]) {
      expect(
        ReduceMotionMode.system.resolve(systemDisablesAnimations: system),
        system,
      );
      expect(
        ReduceMotionMode.on.resolve(systemDisablesAnimations: system),
        isTrue,
      );
      expect(
        ReduceMotionMode.off.resolve(systemDisablesAnimations: system),
        isFalse,
      );
    }
    expect(
      ReduceMotionMode.fromStorage('on', fallback: ReduceMotionMode.system),
      ReduceMotionMode.on,
    );
    for (final junk in [null, 'sometimes', 3]) {
      expect(
        ReduceMotionMode.fromStorage(junk, fallback: ReduceMotionMode.system),
        ReduceMotionMode.system,
      );
    }
  });

  test('intro mechanics are read off the board, in card order', () {
    expect(IntroMechanic.presentIn(levelFrom(tutorialLevelJson)), isEmpty);
    final level = Level(
      id: 'T',
      maxSize: 3,
      shelves: [
        [
          OpenSlot(nest: Nest.run(DollColor.red, outer: 3, length: 3), ice: 1),
          TowerSlot([Nest.run(DollColor.blue, outer: 3, length: 3)]),
          LockedSlot(unlockColor: DollColor.red),
        ],
      ],
    );
    expect(IntroMechanic.presentIn(level), IntroMechanic.values);
    expect(IntroMechanic.tryFromId('glass'), IntroMechanic.glass);
  });
}
