import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/ticker/fake_frame_ticker.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/race/cubit/race_cubit.dart';
import 'package:nesty_game/features/race/widgets/rival_strip.dart';

import '../../../core/ui/support/ui_harness.dart';

/// The race board's rival strip (frames 9.3-9.3e; m7-design P2.9, P4.4): the merged
/// semantics node, the throttled live-region announcer, and the counter
/// bump's reduced-motion rule, all on a [RivalStripView] pumped directly
/// with its data (no live `RaceCubit` needed).
void main() {
  setUpAll(loadBundledFonts);

  RivalStripData dataOf({
    int rival = 1,
    RivalActivity activity = RivalActivity.idle,
    int rivalSets = 0,
    int totalSets = 3,
    int rivalMoves = 0,
    bool held = false,
    bool over = false,
  }) => (
    rival: rival,
    activity: activity,
    rivalSets: rivalSets,
    totalSets: totalSets,
    rivalMoves: rivalMoves,
    held: held,
    over: over,
  );

  Future<void> pump(
    WidgetTester tester,
    RivalStripData data, {
    bool reduceMotion = false,
    double width = 390,
  }) => pumpUi(
    tester,
    RivalStripView(data: data),
    reduceMotion: reduceMotion,
    width: width,
  );

  testWidgets('one merged node names the rival, Computer and its progress', (
    tester,
  ) async {
    await pump(tester, dataOf(rivalSets: 1, totalSets: 3));
    expect(
      find.bySemanticsLabel('Pebble, computer: 1 of 3 families'),
      findsOneWidget,
    );
    expect(find.text('Pebble'), findsOneWidget);
    expect(find.text('Computer'), findsOneWidget, reason: 'the tag');
    expect(find.byIcon(IconUses.computerTag), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
  });

  testWidgets('the portrait is ui_rival_react at 38 dp; its family count is '
      'the rival\'s completed families (m7-4 C.6)', (tester) async {
    await pump(tester, dataOf(rival: 2, rivalSets: 1));
    final react = tester.widget<RivalReact>(find.byType(RivalReact));
    expect((react.number, react.size, react.familyCount), (2, 38, 1));
    await pump(tester, dataOf(rival: 2, rivalSets: 2));
    expect(tester.widget<RivalReact>(find.byType(RivalReact)).familyCount, 2);
  });

  testWidgets('the Computer tag sits beside every rival name', (tester) async {
    for (final rival in [1, 2, 3]) {
      await pump(tester, dataOf(rival: rival));
      final names = ['Pebble', 'Button', 'Comet'];
      expect(find.text(names[rival - 1]), findsOneWidget);
      expect(find.byType(ComputerTag), findsOneWidget, reason: 'rival $rival');
    }
  });

  testWidgets('the strip is 48 tall with a 38 dp portrait', (tester) async {
    await pump(tester, dataOf());
    expect(tester.getSize(find.byType(RivalStripView)).height, 48);
    expect(
      tester.getSize(find.byType(RivalPortrait)),
      const Size.square(RivalStripTokens.portrait),
    );
  });

  for (final (activity, label) in const [
    (RivalActivity.idle, 'Ready when you are'),
    (RivalActivity.thinking, 'Thinking…'),
    (RivalActivity.startingOver, 'Starting over'),
    (RivalActivity.finished, 'Finished'),
  ]) {
    testWidgets('the state line for $activity reads "$label"', (tester) async {
      // Reduced motion shows the label whole; motion swaps the ellipsis
      // for animated dots (tested below).
      await pump(tester, dataOf(activity: activity), reduceMotion: true);
      expect(find.text(label), findsOneWidget);
    });
  }

  testWidgets('thinking: the word and three animated 3 dp dots; reduced '
      'motion and a hold show the text alone', (tester) async {
    await pump(tester, dataOf(activity: RivalActivity.thinking));
    expect(find.text('Thinking'), findsOneWidget);
    Iterable<Opacity> dots() => tester.widgetList<Opacity>(
      find.descendant(
        of: find.byType(RivalStripView),
        matching: find.byType(Opacity),
      ),
    );
    expect(dots().length, RivalStripTokens.stateThinkingDots);
    // The dots start after the first frame (a repeat notifies at once).
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));
    final before = dots().map((o) => o.opacity).toList();
    await tester.pump(const Duration(milliseconds: 500));
    final after = dots().map((o) => o.opacity).toList();
    expect(after, isNot(before), reason: 'the dots move');

    await pump(tester, dataOf(activity: RivalActivity.thinking, held: true));
    expect(find.text('Thinking…'), findsOneWidget);
    expect(dots(), isEmpty, reason: 'a hold stops the dots');
    await pump(
      tester,
      dataOf(activity: RivalActivity.thinking),
      reduceMotion: true,
    );
    expect(find.text('Thinking…'), findsOneWidget);
    expect(dots(), isEmpty);
  });

  testWidgets('starting over and finished carry their glyphs', (tester) async {
    await pump(tester, dataOf(activity: RivalActivity.startingOver));
    expect(find.byIcon(NestyIcons.refresh), findsOneWidget);
    await pump(
      tester,
      dataOf(activity: RivalActivity.finished, rivalSets: 3, over: true),
    );
    expect(find.byIcon(NestyIcons.checkCircle), findsOneWidget);
    final icon = tester.widget<Icon>(find.byIcon(NestyIcons.checkCircle));
    expect(icon.color, AppColorTokens.versus);
  });

  // The rival's activity stays `thinking` when the player wins, so the line
  // names the win instead of "Thinking…" under 9.6's card (frame 9.6).
  for (final activity in const [
    RivalActivity.thinking,
    RivalActivity.startingOver,
  ]) {
    testWidgets('once the player has won, $activity reads "You finished '
        'first" with a green check', (tester) async {
      await pump(tester, dataOf(activity: activity, rivalSets: 3, over: true));
      expect(find.text('You finished first'), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(NestyIcons.checkCircle));
      expect(icon.color, AppColorTokens.success);
      for (final line in const ['Thinking…', 'Starting over', 'Finished']) {
        expect(find.text(line), findsNothing, reason: line);
      }
      // Frozen at the rival's progress.
      expect(find.text('3/3'), findsOneWidget);
    });
  }

  testWidgets('a rival that finished first still says "Finished" once the '
      'race is over', (tester) async {
    await pump(
      tester,
      dataOf(activity: RivalActivity.finished, rivalSets: 3, over: true),
    );
    expect(find.text('Finished'), findsOneWidget);
    expect(find.text('You finished first'), findsNothing);
  });

  testWidgets('one dot per family, filled up to the count', (tester) async {
    await pump(tester, dataOf(rivalSets: 2, totalSets: 4), reduceMotion: true);
    for (var i = 0; i < 4; i++) {
      final dot = find.byKey(ValueKey('rivalDot-$i'));
      expect(dot, findsOneWidget);
      final box = tester.widget<DecoratedBox>(
        find.descendant(of: dot, matching: find.byType(DecoratedBox)).first,
      );
      final color = (box.decoration as BoxDecoration).color;
      expect(
        color,
        i < 2 ? RivalStripTokens.dotsFilled : RivalStripTokens.dotsEmpty,
        reason: 'dot $i',
      );
    }
    final size = tester.getSize(
      find
          .descendant(
            of: find.byKey(const ValueKey('rivalDot-0')),
            matching: find.byType(SizedBox),
          )
          .first,
    );
    expect(size, const Size.square(RivalStripTokens.dotsSize));
  });

  testWidgets('above 8 families the count stands alone, so the name and '
      'the Computer word keep their room', (tester) async {
    await pump(tester, dataOf(rivalSets: 5, totalSets: 12), width: 320);
    expect(tester.takeException(), isNull);
    expect(find.text('5/12'), findsOneWidget);
    expect(find.byKey(const ValueKey('rivalDot-0')), findsNothing);
  });

  testWidgets('a filling dot and the count bump with the tokens; reduced '
      'motion fills at once', (tester) async {
    await pump(tester, dataOf());
    await pump(tester, dataOf(rivalSets: 1, rivalMoves: 1));
    final bump = tester.widget<TweenAnimationBuilder<double>>(
      find.byKey(const ValueKey('rivalCounterBump-1')),
    );
    expect(
      bump.duration,
      const Duration(milliseconds: RivalMotionTokens.dotFillMs),
    );
    expect(bump.tween.begin, RivalMotionTokens.dotBump);
    expect(bump.curve, RivalMotionTokens.dotCurve);
    await tester.pump(const Duration(milliseconds: 500));

    await pump(tester, dataOf(), reduceMotion: true);
    await pump(tester, dataOf(rivalSets: 1, rivalMoves: 1), reduceMotion: true);
    final still = tester.widget<TweenAnimationBuilder<double>>(
      find.byKey(const ValueKey('rivalCounterBump-1')),
    );
    expect(still.duration, Duration.zero);
    expect(still.tween.begin, 1.0);
    final beat = tester.widget<TweenAnimationBuilder<double>>(
      find.byKey(const ValueKey('rivalMovedBeat')),
    );
    expect(beat.duration, Duration.zero);
  });

  testWidgets('the portrait beats 1.06 for 160 ms on a move, not on a family '
      'count alone', (tester) async {
    await pump(tester, dataOf());
    await pump(tester, dataOf(rivalMoves: 1));
    final beat = tester.widget<TweenAnimationBuilder<double>>(
      find.byKey(const ValueKey('rivalMovedBeat')),
    );
    expect(beat.tween.begin, RivalMotionTokens.movePortraitScale);
    expect(
      beat.duration,
      const Duration(milliseconds: RivalMotionTokens.moveMs),
    );
    await tester.pump(const Duration(milliseconds: 300));
  });

  // Widths 320 to 430: the tag is glyph only under 360, the state line is
  // hidden under 340 (screen width; the strip is W - 92 wide), and nothing
  // overflows or is cut, at 1.0 and 1.3 text.
  for (final width in const [320.0, 339.0, 340.0, 359.0, 360.0, 390.0, 430.0]) {
    for (final scale in const [1.0, 1.3]) {
      final tag = width < 360 ? 'glyph only' : 'with its word';
      final line = width < 340 ? 'hidden' : 'shown';
      testWidgets(
        'at $width dp and ${scale}x text: tag $tag, state line $line, '
        'no overflow',
        (tester) async {
          await pumpUi(
            tester,
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 76, right: 16),
                child: RivalStripView(
                  data: dataOf(
                    activity: RivalActivity.thinking,
                    rivalSets: 1,
                    totalSets: 4,
                  ),
                ),
              ),
            ),
            width: width,
            textScale: scale,
          );
          expect(tester.takeException(), isNull);
          expect(
            find.text('Computer'),
            width < 360 ? findsNothing : findsOneWidget,
          );
          expect(find.byIcon(IconUses.computerTag), findsOneWidget);
          expect(
            find.textContaining('Thinking'),
            width < 340 ? findsNothing : findsOneWidget,
          );
          expect(tester.getSize(find.byType(RivalStripView)).height, 48);
          // Screen readers always hear "Computer", whatever is drawn.
          final handle = tester.ensureSemantics();
          expect(
            find.bySemanticsLabel(RegExp('^Pebble, computer')),
            findsOneWidget,
          );
          handle.dispose();
        },
      );
    }
  }

  testWidgets('Start is announced once, naming the computer '
      '(a11y_race_start)', (tester) async {
    await pump(tester, dataOf());
    await pump(tester, dataOf(activity: RivalActivity.thinking));
    expect(
      find.bySemanticsLabel('Race started against Pebble, a computer player.'),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 2000));
  });

  testWidgets('the live region announces a family, throttled to one per '
      '2,000 ms, and the latest wins', (tester) async {
    await pump(tester, dataOf());
    await pump(tester, dataOf(rivalSets: 1, rivalMoves: 1));
    expect(
      find.bySemanticsLabel('The computer completed a family: 1 of 3'),
      findsOneWidget,
    );

    // Queued while the first announcement's throttle is still open: the
    // live region doesn't change yet.
    await pump(
      tester,
      dataOf(rivalSets: 1, rivalMoves: 2, activity: RivalActivity.startingOver),
    );
    expect(
      find.bySemanticsLabel('The computer completed a family: 1 of 3'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('The computer is starting over.'),
      findsNothing,
    );

    await tester.pump(const Duration(milliseconds: 2000));
    expect(
      find.bySemanticsLabel('The computer is starting over.'),
      findsOneWidget,
    );

    // Lets the second announcement's own throttle timer run out, so
    // nothing is left pending when the test tears the tree down.
    await tester.pump(const Duration(milliseconds: 2000));
  });

  group('rival_complete', () {
    _PushCubit cubit() => _PushCubit(
      const RacePlay(rival: 1, raceNo: 1),
      FakeSaveService(),
      FakeRemoteConfigService(),
      FakeFrameTicker(),
    );

    testWidgets('plays once per family the rival lands, with no haptic, and '
        'not for a move or a restart', (tester) async {
      final audio = FakeAudioService();
      final race = cubit();
      addTearDown(() => tester.runAsync(race.close));
      race.push(
        AsyncValue.data(
          data: RaceState(
            request: race.request,
            totalSets: 3,
            phase: RacePhase.running,
          ),
        ),
      );
      await pumpUi(tester, RivalStrip(cubit: race, audio: audio));
      expect(audio.played, isEmpty);

      RaceState now() => race.state.data!;
      race.push(AsyncValue.data(data: now().copyWith(rivalMoves: 1)));
      await tester.pump();
      expect(audio.played, isEmpty, reason: 'a move alone is silent');

      race.push(AsyncValue.data(data: now().copyWith(rivalSets: 1)));
      await tester.pump();
      race.push(AsyncValue.data(data: now().copyWith(rivalSets: 2)));
      await tester.pump();
      expect(
        audio.played.where((p) => p.effect == SoundEffect.rivalComplete),
        hasLength(2),
      );

      race.push(
        AsyncValue.data(
          data: now().copyWith(
            rivalSets: 0,
            activity: RivalActivity.startingOver,
          ),
        ),
      );
      await tester.pump();
      expect(
        audio.played.where((p) => p.effect == SoundEffect.rivalComplete),
        hasLength(2),
        reason: 'starting over is not a family',
      );
      await tester.pump(const Duration(seconds: 5));
    });
  });
}

/// A [RaceCubit] whose state a test sets directly.
class _PushCubit extends RaceCubit {
  _PushCubit(super.request, super.save, super.remoteConfig, super.ticker);

  void push(AsyncValue<RaceState> value) => emit(value);
}
