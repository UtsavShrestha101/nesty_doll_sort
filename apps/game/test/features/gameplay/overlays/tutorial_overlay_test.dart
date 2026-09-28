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

    testWidgets('a tap step: ui_tap_hand at its 128×144 canvas, its fingertip '
        '(48, 32) on the tapped doll', (tester) async {
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
      expect(tester.getSize(hand), const Size(128, 144));
      expect(tester.getTopLeft(hand), tapPoint - const Offset(48, 32));
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
