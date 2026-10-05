import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/daily/widgets/streak_card.dart';

import '../support/screen_harness.dart';

/// The Daily streak card (frames 5.1, 10.7, 10.7b; ui-spec-menus §6.5;
/// docs/plans/m7-design.md §8): lit, paused, zero and relit, never red
/// (Q96), and the number never drops.
void main() {
  DailyStatus statusOf({required bool lit, required int streak}) => DailyStatus(
    today: LocalDate(2026, 9, 26),
    tier: Tier.hard,
    colors: 5,
    unlocked: true,
    streak: streak,
    lit: lit,
    run: lit ? 1 : 0,
    freezes: 1,
  );

  Color flameColor(WidgetTester tester) =>
      tester.widget<Icon>(find.byIcon(NestyIcons.localFireDepartment)).color!;

  final cardSurface = find.descendant(
    of: find.byType(StreakCard),
    matching: find.byType(NestySurface),
  );

  Future<void> pump(WidgetTester tester, StreakCard card) => pumpScreen(
    tester,
    Material(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(padding: const EdgeInsets.all(16), child: card),
      ),
    ),
  );

  testWidgets('lit: the count, the keep-streak line and a white flame', (
    tester,
  ) async {
    await pump(tester, StreakCard(status: statusOf(lit: true, streak: 4)));
    expect(find.text('4 days'), findsOneWidget);
    expect(find.text('Play today to add to your streak'), findsOneWidget);
    // Frame 5.1: the flame is #FFF6E6 on a translucent disc.
    expect(flameColor(tester), AppColorTokens.cream);
    expect(find.text('Paused'), findsNothing);
  });

  testWidgets('lit (5.1): the orange `gradient.streak` face, a 36 dp white '
      'count and a 14 dp #FFEBDA line', (tester) async {
    await pump(tester, StreakCard(status: statusOf(lit: true, streak: 4)));
    final surface = tester.widget<NestySurface>(cardSurface.first);
    expect(surface.style.gradient, AppGradientTokens.streak);
    // The style the card asks for (the test font may shrink it to fit).
    final count = tester.widget<ShrinkToFitText>(
      find.widgetWithText(ShrinkToFitText, '4 days'),
    );
    expect(count.style.fontSize, 36);
    expect(count.style.color, const Color(0xFFFFFFFF));
    final line = tester.widget<Text>(
      find.text('Play today to add to your streak'),
    );
    expect(line.style!.fontSize, 14);
    expect(line.style!.color, const Color(0xFFFFEBDA));
  });

  testWidgets('paused (5.2b): a cream face, one title row with the Paused '
      'and freeze chips, at most 150 dp tall', (tester) async {
    await pump(tester, StreakCard(status: statusOf(lit: false, streak: 4)));
    final surface = tester.widget<NestySurface>(cardSurface.first);
    expect(surface.style.color, AppColorTokens.surface);
    expect(tester.getSize(cardSurface.first).height, lessThanOrEqualTo(150));
    // The freeze chip is inline at the title row's end, not a column to
    // the card's right (the test font is wider than Fredoka, so the Paused
    // chip may wrap under the count here; it does not at 390 dp).
    final card = tester.getRect(cardSurface.first);
    expect(
      tester.getTopRight(find.text('1 freeze')).dx,
      greaterThan(card.right - 30),
    );
  });

  testWidgets('the card reads its freezes (a11y_freezes)', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, StreakCard(status: statusOf(lit: true, streak: 4)));
    expect(
      find.bySemanticsLabel(
        '4 days. Play today to add to your streak. 1 streak freeze',
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('solved today: "Your flame is lit. See you tomorrow."', (
    tester,
  ) async {
    await pump(
      tester,
      StreakCard(
        status: statusOf(lit: true, streak: 4).copyWith(solvedToday: true),
      ),
    );
    expect(find.text('Your flame is lit. See you tomorrow.'), findsOneWidget);
  });

  testWidgets('a freeze kept the flame (5.2): the lit card says so until '
      'the solve, then the solved line (m7-4 4.17)', (tester) async {
    final lit = statusOf(lit: true, streak: 4);
    await pump(tester, StreakCard(status: lit, freezeKept: true));
    expect(find.text('A freeze kept your flame lit.'), findsOneWidget);
    expect(find.text('Play today to add to your streak'), findsNothing);

    await pump(
      tester,
      StreakCard(status: lit.copyWith(solvedToday: true), freezeKept: true),
    );
    expect(find.text('Your flame is lit. See you tomorrow.'), findsOneWidget);
  });

  testWidgets('5.2b: paused with no freeze left keeps the number and shows '
      'the resting line and the freeze chip', (tester) async {
    await pump(
      tester,
      StreakCard(status: statusOf(lit: false, streak: 4).copyWith(freezes: 0)),
    );
    expect(find.text('4 days'), findsOneWidget);
    expect(find.text('Paused'), findsOneWidget);
    expect(
      find.text(
        'Your 4-day streak is resting. Solve today’s puzzle to light it again.',
      ),
      findsOneWidget,
    );
    expect(find.text('No freeze'), findsOneWidget);
  });

  testWidgets('paused: the count, a Paused chip, the resting line and the '
      'resting flame, never red (Q96)', (tester) async {
    await pump(tester, StreakCard(status: statusOf(lit: false, streak: 12)));
    expect(find.text('12 days'), findsOneWidget);
    expect(find.text('Paused'), findsOneWidget);
    expect(
      find.text(
        'Your 12-day streak is resting. Solve today’s puzzle to light it again.',
      ),
      findsOneWidget,
    );
    expect(flameColor(tester), AppColorTokens.streakPausedGlyph);
    expect(flameColor(tester), isNot(AppColorTokens.danger));
  });

  testWidgets('paused: the count never drops below the days counted', (
    tester,
  ) async {
    await pump(tester, StreakCard(status: statusOf(lit: false, streak: 4)));
    expect(find.text('4 days'), findsOneWidget);
    expect(find.text('0 days'), findsNothing);
  });

  testWidgets('paused reads as one sentence for a screen reader', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, StreakCard(status: statusOf(lit: false, streak: 4)));
    expect(
      find.bySemanticsLabel(
        '4 days. Paused. Your 4-day streak is resting. Solve today’s puzzle '
        'to light it again. 1 streak freeze',
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('zero (never lit): no number, the first-flame line, the '
      'resting flame', (tester) async {
    await pump(tester, StreakCard(status: statusOf(lit: false, streak: 0)));
    expect(
      find.text('Solve today’s puzzle to light your first flame.'),
      findsOneWidget,
    );
    expect(find.textContaining('days'), findsNothing);
    expect(find.text('Paused'), findsNothing);
    expect(flameColor(tester), AppColorTokens.streakPausedGlyph);
  });

  testWidgets('relit (10.7b): "Streak relit!" and the glowing line, lit '
      'flame', (tester) async {
    await pump(
      tester,
      StreakCard(status: statusOf(lit: true, streak: 5), relit: true),
    );
    expect(find.text('Streak relit!'), findsOneWidget);
    expect(find.text('Your 5-day streak is glowing again.'), findsOneWidget);
    expect(flameColor(tester), const Color(0xFFFFFFFF));
    expect(find.text('5 days'), findsNothing);
  });

  testWidgets('every state states its streak without the word "lost" or '
      '"broken" (E2)', (tester) async {
    for (final status in [
      statusOf(lit: true, streak: 4),
      statusOf(lit: false, streak: 4),
      statusOf(lit: false, streak: 0),
    ]) {
      await pump(tester, StreakCard(status: status));
      final text = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .join(' ')
          .toLowerCase();
      expect(text, isNot(contains('lost')));
      expect(text, isNot(contains('broke')));
      expect(text, isNot(contains('reset')));
    }
  });
}
