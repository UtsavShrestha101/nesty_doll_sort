import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
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
}) {
  final level = levelFrom(tutorialLevelJson);
  return GameplayState(
    entry: entryFor(level),
    board: GameState.initial(level),
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
  );
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

    test('shows no count at 0 or in the dev flavor', () {
      final empty = BoosterBarModel.of(
        _state(freeUndosLeft: 0, hintsLeft: 0, extraSlotsLeft: 0),
      );
      expect(empty.undoBadge, isNull);
      expect(empty.hintBadge, isNull);
      expect(empty.slotBadge, isNull);

      final dev = BoosterBarModel.of(_state(unlimited: true));
      expect(dev.undoBadge, isNull);
      expect(dev.hintBadge, isNull);
      expect(dev.slotBadge, isNull);
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

    test('soft stuck with nothing to undo glows nothing: the banner '
        'suggests Restart (review FIDELITY-6)', () {
      final model = BoosterBarModel.of(_state(softStuck: true, canUndo: false));
      expect(model.undoGlow, isFalse);
      expect(model.undoEnabled, isFalse);
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
  });
}
