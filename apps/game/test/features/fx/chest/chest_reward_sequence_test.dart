import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/chest/chest_reward_sequence.dart';
import 'package:nesty_game/features/fx/chest/reward_flight.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_id.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';
import '../support/fx_test_art.dart';

/// The shared chest moment on `ui_chest` (phase 4 architecture §3.5;
/// frames 10.3b–10.3d, 5.6, 5.6b): arrive → idle, Open (wiggle, then open
/// and open_idle), Collect's flights, and reduce motion's crossfade. Both
/// `MilestoneChestModal` and `DailyChestModal` are thin wrappers over this.
/// Without a composition (`FakeFxLibrary`) the SVG art stands in, which is
/// what these read.
///
/// Never `pumpAndSettle` once the chest is open: its `open_idle` loops.
void main() {
  setUpAll(loadBundledFonts);

  Widget sequence({
    int coins = 100,
    int hints = 1,
    String body = 'A chest for reaching level 30.',
    bool streak = false,
    VoidCallback? onCollect,
    RecordingCues? feedback,
    RewardFlightTarget? coinTarget,
    RewardFlightTarget? hintTarget,
    ValueChanged<int>? onCoinsRevealed,
    VoidCallback? onHintLanded,
    FakeFxLibrary? library,
  }) => ChestRewardSequence(
    title: 'Milestone chest',
    streakRibbon: streak,
    body: body,
    coins: coins,
    hints: hints,
    feedback: feedback,
    library: library ?? FakeFxLibrary(),
    coinTarget: coinTarget,
    hintTarget: hintTarget,
    onCoinsRevealed: onCoinsRevealed,
    onHintLanded: onHintLanded,
    onCollect: onCollect ?? () {},
  );

  Future<void> toIdle(WidgetTester tester) => tester.pump(
    const Duration(milliseconds: ChestRewardSequence.arrivalMs + 50),
  );

  /// Idle → Open → past `open` (wiggle 483 + open 750 ms).
  Future<void> openChest(WidgetTester tester) async {
    await toIdle(tester);
    await tester.tap(find.text('Open'));
    await tester.pump(const Duration(milliseconds: 1300));
  }

  group('arrival', () {
    testWidgets('the card sits at top 168 (28 in from each side); Open is '
        'not live yet', (tester) async {
      await pumpScreen(tester, sequence());
      final card = tester.getRect(find.byKey(ChestRewardSequence.cardKey));
      expect(card.left, closeTo(28, 0.01));
      expect(card.right, closeTo(390 - 28, 0.01));
      // The design's y 168 on the harness' 59 dp safe area (m7-4 6.4).
      expect(card.top, closeTo(ChestCardTokens.cardTop, 0.01));
      expect(ChestCardTokens.cardTop, 168);
      await tester.tap(find.text('Open'), warnIfMissed: false);
      await toIdle(tester);
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Collect'), findsNothing);
    });

    testWidgets('the day-7 chest sits at top 176 (frame 5.6)', (tester) async {
      await pumpScreen(tester, sequence(streak: true));
      final card = tester.getRect(find.byKey(ChestRewardSequence.cardKey));
      expect(card.top, closeTo(ChestCardTokens.cardTopDay7, 0.01));
      expect(ChestCardTokens.cardTopDay7, 176);
    });

    testWidgets('the card pads 44 / 22 / 22 and the art box starts 44 below '
        'its top', (tester) async {
      await pumpScreen(tester, sequence());
      await toIdle(tester);
      final card = tester.getRect(find.byKey(ChestRewardSequence.cardKey));
      final box = tester.getRect(_artBox());
      expect(box.top - card.top, 44);
      expect(box.left - card.left, closeTo((card.width - 156) / 2, 0.01));
    });

    testWidgets("the chest's Lottie box is the 200 canvas at 1.2", (
      tester,
    ) async {
      await pumpScreen(tester, sequence());
      await toIdle(tester);
      expect(
        tester.getSize(find.byKey(ChestRewardSequence.chestKey)),
        const Size(240, 240),
      );
    });
  });

  group('the chest art box (m7-4 6.4, 8.3)', () {
    testWidgets('the contents are spoken as "Chest. Inside: 100 coins, 1 '
        'hint." (a11y_chest_contents)', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, sequence());
      await toIdle(tester);
      expect(
        find.bySemanticsLabel('Chest. Inside: 100 coins, 1 hint.'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('a coins-only chest says "Chest. Inside: 50 coins."', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, sequence(coins: 50, hints: 0));
      await toIdle(tester);
      expect(find.bySemanticsLabel('Chest. Inside: 50 coins.'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('with the real ui_chest loaded the view still fills the 240 '
        'box (a CustomPaint of its own 200 canvas drew at 1.0 under loose '
        'constraints: the 102 dp chest of audit f10-3b)', (tester) async {
      final library = FakeFxLibrary()..blank = transparentPixel;
      await tester.runAsync(() async {
        library.compositions[FxId.uiChest] = await shippedOnce(FxId.uiChest);
        await library.load();
      });
      await pumpScreen(tester, sequence(library: library));
      await toIdle(tester);
      expect(
        tester.getSize(find.byKey(ChestRewardSequence.chestKey)),
        const Size(240, 240),
      );
    });

    testWidgets('a 156 x 130 box; ui_chest at 1.2 overlays it with its base '
        'on the box bottom centre; the card is 390 dp tall at 390 x 844', (
      tester,
    ) async {
      // The shipped line wraps to two lines.
      await pumpScreen(
        tester,
        sequence(body: 'A chest for reaching level 10. Here’s what’s inside.'),
      );
      await toIdle(tester);
      final box = tester.getRect(_artBox());
      expect(box.size, const Size(156, 130));
      final lottie = tester.getRect(find.byKey(ChestRewardSequence.chestKey));
      expect(lottie.size, const Size(240, 240));
      // The chest base (100, 186) at 1.2 is (120, 223.2) in the canvas.
      expect(lottie.left + 120, closeTo(box.center.dx, 0.01));
      expect(lottie.top + 223.2, closeTo(box.bottom, 0.01));
      // The overlay takes no layout space: it draws up past the art box.
      expect(lottie.top, lessThan(box.top - 90));
      final card = tester.getRect(find.byKey(ChestRewardSequence.cardKey));
      expect(card.height, closeTo(ChestCardTokens.cardHeightClosed, 8));
    });

    testWidgets('the ribbon is painted above the card content, so the '
        'arrive drop passes behind it', (tester) async {
      await pumpScreen(tester, sequence());
      await toIdle(tester);
      final stack = tester.widget<Stack>(
        find
            .ancestor(
              of: find.byType(RibbonTitle),
              matching: find.byType(Stack),
            )
            .first,
      );
      final ribbon = stack.children.indexWhere(
        (c) => c is Positioned && c.child is Center,
      );
      expect(ribbon, stack.children.length - 1 - 0, reason: 'last child');
      expect(
        find.descendant(
          of: find.byKey(ChestRewardSequence.cardKey),
          matching: find.byKey(ChestRewardSequence.chestKey),
        ),
        findsOneWidget,
      );
    });
  });

  group('idle', () {
    testWidgets('the contents are shown at their promised amounts before it '
        'opens (rule 2)', (tester) async {
      await pumpScreen(tester, sequence());
      await toIdle(tester);
      expect(find.text('+100 coins'), findsOneWidget);
      expect(find.text('+1 hint'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.byKey(_raysKey), findsNothing);
    });

    testWidgets('no hints: only the coin chip shows', (tester) async {
      await pumpScreen(tester, sequence(hints: 0));
      await toIdle(tester);
      expect(find.text('+100 coins'), findsOneWidget);
      expect(find.text('+1 hint'), findsNothing);
    });
  });

  group('opening', () {
    testWidgets('Open plays the wiggle sound at once, chest_open with a '
        'medium haptic when the wiggle ends (483 ms)', (tester) async {
      final feedback = RecordingCues();
      await pumpScreen(tester, sequence(feedback: feedback));
      await toIdle(tester);
      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 10));
      expect(feedback.played.map((c) => c.sound), [SoundEffect.chestWiggle]);

      await tester.pump(const Duration(milliseconds: 460));
      expect(find.text('Collect'), findsNothing);
      expect(
        feedback.played.where((c) => c.sound == SoundEffect.chestOpen),
        isEmpty,
      );
      await tester.pump(const Duration(milliseconds: 30));
      final open = feedback.played.where(
        (c) => c.sound == SoundEffect.chestOpen,
      );
      expect(open, hasLength(1));
      expect(open.single.haptic, HapticPattern.nest);
      // The rays are the Lottie's own: nothing of ours turns over it (m7-4
      // 1.7, no 24 s turn).
      expect(find.byKey(_raysKey), findsNothing);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('Collect goes live once open ends (483 + 750 ms), with the '
        'contents unchanged', (tester) async {
      await pumpScreen(tester, sequence());
      await toIdle(tester);
      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 1100));
      expect(find.text('Collect'), findsNothing);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Collect'), findsOneWidget);
      expect(find.text('+100 coins'), findsOneWidget);
      expect(find.text('+1 hint'), findsOneWidget);
    });

    testWidgets('a second tap while it opens skips straight to Collect, '
        'with chest_open and the medium haptic still landing once', (
      tester,
    ) async {
      final feedback = RecordingCues();
      await pumpScreen(tester, sequence(feedback: feedback));
      await toIdle(tester);
      await tester.tap(find.text('Open'));
      await tester.pump(const Duration(milliseconds: 40));
      await tester.tap(find.text('Open'));
      await tester.pump();
      expect(find.text('Collect'), findsOneWidget);
      expect(
        feedback.played.where((c) => c.sound == SoundEffect.chestOpen),
        hasLength(1),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(
        feedback.played.where((c) => c.sound == SoundEffect.chestOpen),
        hasLength(1),
        reason: 'the skipped timers never fire',
      );
    });
  });

  group('collect', () {
    testWidgets('Collect plays the coins sound, flies the sprites to the '
        'targets, releases the coins one landing at a time and lands the '
        'hint once', (tester) async {
      final feedback = RecordingCues();
      final revealed = <int>[];
      var hintLanded = 0;
      var collected = 0;
      await pumpScreen(
        tester,
        sequence(
          feedback: feedback,
          coinTarget: () => const Rect.fromLTWH(300, 40, 40, 40),
          hintTarget: () => const Rect.fromLTWH(40, 700, 48, 48),
          onCoinsRevealed: revealed.add,
          onHintLanded: () => hintLanded++,
          onCollect: () => collected++,
        ),
      );
      await openChest(tester);
      await tester.tap(find.text('Collect'));
      await tester.pump();
      expect(
        feedback.played.where((c) => c.sound == SoundEffect.coins),
        hasLength(1),
      );
      // 6 coin sprites, 60 ms apart, 700 ms each: 1,000 ms in all.
      await tester.pump(const Duration(milliseconds: 1100));
      expect(revealed, hasLength(ChestRewardSequence.coinSpriteCount + 1));
      expect(revealed.last, 100, reason: 'ends at the full amount');
      expect(revealed, List<int>.from(revealed)..sort());
      expect(hintLanded, 1);
      expect(
        feedback.played.where((c) => c.haptic == HapticPattern.pick),
        isNotEmpty,
        reason: 'a light haptic as the hint lands',
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(collected, 1);
    });

    testWidgets('trail dots follow the sprites while they fly and are gone '
        'after (F-CH2)', (tester) async {
      await pumpScreen(
        tester,
        sequence(
          coinTarget: () => const Rect.fromLTWH(300, 40, 40, 40),
          hintTarget: () => const Rect.fromLTWH(40, 700, 48, 48),
        ),
      );
      await openChest(tester);
      expect(find.byKey(RewardFlight.trailKey), findsNothing);
      await tester.tap(find.text('Collect'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(RewardFlight.trailKey), findsWidgets);
      expect(
        tester.renderObject(find.byKey(RewardFlight.trailKey).first),
        paints..circle(),
      );
      await tester.pump(const Duration(milliseconds: 1500));
      expect(find.byKey(RewardFlight.trailKey), findsNothing);
    });

    test('a trail dot is 6 dp, 0.95 near the sprite to 0.35 at the tail, '
        'five behind a coin and three behind the hint, fading over 200 ms', () {
      expect(TrailDotsPainter.dotSize, 6);
      expect(TrailDotsPainter.headOpacity, 0.95);
      expect(TrailDotsPainter.tailOpacity, 0.35);
      expect(TrailDotsPainter.fadeMs, 200);
      expect(TrailDotsPainter.spacing, [0.1, 0.2, 0.3, 0.45, 0.6]);
      expect(ChestCollectTokens.trailCoinDots, 5);
      expect(ChestCollectTokens.trailHintDots, 3);
      expect(ChestCollectTokens.trailColor, const Color(0xFFFFF1C9));
    });

    testWidgets('a trail paints dots at path t - 0.1 ... behind the sprite, '
        'fading from 0.95 to 0.35', (tester) async {
      TrailDotsPainter at(double progress) => TrailDotsPainter(
        progress: AlwaysStoppedAnimation(progress),
        starts: const [0],
        flightMs: 1000,
        totalMs: 1200,
        dots: 5,
        eased: (t) => t.clamp(0.0, 1.0),
        pathAt: (p) => Offset(p * 100, 0),
      );
      final painter = at(0.5);
      final recorder = _RecordingCanvas();
      painter.paint(recorder, const Size(100, 10));
      // Elapsed 600 ms of a 1,000 ms flight: the sprite is at 0.6; the
      // dots sit at 0.5, 0.4, 0.3, 0.15 and 0.0.
      expect(recorder.circles.map((c) => c.dx.round()), [50, 40, 30, 15, 0]);
      expect(recorder.alphas.first, closeTo(0.95, 0.01));
      expect(recorder.alphas.last, closeTo(0.35, 0.01));
      // 100 ms after landing: the trail holds and has faded by half.
      final later = _RecordingCanvas();
      at(1100 / 1200).paint(later, const Size(100, 10));
      expect(later.circles.first.dx.round(), 90);
      expect(later.alphas.first, closeTo(0.95 * 0.5, 0.01));
    });

    testWidgets('nothing to fly to: the count releases in place, then it '
        'collects', (tester) async {
      final revealed = <int>[];
      var collected = 0;
      await pumpScreen(
        tester,
        sequence(
          coins: 300,
          hints: 0,
          onCoinsRevealed: revealed.add,
          onCollect: () => collected++,
        ),
      );
      await openChest(tester);
      await tester.tap(find.text('Collect'));
      await tester.pump(const Duration(seconds: 1));
      expect(revealed, [300]);
      expect(collected, 1);
    });

    testWidgets('the card closes at once and the dim lightens (10.3d)', (
      tester,
    ) async {
      await pumpScreen(tester, sequence());
      await openChest(tester);
      await tester.tap(find.text('Collect'));
      await tester.pump(const Duration(milliseconds: 300));
      final dim = tester.widget<AnimatedOpacity>(
        find.byKey(ChestRewardSequence.dimKey),
      );
      expect(dim.opacity, lessThan(0.5));
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('Collect only ever fires once', (tester) async {
      var collected = 0;
      await pumpScreen(tester, sequence(onCollect: () => collected++));
      await openChest(tester);
      await tester.tap(find.text('Collect'));
      await tester.pump(const Duration(seconds: 2));
      expect(collected, 1);
    });
  });

  group('reduced motion', () {
    testWidgets('no wiggle, no rays: a 200 ms crossfade; chips appear '
        'together; chest_open still plays with one light haptic', (
      tester,
    ) async {
      final feedback = RecordingCues();
      await pumpScreen(
        tester,
        sequence(feedback: feedback),
        reduceMotion: true,
      );
      await tester.pump();
      expect(find.text('Open'), findsOneWidget);

      await tester.tap(find.text('Open'));
      await tester.pump(
        const Duration(milliseconds: ChestRewardSequence.reducedOpenMs + 20),
      );
      expect(find.text('Collect'), findsOneWidget);
      expect(find.text('+100 coins'), findsOneWidget);
      expect(find.text('+1 hint'), findsOneWidget);
      expect(
        feedback.played.map((c) => c.sound),
        isNot(contains(SoundEffect.chestWiggle)),
      );
      final open = feedback.played.where(
        (c) => c.sound == SoundEffect.chestOpen,
      );
      expect(open, hasLength(1));
      expect(open.single.haptic, HapticPattern.pick);
      expect(find.byKey(_raysKey), findsNothing);
    });

    testWidgets('Collect is instant: no flights, the reveal jumps to the '
        'total and the card fades', (tester) async {
      final revealed = <int>[];
      var collected = 0;
      await pumpScreen(
        tester,
        sequence(
          onCoinsRevealed: revealed.add,
          onCollect: () => collected++,
          // A target is supplied but must never be flown to.
          coinTarget: () => const Rect.fromLTWH(300, 40, 40, 40),
        ),
        reduceMotion: true,
      );
      await tester.pump();
      await tester.tap(find.text('Open'));
      await tester.pump(
        const Duration(milliseconds: ChestRewardSequence.reducedOpenMs + 20),
      );
      await tester.tap(find.text('Collect'));
      await tester.pump(const Duration(seconds: 1));
      expect(revealed, [100]);
      expect(collected, 1);
    });
  });
}

/// The 156 x 130 art box in the card (a [SizedBox] holding the chest's
/// Lottie overlay).
Finder _artBox() => find.ancestor(
  of: find.byKey(ChestRewardSequence.chestKey),
  matching: find.byWidgetPredicate(
    (w) => w is SizedBox && w.width == 156 && w.height == 130,
  ),
);

/// Nothing of ours draws rays any more: they belong to `ui_chest`.
const _raysKey = Key('chest-rays');

/// Records the circles a painter draws, with their alphas.
class _RecordingCanvas implements Canvas {
  final List<Offset> circles = [];
  final List<double> alphas = [];

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    circles.add(c);
    alphas.add(paint.color.a);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
