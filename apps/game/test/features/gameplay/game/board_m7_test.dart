// Phase 4 lane B on the mounted board (architecture §2, D180–D185): the tall
// glass case's composition and unlock, the tower stack, the iced tower (its
// tag hidden and popping in, its doll drawn under the ice), the tap
// feedback, the drag hover and the counter's yield to a hint.

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart' show FxRole;
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/bloc/tap_policy.dart';
import 'package:nesty_game/features/gameplay/game/board_shape_of.dart';
import 'package:nesty_game/features/gameplay/game/components/slot_view.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';
import 'package:nesty_render/nesty_render.dart';

import 'support/board_fixtures.dart';
import 'timeline/support/timeline_fixtures.dart' as tl;

/// A sealed size-5 doll on two shelves (a tall case: 124.6 dp > 117.5), and
/// a red set that completes in one move (red5 nests over the four smaller).
final Level _tallCaseLevel = levelFrom('''
{
  "schemaVersion": 1,
  "id": "T7100",
  "maxSize": 5,
  "shelves": [
    [ {"type": "locked", "unlockColor": "red", "nest": ["blue5"]},
      {"type": "open", "nest": ["red5"]},
      {"type": "open", "nest": ["red4", "red3", "red2", "red1"]},
      {"type": "open", "nest": null} ],
    [ {"type": "open", "nest": ["blue4", "blue3", "blue2", "blue1"]},
      {"type": "open", "nest": null},
      {"type": "open", "nest": null},
      {"type": "open", "nest": null} ]
  ]
}
''');

/// A tower under ice: red3 swallows [red2, red1] on r0c2 and completes red,
/// which cracks the ice (1) on the r0c0 tower over green1 (blue3 on top).
final Level _icedTowerLevel = levelFrom('''
{
  "schemaVersion": 1,
  "id": "T7101",
  "maxSize": 3,
  "shelves": [
    [ {"type": "tower", "stack": [["green1"], ["blue3"]], "ice": 1},
      {"type": "open", "nest": ["red3"]},
      {"type": "open", "nest": ["red2", "red1"]} ],
    [ {"type": "open", "nest": ["green3"]},
      {"type": "open", "nest": ["green2"]},
      {"type": "open", "nest": null} ]
  ]
}
''');

/// Three shelves of three: the top row's middle stand sits under the family
/// counter, where a hint over a tall doll must yield it.
final Level _threeByThree = levelFrom('''
{
  "schemaVersion": 1,
  "id": "T7102",
  "maxSize": 4,
  "shelves": [
    [ {"type": "open", "nest": ["red4"]},
      {"type": "open", "nest": ["red3"]},
      {"type": "open", "nest": ["red2", "red1"]} ],
    [ {"type": "open", "nest": ["blue4"]},
      {"type": "open", "nest": ["blue3"]},
      {"type": "open", "nest": ["blue2", "blue1"]} ],
    [ {"type": "open", "nest": null},
      {"type": "open", "nest": null},
      {"type": "open", "nest": null} ]
  ]
}
''');

/// A tower of three buried nests under a size-4 top, on the middle shelf
/// (room for one silhouette at the 9 dp step), and another under a size-1
/// top (room for all three at the full 18).
final Level _stackLevel = levelFrom('''
{
  "schemaVersion": 1,
  "id": "T7103",
  "maxSize": 4,
  "shelves": [
    [ {"type": "open", "nest": ["red4"]},
      {"type": "open", "nest": ["red3"]},
      {"type": "open", "nest": null} ],
    [ {"type": "tower", "stack": [["blue1"], ["blue2"], ["blue3"], ["blue4"]]},
      {"type": "tower", "stack": [["green1"], ["red1"], ["blue1"], ["green1"]]},
      {"type": "open", "nest": null} ],
    [ {"type": "open", "nest": null},
      {"type": "open", "nest": null},
      {"type": "open", "nest": null} ]
  ]
}
''');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<GameHarness> loaded(
    Level level, {
    bool reduceMotion = false,
    Iterable<FxId>? files,
  }) async {
    final h = await GameHarness.mount(
      level,
      fx: await libraryWith(files ?? boardFiles),
      reduceMotion: reduceMotion,
    );
    await h.start();
    return h;
  }

  group('the shape the board lays out (B.4)', () {
    test('boardShapeOf hands the layout each case\'s sealed size, from the '
        'level (a case broken later keeps it)', () async {
      final shape = boardShapeOf(GameState.initial(_tallCaseLevel));
      expect(shape.rows.first.first.kind, SlotShapeKind.locked);
      expect(shape.rows.first.first.lockedSize, 5);
      for (final slot in [...shape.rows.first.skip(1), ...shape.rows.last]) {
        expect(slot.lockedSize, isNull, reason: slot.id);
      }
      final h = await loaded(_tallCaseLevel);
      await h.move('r0c1', 'r0c2');
      await h.run(4800);
      // The case has shattered in core, but the shape is the level's.
      expect(h.state.slot('r0c0'), isA<OpenSlot>());
      expect(boardShapeOf(h.state), shape);
    });

    test('SlotView reads the tower\'s tallest size and depth at the start', () {
      final view = SlotView.of(GameState.initial(_stackLevel), 'r1c0');
      expect(view.towerSizeAtStart, 4);
      expect(view.buriedAtStart, 3);
      expect(
        SlotView.of(GameState.initial(_stackLevel), 'r0c0').towerSizeAtStart,
        0,
      );
    });
  });

  group('the tall glass case (B.4, D182)', () {
    test('a sealed size-5 doll gets fx_glass_unlock_tall, sized to its doll, '
        'standing on the stand surface', () async {
      final h = await loaded(_tallCaseLevel);
      final g = h.game.geometry!;
      final geometry = g.slot('r0c0');
      final component = h.board.slots['r0c0']!;
      expect(geometry.usesTallCase, isTrue);
      final glass = component.glass!;
      expect(glass.id, FxId.fxGlassUnlockTall);
      // doll_size = case_size = h / (150 · fs).
      final fs = geometry.furnitureScale;
      final k = geometry.dollHeight(5) / (150 * fs);
      expect(glass.drawable.params.caseScale, closeTo(k, 1e-12));
      expect(glass.drawable.params.sizeOf(FxRole.doll)!.dx, closeTo(k, 1e-12));
      // Its stand surface (100, 212) goes on the stand's surface.
      expect(glass.position.y, closeTo(geometry.surfaceY, 1e-3));
      expect(glass.position.x, closeTo(geometry.centerX, 1e-3));
      expect(glass.scale.x, closeTo(fs, 1e-6));
      // The rest sprite doesn't draw the doll: the composition does.
      expect(component.nest.isDrawn, isFalse);
      expect(component.slot.restBaseY(null), geometry.surfaceY);
    });

    test(
      'a sealed doll under 117.5 dp keeps the normal fx_glass_unlock',
      () async {
        final h = await loaded(tl.comboLevel);
        // The combo level is size 3 on two shelves: 140 dp, above the 117.5
        // threshold, so it is a tall case too; a smaller doll isn't.
        expect(h.board.slots['r0c2']!.glass!.id, FxId.fxGlassUnlockTall);
        final small = await loaded(
          levelFrom('''
{
  "schemaVersion": 1,
  "id": "T7104",
  "maxSize": 4,
  "shelves": [
    [ {"type": "locked", "unlockColor": "red", "nest": ["blue2"]},
      {"type": "open", "nest": ["red4", "red3", "red2", "red1"]},
      {"type": "open", "nest": ["red4"]} ],
    [ {"type": "open", "nest": null}, {"type": "open", "nest": null},
      {"type": "open", "nest": null} ],
    [ {"type": "open", "nest": ["blue4", "blue3"]},
      {"type": "open", "nest": null}, {"type": "open", "nest": null} ]
  ]
}
'''),
        );
        expect(small.board.slots['r0c0']!.glass!.id, FxId.fxGlassUnlock);
      },
    );

    test('the unlock plays the tall file and releases it (both ids)', () async {
      final h = await loaded(_tallCaseLevel);
      await h.move('r0c1', 'r0c2');
      await h.run(3600);
      final plays = h.commandsOf<PlaySlotFx>().where(
        (c) => c.slotId == 'r0c0' && c.fx != FxId.fxIce,
      );
      expect(plays.map((c) => c.fx).toSet(), {FxId.fxGlassUnlockTall});
      final releases = h.commandsOf<ReleaseSlotFx>().where(
        (c) => c.slotId == 'r0c0',
      );
      expect(releases.map((c) => c.fx), [FxId.fxGlassUnlockTall]);
      await h.run(1200);
      final component = h.board.slots['r0c0']!;
      expect(component.glass, isNull, reason: 'the case shattered');
      expect(component.nest.isDrawn, isTrue, reason: 'the doll stands free');
      expect(component.slot.restBaseY(null), component.slot.geometry.surfaceY);
    });

    test('a failed tall file draws the static tall case and swaps its '
        'frames', () async {
      final files = [...boardFiles]..remove(FxId.fxGlassUnlockTall);
      final h = await loaded(_tallCaseLevel, files: files);
      final component = h.board.slots['r0c0']!;
      expect(component.glass, isNull);
      expect(component.drawsGlassFallback, isTrue);
      expect(component.nest.isDrawn, isTrue);
      await h.move('r0c1', 'r0c2');
      await h.run(3200);
      expect(component.drawsGlassFallback, isFalse);
    });
  });

  group('the tower stack (B.5, D183)', () {
    test('the silhouettes drawn follow the stack: one under a tall top on '
        'the middle shelf, all three under a small one', () async {
      final h = await loaded(_stackLevel);
      final tall = h.board.scene.slot('r1c0')!;
      final small = h.board.scene.slot('r1c1')!;
      expect(tall.view.buried, hasLength(3));
      expect(tall.view.towerSizeAtStart, 4);
      expect(tall.buriedDrawn, 1, reason: 'a size-4 top leaves room for 1');
      expect(small.buriedDrawn, 3);
      // The tag keeps the real depth.
      expect(tall.decor.tagLabel, '+3');
      expect(small.decor.tagLabel, '+3');
      // The spacing matches the geometry's stack, at rest.
      final g = h.game.geometry!;
      final stack = g.slot('r1c0').towerStack(4, 3);
      expect(
        tall.buriedBaseY(1, null),
        closeTo(g.slot('r1c0').surfaceY - stack.step, 1e-9),
      );
      expect(stack.step, closeTo(9, 1e-9));
    });

    test('a reveal shifts the silhouettes by the same stack the slot draws '
        '(the tower\'s own tallest size, not the level\'s)', () async {
      final h = await loaded(_stackLevel);
      final small = h.board.scene.slot('r1c1')!;
      final before = [for (var d = 1; d <= 3; d++) small.buriedBaseY(d, null)];
      await h.move('r1c1', 'r1c2');
      final tween = h
          .commandsOf<StartTween>()
          .map((c) => c.tween)
          .whereType<RevealDropTween>()
          .single;
      expect(tween.topSize, 1, reason: 'a tower of size-1 nests');
      // At progress 0 the nests are where they were: depth d of the new
      // stack is depth d + 1 of the old one.
      for (var d = 1; d <= 2; d++) {
        expect(tween.buriedBaseY(d), closeTo(before[d], 1e-9), reason: '$d');
      }
      // The step is the small tower's 18, not the level's size-4 stack's.
      final geometry = h.game.geometry!.slot('r1c1');
      expect(
        geometry.surfaceY - tween.buriedBaseY(0),
        closeTo(18, 1e-6),
        reason: 'one step above the nest right under the top',
      );
    });

    test(
      'the spacing stays put as the tower empties (the starting depth)',
      () async {
        final h = await loaded(tl.towerLevel);
        final tower = h.board.scene.slot('r0c0')!;
        final before = tower.buriedBaseY(1, null);
        await h.move('r0c0', 'r0c2');
        await h.run(700);
        expect(tower.view.buried, hasLength(1));
        expect(tower.buriedBaseY(1, null), closeTo(before, 1e-9));
      },
    );
  });

  group('an iced tower (B.7, D183)', () {
    test('the +N tag is hidden while the ice is on, pops in with the '
        'shatter (240 ms from 0.6, easeOutBack), and the doll is drawn by '
        'the slot under the ice', () async {
      final h = await loaded(_icedTowerLevel);
      final tower = h.board.scene.slot('r0c0')!;
      final component = h.board.slots['r0c0']!;
      expect(tower.view.frozen, isTrue);
      expect(tower.decor.hasTag, isFalse, reason: 'hidden while iced');
      expect(tower.decor.hasBadge, isTrue);
      // The ice's composition hides its own doll (an iced tower's stand is
      // 5 dp taller than the composition's): the slot draws it, under it.
      expect(component.ice, isNotNull);
      expect(component.ice!.drawable.images.request.hideDoll, isTrue);
      expect(component.compositionDraws, isFalse);
      expect(component.nest.isDrawn, isTrue);
      // The ice sits where the design puts it: its bottom 16.5 under the
      // plank's top.
      final geometry = tower.geometry;
      expect(
        geometry.iceRect.bottom - geometry.plankTop,
        closeTo(16.5 * geometry.furnitureScale, 1e-6),
      );
      expect(component.ice!.position.y, closeTo(geometry.iceDollBaseY, 1e-3));

      await h.move('r0c1', 'r0c2');
      // The shatter starts 700 ms after the landing + the slot-event
      // stagger: poll for its pop.
      var sawPop = false;
      var lowest = 1.0;
      var highest = 0.0;
      for (var t = 0; t < 4000; t += 8) {
        await h.run(8);
        final pop = tower.tagPop;
        if (pop != null) {
          sawPop = true;
          expect(tower.decor.hasTag, isTrue, reason: 'shown from the start');
          lowest = tower.tagScale < lowest ? tower.tagScale : lowest;
          highest = tower.tagScale > highest ? tower.tagScale : highest;
        }
      }
      expect(sawPop, isTrue);
      expect(lowest, closeTo(MotionTokens.tagPopFrom, 0.05));
      expect(highest, greaterThan(1), reason: 'easeOutBack overshoots');
      expect(tower.tagPop, isNull, reason: 'the pop ended');
      expect(tower.tagScale, 1);
      expect(tower.decor.tagLabel, '+1');
      final starts = h.commandsOf<StartTween>().map((c) => c.tween);
      final pop = starts.whereType<TagPopTween>().single;
      expect(pop.durationMs, closeTo(MotionTokens.tagPopMs, 1e-9));
    });

    test('a restart brings the ice back with the tag hidden again', () async {
      final h = await loaded(_icedTowerLevel);
      final tower = h.board.scene.slot('r0c0')!;
      await h.move('r0c1', 'r0c2');
      await h.run(4000);
      expect(tower.decor.hasTag, isTrue);
      h.session.restart();
      await h.apply(
        BoardResetEffect(snapshot: h.state, reason: BoardResetReason.restart),
      );
      expect(tower.view.frozen, isTrue);
      expect(tower.decor.hasTag, isFalse);
      expect(tower.tagPop, isNull);
      expect(h.board.slots['r0c0']!.nest.isDrawn, isTrue);
    });

    test('a plain iced slot keeps its composition drawing the doll', () async {
      final h = await loaded(tl.comboLevel);
      final iced = h.board.slots['r0c3']!;
      expect(iced.ice!.drawable.images.request.hideDoll, isFalse);
      expect(iced.compositionDraws, isTrue);
      expect(iced.nest.isDrawn, isFalse);
    });
  });

  group('the tap feedback (E.13, D185)', () {
    test('an empty stand dips 2 dp for 80 ms with a light haptic, never the '
        'invalid shake, and gates nothing', () async {
      final h = await loaded(tl.comboLevel);
      final slot = h.board.scene.slot('r1c1')!;
      expect(slot.standDip, 0);
      await h.apply(const SlotNudgeEffect('r1c1', SlotNudgeKind.emptyStand));
      expect(slot.nudge, isNotNull);
      expect(h.cues.where((c) => c.haptic == HapticPattern.pick), hasLength(1));
      expect(h.cues.where((c) => c.sound != null), isEmpty, reason: 'no sound');
      // Nothing is reserved or locked: the next tap plays at once.
      expect(h.timeline.acceptsInput('r1c1'), isTrue);
      expect(h.timeline.inputLocked, isFalse);
      var peak = 0.0;
      for (var t = 0; t < 80; t += 4) {
        await h.run(4);
        if (slot.standDip > peak) peak = slot.standDip;
      }
      expect(peak, closeTo(MotionTokens.tapDip, 0.05));
      await h.run(20);
      expect(slot.nudge, isNull);
      expect(slot.standDip, 0);
      expect(
        h.commandsOf<StartClip>().where((c) => c.clip.fx == FxId.dollInvalid),
        isEmpty,
      );
      expect(
        h.commandsOf<StartTween>().map((c) => c.tween).whereType<ShakeTween>(),
        isEmpty,
      );
    });

    test('a sealed case pings its padlock 1.15× for 160 ms', () async {
      final h = await loaded(tl.comboLevel);
      final slot = h.board.scene.slot('r0c2')!;
      final glass = h.board.slots['r0c2']!.glass!;
      await h.apply(const SlotNudgeEffect('r0c2', SlotNudgeKind.lockedCase));
      var peak = 1.0;
      for (var t = 0; t < 160; t += 4) {
        await h.run(4);
        if (slot.padlockPing > peak) peak = slot.padlockPing;
      }
      expect(peak, closeTo(MotionTokens.padlockPingScale, 0.01));
      // The composition follows the ping (its symbol is scaled).
      await h.apply(const SlotNudgeEffect('r0c2', SlotNudgeKind.lockedCase));
      await h.run(80);
      expect(glass.drawable.params.padlockPing, greaterThan(1));
      await h.run(120);
      expect(slot.padlockPing, 1);
      expect(glass.drawable.params.padlockPing, 1);
      expect(h.cues, isEmpty, reason: 'no cue for a ping');
    });

    test('an iced slot bumps its counter 1.2× for 160 ms', () async {
      final h = await loaded(tl.comboLevel);
      final slot = h.board.scene.slot('r0c3')!;
      await h.apply(const SlotNudgeEffect('r0c3', SlotNudgeKind.iced));
      var peak = 1.0;
      for (var t = 0; t < 160; t += 4) {
        await h.run(4);
        if (slot.badgeBump > peak) peak = slot.badgeBump;
      }
      expect(peak, closeTo(MotionTokens.iceBumpScale, 0.01));
      await h.run(20);
      expect(slot.badgeBump, 1);
    });

    test('reduced motion halves the durations', () async {
      final h = await loaded(tl.comboLevel, reduceMotion: true);
      final slot = h.board.scene.slot('r0c3')!;
      await h.apply(const SlotNudgeEffect('r0c3', SlotNudgeKind.iced));
      expect(slot.nudge!.durationMs, closeTo(MotionTokens.iceBumpMs / 2, 1e-9));
      await h.apply(const SlotNudgeEffect('r1c1', SlotNudgeKind.emptyStand));
      expect(
        h.board.scene.slot('r1c1')!.nudge!.durationMs,
        closeTo(MotionTokens.tapDipMs / 2, 1e-9),
      );
    });

    test('a nudge for a slot the board lacks plans nothing', () async {
      final h = await loaded(tl.comboLevel);
      await h.apply(const SlotNudgeEffect('nope', SlotNudgeKind.emptyStand));
      expect(h.commandsOf<StartTween>(), isEmpty);
    });
  });

  group('the drag hover (E.14, D185)', () {
    Future<(GameHarness, SlotGeometry, SlotGeometry, SlotGeometry)>
    drag() async {
      final h = await loaded(tl.tutorial);
      final g = h.game.geometry!;
      final targets = Rules.legalTargets(h.state, 'r1c1');
      expect(targets, isNotEmpty);
      // What the bloc hands the page on the pick.
      h.game.dropTargets = targets.toSet();
      final legal = g.slot(targets.first);
      final illegal = g.slots.firstWhere(
        (s) => s.id != 'r1c1' && !targets.contains(s.id),
      );
      return (h, g.slot('r1c1'), legal, illegal);
    }

    test('a legal stand under the finger gets fx_select_glow at 60 %, an '
        'illegal one nothing; the glow follows the stand', () async {
      final (h, source, legal, illegal) = await drag();
      expect(
        h.board.beginDrag(1, source.centerX, source.hitRect.center.dy),
        isTrue,
      );
      // Over the source itself: nothing.
      h.board.moveDrag(1, source.centerX, source.hitRect.center.dy);
      expect(h.timeline.hoverSlotId, isNull);
      // Over a legal stand.
      h.board.moveDrag(1, legal.centerX, legal.hitRect.center.dy);
      expect(h.timeline.hoverSlotId, legal.id);
      final glow = h.board.fx.liveClips.singleWhere(
        (c) => c.purpose == FxClipPurpose.hoverGlow,
      );
      expect(glow.fx, FxId.fxSelectGlow);
      expect(glow.slotId, legal.id);
      expect(h.board.fx.componentOf(glow.id)!.opacity, 0.6);
      // It sits on the stand, like the selection's glow.
      expect(
        h.board.fx.componentOf(glow.id)!.position.x,
        closeTo(legal.centerX, 1e-3),
      );
      expect(
        h.board.fx.componentOf(glow.id)!.position.y,
        closeTo(legal.glowCenterY, 1e-3),
      );
      await h.run(300);
      expect(h.board.fx.componentOf(glow.id)!.active, isTrue);
      // Over an illegal stand: the glow goes out (its `out`), no new one.
      h.board.moveDrag(1, illegal.centerX, illegal.hitRect.center.dy);
      expect(h.timeline.hoverSlotId, isNull);
      await h.run(700);
      expect(
        h.board.fx.liveClips.where((c) => c.purpose == FxClipPurpose.hoverGlow),
        isEmpty,
      );
      // Moving inside one column changes nothing (no clip per pointer move).
      h.board.moveDrag(1, legal.centerX, legal.hitRect.center.dy);
      final started = h.commandsOf<StartClip>().length;
      h.board.moveDrag(1, legal.centerX + 2, legal.hitRect.center.dy);
      h.board.moveDrag(1, legal.centerX - 2, legal.hitRect.center.dy + 1);
      expect(h.commandsOf<StartClip>().length, started);
      // Released: the glow is gone with the drag.
      h.board.endDrag(1);
      expect(h.timeline.hoverSlotId, isNull);
    });

    test('without drop targets from the bloc nothing glows: the board never '
        'decides legality', () async {
      final (h, source, legal, _) = await drag();
      h.game.dropTargets = const {};
      h.board.beginDrag(1, source.centerX, source.hitRect.center.dy);
      h.board.moveDrag(1, legal.centerX, legal.hitRect.center.dy);
      expect(h.timeline.hoverSlotId, isNull);
      h.board.endDrag(1);
    });

    test('a reset ends the hover', () async {
      final (h, source, legal, _) = await drag();
      h.board.beginDrag(1, source.centerX, source.hitRect.center.dy);
      h.board.moveDrag(1, legal.centerX, legal.hitRect.center.dy);
      expect(h.timeline.hoverSlotId, legal.id);
      await h.start();
      expect(h.timeline.hoverSlotId, isNull);
      expect(
        h.board.fx.liveClips.where((c) => c.purpose == FxClipPurpose.hoverGlow),
        isEmpty,
      );
    });
  });

  group('the family counter yields to a hint over it (E.20, frame 3.1b)', () {
    test('a hint whose arrow rises into the counter yields it, and gives it '
        'back when the hint ends', () async {
      final h = await loaded(_threeByThree);
      final notes = <bool>[];
      h.board.familyCounterYield.addListener(
        () => notes.add(h.board.familyCounterYield.value),
      );
      expect(h.board.familyCounterYield.value, isFalse);
      // r0c1 holds red3 (a 4-slot-tall board's middle top stand).
      final g = h.game.geometry!;
      final middle = g.slot('r0c1');
      expect(middle.hintNeedsCounter(3), isTrue);
      await h.apply(const HintShownEffect(Move('r0c1', 'r0c2')));
      expect(h.board.familyCounterYield.value, isTrue);
      await h.apply(const HintClearedEffect());
      expect(h.board.familyCounterYield.value, isFalse);
      expect(notes, [true, false], reason: 'one change each way');
    });

    test(
      'a hint from a side stand, or from a lower shelf, leaves it',
      () async {
        final h = await loaded(_threeByThree);
        await h.apply(const HintShownEffect(Move('r0c0', 'r2c0')));
        expect(h.board.familyCounterYield.value, isFalse);
        await h.apply(const HintShownEffect(Move('r1c1', 'r2c0')));
        expect(h.board.familyCounterYield.value, isFalse);
      },
    );

    test('a reset clears it', () async {
      final h = await loaded(_threeByThree);
      await h.apply(const HintShownEffect(Move('r0c1', 'r0c2')));
      expect(h.board.familyCounterYield.value, isTrue);
      await h.start();
      expect(h.board.familyCounterYield.value, isFalse);
    });

    test(
      'the middle arrow keeps its rest pose (D62\'s drop is gone here)',
      () async {
        final h = await loaded(_threeByThree);
        await h.apply(const HintShownEffect(Move('r0c1', 'r0c2')));
        final g = h.game.geometry!;
        final middle = g.slot('r0c1');
        final clip = h.board.fx.liveClips.singleWhere(
          (c) => c.fx == FxId.uiHintArrow,
        );
        final arrow = h.board.fx.componentOf(clip.id)!;
        final fs = middle.furnitureScale;
        expect(
          arrow.position.y,
          closeTo(middle.dollTopY(3) - 33 * fs, 1e-3),
          reason: 'anchor at dollTop − 33·fs, no drop',
        );
        expect(arrow.position, isNot(Offset.zero));
      },
    );
  });
}
