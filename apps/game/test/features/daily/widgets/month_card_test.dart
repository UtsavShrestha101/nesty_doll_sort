import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/daily/widgets/month_card.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

/// The month of played days (local habit 2, stage 2): each day's look and
/// label, today's ring, and none of the failure marks (D92).
void main() {
  setUpAll(loadBundledFonts);

  DailyStatus statusOf(
    LocalDate today, {
    List<LocalDate> done = const [],
    List<LocalDate> frozen = const [],
  }) => DailyStatus(
    today: today,
    tier: Tier.hard,
    colors: 5,
    unlocked: true,
    streak: 3,
    lit: true,
    run: 3,
    freezes: 1,
    done: done,
    frozen: frozen,
  );

  Future<void> pump(
    WidgetTester tester,
    DailyStatus status, {
    Size size = const Size(360, 640),
    double textScale = 1,
  }) => pumpScreen(
    tester,
    Material(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: MonthCard(status: status),
      ),
    ),
    size: size,
    textScale: textScale,
  );

  String label(String state, LocalDate date) => testL10n.dailyMonthDaySemantics(
    state,
    DateFormat.MMMMd(testLocaleCode).format(date.startOfDay),
  );

  final today = LocalDate(2026, 10, 8);
  Finder semanticsOf(String l) => find.bySemanticsLabel(l);

  String monthTitle() => testL10n.dailyMonthTitle(
    toBeginningOfSentenceCase(
          DateFormat.LLLL(testLocaleCode).format(today.startOfDay),
          testLocaleCode,
        ) ??
        '',
  );

  /// The faces drawn with [face] (a colour or a gradient).
  Finder facesOf(Object face) => find.byWidgetPredicate(
    (w) =>
        w is NestySurface &&
        (w.style.color == face || w.style.gradient == face) &&
        w.width != null &&
        w.width! > 20,
  );

  testWidgets('each look has its own label, and the title is a header', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      statusOf(
        today,
        done: [LocalDate(2026, 10, 7), today],
        frozen: [LocalDate(2026, 10, 5)],
      ),
    );
    expect(semanticsOf(label('solved', LocalDate(2026, 10, 7))), findsOne);
    expect(semanticsOf(label('todaySolved', today)), findsOne);
    expect(
      semanticsOf(label('frozen', LocalDate(2026, 10, 5))),
      findsOne,
      reason: 'covered by a freeze',
    );
    expect(semanticsOf(label('other', LocalDate(2026, 10, 6))), findsOne);
    expect(semanticsOf(label('future', LocalDate(2026, 10, 9))), findsOne);
    expect(
      tester.getSemantics(find.text(monthTitle())),
      isSemantics(isHeader: true, label: monthTitle()),
    );
    handle.dispose();
  });

  testWidgets('the frozen day reads "covered by a freeze"', (tester) async {
    expect(
      testL10n.dailyMonthDaySemantics('frozen', 'October 5'),
      contains('covered by a freeze'),
    );
  }, skip: testLocaleCode != 'en');

  testWidgets('today unsolved: a cream face with the orange ring', (
    tester,
  ) async {
    await pump(tester, statusOf(today));
    final face = facesOf(HabitsDayCellTokens.todayFace);
    expect(face, findsOneWidget);
    expect(
      tester.widget<NestySurface>(face).style.shadows,
      HabitsDayCellTokens.todayShadow,
    );
  });

  testWidgets('a day solved on its own date is lit; today solved is lit with '
      'the ring', (tester) async {
    await pump(tester, statusOf(today, done: [LocalDate(2026, 10, 3), today]));
    final lit = facesOf(HabitsDayCellTokens.litFace);
    expect(lit, findsNWidgets(2));
    final shadows = tester
        .widgetList<NestySurface>(lit)
        .map((w) => w.style.shadows)
        .toList();
    expect(
      shadows.map((l) => l.length),
      unorderedEquals([
        HabitsDayCellTokens.litInner.length,
        HabitsDayCellTokens.todayLitShadow.length,
      ]),
    );
    expect(shadows.any((l) => l.length == 3), isTrue, reason: 'the ring');
  });

  testWidgets('a freeze day has its own blue mark: the number and the '
      'snowflake, never lit', (tester) async {
    await pump(
      tester,
      statusOf(today, frozen: [LocalDate(2026, 10, 2), LocalDate(2026, 10, 4)]),
    );
    expect(find.byIcon(NestyIcons.acUnit), findsNWidgets(2));
    expect(facesOf(HabitsDayCellTokens.freezeFace), findsNWidgets(2));
    expect(facesOf(HabitsDayCellTokens.litFace), findsNothing);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('an unplayed past day is blank, as a future day is: no face, '
      'no lock, no word', (tester) async {
    await pump(tester, statusOf(today));
    // Only today has a face.
    expect(
      find.byWidgetPredicate(
        (w) => w is NestySurface && (w.width ?? 0) > 20 && w.width! < 60,
      ),
      findsOneWidget,
    );
    expect(find.byIcon(NestyIcons.lock), findsNothing);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
  });

  testWidgets('the legend names only the marks the month holds', (
    tester,
  ) async {
    await pump(tester, statusOf(today));
    expect(find.text(testL10n.dailyMonthKeyLit), findsNothing);
    expect(find.text(testL10n.dailyMonthKeyFreeze), findsNothing);
    await pump(
      tester,
      statusOf(
        today,
        done: [LocalDate(2026, 10, 3)],
        frozen: [LocalDate(2026, 10, 4)],
      ),
    );
    expect(find.text(testL10n.dailyMonthKeyLit), findsOneWidget);
    expect(find.text(testL10n.dailyMonthKeyFreeze), findsOneWidget);
    expect(find.text(testL10n.dailyMonthKeyLater), findsNothing);
  });

  testWidgets('the hint and the previous-month chip wait for stage 3', (
    tester,
  ) async {
    await pump(tester, statusOf(today));
    expect(find.text(testL10n.dailyMonthHint), findsNothing);
    expect(find.byIcon(NestyIcons.chevronRight), findsNothing);
  });

  testWidgets('the 1st and the 31st', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      statusOf(
        LocalDate(2026, 10, 31),
        done: [LocalDate(2026, 10, 1), LocalDate(2026, 10, 31)],
      ),
    );
    expect(semanticsOf(label('solved', LocalDate(2026, 10, 1))), findsOne);
    expect(
      semanticsOf(label('todaySolved', LocalDate(2026, 10, 31))),
      findsOne,
    );
    expect(find.text('31'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('no red, no X and no "missed" in any state', (tester) async {
    await pump(
      tester,
      statusOf(
        LocalDate(2026, 10, 20),
        done: [LocalDate(2026, 10, 1), LocalDate(2026, 10, 2)],
        frozen: [LocalDate(2026, 10, 4)],
      ),
    );
    expect(find.byIcon(NestyIcons.close), findsNothing);
    expect(
      find.textContaining(RegExp('missed', caseSensitive: false)),
      findsNothing,
    );
    bool reddish(Color c) => c.r > 0.7 && c.g < 0.25 && c.b < 0.25;
    for (final box in tester.widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(MonthCard),
        matching: find.byType(DecoratedBox),
      ),
    )) {
      final d = box.decoration;
      if (d is! BoxDecoration) continue;
      expect(d.color == null || !reddish(d.color!), isTrue);
      expect(d.border == null || !reddish(d.border!.top.color), isTrue);
    }
    for (final icon in tester.widgetList<Icon>(find.byType(Icon))) {
      expect(icon.color == null || !reddish(icon.color!), isTrue);
    }
    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      final c = text.style?.color;
      expect(c == null || !reddish(c), isTrue);
    }
  });

  for (final (width, height, pitch, face) in const [
    (390.0, 844.0, 48.0, 42.0),
    (360.0, 640.0, 44.0, 40.0),
    (390.0, 693.0, 48.0, 40.0),
  ]) {
    testWidgets('${width.toInt()}x${height.toInt()}: a ${pitch.toInt()} dp '
        'column and a ${face.toInt()} dp face', (tester) async {
      await pump(
        tester,
        statusOf(today, done: [LocalDate(2026, 10, 3)]),
        size: Size(width, height),
      );
      final lit = facesOf(HabitsDayCellTokens.litFace);
      expect(tester.getSize(lit), Size(face, face));
      final a = tester.getCenter(find.text('1'));
      final b = tester.getCenter(find.text('2'));
      expect(b.dx - a.dx, pitch);
      expect(tester.getSize(find.byType(MonthCard)).width, width - 32);
    });
  }

  testWidgets('1.3x text: no overflow, the weekday names still fit', (
    tester,
  ) async {
    await pump(
      tester,
      statusOf(today, done: [LocalDate(2026, 10, 3)]),
      textScale: 1.3,
    );
    expectNoLayoutErrors(tester);
  });
}
