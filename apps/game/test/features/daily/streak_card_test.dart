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

  Future<void> pump(WidgetTester tester, StreakCard card) => pumpScreen(
    tester,
    Material(
      child: Padding(padding: const EdgeInsets.all(16), child: card),
    ),
  );

  testWidgets('lit: the count, the keep-streak line and a white flame', (
    tester,
  ) async {
    await pump(tester, StreakCard(status: statusOf(lit: true, streak: 4)));
    expect(find.text('4 days'), findsOneWidget);
    expect(find.text('Play today to add to your streak'), findsOneWidget);
    expect(flameColor(tester), const Color(0xFFFFFFFF));
    expect(find.text('Paused'), findsNothing);
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
        'to light it again.',
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
