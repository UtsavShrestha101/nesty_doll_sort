import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/welcome_back/welcome_back_rules.dart';

import '../l10n/locales/locales.dart';
import '../l10n/support/arb_checks.dart';
import '../l10n/support/arb_file.dart';

/// The respect rules for the local habits (D92, spec-prop §1.1; plan-local-
/// habits "The respect rules every habit keeps", D297), on
/// `login_gift_respect_test`'s pattern:
/// - no ad, purchase, chance, timer or countdown in any habit's path;
/// - no habit writes the streak, a freeze, the chest, the coins or the
///   dailies count: a gap never lowers anything and an old day never moves
///   the streak;
/// - nothing pops up on its own: no dialog, sheet or overlay in a habit's
///   path, and no navigation outside a widget's tap;
/// - the copy, in every language, has no loss, guilt, urgency or scarcity
///   word and no clock;
/// - the month never draws a red mark or an X.
///
/// Each stage adds its paths (plan-local-habits "Stages"). Run from
/// `apps/game`.
void main() {
  /// Every habit's own code: the folders and the files outside them.
  const habitPaths = [
    // 1. Welcome back.
    'lib/features/welcome_back',
    'lib/core/services/welcome_back',
    // 2. The month.
    'lib/core/services/daily_month',
    'lib/core/ui/week_start.dart',
    'lib/features/daily/widgets/month_card.dart',
  ];

  /// The habits' code that isn't a widget: it never navigates or shows UI.
  const logicPaths = [
    'lib/features/welcome_back/cubit',
    'lib/core/services/welcome_back',
    'lib/core/services/daily_month',
    'lib/core/ui/week_start.dart',
  ];

  List<File> dartFilesUnder(String path) {
    if (File(path).existsSync()) return [File(path)];
    return Directory(path)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where(
          (file) =>
              !file.path.endsWith('.freezed.dart') &&
              !file.path.endsWith('.g.dart') &&
              !file.path.endsWith('.gr.dart'),
        )
        .toList();
  }

  /// Code lines only: a doc comment may explain what a habit never does.
  List<String> offendingLines(Iterable<File> files, RegExp pattern) => [
    for (final file in files)
      for (final (i, line) in file.readAsLinesSync().indexed)
        if (pattern.hasMatch(line.split('//').first))
          '${file.path}:${i + 1}: ${line.trim()}',
  ];

  final habitFiles = [for (final path in habitPaths) ...dartFilesUnder(path)];

  group('the code', () {
    test('every scanned path exists', () {
      for (final path in [...habitPaths, ...logicPaths]) {
        expect(
          File(path).existsSync() || Directory(path).existsSync(),
          isTrue,
          reason: '$path is gone',
        );
      }
    });

    test('no ad, purchase, chance, timer or countdown', () {
      expect(habitFiles.length, greaterThanOrEqualTo(6));
      final found = offendingLines(
        habitFiles,
        RegExp(
          r'services/(ads|purchase)/|\bAdsService\b|\bPurchaseService\b|'
          r'\bRandom\b|countdown|Countdown|untilNextPuzzle|Timer\.periodic|'
          r'\bTimer\(',
        ),
      );
      expect(found, isEmpty, reason: found.join('\n'));
    });

    test('no habit writes the streak, a freeze, the chest, coins or the '
        'dailies count', () {
      final found = offendingLines(
        habitFiles,
        RegExp(
          r'progressAfterSolve|recordLevelWin|recordWin\(|writeDaily|'
          r'collectChest|acknowledgeFreezeNotice|claimLoginGift|addCoins|'
          r'spendCoins|DailyProgress\(|\.copyWith\(\s*(streak|lit|run|'
          r'freezes|done|frozen|chestPending)\s*:',
        ),
      );
      expect(found, isEmpty, reason: found.join('\n'));
    });

    test('nothing pops up: no dialog, sheet or overlay in a habit', () {
      final found = offendingLines(
        habitFiles,
        RegExp(
          r'showDialog|showModalBottomSheet|showGeneralDialog|'
          r'showCupertino|OverlayEntry|Overlay\.of|ToastQueue',
        ),
      );
      expect(found, isEmpty, reason: found.join('\n'));
    });

    test("a habit's logic never navigates: only a widget's tap does", () {
      final files = [for (final path in logicPaths) ...dartFilesUnder(path)];
      final found = offendingLines(
        files,
        RegExp(r'\brouter\b|AutoRouter|StackRouter|Navigator|BuildContext'),
      );
      expect(found, isEmpty, reason: found.join('\n'));
    });

    test('a walk through odd clocks never lowers the open date, and a '
        'card only comes after a real gap forward', () {
      final random = math.Random(20261008);
      var date = LocalDate(2026, 10, 8);
      String? storedLast;
      String? storedCard;
      LocalDate? high;
      var cards = 0;
      for (var step = 0; step < 600; step++) {
        // Mostly a day or a few forward, sometimes back, sometimes far.
        final jump = switch (random.nextInt(10)) {
          < 6 => 1,
          < 8 => random.nextInt(5),
          < 9 => -1 - random.nextInt(9),
          _ => random.nextInt(61) - 30,
        };
        date = date.addDays(jump);
        final open = WelcomeBackRules.onOpen(
          today: date,
          storedLastOpen: storedLast,
          storedWelcomeBack: storedCard,
          gapDays: WelcomeBackRules.minDays,
        );
        if (high != null) {
          expect(
            open.lastOpenDate.compareTo(high),
            greaterThanOrEqualTo(0),
            reason: 'step $step: the open date fell from $high',
          );
        }
        final card = open.welcomeBackDate;
        if (card != null && card.toString() != storedCard) {
          cards++;
          expect(card, date, reason: 'step $step: a card is for today');
          expect(
            high == null || high.daysUntil(date) >= WelcomeBackRules.minDays,
            isTrue,
            reason: 'step $step: a card without a gap forward from $high',
          );
        }
        high = open.lastOpenDate;
        storedLast = open.lastOpenDate.toString();
        storedCard = card?.toString();
      }
      expect(cards, greaterThan(20), reason: 'the walk found too few gaps');
    });

    test('the month draws no red mark and no X', () {
      final found = offendingLines(
        dartFilesUnder('lib/features/daily/widgets/month_card.dart'),
        RegExp(
          r'Colors\.red|\.error\b|errorColor|danger|NestyIcons\.(close|block)|'
          r'Icons\.(close|clear|cancel)',
        ),
      );
      expect(found, isEmpty, reason: found.join('\n'));
    });
  });

  group('the copy', () {
    const prefixes = [
      'welcomeBack',
      'dailyMonth',
      'pastDaily',
      'dailyLocked',
      'widget',
    ];

    test('the habit keys exist', () {
      final english = readEnglishArb();
      for (final key in [
        'welcomeBackTitle',
        'welcomeBackPlay',
        'dailyMonthDaySemantics',
      ]) {
        expect(english[key], isNotNull, reason: 'missing "$key"');
      }
    });

    for (final file in readArbFiles()) {
      final rules = rulesFor(file.code)!;
      final keys = [
        ...keysWithPrefix(file, prefixes),
        // The welcome-back card's variant lines, reused from the Daily
        // (plan-local-habits §1).
        'dailySavedTitle',
        'dailyStreakPaused',
        'dailyStreakStart',
      ];

      test('app_${file.code}.arb: no loss, guilt, urgency, scarcity or '
          'taunt word, and no clock', () {
        final found = [
          for (final key in keys) ...[
            for (final word in wordOffences(rules, file, key, [
              ...rules.denied,
              ...rules.taunts,
            ]))
              '$key: "$word" in "${file[key]}"',
            if (file[key] != null &&
                RegExp(r'\d\s*[:：]\s*\d').hasMatch(file[key]!))
              '$key: a clock in "${file[key]}"',
          ],
        ];
        expect(found, isEmpty, reason: found.join('\n'));
      });
    }
  });
}
