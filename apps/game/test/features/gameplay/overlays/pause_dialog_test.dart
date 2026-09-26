import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

void main() {
  setUpAll(loadBundledFonts);

  Widget dialog({
    PauseSettings settings = const PauseSettings(
      sound: true,
      music: false,
      haptics: true,
    ),
    List<String>? calls,
  }) => PauseDialog(
    level: 56,
    tier: Tier.hard,
    settings: settings,
    library: FakeFxLibrary(),
    onSoundChanged: (on) => calls?.add('sound $on'),
    onMusicChanged: (on) => calls?.add('music $on'),
    onHapticsChanged: (on) => calls?.add('haptics $on'),
    onResume: () => calls?.add('resume'),
    onRestart: () => calls?.add('restart'),
    onHome: () => calls?.add('home'),
  );

  testWidgets('frame 3.9: "Paused", the level, three toggles, the actions', (
    tester,
  ) async {
    await pumpScreen(tester, dialog());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('Level 56 · Hard'), findsOneWidget);
    expect(find.byType(NestyToggle), findsNWidgets(3));
    for (final label in ['Resume', 'Restart', 'Home', 'Settings']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(
      tester.getSemantics(find.bySemanticsLabel('Sound')),
      isSemantics(hasToggledState: true, isToggled: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Music')),
      isSemantics(hasToggledState: true, isToggled: false),
    );
  });

  testWidgets('toggles and actions call back; Settings waits for M3', (
    tester,
  ) async {
    final calls = <String>[];
    await pumpScreen(tester, dialog(calls: calls));
    await tester.pump(const Duration(milliseconds: 300));
    for (final label in ['Sound', 'Music', 'Haptics']) {
      await tester.tap(find.bySemanticsLabel(label));
      await tester.pump(const Duration(milliseconds: 100));
    }
    for (final label in ['Resume', 'Restart', 'Home', 'Settings']) {
      await tester.tap(find.text(label));
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(calls, [
      'sound false',
      'music true',
      'haptics false',
      'resume',
      'restart',
      'home',
    ]);
  });

  testWidgets('the scrim does not resume', (tester) async {
    final calls = <String>[];
    await pumpScreen(tester, dialog(calls: calls));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    expect(calls, isEmpty);
  });

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets('fits ${size.width.toInt()} wide at $scale× text', (
        tester,
      ) async {
        await pumpScreen(tester, dialog(), size: size, textScale: scale);
        await tester.pump(const Duration(milliseconds: 300));
        expectNoLayoutErrors(tester);
        final card = tester.getRect(find.byType(ModalCard));
        expect(card.left, greaterThanOrEqualTo(32));
        expect(card.right, lessThanOrEqualTo(size.width - 32));
      });
    }
  }
}
