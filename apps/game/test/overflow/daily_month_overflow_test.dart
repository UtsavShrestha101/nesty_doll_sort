import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/daily/cubit/daily_cubit.dart';
import 'package:nesty_game/features/daily/widgets/daily_background_loader.dart';
import 'package:nesty_game/features/daily/widgets/daily_locked_card.dart';
import 'package:nesty_game/features/daily/widgets/month_card.dart';
import 'package:nesty_game/features/daily/widgets/past_day_card.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_render/nesty_render.dart' show ChapterTheme;

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';

/// Local habit 2's month card (docs/plans/plan-local-habits.md "2. A month
/// of played days"): the five sizes at both text scales, in this run's
/// locale (`--dart-define=NESTY_TEST_LOCALE=<code>`). `expectAccessibleLayout`
/// includes the readability floor, so the weekday header and the day numbers
/// are checked in `ja` and `hi` (no text drawn below 75 % of its style, none
/// cut). The page's own scroll is covered by `daily_overflow_test.dart`.
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

  final states = {
    // 2026-08-01 is a Saturday: a six-row month on a Sunday start.
    'a six-row month': statusOf(
      LocalDate(2026, 8, 31),
      done: [for (var d = 1; d <= 31; d += 2) LocalDate(2026, 8, d)],
      frozen: [LocalDate(2026, 8, 2), LocalDate(2026, 8, 30)],
    ),
    'the 31st, today solved': statusOf(
      LocalDate(2026, 10, 31),
      done: [LocalDate(2026, 10, 31), LocalDate(2026, 10, 30)],
    ),
    'a four-row month, nothing played': statusOf(LocalDate(2027, 2, 14)),
    'a leap February': statusOf(
      LocalDate(2028, 2, 10),
      done: [LocalDate(2028, 2, 9)],
    ),
  };

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      for (final MapEntry(key: name, value: status) in states.entries) {
        testWidgets(
          'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text '
          '($name)',
          (tester) async {
            await pumpScreen(
              tester,
              Material(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: MonthCard(status: status),
                ),
              ),
              size: size,
              textScale: scale,
            );
            await tester.pump(const Duration(milliseconds: 100));
            await expectAccessibleLayout(tester);
          },
        );
      }
    }
  }

  // Frame 12.14, the Daily before Level 2 (the same sizes and scales).
  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets('the locked Daily card fits ${size.width.toInt()}×'
          '${size.height.toInt()} at $scale× text', (tester) async {
        await pumpScreen(
          tester,
          Material(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: DailyLockedCard(playLevelNumber: 2, onPlay: () {}),
            ),
          ),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(milliseconds: 100));
        await expectAccessibleLayout(tester);
      });
    }
  }

  // Local habits 3: the picker (raised days, the hint, the ‹ chip) and the
  // past day's card (frames 14.3a to 14.3e), the same sizes and scales.
  DailyStatus pickerStatus(
    LocalDate today, {
    List<LocalDate> done = const [],
    List<LocalDate> played = const [],
  }) => statusOf(today, done: done).copyWith(
    played: played,
    window: [for (var i = 7; i >= 1; i--) today.addDays(-i)],
  );

  final pickers = {
    'a window inside the month': pickerStatus(
      LocalDate(2026, 10, 18),
      done: [LocalDate(2026, 10, 17)],
      played: [LocalDate(2026, 10, 14)],
    ),
    'a window across the 1st (the ‹ chip)': pickerStatus(
      LocalDate(2026, 10, 3),
    ),
    'the chip on a six-row month': pickerStatus(
      LocalDate(2026, 8, 4),
      done: [LocalDate(2026, 8, 3)],
    ),
  };

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      for (final MapEntry(key: name, value: status) in pickers.entries) {
        for (final offset in [0, -1]) {
          if (offset == -1 && !name.contains('chip')) continue;
          testWidgets(
            'the picker fits ${size.width.toInt()}×${size.height.toInt()} at '
            '$scale× text ($name, month offset $offset)',
            (tester) async {
              await pumpScreen(
                tester,
                Material(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: MonthCard(
                      status: status,
                      monthOffset: offset,
                      selected: status.window[2],
                      onSelect: (_) {},
                      onShowMonth: (_) {},
                    ),
                  ),
                ),
                size: size,
                textScale: scale,
              );
              await tester.pump(const Duration(milliseconds: 100));
              await _expectPickerLayout(tester);
            },
          );
        }
      }

      for (final solved in [false, true]) {
        testWidgets(
          'the past day card (${solved ? 'solved, Play again' : 'Play'}) '
          'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text',
          (tester) async {
            final day = LocalDate(2026, 10, 10);
            await pumpScreen(
              tester,
              MultiRepositoryProvider(
                providers: [
                  RepositoryProvider<SkinService>.value(
                    value: FakeSkinService(),
                  ),
                  RepositoryProvider<DatabaseService>.value(
                    value: FakeDatabaseService(),
                  ),
                  RepositoryProvider<FxLibrary>.value(value: FakeFxLibrary()),
                  RepositoryProvider<DailyBackgroundLoader>.value(
                    value: const _NoBackground(),
                  ),
                ],
                child: Scaffold(
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: PastDayCard(
                      date: day,
                      onPlay: () {},
                      state: DailyState(
                        status: statusOf(
                          LocalDate(2026, 10, 15),
                          done: solved ? [day] : const [],
                        ),
                        previewColors: const [
                          DollColor.purple,
                          DollColor.yellow,
                          DollColor.red,
                          DollColor.teal,
                          DollColor.pink,
                        ],
                        pastTier: Tier.superhard,
                        pastColorCount: 6,
                        selectedPastDate: day,
                      ),
                    ),
                  ),
                ),
              ),
              size: size,
              textScale: scale,
            );
            await tester.pump(const Duration(milliseconds: 400));
            await expectAccessibleLayout(tester);
          },
        );
      }
    }
  }
}

/// [expectAccessibleLayout] minus the tap-target width: a day column is
/// `floor(card width / 7)` wide, 43 to 48 dp on a phone, so its 48 dp tall
/// target can be 4 dp narrower than 48 on a 360 dp screen. The month's grid
/// can't be wider than its card (frame 14.3a), so the day buttons keep the
/// column's width and a 48 dp height (reported to the lead). Every other
/// target (the ‹ chip) and the labels keep their checks.
Future<void> _expectPickerLayout(WidgetTester tester) async {
  expectNoLayoutErrors(tester);
  final handle = tester.ensureSemantics();
  try {
    await tester.pump();
    final result = await labeledTapTargetGuideline.evaluate(tester);
    expect(result.passed, isTrue, reason: result.reason);
    final root = tester
        .renderObject(find.byType(MonthCard))
        .owner!
        .semanticsOwner!
        .rootSemanticsNode!;
    void visit(SemanticsNode node) {
      final tappable = node.getSemanticsData().hasAction(SemanticsAction.tap);
      if (tappable) {
        final label = node.label;
        final day = label.contains(testL10n.dailyMonthDayOpenSemantics(''));
        expect(
          node.rect.height,
          greaterThanOrEqualTo(48),
          reason: '"$label" is under 48 dp tall',
        );
        if (!day) {
          expect(node.rect.width, greaterThanOrEqualTo(48), reason: label);
        }
      }
      node.visitChildren((c) {
        visit(c);
        return true;
      });
    }

    visit(root);
  } finally {
    handle.dispose();
  }
  expectNoCutText(tester);
  expectReadableText(tester);
}

class _NoBackground implements DailyBackgroundLoader {
  const _NoBackground();

  @override
  Future<ui.Image?> rasterize(
    ChapterTheme theme, {
    required Size box,
    required double devicePixelRatio,
  }) async => null;
}
