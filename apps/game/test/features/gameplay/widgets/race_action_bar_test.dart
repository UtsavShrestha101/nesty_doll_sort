import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/gameplay/widgets/race_action_bar.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

/// The wood bar in a race (frame 9.3; `layout.raceBar`; m7-design P4.4):
/// Start over slots 2 and 3, then Undo (unlimited) and Restart.
void main() {
  setUpAll(loadBundledFonts);

  Widget bar({required bool ready, List<String>? calls, bool canUndo = true}) =>
      Align(
        alignment: Alignment.bottomCenter,
        child: RaceActionBar(
          ready: ready,
          onStart: () => calls?.add('start'),
          canUndo: canUndo,
          onUndo: () => calls?.add('undo'),
          onRestart: () => calls?.add('restart'),
        ),
      );

  testWidgets('before Start: one 168 wide Start, centred over slots 2 and 3, '
      'the four boosters hidden', (tester) async {
    final calls = <String>[];
    await pumpScreen(tester, bar(ready: true, calls: calls));
    expect(find.text('Undo'), findsNothing);
    expect(find.text('Restart'), findsNothing);
    expect(find.text('Hint'), findsNothing);
    expect(find.text('+Slot'), findsNothing);
    final start = tester.getRect(
      find.ancestor(
        of: find.text('Start'),
        matching: find.byType(TactileButton),
      ),
    );
    expect(start.width, RaceBarTokens.startWidth);
    expect(start.height, RaceBarTokens.startHeight);
    expect(start.center.dx, moreOrLessEquals(195));
    final button = tester.widget<TactileButton>(find.byType(TactileButton));
    expect(button.variant, TactileButtonVariant.versus);
    expect(button.icon, NestyIcons.playArrow);
    await tester.tap(find.text('Start'));
    expect(calls, ['start']);
  });

  testWidgets('running: Undo in slot 1 with the unlimited badge and Restart '
      'in slot 4, nothing in slots 2 and 3', (tester) async {
    final calls = <String>[];
    await pumpScreen(tester, bar(ready: false, calls: calls));
    expect(find.text('Start'), findsNothing);
    expect(find.text('Hint'), findsNothing);
    expect(find.text('+Slot'), findsNothing);
    expect(find.byIcon(IconUses.undoUnlimited), findsOneWidget);
    final undo = tester.getCenter(find.text('Undo'));
    final restart = tester.getCenter(find.text('Restart'));
    // 80 wide slots and 8 dp gaps: slot 4 is three pitches from slot 1.
    expect(restart.dx - undo.dx, moreOrLessEquals(3 * 88));
    await tester.tap(find.text('Undo'));
    await tester.tap(find.text('Restart'));
    expect(calls, ['undo', 'restart']);
  });

  testWidgets('Undo is disabled with nothing to undo', (tester) async {
    final calls = <String>[];
    await pumpScreen(tester, bar(ready: false, calls: calls, canUndo: false));
    await tester.tap(find.text('Undo'));
    expect(calls, isEmpty);
  });
}
