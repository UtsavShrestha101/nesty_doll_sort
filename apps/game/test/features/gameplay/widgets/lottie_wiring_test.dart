// The HUD, booster bar, overlays and ribbon on the shipped Lottie files
// (m2-lottie-design §7, §12, §13, §15): the markers they play exist, their
// tickers stop at rest, and the static fallbacks give way to the files.
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';
import 'package:nesty_game/features/gameplay/overlays/win_overlay.dart';
import 'package:nesty_game/features/gameplay/pages/chapter_progress.dart';
import 'package:nesty_game/features/gameplay/widgets/booster_bar.dart';
import 'package:nesty_game/features/gameplay/widgets/chapter_ribbon.dart';
import 'package:nesty_game/features/gameplay/widgets/family_counter.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../fx/support/fx_test_art.dart';
import '../../support/lottie_library.dart';
import '../../support/screen_harness.dart';

bool _ticking() => SchedulerBinding.instance.transientCallbackCount > 0;

Finder _painted<T extends CustomPainter>() => find.byWidgetPredicate(
  (widget) => widget is CustomPaint && widget.painter is T,
);

class _Counter extends StatefulWidget {
  const _Counter({required this.library});

  final FakeFxLibrary library;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int done = 0;

  @override
  Widget build(BuildContext context) => Center(
    child: GestureDetector(
      onTap: () => setState(() => done++),
      child: SizedBox.fromSize(
        size: FamilyCounter.canvas,
        child: FamilyCounter(done: done, total: 5, library: widget.library),
      ),
    ),
  );
}

void main() {
  late FakeFxLibrary library;

  setUpAll(loadBundledFonts);

  Future<void> load(WidgetTester tester) async {
    library = (await tester.runAsync(widgetLottieLibrary))!;
  }

  testWidgets('the family counter bumps on its file, then rests', (
    tester,
  ) async {
    await load(tester);
    await pumpScreen(tester, _Counter(library: library));
    await tester.pump();
    expect(_painted<FamilyCounterPillPainter>(), findsNothing);
    expect(find.bySemanticsLabel('0 of 5 families done'), findsOneWidget);
    expect(_ticking(), isFalse, reason: 'rests on frame 0');

    await tester.tap(find.byType(FamilyCounter));
    await tester.pump();
    expect(_ticking(), isTrue, reason: 'bump plays');
    expect(find.bySemanticsLabel('1 of 5 families done'), findsOneWidget);
    // bump: 12 frames (200 ms).
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 150));
    expect(_ticking(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a landing family bursts a 1.5× fx_sparkle over the counter, '
      'drawn only while it plays (LOTTIE.md "Completed", review '
      'FIDELITY-1)', (tester) async {
    await load(tester);
    library.compositions[FxId.fxSparkle] = (await tester.runAsync(
      () => shippedOnce(FxId.fxSparkle),
    ))!;
    await pumpScreen(tester, _Counter(library: library));
    await tester.pump();
    Finder sparkle() => find.byWidgetPredicate(
      (w) => w is LottieFxView && w.id == FxId.fxSparkle,
    );
    expect(sparkle(), findsNothing, reason: 'nothing at rest');

    await tester.tap(find.byType(FamilyCounter));
    await tester.pump();
    expect(sparkle(), findsOneWidget);
    // 1.5 × the 64 × 64 canvas, its centre (the anchor) on the counter's.
    final box = tester.getRect(sparkle());
    expect(box.size, const Size(96, 96));
    expect(box.center, tester.getCenter(find.byType(FamilyCounter)));
    // 16 frames (267 ms), then gone.
    await tester.pump(const Duration(milliseconds: 150));
    expect(sparkle(), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump();
    expect(sparkle(), findsNothing);
    expect(_ticking(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the pause toggles play ui_toggle on and off', (tester) async {
    await load(tester);
    var sound = true;
    await pumpScreen(
      tester,
      StatefulBuilder(
        builder: (context, setState) => PauseDialog(
          level: 3,
          tier: Tier.easy,
          settings: PauseSettings(sound: sound, music: false, haptics: true),
          library: library,
          onSoundChanged: (on) => setState(() => sound = on),
          onMusicChanged: (_) {},
          onHapticsChanged: (_) {},
          onResume: () {},
          onRestart: () {},
          onHome: () {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(LottieToggle), findsNWidgets(3));
    expect(_ticking(), isFalse, reason: 'toggles rest on on/off');

    await tester.tap(find.bySemanticsLabel('Sound'));
    await tester.pump();
    expect(sound, isFalse);
    expect(_ticking(), isTrue, reason: '`off` plays');
    await tester.pump(const Duration(milliseconds: 250));
    expect(_ticking(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the soft-stuck Undo glows on ui_booster_glow (a loop)', (
    tester,
  ) async {
    await load(tester);
    await pumpScreen(
      tester,
      Align(
        alignment: Alignment.bottomCenter,
        child: BoosterBar(
          model: const BoosterBarModel(undoEnabled: true, undoGlow: true),
          library: library,
          onUndo: () {},
          onHint: () {},
          onExtraSlot: () {},
          onRestart: () {},
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(BoosterGlow), findsOneWidget);
    expect(_ticking(), isTrue, reason: 'informational loop, D48');
    expect(tester.takeException(), isNull);
  });

  testWidgets('the chapter ribbon plays its file and ends', (tester) async {
    await load(tester);
    var done = 0;
    await pumpScreen(
      tester,
      Center(
        child: SizedBox.fromSize(
          size: ChapterRibbon.canvas,
          child: ChapterRibbon(
            number: 2,
            chapterId: 'ch02',
            library: library,
            onDone: () => done++,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(
      find.bySemanticsLabel('CHAPTER 2 · Rainy Café Corner'),
      findsOneWidget,
    );
    expect(_ticking(), isTrue);
    for (var i = 0; i < 28; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(done, 1);
    expect(tester.takeException(), isNull);
  });

  for (final reduceMotion in [false, true]) {
    testWidgets('the win overlay plays its files '
        '(reduced motion: $reduceMotion)', (tester) async {
      await load(tester);
      final cues = RecordingCues();
      await pumpScreen(
        tester,
        WinOverlay(
          summary: const WinSummary(
            reward: 25,
            families: [DollColor.red, DollColor.blue, DollColor.green],
            chapter: ChapterProgress(
              chapterId: 'ch01',
              number: 1,
              done: 4,
              total: 20,
              isFirstLevel: false,
            ),
          ),
          library: library,
          feedback: cues,
          onContinue: () {},
        ),
        reduceMotion: reduceMotion,
      );
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('+25'), findsOneWidget);
      expect(find.bySemanticsLabel('Level Complete!'), findsOneWidget);
      expect(cues.played, hasLength(2), reason: 'win @0, coins @700');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('without files every piece keeps its static look (R10)', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      Center(
        child: SizedBox.fromSize(
          size: FamilyCounter.canvas,
          child: FamilyCounter(done: 1, total: 3, library: FakeFxLibrary()),
        ),
      ),
    );
    await tester.pump();
    expect(_painted<FamilyCounterPillPainter>(), findsOneWidget);
    expect(find.byType(NestyToggle), findsNothing);
  });
}
