import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/overlays/win_overlay.dart';
import 'package:nesty_game/features/gameplay/pages/chapter_progress.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../../helpers/level_fixtures.dart';
import '../../support/screen_harness.dart';

const _chapter = ChapterProgress(
  chapterId: 'ch03',
  number: 3,
  done: 16,
  total: 20,
  isFirstLevel: false,
);

Widget _overlay({
  int reward = 25,
  List<DollColor> families = const [
    DollColor.red,
    DollColor.blue,
    DollColor.green,
    DollColor.purple,
  ],
  ChapterProgress chapter = _chapter,
  RecordingCues? feedback,
  VoidCallback? onContinue,
}) => WinOverlay(
  summary: WinSummary(reward: reward, families: families, chapter: chapter),
  feedback: feedback,
  library: FakeFxLibrary(),
  onContinue: onContinue ?? () {},
);

void main() {
  setUpAll(loadBundledFonts);

  testWidgets('frame 2.8: ribbon, families, "+N", chapter card, Continue', (
    tester,
  ) async {
    await pumpScreen(tester, _overlay());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.bySemanticsLabel('Level Complete!'), findsOneWidget);
    expect(find.byType(LottieDoll), findsNWidgets(4));
    expect(find.text('Chapter 3'), findsOneWidget);
    expect(find.text('16 / 20'), findsOneWidget);
    expect(find.text('Next up: The Baker Family'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    // The ×3 video is M6: hidden, as offline.
    expect(find.text('×3 coins'), findsNothing);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('the coins count up from 700 ms with the coins cue', (
    tester,
  ) async {
    final feedback = RecordingCues();
    await pumpScreen(tester, _overlay(feedback: feedback));
    // win + its haptic at the open (LOTTIE.md "Win overlay").
    expect(feedback.played.single.sound, SoundEffect.win);
    expect(feedback.played.single.haptic, HapticPattern.win);
    expect(find.text('+0'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 699));
    expect(find.text('+0'), findsOneWidget);
    expect(feedback.played, hasLength(1));

    await tester.pump(const Duration(milliseconds: 2));
    expect(feedback.played.last.sound, SoundEffect.coins);
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('+25'), findsOneWidget);
    expect(find.bySemanticsLabel('25 coins'), findsOneWidget);
  });

  testWidgets('reduced motion halves the schedule (D48)', (tester) async {
    final feedback = RecordingCues();
    await pumpScreen(tester, _overlay(feedback: feedback), reduceMotion: true);
    await tester.pump(const Duration(milliseconds: 351));
    expect(feedback.played.last.sound, SoundEffect.coins);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('+25'), findsOneWidget);
  });

  testWidgets('Continue calls back', (tester) async {
    var continued = 0;
    await pumpScreen(tester, _overlay(onContinue: () => continued++));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Continue'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(continued, 1);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('the last level of a chapter says the prize is next', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      _overlay(
        chapter: const ChapterProgress(
          chapterId: 'ch01',
          number: 1,
          done: 20,
          total: 20,
          isFirstLevel: false,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Chapter complete! Your prize is next.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets('fits ${size.width.toInt()} wide at $scale× text', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          _overlay(
            reward: 1240,
            families: const [
              DollColor.red,
              DollColor.blue,
              DollColor.green,
              DollColor.purple,
              DollColor.orange,
            ],
          ),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(seconds: 2));
        expectNoLayoutErrors(tester);
        // Continue stays on screen.
        final button = tester.getRect(find.text('Continue'));
        expect(button.bottom, lessThanOrEqualTo(size.height));
        expect(find.byType(LottieDoll), findsNWidgets(5));
      });
    }
  }

  group('WinSummary.familiesOf', () {
    test('one per completed colour, in first-seen board order', () {
      final level = levelFrom('''
{
  "schemaVersion": 1, "id": "T1", "maxSize": 3,
  "shelves": [
    [ {"type": "open", "nest": ["blue3"]},
      {"type": "open", "nest": ["blue2", "blue1"]},
      {"type": "open", "nest": ["red3"]} ],
    [ {"type": "open", "nest": ["red2", "red1"]},
      {"type": "open", "nest": null},
      {"type": "open", "nest": null} ]
  ]
}
''');
      final session = GameSession(level);
      expect(WinSummary.familiesOf(level, session.state), isEmpty);
      session.move('r1c0', 'r0c2');
      expect(WinSummary.familiesOf(level, session.state), [DollColor.red]);
      session.move('r0c1', 'r0c0');
      // Blue shows first: it comes first on the board.
      expect(WinSummary.familiesOf(level, session.state), [
        DollColor.blue,
        DollColor.red,
      ]);
    });
  });
}
