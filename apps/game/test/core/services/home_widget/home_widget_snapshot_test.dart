import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_projection.dart';
import 'package:nesty_game/core/services/daily/streak_daily_service.dart';
import 'package:nesty_game/core/services/home_widget/home_widget_snapshot.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

/// The home-screen widget's snapshot (stage 4 contract §3): its shape in a
/// JSON golden the Swift and Kotlin tests decode too, and its strings in
/// every language.
///
/// Rewrite the goldens with `NESTY_UPDATE_GOLDEN=1 flutter test <this file>`
/// after a contract change (and tell the native lanes).
void main() {
  final today = LocalDate(2026, 10, 8); // a Thursday
  final update = Platform.environment['NESTY_UPDATE_GOLDEN'] == '1';

  setUpAll(() async {
    await initializeDateFormatting();
  });

  List<DailyDayProjection> projectionOf(DailyProgress daily) =>
      StreakDailyService(
        FakeSaveService(initial: SaveDocument(daily: daily, highestLevel: 5)),
        FakeClock(now: DateTime(2026, 10, 8, 12)),
        FakeRemoteConfigService(),
      ).projection(today, HomeWidgetSnapshot.dayCount);

  /// A lit 4-day streak, unsolved today, no freeze: today is ready and the
  /// flame rests from tomorrow on if the player never comes back.
  final litFour = DailyProgress(
    streak: 4,
    lit: true,
    run: 4,
    lastDate: today.addDays(-1),
    freezeWeek: today.isoWeekKey,
    done: [for (var i = 4; i >= 1; i--) today.addDays(-i)],
  );

  HomeWidgetSnapshot snapshotOf(
    DailyProgress daily, {
    String lang = 'en',
    bool unlocked = true,
  }) => HomeWidgetSnapshot.compose(
    lang: lang,
    scheme: 'nesty-dev',
    unlocked: unlocked,
    unlockLevel: 2,
    days: projectionOf(daily),
    dolls: {
      today: [DollColor.navy, DollColor.orange],
      today.addDays(1): [DollColor.green, DollColor.blue, DollColor.brown],
    },
  );

  File fixture(String name) => File('test/fixtures/$name');

  void expectGolden(String name, HomeWidgetSnapshot snapshot) {
    final pretty =
        '${const JsonEncoder.withIndent('  ').convert(snapshot.toJson())}\n';
    final file = fixture(name);
    if (update) {
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(pretty);
    }
    expect(file.existsSync(), isTrue, reason: '$name is missing');
    expect(
      jsonDecode(file.readAsStringSync()),
      jsonDecode(snapshot.encode()),
      reason:
          '$name differs: rerun with NESTY_UPDATE_GOLDEN=1 and tell the '
          'native lanes',
    );
  }

  group('the golden', () {
    test('a lit 4-day streak, unsolved today, in English', () {
      expectGolden('widget_snapshot_v1.json', snapshotOf(litFour));
    });

    test('a Daily still locked (before Level 2 is won)', () {
      expectGolden(
        'widget_snapshot_v1_locked.json',
        snapshotOf(const DailyProgress(), unlocked: false),
      );
    });

    test('a streak of 5 solved today, ready again tomorrow', () {
      expectGolden(
        'widget_snapshot_v1_solved.json',
        snapshotOf(
          DailyProgress(
            streak: 5,
            lit: true,
            run: 5,
            lastDate: today,
            freezeWeek: today.isoWeekKey,
            done: [today],
          ),
        ),
      );
    });
  });

  group('the shape', () {
    test('is schema 1, with 8 days, today first, and the contract keys', () {
      final json = snapshotOf(litFour).toJson();
      expect(json.keys, ['v', 'scheme', 'lang', 'unlocked', 'locked', 'days']);
      expect(json['v'], 1);
      expect(json['scheme'], 'nesty-dev');
      expect(json['lang'], 'en');
      final days = json['days']! as List;
      expect(days, hasLength(8));
      expect((days.first as Map)['date'], '2026-10-08');
      expect((days.last as Map)['date'], '2026-10-15');
      expect((days.first as Map).keys, [
        'date',
        'state',
        'streak',
        'number',
        'label',
        'labelShort',
        'title',
        'sub',
        'dolls',
        'line',
        'lineShort',
        'a11y',
      ]);
    });

    test('lists the colours of today and tomorrow only', () {
      final days = snapshotOf(litFour).days;
      expect(days[0].dolls, ['#2F3E8F', '#F2893B']);
      expect(days[1].dolls, ['#46A758', '#3E8EDE', '#A0673C']);
      for (final day in days.skip(2)) {
        expect(day.dolls, isEmpty, reason: '${day.date}');
      }
    });

    test('caps the dolls at 8 and gives a date nobody asked for none', () {
      final snapshot = HomeWidgetSnapshot.compose(
        lang: 'en',
        scheme: 'nesty',
        unlocked: true,
        unlockLevel: 2,
        days: projectionOf(litFour),
        dolls: {today: DollColor.values.where((c) => !c.isWild).toList()},
      );
      expect(snapshot.days.first.dolls, hasLength(8));
      expect(snapshot.days[1].dolls, isEmpty);
    });

    test('fills the locked strings with the level', () {
      final locked = snapshotOf(litFour).locked;
      expect(locked.small, 'Opens after Level 2');
      expect(locked.medium, contains('Level 2'));
      expect(locked.a11y, contains('Level 2'));
      expect(locked.title, 'Daily puzzle');
    });

    test('says what each state says, and the number only with a streak', () {
      final byState = <DailyDayState, HomeWidgetDay>{};
      for (final daily in [
        litFour,
        const DailyProgress(),
        DailyProgress(
          streak: 3,
          lit: true,
          run: 3,
          lastDate: today,
          freezeWeek: today.isoWeekKey,
          done: [today],
        ),
      ]) {
        for (final day in snapshotOf(daily).days) {
          byState.putIfAbsent(day.state, () => day);
        }
      }
      expect(byState.keys, containsAll(DailyDayState.values));

      final ready = byState[DailyDayState.ready]!;
      expect(ready.number, '4');
      expect(ready.label, 'day streak');
      expect(ready.labelShort, isNull);
      expect(ready.line, 'Today’s puzzle is ready');
      expect(ready.lineShort, 'Ready to play');
      expect(ready.title, 'Thursday’s puzzle');

      final solved = byState[DailyDayState.solved]!;
      expect(solved.number, '3');
      expect(solved.line, 'Solved. See you tomorrow.');
      expect(solved.lineShort, 'Solved!');

      final paused = byState[DailyDayState.paused]!;
      expect(paused.number, '4');
      expect(paused.label, 'day streak · resting');
      expect(paused.labelShort, 'resting');
      expect(paused.line, 'Today’s puzzle is ready');

      final zero = byState[DailyDayState.zero]!;
      expect(zero.number, isNull);
      expect(zero.label, 'Your first flame');
      expect(zero.streak, 0);
    });

    test('the sub line is the Daily card\'s: colours and tier', () {
      final first = snapshotOf(litFour).days.first;
      final params = DifficultyCurve.dailyParams(today.yyyymmdd);
      expect(first.sub, startsWith('${params.colors} colors'));
    });

    test('formats numbers in the rendered language and names its code', () {
      final big = DailyProgress(
        streak: 1234,
        lit: true,
        run: 3,
        lastDate: today.addDays(-1),
        freezeWeek: today.isoWeekKey,
      );
      expect(snapshotOf(big).days.first.number, '1,234');
      final german = snapshotOf(big, lang: 'de');
      expect(german.lang, 'de');
      expect(german.days.first.number, '1.234');
      expect(snapshotOf(big, lang: 'pt_BR').lang, 'pt_BR');
    });

    test('an unknown language falls back to English', () {
      final snapshot = snapshotOf(litFour, lang: 'xx');
      expect(snapshot.lang, 'en');
      expect(snapshot.days.first.line, 'Today’s puzzle is ready');
    });

    test('two snapshots of the same facts are equal', () {
      expect(snapshotOf(litFour), snapshotOf(litFour));
      expect(snapshotOf(litFour), isNot(snapshotOf(litFour, lang: 'de')));
    });
  });

  group('every language', () {
    const languages = [
      'en',
      'es',
      'pt',
      'pt_BR',
      'id',
      'hi',
      'de',
      'fr',
      'tr',
      'ja',
    ];
    // A lit streak, a resting one and no streak, so all four looks run.
    final dailies = [litFour, const DailyProgress()];

    for (final lang in languages) {
      test('$lang: every string is there, with no clock in any', () {
        for (final daily in dailies) {
          final snapshot = snapshotOf(daily, lang: lang);
          expect(snapshot.days, hasLength(8));
          final texts = <String>[
            snapshot.locked.title,
            snapshot.locked.small,
            snapshot.locked.medium,
            snapshot.locked.a11y,
            for (final day in snapshot.days) ...[
              day.label,
              if (day.labelShort != null) day.labelShort!,
              day.title,
              day.sub,
              day.line,
              day.lineShort,
              day.a11y,
            ],
          ];
          for (final text in texts) {
            expect(text.trim(), isNotEmpty, reason: lang);
            expect(text, isNot(contains('{')), reason: '$lang: "$text"');
            expect(
              RegExp(r'\d\s*[:：]\s*\d').hasMatch(text),
              isFalse,
              reason: '$lang: a clock in "$text"',
            );
          }
        }
      });
    }
  });
}
