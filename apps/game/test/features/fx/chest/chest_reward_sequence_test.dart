import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/features/fx/chest/chest_reward_sequence.dart';
import 'package:nesty_game/features/fx/chest/reward_flight.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

/// The shared chest moment on `ui_chest` (phase 4 architecture §3.5;
/// frames 10.3b–10.3d, 5.6, 5.6b): arrive → idle, Open (wiggle, then open
/// and open_idle), Collect's flights, and reduce motion's crossfade. Both
/// `MilestoneChestModal` and `DailyChestModal` are thin wrappers over this.
/// Without a composition (`FakeFxLibrary`) the SVG art stands in, which is
/// what these read.
///
/// Never `pumpAndSettle` once the chest is open: the rays turn forever.
void main() {
  setUpAll(loadBundledFonts);

  Widget sequence({
    int coins = 100,
    int hints = 1,
    VoidCallback? onCollect,
    RecordingCues? feedback,
    RewardFlightTarget? coinTarget,
    RewardFlightTarget? hintTarget,
    ValueChanged<int>? onCoinsRevealed,
    VoidCallback? onHintLanded,
  }) => ChestRewardSequence(
    title: 'Milestone chest',
    streakRibbon: true,
    body: 'A chest for reaching level 30.',
    coins: coins,
    hints: hints,
    feedback: feedback,
    library: FakeFxLibrary(),
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
    testWidgets('the card sits at top 214 (28 in from each side); Open is '
        'not live yet', (tester) async {
      await pumpScreen(tester, sequence());
      final card = tester.getRect(find.byKey(ChestRewardSequence.cardKey));
      expect(card.left, closeTo(28, 0.01));
      expect(card.right, closeTo(390 - 28, 0.01));
      // The design's y 214 on the harness' 59 dp safe area.
      expect(card.top, closeTo(214, 0.01));
      await tester.tap(find.text('Open'), warnIfMissed: false);
      await toIdle(tester);
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Collect'), findsNothing);
    });

    testWidgets('the chest\'s Lottie box is 200 × 200', (tester) async {
      await pumpScreen(tester, sequence());
      await toIdle(tester);
      expect(
        tester.getSize(find.byKey(ChestRewardSequence.chestKey)),
        const Size(200, 200),
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
      expect(find.byKey(ChestRewardSequence.raysKey), findsNothing);
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
      // The rays turn from the lid.
      expect(find.byKey(ChestRewardSequence.raysKey), findsOneWidget);
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
      expect(find.byKey(ChestRewardSequence.raysKey), findsNothing);
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
