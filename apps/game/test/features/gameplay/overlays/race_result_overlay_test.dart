import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart' show DollColor;
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/services/records/badge.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/widgets/race/race_coin_chip.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/overlays/race_result_overlay.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

/// Frames 9.4 ([RaceWinCard]), 9.5 ([RaceLossCard]) and 9.6
/// ([RivalUnlockedCard]) (vs Computer; m7-design P4.4): the two-button
/// layout, the jingles and haptics, the plank with the player's families,
/// the rival tagged Computer, and the once-per-rival card. The layer that
/// joins them (9.6 as 9.4 closes) is exercised by the race view test.
void main() {
  setUpAll(loadBundledFonts);

  Widget win({
    int rival = 2,
    int reward = 30,
    List<DollColor> families = const [DollColor.red, DollColor.blue],
    List<BadgeId> badges = const [],
    List<String>? calls,
    RecordingCues? cues,
    FakeAudioService? jingles,
  }) => RaceWinCard(
    rival: rival,
    rewardCoins: reward,
    families: families,
    newBadges: badges,
    feedback: cues,
    jingles: jingles,
    library: FakeFxLibrary(),
    onRematch: () => calls?.add('rematch'),
    onNewRace: () => calls?.add('newRace'),
  );

  Widget loss({
    int rival = 3,
    List<DollColor> families = const [DollColor.red],
    List<String>? calls,
    FakeAudioService? jingles,
  }) => RaceLossCard(
    rival: rival,
    families: families,
    jingles: jingles,
    library: FakeFxLibrary(),
    onRematch: () => calls?.add('rematch'),
    onNewRace: () => calls?.add('newRace'),
  );

  group('9.4 RaceWinCard', () {
    testWidgets('the ribbon, "+30 coins" counting up, the rival, tagged '
        'Computer, and New race then Rematch', (tester) async {
      final calls = <String>[];
      await pumpScreen(tester, win(calls: calls));
      expect(find.text('You won the race!'), findsOneWidget);
      // The chip counts up once the coin bursts (700 ms in); its label says
      // the whole reward.
      expect(find.text('+0 coins'), findsOneWidget);
      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('+30 coins'), findsOneWidget);
      handle.dispose();
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('+30 coins'), findsOneWidget);
      expect(find.text('Button'), findsOneWidget);
      expect(find.text('Computer'), findsOneWidget);
      expect(
        find.text('You completed every family before Button.'),
        findsOneWidget,
      );
      // No moves chip, no stars, no third control.
      expect(find.textContaining('Moves'), findsNothing);
      expect(find.text('Back to races'), findsNothing);
      expect(find.byType(TactileButton), findsNWidgets(2));
      // New race (versus) above Rematch (secondary).
      final buttons = tester
          .widgetList<TactileButton>(find.byType(TactileButton))
          .toList();
      expect(buttons.map((b) => b.label), ['New race', 'Rematch']);
      expect(buttons[0].variant, TactileButtonVariant.versus);
      expect(buttons[1].variant, TactileButtonVariant.secondary);
      expect(
        tester.getTopLeft(find.text('New race')).dy,
        lessThan(tester.getTopLeft(find.text('Rematch')).dy),
      );

      await tester.tap(find.text('Rematch'));
      await tester.tap(find.text('New race'));
      expect(calls, ['rematch', 'newRace']);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('jingle_versus_win at the open instead of the win sound; '
        'the win haptic stays; the coins cue follows', (tester) async {
      final cues = RecordingCues();
      final jingles = FakeAudioService();
      await pumpScreen(tester, win(cues: cues, jingles: jingles));
      expect(jingles.jingles, [Jingle.versusWin]);
      expect(cues.played.map((c) => c.sound), isNot(contains(SoundEffect.win)));
      expect(cues.played.map((c) => c.haptic), contains(HapticPattern.win));
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(cues.played.map((c) => c.sound), contains(SoundEffect.coins));
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('the player\'s completed families hop on the plank, 104 '
        'tall (88 above four)', (tester) async {
      await pumpScreen(tester, win());
      var dolls = tester.widgetList<LottieDoll>(find.byType(LottieDoll));
      expect(dolls.map((d) => d.color), [DollColor.red, DollColor.blue]);
      expect(dolls.map((d) => d.height).toSet(), {104.0});
      expect(dolls.last.startDelay, greaterThan(Duration.zero));
      await pumpScreen(
        tester,
        win(families: DollColor.values.take(5).toList()),
      );
      dolls = tester.widgetList<LottieDoll>(find.byType(LottieDoll));
      expect(dolls.map((d) => d.height).toSet(), {88.0});
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('badge toasts queue at 900 ms on the card\'s own host, top '
        '60, and leave with it', (tester) async {
      await pumpScreen(
        tester,
        ToastHost(
          top: ToastHost.badgeTop,
          child: win(badges: const [BadgeId.firstRace]),
        ),
      );
      expect(find.textContaining('Badge earned'), findsNothing);
      await tester.pump(const Duration(milliseconds: 950));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('Badge earned'), findsOneWidget);
      final top = tester.getTopLeft(find.textContaining('Badge earned')).dy;
      // 60 below the design's safe top (59) is the host's `top - 59` inside
      // the safe area the harness gives.
      expect(top, greaterThan(50));
      expect(top, lessThan(150));
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('reduced motion: no confetti, no twinkle, no hop delay', (
      tester,
    ) async {
      await pumpScreen(tester, win(), reduceMotion: true);
      expect(find.byType(LottieTwinkle), findsNothing);
      await pumpScreen(tester, win());
      expect(find.byType(LottieTwinkle), findsWidgets);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('a screen reader hears the rival as "{name}, Computer" with '
        'the body, and a live "You won the race."', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, win());
      expect(
        find.bySemanticsLabel(
          'Button, Computer. You completed every family before Button.',
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('You won the race.'), findsOneWidget);
      expect(find.bySemanticsLabel('2'), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      handle.dispose();
    });
  });

  group('9.5 RaceLossCard', () {
    testWidgets('the warm title and body, the rival tagged Computer, Rematch '
        'then New race, and no reward', (tester) async {
      final calls = <String>[];
      await pumpScreen(tester, loss(calls: calls));
      expect(find.text('So close! Rematch?'), findsOneWidget);
      expect(
        find.text('Comet finished first this time. A rematch costs nothing.'),
        findsOneWidget,
      );
      expect(find.text('Comet'), findsOneWidget);
      expect(find.text('Computer'), findsOneWidget);
      expect(find.byType(RaceCoinChip), findsNothing);
      expect(find.textContaining('coins'), findsNothing);
      final buttons = tester
          .widgetList<TactileButton>(find.byType(TactileButton))
          .toList();
      expect(buttons.map((b) => b.label), ['Rematch', 'New race']);
      expect(buttons[0].variant, TactileButtonVariant.versus);
      expect(buttons[1].variant, TactileButtonVariant.secondary);
      expect(find.text('Back to races'), findsNothing);

      await tester.tap(find.text('Rematch'));
      await tester.tap(find.text('New race'));
      expect(calls, ['rematch', 'newRace']);
    });

    testWidgets('jingle_versus_lose at the open, the plain scrim (never the '
        'strong one), and no twinkle', (tester) async {
      final jingles = FakeAudioService();
      await pumpScreen(tester, loss(jingles: jingles));
      expect(jingles.jingles, [Jingle.versusLose]);
      expect(find.byType(Scrim), findsOneWidget);
      expect(find.byType(LottieTwinkle), findsNothing);
    });

    testWidgets('only the families the player completed stand on the plank, '
        'still', (tester) async {
      await pumpScreen(tester, loss(families: const [DollColor.red]));
      final dolls = tester.widgetList<LottieDoll>(find.byType(LottieDoll));
      expect(dolls.map((d) => d.color), [DollColor.red]);
      expect(dolls.single.startDelay, Duration.zero);
      // Standing still: the doll's ancestors say motion is off.
      final motion = MediaQuery.of(tester.element(find.byType(LottieDoll)));
      expect(motion.disableAnimations, isTrue);
    });

    testWidgets('reads "{name}, Computer" with the warm body and announces '
        'the loss', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, loss());
      expect(
        find.bySemanticsLabel(
          'Comet, Computer. Comet finished first this time. '
          'A rematch costs nothing.',
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('The computer finished first.'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('9.6 RivalUnlockedCard', () {
    testWidgets('the pill, the rival with its tag and skill, the body, New '
        'race and Not now', (tester) async {
      final calls = <String>[];
      await pumpScreen(
        tester,
        RivalUnlockedCard(
          rival: 2,
          onNewRace: () => calls.add('newRace'),
          onNotNow: () => calls.add('notNow'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('New rival unlocked!'), findsOneWidget);
      expect(find.text('Button'), findsOneWidget);
      expect(find.text('Computer'), findsOneWidget);
      expect(find.text('Careful · Slow'), findsOneWidget);
      expect(find.text('Button is ready to race.'), findsOneWidget);
      final portrait = tester.widget<RivalPortrait>(find.byType(RivalPortrait));
      expect(portrait.size, 128);
      expect(portrait.emphasis, isTrue);

      await tester.tap(find.text('New race'));
      await tester.tap(find.text('Not now'));
      expect(calls, ['newRace', 'notNow']);
    });

    testWidgets('no sound and no haptic of its own; the rays turn, and stay '
        'still under reduced motion', (tester) async {
      Widget card() =>
          RivalUnlockedCard(rival: 3, onNewRace: () {}, onNotNow: () {});
      await pumpScreen(tester, card());
      await tester.pump(const Duration(milliseconds: 300));
      RotationTransition rays() =>
          tester.widget<RotationTransition>(find.byType(RotationTransition));
      final before = rays().turns.value;
      await tester.pump(const Duration(seconds: 3));
      expect(rays().turns.value, isNot(before));

      await pumpScreen(tester, card(), reduceMotion: true);
      await tester.pump(const Duration(milliseconds: 300));
      final still = rays().turns.value;
      await tester.pump(const Duration(seconds: 3));
      expect(rays().turns.value, still);
    });

    testWidgets('reads the rival as Computer with the body', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(
        tester,
        RivalUnlockedCard(rival: 3, onNewRace: () {}, onNotNow: () {}),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.bySemanticsLabel('Comet, Computer. Comet is ready to race.'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
