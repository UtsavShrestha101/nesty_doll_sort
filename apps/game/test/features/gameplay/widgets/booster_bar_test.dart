import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/repository/fake_level_resolver.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/widgets/booster_bar.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../../helpers/level_fixtures.dart';
import '../../support/screen_harness.dart';

GameplayState _state({
  GameplayStatus status = GameplayStatus.playing,
  bool paused = false,
  bool softStuck = false,
  Move? hint,
  int freeUndosLeft = 2,
  int hintsLeft = 3,
  int extraSlotsLeft = 2,
  bool canUndo = true,
  bool canHint = true,
  bool canAddSlot = true,
  bool unlimited = false,
  int undoPrice = 0,
  int hintPrice = 0,
  int slotPrice = 0,
  bool relaxed = false,
  int extraSlots = 0,
}) {
  final level = levelFrom(tutorialLevelJson);
  final entry = entryFor(level);
  return GameplayState(
    play: FakeLevelResolver.campaignEntry(entry, entry.rewardCoins),
    entry: entry,
    board: extraSlots == 0
        ? GameState.initial(level)
        : _withExtras(level, extraSlots),
    status: status,
    paused: paused,
    softStuck: softStuck,
    hint: hint,
    freeUndosLeft: freeUndosLeft,
    hintsLeft: hintsLeft,
    extraSlotsLeft: extraSlotsLeft,
    canUndo: canUndo,
    canHint: canHint,
    canAddSlot: canAddSlot,
    unlimitedBoosters: unlimited,
    undoPrice: undoPrice,
    hintPrice: hintPrice,
    slotPrice: slotPrice,
    relaxed: relaxed,
  );
}

GameState _withExtras(Level level, int count) {
  final session = GameSession(level);
  for (var i = 0; i < count; i++) {
    session.addExtraSlot();
  }
  return session.state;
}

void main() {
  group('BoosterBarModel.of', () {
    test('counts what the player holds (NestyBoard badges)', () {
      final model = BoosterBarModel.of(_state());
      expect(model.undoBadge, const BoosterBadge.count(2));
      expect(model.hintBadge, const BoosterBadge.count(3));
      expect(model.slotBadge, const BoosterBadge.count(2));
      expect(model.undoEnabled, isTrue);
      expect(model.hintEnabled, isTrue);
      expect(model.slotEnabled, isTrue);
      expect(model.restartEnabled, isTrue);
      expect(model.undoGlow, isFalse);
    });

    test('shows the coin price once free/held counts hit 0 (m3-design '
        '§7.3), none in the dev flavor', () {
      final priced = BoosterBarModel.of(
        _state(
          freeUndosLeft: 0,
          hintsLeft: 0,
          extraSlotsLeft: 0,
          undoPrice: 20,
          hintPrice: 60,
          slotPrice: 150,
        ),
      );
      expect(priced.undoBadge, const BoosterBadge.coin(20));
      expect(priced.hintBadge, const BoosterBadge.coin(60));
      expect(priced.slotBadge, const BoosterBadge.coin(150));

      final dev = BoosterBarModel.of(_state(unlimited: true));
      expect(dev.undoBadge, isNull);
      expect(dev.hintBadge, isNull);
      expect(dev.slotBadge, isNull);

      // The level's own +1 Slot limit (2 per level, `canAddSlot` false)
      // disables the button entirely: no coin badge to press either.
      final capped = BoosterBarModel.of(
        _state(extraSlotsLeft: 0, canAddSlot: false, slotPrice: 150),
      );
      expect(capped.slotBadge, isNull);
    });

    test('relaxed mode (E6; frame 10.9): Undo shows the all_inclusive glyph '
        'instead of a count or price; Hint and +1 Slot are unchanged', () {
      final model = BoosterBarModel.of(
        _state(
          relaxed: true,
          freeUndosLeft: 0,
          undoPrice: 20,
          hintsLeft: 3,
          extraSlotsLeft: 2,
        ),
      );
      expect(model.undoBadge, const BoosterBadge.infinite());
      expect(model.hintBadge, const BoosterBadge.count(3));
      expect(model.slotBadge, const BoosterBadge.count(2));
    });

    test('the dev flavor wins over relaxed mode: no badge at all', () {
      final model = BoosterBarModel.of(_state(relaxed: true, unlimited: true));
      expect(model.undoBadge, isNull);
    });

    test('follows the bloc: nothing works while paused or once all levels '
        'are done', () {
      for (final state in [
        _state(paused: true),
        _state(status: GameplayStatus.allLevelsDone),
      ]) {
        final model = BoosterBarModel.of(state);
        expect(model.undoEnabled, isFalse);
        expect(model.hintEnabled, isFalse);
        expect(model.slotEnabled, isFalse);
        expect(model.restartEnabled, isFalse);
        expect(model.locked, isFalse);
      }
    });

    test('won: the bar keeps its look and only swallows presses, instead '
        'of flashing disabled while the set flies (frame 2.5, review '
        'FIDELITY-2)', () {
      // The winning move completed a family: nothing to undo (spec §2.4).
      final model = BoosterBarModel.of(
        _state(status: GameplayStatus.won, canUndo: false),
      );
      expect(model.locked, isTrue);
      expect(model.undoEnabled, isFalse);
      expect(model.hintEnabled, isTrue);
      expect(model.slotEnabled, isTrue);
      expect(model.restartEnabled, isTrue);
      expect(BoosterBarModel.of(_state()).locked, isFalse);
    });

    test('out of moves keeps Undo, +Slot and Restart but not Hint', () {
      final model = BoosterBarModel.of(
        _state(status: GameplayStatus.outOfMoves),
      );
      expect(model.undoEnabled, isTrue);
      expect(model.slotEnabled, isTrue);
      expect(model.restartEnabled, isTrue);
      expect(model.hintEnabled, isFalse);
    });

    test('Hint stays live while one shows and when stuck (frames 3.1, '
        '3.4), and is off when none is left', () {
      const hint = Move('r0c2', 'r0c0');
      expect(BoosterBarModel.of(_state(hint: hint)).hintEnabled, isTrue);
      expect(BoosterBarModel.of(_state(softStuck: true)).hintEnabled, isTrue);
      expect(BoosterBarModel.of(_state(canHint: false)).hintEnabled, isFalse);
    });

    test('soft stuck makes Undo glow (frame 3.4)', () {
      expect(BoosterBarModel.of(_state(softStuck: true)).undoGlow, isTrue);
    });

    test('soft stuck with nothing to undo glows Restart, not Undo (frame '
        '12.7)', () {
      final model = BoosterBarModel.of(_state(softStuck: true, canUndo: false));
      expect(model.undoGlow, isFalse);
      expect(model.undoEnabled, isFalse);
      expect(model.restartGlow, isTrue);
      // With an Undo that works, only Undo glows.
      final undoable = BoosterBarModel.of(_state(softStuck: true));
      expect(undoable.undoGlow, isTrue);
      expect(undoable.restartGlow, isFalse);
      expect(BoosterBarModel.of(_state()).restartGlow, isFalse);
    });

    test('+1 Slot at its limit (frame 12.9): the model carries how many the '
        'level holds; before that, none', () {
      final atLimit = BoosterBarModel.of(
        _state(extraSlots: 2, canAddSlot: false),
      );
      expect(atLimit.slotLimit, 2);
      expect(atLimit.slotEnabled, isFalse);
      expect(atLimit.slotBadge, isNull);
      expect(BoosterBarModel.of(_state(extraSlots: 1)).slotLimit, isNull);
      expect(BoosterBarModel.of(_state()).slotLimit, isNull);
      // A board that can't add one for another reason (a race) has held
      // none: no sunk face.
      expect(BoosterBarModel.of(_state(canAddSlot: false)).slotLimit, isNull);
    });
  });

  group('BoosterBar', () {
    setUpAll(loadBundledFonts);

    for (final size in screenSizes) {
      for (final scale in textScales) {
        testWidgets('fits ${size.width.toInt()} wide at $scale× text', (
          tester,
        ) async {
          await pumpScreen(
            tester,
            Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: BoosterBar(
                  model: BoosterBarModel.of(_state(softStuck: true)),
                  library: FakeFxLibrary(),
                  onUndo: () {},
                  onHint: () {},
                  onExtraSlot: () {},
                  onRestart: () {},
                ),
              ),
            ),
            size: size,
            textScale: scale,
          );
          expectNoLayoutErrors(tester);
          for (final label in ['Undo', 'Hint', '+Slot', 'Restart']) {
            expect(find.text(label), findsOneWidget, reason: label);
          }
          // min(80, (W − 56) / 4) wide, 58 tall.
          final width = BoosterBar.buttonWidth(size.width);
          expect(
            tester.getSize(find.byType(BoosterButton).first),
            Size(width, 58),
          );
          // The bar reaches from H − safeBottom − 76 to the bottom.
          final bar = tester.getRect(find.byType(WoodBar));
          expect(bar.bottom, size.height);
          expect(bar.height, 76 + safeAreaOf(size).bottom);
        });
      }
    }

    testWidgets('each button sends its intent; disabled ones do nothing', (
      tester,
    ) async {
      final pressed = <String>[];
      await pumpScreen(
        tester,
        Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: BoosterBar(
              model: BoosterBarModel.of(_state(canHint: false)),
              onUndo: () => pressed.add('undo'),
              onHint: () => pressed.add('hint'),
              onExtraSlot: () => pressed.add('slot'),
              onRestart: () => pressed.add('restart'),
            ),
          ),
        ),
      );
      for (final label in ['Undo', 'Hint', '+Slot', 'Restart']) {
        await tester.tap(find.text(label));
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(pressed, ['undo', 'slot', 'restart']);
    });

    testWidgets('locked (won): every button keeps its enabled look, and no '
        'press gets through', (tester) async {
      final pressed = <String>[];
      await pumpScreen(
        tester,
        Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: BoosterBar(
              model: BoosterBarModel.of(_state(status: GameplayStatus.won)),
              onUndo: () => pressed.add('undo'),
              onHint: () => pressed.add('hint'),
              onExtraSlot: () => pressed.add('slot'),
              onRestart: () => pressed.add('restart'),
            ),
          ),
        ),
      );
      for (final button in tester.widgetList<BoosterButton>(
        find.byType(BoosterButton),
      )) {
        expect(button.onPressed, isNotNull, reason: button.label);
      }
      for (final label in ['Undo', 'Hint', '+Slot', 'Restart']) {
        await tester.tap(find.text(label), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(pressed, isEmpty);
    });

    testWidgets('the Undo glow sits behind Undo only while soft stuck', (
      tester,
    ) async {
      Future<void> pump(bool stuck) => pumpScreen(
        tester,
        Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: BoosterBar(
              model: BoosterBarModel.of(_state(softStuck: stuck)),
              library: FakeFxLibrary(),
              onUndo: () {},
              onHint: () {},
              onExtraSlot: () {},
              onRestart: () {},
            ),
          ),
        ),
      );
      await pump(false);
      expect(find.byType(BoosterGlow), findsNothing);
      await pump(true);
      expect(find.byType(BoosterGlow), findsOneWidget);
      final glow = tester.getCenter(find.byType(BoosterGlow));
      final undo = tester.getCenter(find.byType(BoosterButton).first);
      expect(glow, undo);
      expect(tester.getSize(find.byType(BoosterGlow)), const Size(130, 110));
    });

    testWidgets('the suggested Restart (12.7) keeps the Undo\'s soft gold '
        'glow: the same ui_booster_glow, behind Restart (m7-5 Choice 4)', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: BoosterBar(
              model: BoosterBarModel.of(
                _state(softStuck: true, canUndo: false),
              ),
              library: FakeFxLibrary(),
              onUndo: () {},
              onHint: () {},
              onExtraSlot: () {},
              onRestart: () {},
            ),
          ),
        ),
      );
      expect(find.byType(BoosterGlow), findsOneWidget);
      expect(
        tester.getCenter(find.byType(BoosterGlow)),
        tester.getCenter(find.byType(BoosterButton).last),
      );
      expect(tester.getSize(find.byType(BoosterGlow)), const Size(130, 110));
      // No crisp ring of its own: nothing but the glow marks it.
      expect(
        tester.widget<BoosterButton>(find.byType(BoosterButton).last).suggested,
        isTrue,
      );
    });

    testWidgets('relaxed mode draws the all_inclusive glyph on Undo (frame '
        '10.9; E6)', (tester) async {
      await pumpScreen(
        tester,
        Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: BoosterBar(
              model: BoosterBarModel.of(_state(relaxed: true)),
              onUndo: () {},
              onHint: () {},
              onExtraSlot: () {},
              onRestart: () {},
            ),
          ),
        ),
      );
      expect(find.byIcon(IconUses.undoUnlimited), findsOneWidget);
      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Undo, unlimited'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('hintKey marks the Hint button and hintGlow pulses behind '
        'it only (the milestone chest\'s Collect flight, m7-design chest '
        'sequence step 4)', (tester) async {
      final hintKey = GlobalKey();
      await pumpScreen(
        tester,
        Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: BoosterBar(
              model: BoosterBarModel.of(_state()),
              library: FakeFxLibrary(),
              onUndo: () {},
              onHint: () {},
              onExtraSlot: () {},
              onRestart: () {},
              hintKey: hintKey,
              hintGlow: true,
            ),
          ),
        ),
      );
      // The keyed widget is the Hint button itself, not some other one.
      expect(tester.widget<BoosterButton>(find.byKey(hintKey)).label, 'Hint');
      expect(find.byType(BoosterGlow), findsOneWidget);
      final glow = tester.getCenter(find.byType(BoosterGlow));
      final hint = tester.getCenter(find.byKey(hintKey));
      expect(glow, hint);
    });

    Future<void> pumpBar(
      WidgetTester tester,
      GameplayState state, {
      VoidCallback? onSlotLimit,
      VoidCallback? onExtraSlot,
      bool hintGlow = false,
      int hintGain = 0,
      bool hintRing = false,
    }) => pumpScreen(
      tester,
      Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: BoosterBar(
            model: BoosterBarModel.of(state),
            library: FakeFxLibrary(),
            onUndo: () {},
            onHint: () {},
            onExtraSlot: onExtraSlot ?? () {},
            onRestart: () {},
            onSlotLimit: onSlotLimit,
            hintGlow: hintGlow,
            hintGain: hintGain,
            hintRing: hintRing,
          ),
        ),
      ),
    );

    testWidgets('+1 Slot at its limit: the sunk face and "2/2", a tap says '
        'why and never adds a slot (frame 12.9)', (tester) async {
      var limitTaps = 0;
      var adds = 0;
      await pumpBar(
        tester,
        _state(extraSlots: 2, canAddSlot: false),
        onSlotLimit: () => limitTaps++,
        onExtraSlot: () => adds++,
      );
      expect(find.text('2/2'), findsOneWidget);
      final slot = tester.widget<BoosterButton>(
        find.widgetWithText(BoosterButton, '+Slot'),
      );
      expect(slot.spent, isTrue);
      await tester.tap(find.text('+Slot'));
      await tester.pump(const Duration(milliseconds: 200));
      expect((limitTaps, adds), (1, 0));
      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('+Slot, 2 of 2 used'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('Restart glows, and reads "Suggested", when the level looks '
        'stuck with nothing to undo (frame 12.7)', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpBar(tester, _state(softStuck: true, canUndo: false));
      final restart = tester.getCenter(find.byType(BoosterButton).last);
      expect(tester.getCenter(find.byType(BoosterGlow)), restart);
      expect(find.bySemanticsLabel('Restart, suggested'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('the chest\'s hint landing tags Hint "+N" at the badge\'s '
        'centre + (12, -42), green, popping in (frame 10.3d, m7-4 1.7)', (
      tester,
    ) async {
      await pumpBar(tester, _state(), hintGain: 2);
      expect(find.text('+2'), findsOneWidget, reason: 'the count gained');
      await tester.pump(const Duration(milliseconds: 300));
      final badge = tester.getCenter(
        find.descendant(
          of: find.widgetWithText(BoosterButton, 'Hint'),
          matching: find.byType(BoosterBadgeView),
        ),
      );
      final tag = tester.getRect(
        find
            .ancestor(of: find.text('+2'), matching: find.byType(NestySurface))
            .first,
      );
      // The tag is scaled about its centre while it pops; settled it is 1.
      expect(tag.left - badge.dx, closeTo(12, 0.6));
      expect(tag.top - badge.dy, closeTo(-42, 0.6));
      final style = tester
          .widget<NestySurface>(
            find
                .ancestor(
                  of: find.text('+2'),
                  matching: find.byType(NestySurface),
                )
                .first,
          )
          .style;
      expect(style.color, ChestCollectTokens.gainTagFace);
      expect(style.shadows, ChestCollectTokens.gainTagEdge);
      await pumpBar(tester, _state());
      expect(find.text('+2'), findsNothing);
    });

    testWidgets('the Hint badge ring is a 38 dp circle centred on the '
        'badge, fading in over 80 ms and out over 240 ms', (tester) async {
      await pumpBar(tester, _state(), hintRing: true);
      await tester.pump(const Duration(milliseconds: 100));
      final badge = tester.getCenter(
        find.descendant(
          of: find.widgetWithText(BoosterButton, 'Hint'),
          matching: find.byType(BoosterBadgeView),
        ),
      );
      expect(
        find.byKey(RewardRing.ringKey),
        findsOneWidget,
        reason: 'only the Hint badge lights a ring',
      );
      final ring = find.byKey(RewardRing.ringKey);
      expect(tester.getSize(ring), const Size.square(38));
      expect(tester.getCenter(ring), offsetMoreOrLessEquals(badge));
      // A ring round the circle, never over the badge (m7-5: painted
      // outside its shape, as 10.3d's CSS draws it).
      final painter =
          tester.widget<CustomPaint>(ring).painter! as RingGlowPainter;
      expect(painter.circle, isTrue);
      expect(painter.shadows, ChestCollectTokens.hintRingShadow);
      expect(
        tester
            .widget<AnimatedOpacity>(
              find.ancestor(of: ring, matching: find.byType(AnimatedOpacity)),
            )
            .duration,
        RewardRing.fadeIn,
      );
      await pumpBar(tester, _state());
      final out = tester.widget<AnimatedOpacity>(
        find.ancestor(of: ring, matching: find.byType(AnimatedOpacity)),
      );
      expect(out.opacity, 0);
      expect(out.duration, RewardRing.fadeOut);
    });
  });
}
