import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

/// Pause in a race (frame 9.7) and Leave race's one confirmation (9.7b)
/// (vs Computer; m7-design P4.4).
void main() {
  setUpAll(loadBundledFonts);

  Widget dialog({int rival = 1, List<String>? calls, bool settings = true}) =>
      PauseDialog(
        race: RacePauseInfo(rival: rival),
        settings: const PauseSettings(sound: true, music: true, haptics: true),
        library: FakeFxLibrary(),
        onSoundChanged: (_) {},
        onMusicChanged: (_) {},
        onHapticsChanged: (_) {},
        onResume: () => calls?.add('resume'),
        onRestart: () => calls?.add('restart'),
        onSettings: settings ? () => calls?.add('settings') : null,
        onLeaveRace: () => calls?.add('leave'),
      );

  testWidgets('9.7: a versus "Paused" pill, the header with the rival\'s '
      'portrait and Computer tag, and "{rival} is paused too."', (
    tester,
  ) async {
    await pumpScreen(tester, dialog(rival: 2));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('vs Computer · Button'), findsOneWidget);
    expect(find.text('Button is paused too.'), findsOneWidget);
    expect(find.text('Computer'), findsOneWidget, reason: 'the tag');
    final portrait = tester.widget<RivalPortrait>(find.byType(RivalPortrait));
    expect(portrait.number, 2);
    expect(portrait.size, 30);
    // The level's "Level N · Tier" line is a campaign's, never a race's.
    expect(find.textContaining('Level'), findsNothing);
    final ribbon = tester.widget<RibbonTitle>(find.byType(RibbonTitle));
    expect(ribbon.gradient, AppGradientTokens.versus);
    expect(ribbon.edgeColor, AppColorTokens.versusEdge);
    // Resume is the versus button.
    final resume = tester
        .widgetList<TactileButton>(find.byType(TactileButton))
        .singleWhere((b) => b.label == 'Resume');
    expect(resume.variant, TactileButtonVariant.versus);
  });

  testWidgets('the tiles are Restart, Leave race and Settings, in that '
      'order, each at least 48 dp; no Home', (tester) async {
    await pumpScreen(tester, dialog());
    await tester.pump(const Duration(milliseconds: 300));
    final xs = [
      for (final label in ['Restart', 'Leave race', 'Settings'])
        tester.getCenter(find.text(label)).dx,
    ];
    expect(xs[0], lessThan(xs[1]));
    expect(xs[1], lessThan(xs[2]));
    expect(find.text('Home'), findsNothing);
    for (final label in ['Restart', 'Leave race', 'Settings']) {
      final tile = find.ancestor(
        of: find.text(label),
        matching: find.byType(TactileSurface),
      );
      expect(tester.getSize(tile.first).height, greaterThanOrEqualTo(48));
    }
  });

  testWidgets('Settings stays reachable in a race\'s Pause when wired '
      '(Q132), and is absent when it is not', (tester) async {
    final calls = <String>[];
    await pumpScreen(tester, dialog(calls: calls));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Settings'));
    expect(calls, ['settings']);
    await pumpScreen(tester, dialog(settings: false));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Settings'), findsNothing);
  });

  testWidgets('Leave race asks once: 9.7b, and the race is not left yet', (
    tester,
  ) async {
    final calls = <String>[];
    await pumpScreen(tester, dialog(rival: 3, calls: calls));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Leave race'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(calls, isEmpty, reason: 'one tap only asks');
    expect(find.byKey(const ValueKey('raceLeaveConfirm')), findsOneWidget);
    expect(find.text('Leave this race?'), findsOneWidget);
    expect(
      find.text('The race ends here. No coins, and nothing lost.'),
      findsOneWidget,
    );
    final portrait = tester.widget<RivalPortrait>(find.byType(RivalPortrait));
    expect(portrait.size, 88);
    expect(portrait.emphasis, isTrue);
    expect(portrait.number, 3);
    expect(find.text('Computer'), findsOneWidget);
    // The toggles and Pause's tiles are gone: one confirmation only.
    expect(find.text('Sound'), findsNothing);
    final buttons = tester
        .widgetList<TactileButton>(find.byType(TactileButton))
        .toList();
    expect(buttons.map((b) => b.label), ['Keep racing', 'Leave race']);
    expect(buttons[0].variant, TactileButtonVariant.versus);
    // Never a danger button: "Leave race" is secondary.
    expect(buttons[1].variant, TactileButtonVariant.secondary);
    expect(
      tester.getTopLeft(find.text('Keep racing')).dy,
      lessThan(tester.getTopLeft(find.text('Leave race')).dy),
    );

    await tester.tap(find.text('Leave race'));
    expect(calls, ['leave']);
  });

  testWidgets('Keep racing resumes and Leave race is never called', (
    tester,
  ) async {
    final calls = <String>[];
    await pumpScreen(tester, dialog(calls: calls));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Leave race'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Keep racing'));
    expect(calls, ['resume']);
  });

  testWidgets('9.7b reads as a route naming the computer, and the header '
      'reads "vs Computer · Pebble"', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScreen(tester, dialog());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.bySemanticsLabel('vs Computer · Pebble'), findsOneWidget);
    await tester.tap(find.text('Leave race'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.bySemanticsLabel('Pebble, Computer'), findsOneWidget);
    expect(find.bySemanticsLabel('Keep racing'), findsOneWidget);
    handle.dispose();
  });

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets('fits ${size.width.toInt()} wide at $scale× text, in '
          'Pause and in 9.7b', (tester) async {
        await pumpScreen(tester, dialog(), size: size, textScale: scale);
        await tester.pump(const Duration(milliseconds: 300));
        expectNoLayoutErrors(tester);
        await expectAccessibleLayout(tester);
        await tester.tap(find.text('Leave race'));
        await tester.pump(const Duration(milliseconds: 300));
        expectNoLayoutErrors(tester);
        await expectAccessibleLayout(tester);
      });
    }
  }
}
