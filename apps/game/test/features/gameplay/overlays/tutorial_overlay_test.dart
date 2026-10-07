import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart'
    show TutorialCue, TutorialCueKind;
import 'package:nesty_game/features/gameplay/overlays/tutorial_overlay.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_board.dart';
import 'package:nesty_render/nesty_render.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../fx/support/fx_test_art.dart';
import '../../support/screen_harness.dart';
import '../bloc/support/bloc_fixtures.dart' show defaultLevel, red2, red3;

const _tapSource = TutorialCue(
  step: 1,
  kind: TutorialCueKind.tapSource,
  from: red2,
  to: red3,
);

const _tapTarget = TutorialCue(
  step: 2,
  kind: TutorialCueKind.tapTarget,
  from: red2,
  to: red3,
);

const _drag = TutorialCue(
  step: 4,
  kind: TutorialCueKind.drag,
  from: red2,
  to: red3,
);

BoardGeometry _geometryFor(
  GameState board, {
  Size size = const Size(390, 844),
}) {
  final callbacks = GameplayBoardCallbacks(
    onIntent: (_) {},
    onLayout: (_) {},
    onFamilyLanded: (_, _, _) {},
    onWon: () {},
    onOutOfMoves: () {},
  );
  final fake = FakeGameplayBoard(
    callbacks,
    fx: FakeFxLibrary(),
    feedback: RecordingCues(),
  )..screen = size;
  return fake.layoutFor(board)!;
}

void main() {
  setUpAll(loadBundledFonts);

  testWidgets('a tap step (1.3): the hole, the tooltip and ui_tap_hand', (
    tester,
  ) async {
    final board = GameState.initial(defaultLevel);
    await pumpScreen(
      tester,
      TutorialOverlay(
        cue: _tapSource,
        board: board,
        geometry: _geometryFor(board),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Tap the small doll'), findsOneWidget);
    expect(find.byType(TutorialOverlay), findsOneWidget);
  });

  testWidgets('the tip\'s tail is a 22×9 triangle that takes no layout '
      'height (frame 1.3)', (tester) async {
    final board = GameState.initial(defaultLevel);
    await pumpScreen(
      tester,
      TutorialOverlay(
        cue: _tapSource,
        board: board,
        geometry: _geometryFor(board),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    final tail = find.byKey(const Key('tutorial-tip-tail'));
    expect(tail, findsOneWidget);
    expect(tester.getSize(tail), const Size(22, 9));
    // The card's box ends where the tail starts (1 dp of overlap): the tail
    // hangs outside the layout, not in its own column slot.
    final card = tester.getRect(
      find.ancestor(of: tail, matching: find.byType(Stack)).first,
    );
    expect(tester.getRect(tail).top, closeTo(card.bottom - 1, 0.01));
  });

  testWidgets('level 1\'s tip is spoken as "Step n of 3. {title}" then its '
      'text (a11y_tut_step)', (tester) async {
    final handle = tester.ensureSemantics();
    final board = GameState.initial(defaultLevel);
    await pumpScreen(
      tester,
      TutorialOverlay(
        cue: _tapSource,
        board: board,
        geometry: _geometryFor(board),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.bySemanticsLabel(RegExp(r'^Step 1 of 3\. Tap the small doll')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp('STEP 1 OF 3')), findsNothing);
    handle.dispose();
  });

  testWidgets('m7-4 8.1: the scrim has a hole over Pause (10, 56, 60 x 60) '
      'and the tip sits in the HUD row (left 76, right 16, top 62)', (
    tester,
  ) async {
    final board = GameState.initial(defaultLevel);
    const size = Size(390, 844);
    await pumpScreen(
      tester,
      TutorialOverlay(
        cue: _tapSource,
        board: board,
        geometry: _geometryFor(board),
      ),
      padding: const EdgeInsets.only(top: 59),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.renderObject(find.byType(TutorialOverlay)),
      paints..path(
        color: const Color(0x99341A08),
        includes: const [Offset(200, 30), Offset(300, 90), Offset(5, 90)],
        excludes: const [Offset(40, 86), Offset(14, 90), Offset(60, 110)],
      ),
    );
    final tip = tester.getRect(find.byType(NestySurface).first);
    expect(tip.left, 76);
    expect(tip.right, size.width - 16);
    expect(tip.top, 62);
  });

  group('Level 1\'s three steps all wear "STEP n OF 3" (copy.md E; lead note '
      '6)', () {
    for (final (step, chip, title) in [
      (1, 'STEP 1 OF 3', 'Tap the small doll'),
      (2, 'STEP 2 OF 3', 'Now tap the big one'),
      (3, 'STEP 3 OF 3', 'Finish the family'),
    ]) {
      testWidgets('step $step: "$chip" over "$title"', (tester) async {
        final board = GameState.initial(defaultLevel);
        await pumpScreen(
          tester,
          TutorialOverlay(
            cue: TutorialCue(
              step: step,
              kind: TutorialCueKind.tapSource,
              from: red2,
              to: red3,
            ),
            board: board,
            geometry: _geometryFor(board),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text(chip), findsOneWidget);
        expect(find.text(title), findsOneWidget);
      });
    }

    testWidgets('step 3 says an unfinished family is done when every size '
        'is nested', (tester) async {
      final board = GameState.initial(defaultLevel);
      await pumpScreen(
        tester,
        TutorialOverlay(
          cue: const TutorialCue(
            step: 3,
            kind: TutorialCueKind.tapSource,
            from: red2,
            to: red3,
          ),
          board: board,
          geometry: _geometryFor(board),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text(
          'Put the last doll in. A family is done when every size is '
          'nested.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Level 2\'s swallow keeps "NEW MOVE"', (tester) async {
      final board = GameState.initial(defaultLevel);
      await pumpScreen(
        tester,
        TutorialOverlay(
          cue: _drag,
          board: board,
          geometry: _geometryFor(board),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('NEW MOVE'), findsOneWidget);
      expect(find.textContaining('OF 3'), findsNothing);
    });
  });

  // The hand per LOTTIE.md: `ui_tap_hand` is a 128×144 canvas with its
  // fingertip (48, 32) on the target; `ui_drag_hand` is board space
  // (390×844) with a `travel` null remapped from the tap point on the big
  // doll to the target's surface − 0.4 × its height ("Travel remap"). The
  // drag hand used to be squeezed into a 58 px box, which shrank its whole
  // board canvas to a speck: frame 1.6 showed no hand (owner report).
  group('the hand (LOTTIE.md ui_tap_hand, ui_drag_hand)', () {
    final board = GameState.initial(defaultLevel);
    final geometry = _geometryFor(board);
    final from = geometry.slot(red2);
    final to = geometry.slot(red3);
    final fromSize = board.slot(red2).nests.last.outerSize;
    final toSize = board.slot(red3).nests.last.outerSize;
    final tapPoint = Offset(
      from.centerX,
      from.surfaceY - from.dollHeight(fromSize) * 0.42,
    );

    Future<FakeFxLibrary> libraryWith(WidgetTester tester, FxId id) async {
      final library = FakeFxLibrary()..blank = transparentPixel;
      library.compositions[id] = (await tester.runAsync(() => shipped(id)))!;
      return library;
    }

    Finder handOf(FxId id) =>
        find.byWidgetPredicate((w) => w is LottieFxView && w.id == id);

    testWidgets('reduce motion: neither hand loops, both rest on frame 0 '
        '(ui-spec-game §2.4)', (tester) async {
      for (final (cue, id) in [
        (_tapSource, FxId.uiTapHand),
        (_drag, FxId.uiDragHand),
      ]) {
        final library = await libraryWith(tester, id);
        await pumpScreen(
          tester,
          TutorialOverlay(
            cue: cue,
            board: board,
            geometry: geometry,
            library: library,
          ),
          reduceMotion: true,
        );
        await tester.pump(const Duration(milliseconds: 300));
        final controller = tester.widget<LottieFxView>(handOf(id)).controller!;
        expect(controller.isPlaying, isFalse, reason: id.fileName);
        expect(controller.player.frame, 0, reason: id.fileName);
      }
    });

    testWidgets('with motion the hands play', (tester) async {
      final library = await libraryWith(tester, FxId.uiTapHand);
      await pumpScreen(
        tester,
        TutorialOverlay(
          cue: _tapSource,
          board: board,
          geometry: geometry,
          library: library,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        tester
            .widget<LottieFxView>(handOf(FxId.uiTapHand))
            .controller!
            .isPlaying,
        isTrue,
      );
    });

    testWidgets('a drag step (1.6): ui_drag_hand over the whole board, its '
        'travel from the tap point to 0.4 of the target up its height', (
      tester,
    ) async {
      final library = await libraryWith(tester, FxId.uiDragHand);
      await pumpScreen(
        tester,
        TutorialOverlay(
          cue: _drag,
          board: board,
          geometry: geometry,
          library: library,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final hand = handOf(FxId.uiDragHand);
      expect(hand, findsOneWidget);
      expect(tester.getSize(hand), const Size(390, 844));
      final params = tester.widget<LottieFxView>(hand).controller!.params;
      // A 390×844 box: the file's reference units are the overlay's own.
      expect(params.travelSrc, tapPoint);
      expect(
        params.travelDst,
        Offset(to.centerX, to.surfaceY - to.dollHeight(toSize) * 0.4),
      );
      expect(find.byIcon(NestyIcons.touchApp), findsNothing);
    });

    testWidgets('a drag step without the file: the glyph ping-pongs from the '
        'tap point instead (rule 3)', (tester) async {
      await pumpScreen(
        tester,
        TutorialOverlay(
          cue: _drag,
          board: board,
          geometry: geometry,
          library: FakeFxLibrary(),
        ),
      );
      await tester.pump();
      expect(handOf(FxId.uiDragHand), findsNothing);
      final glyph = find.byIcon(NestyIcons.touchApp);
      expect(glyph, findsOneWidget);
      expect(tester.getTopLeft(glyph), tapPoint - const Offset(24, 6));
    });

    testWidgets('a tap step: ui_tap_hand at 0.6 of its 128×144 canvas, its '
        'fingertip (48, 32) on the tapped doll, so the hand is 40 dp (m7-5 '
        'item 8)', (tester) async {
      expect(TutorialTokens.handScale, 0.6);
      final library = await libraryWith(tester, FxId.uiTapHand);
      await pumpScreen(
        tester,
        TutorialOverlay(
          cue: _tapSource,
          board: board,
          geometry: geometry,
          library: library,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      final hand = handOf(FxId.uiTapHand);
      final size = tester.getSize(hand);
      expect(size.width, closeTo(128 * 0.6, 1e-9));
      expect(size.height, closeTo(144 * 0.6, 1e-9));
      final topLeft = tester.getTopLeft(hand);
      expect(topLeft.dx, closeTo(tapPoint.dx - 48 * 0.6, 1e-9));
      expect(topLeft.dy, closeTo(tapPoint.dy - 32 * 0.6, 1e-9));
      expect(
        tester.getRect(find.byKey(TutorialOverlay.tapHandKey)),
        tester.getRect(hand),
      );
    });

    testWidgets('a tap step without the file: the glyph scales with the '
        'canvas, its fingertip on the tapped doll (rule 3)', (tester) async {
      await pumpScreen(
        tester,
        TutorialOverlay(
          cue: _tapSource,
          board: board,
          geometry: geometry,
          library: FakeFxLibrary(),
        ),
      );
      await tester.pump();
      final glyph = find.byIcon(NestyIcons.touchApp);
      expect(glyph, findsOneWidget);
      final rect = tester.getRect(glyph);
      expect(rect.width, closeTo(58 * 0.6, 1e-6));
      expect(rect.left, closeTo(tapPoint.dx - 24 * 0.6, 1e-6));
      expect(rect.top, closeTo(tapPoint.dy - 6 * 0.6, 1e-6));
    });
  });

  // Review FIDELITY-4: NestyBoard tut1a/tut1b always draw `tutArc` from
  // the small doll to the big one: a = (S.cx − 10, S.dt − 8), e = (T.cx +
  // 24, T.dt − 6), control 30 above the higher end (dt: the doll's top,
  // `surf − h·742/768`).
  group('the dotted arc (NestyBoard tutArc)', () {
    final board = GameState.initial(defaultLevel);

    test('a tap step runs from above the source doll to above the target '
        'doll, whichever one the hand taps', () {
      final geometry = _geometryFor(board);
      final s = geometry.slot(red2);
      final t = geometry.slot(red3);
      final sTop = s.dollTopY(2, s.surfaceY);
      final tTop = t.dollTopY(3, t.surfaceY);
      for (final cue in [_tapSource, _tapTarget]) {
        final arc = TutorialArc.of(cue, geometry: geometry, board: board)!;
        expect(arc.start, Offset(s.centerX - 10, sTop - 8), reason: '$cue');
        expect(arc.end, Offset(t.centerX + 24, tTop - 6), reason: '$cue');
        expect(
          arc.control,
          Offset(
            (arc.start.dx + arc.end.dx) / 2,
            math.min(arc.start.dy, arc.end.dy) - 30,
          ),
        );
      }
    });

    test('the drag step (tut2) bows out 124 right of the source', () {
      final geometry = _geometryFor(board);
      final s = geometry.slot(red2);
      final t = geometry.slot(red3);
      final arc = TutorialArc.of(_drag, geometry: geometry, board: board)!;
      final sTop = s.dollTopY(2, s.surfaceY);
      final tTop = t.dollTopY(3, t.surfaceY);
      expect(arc.start, Offset(s.centerX + 44, sTop + 36));
      expect(arc.end, Offset(t.centerX + 46, tTop + 12));
      expect(
        arc.control,
        Offset(s.centerX + 124, (arc.start.dy + arc.end.dy) / 2),
      );
    });

    for (final cue in [_tapSource, _tapTarget, _drag]) {
      testWidgets('step ${cue.step} (${cue.kind.name}) paints the scrim, the '
          'dashed arc and its head', (tester) async {
        await pumpScreen(
          tester,
          TutorialOverlay(
            cue: cue,
            board: board,
            geometry: _geometryFor(board),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(
          tester.renderObject(find.byType(TutorialOverlay)),
          paints
            ..path(color: const Color(0x99341A08))
            ..path(
              color: const Color(0xFFFFF4E0),
              style: PaintingStyle.stroke,
              strokeWidth: 4,
            )
            ..path(color: const Color(0xFFFFF4E0), style: PaintingStyle.fill),
        );
      });
    }
  });

  testWidgets('a drag step (1.6): the dotted arc runs from the source to '
      'the target', (tester) async {
    final board = GameState.initial(defaultLevel);
    await pumpScreen(
      tester,
      TutorialOverlay(cue: _drag, board: board, geometry: _geometryFor(board)),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Big can swallow small'), findsOneWidget);
  });

  testWidgets('no geometry yet: draws nothing (rule 3)', (tester) async {
    final board = GameState.initial(defaultLevel);
    await pumpScreen(tester, TutorialOverlay(cue: _tapSource, board: board));
    await tester.pump();
    expect(find.byType(TutorialOverlay), findsOneWidget);
    expect(find.text('Tap the small doll'), findsNothing);
  });

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets('fits ${size.width.toInt()} wide at $scale× text', (
        tester,
      ) async {
        final board = GameState.initial(defaultLevel);
        await pumpScreen(
          tester,
          TutorialOverlay(
            cue: _tapSource,
            board: board,
            geometry: _geometryFor(board, size: size),
          ),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(milliseconds: 300));
        expectNoLayoutErrors(tester);
      });
    }
  }
}
