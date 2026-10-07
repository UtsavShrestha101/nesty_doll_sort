import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/streak_daily_service.dart';
import 'package:nesty_game/core/services/login_gift/login_gift_rules.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

import '../l10n/locales/locales.dart';
import '../l10n/support/arb_checks.dart';
import '../l10n/support/arb_file.dart';

/// The respect rules for the daily gift (D92, spec-prop §1.1; plan-login-
/// gift §7.5b, D268), on `stars_gate_nothing_test`'s pattern:
/// - no ad, purchase, chance or clock-text path: the gift has no ad, no
///   purchase, no random reward (rule 2) and no countdown (rule 3);
/// - nothing lowers `claims`: a gap never moves the track back (rule 6),
///   checked in the code and by a walk through odd clocks;
/// - the copy, in every language, has no loss, guilt, urgency or scarcity
///   word and never says streak (the gift is not the Daily puzzle);
/// - nothing opens the sheet on its own (Q182b: a button, no popup).
///
/// Run from `apps/game`.
void main() {
  const giftPaths = ['lib/features/login_gift', 'lib/core/services/login_gift'];

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

  /// Code lines only: a doc comment may explain what the gift never does.
  List<String> offendingLines(Iterable<File> files, RegExp pattern) => [
    for (final file in files)
      for (final (i, line) in file.readAsLinesSync().indexed)
        if (pattern.hasMatch(line.split('//').first))
          '${file.path}:${i + 1}: ${line.trim()}',
  ];

  group('the code', () {
    test('every scanned path exists', () {
      for (final path in giftPaths) {
        expect(Directory(path).existsSync(), isTrue, reason: '$path is gone');
      }
    });

    test('the gift paths use no ad, purchase, chance or clock text', () {
      final files = [for (final path in giftPaths) ...dartFilesUnder(path)];
      expect(files.length, greaterThanOrEqualTo(4));
      final found = offendingLines(
        files,
        RegExp(
          r'services/(ads|purchase)/|\bAdsService\b|\bPurchaseService\b|'
          r'\bRandom\b|\bDateFormat\b|countdown|Countdown|Timer\.periodic',
        ),
      );
      expect(found, isEmpty, reason: found.join('\n'));
    });

    test('only LoginGiftRules writes the claim count, and only one up', () {
      // Every `claims:` in app code is the rules' `+ 1`, a read of the
      // progress (`claims: progress.claims` into the cubit's state), the
      // codec's lenient read, or the field's own declaration.
      final allowed = RegExp(
        r'claims: progress\.claims \+ 1|claims: progress\.claims\b|'
        r'claims: _int\(|claims: doc\.loginGift\.claims|'
        r"'claims': (doc\.loginGift\.claims|grant\.claims)|int claims",
      );
      final found = [
        for (final line in offendingLines(
          dartFilesUnder('lib'),
          RegExp(r'\bclaims\s*[:=]'),
        ))
          if (!allowed.hasMatch(line)) line,
      ];
      expect(found, isEmpty, reason: found.join('\n'));
    });

    test('a walk through odd clocks never lowers claims, and each claim '
        'pays the next day', () {
      final save = FakeSaveService(
        initial: const SaveDocument(
          currentLevel: StreakDailyService.unlockAtHighestLevel,
          highestLevel: StreakDailyService.unlockAtHighestLevel,
        ),
      );
      final random = math.Random(20261005);
      var date = LocalDate(2026, 10, 5);
      var claims = 0;
      for (var step = 0; step < 600; step++) {
        // Mostly a day or a few forward (so real claims happen), sometimes
        // back a little, sometimes far either way.
        final jump = switch (random.nextInt(10)) {
          < 6 => 1,
          < 8 => random.nextInt(5),
          < 9 => -1 - random.nextInt(9),
          _ => random.nextInt(61) - 30,
        };
        date = date.addDays(jump);
        if (random.nextBool()) save.noteLoginGiftDate(date);
        final grant = save.claimLoginGift(date);
        final after = save.document.loginGift.claims;
        expect(after, greaterThanOrEqualTo(claims), reason: 'step $step');
        if (grant == null) {
          expect(after, claims, reason: 'a refused claim changes nothing');
        } else {
          expect(after, claims + 1);
          expect(grant.day, LoginGiftRules.dayOf(claims));
        }
        claims = after;
      }
      expect(claims, greaterThan(50), reason: 'the walk claimed too little');
    });
  });

  group('the copy', () {
    final files = readArbFiles();

    test('the gift keys exist', () {
      final english = readEnglishArb();
      for (final key in ['giftTitle', 'giftTomorrow', 'chestContentsSlot']) {
        expect(english[key], isNotNull, reason: 'missing "$key"');
      }
    });

    for (final file in files) {
      final rules = rulesFor(file.code)!;
      final keys = keysWithPrefix(file, const ['gift', 'chestContentsSlot']);

      test('app_${file.code}.arb: no loss, guilt, urgency, scarcity or '
          'streak word, and no clock', () {
        final found = [
          for (final key in keys) ...[
            for (final word in wordOffences(rules, file, key, [
              ...rules.denied,
              ...rules.streakWords,
            ]))
              '$key: "$word" in "${file[key]}"',
            if (RegExp(r'\d\s*[:：]\s*\d').hasMatch(file[key]!))
              '$key: a clock in "${file[key]}"',
          ],
        ];
        expect(found, isEmpty, reason: found.join('\n'));
      });
    }
  });

  test('the tally only appears from a claim (m7-5 13.5b, 13.6d): the '
      "sheet's Claim and Day 7's Collect, nothing else", () {
    final method = RegExp(
      r'^\s*(?:static\s+)?(?:Future<[^>]*>|void|[A-Z]\w*\??)\s+(_?\w+)\s*\(',
    );
    final owners = <String>{};
    for (final file in dartFilesUnder('lib')) {
      final lines = file.readAsLinesSync();
      for (final (i, line) in lines.indexed) {
        if (!line.split('//').first.contains('GiftTally.show(')) continue;
        String? owner;
        for (var j = i; j >= 0 && owner == null; j--) {
          owner = method.firstMatch(lines[j])?.group(1);
        }
        owners.add('${file.uri.pathSegments.last}:$owner');
      }
    }
    expect(owners, {
      'gift_sheet.dart:_payTally',
      'gift_chest_modal.dart:_onCollectStart',
    });
    final sheet = File(
      'lib/features/login_gift/widgets/gift_sheet.dart',
    ).readAsStringSync();
    // `_payTally` runs only from `_claim`, which only Claim's onPressed calls.
    expect(RegExp(r'_payTally\(cubit').allMatches(sheet), hasLength(1));
    expect(sheet, contains('onPressed: _claim'));
    final chest = File(
      'lib/features/login_gift/widgets/gift_chest_modal.dart',
    ).readAsStringSync();
    expect(
      RegExp(r'_onCollectStart\b').allMatches(chest).length,
      2,
      reason: 'declared once, handed to the chest\'s Collect once',
    );
    expect(chest, contains('onCollectStart: _onCollectStart'));
  });

  test("the button's ready dot is still: nothing animates it (m7-5 "
      '`gift.button.readyDot.motion`)', () {
    final button = File(
      'lib/features/login_gift/widgets/gift_button.dart',
    ).readAsLinesSync().map((l) => l.split('//').first).join('\n');
    for (final word in [
      'AnimationController',
      'repeat(',
      'Tween',
      'Animated',
      'Lottie',
    ]) {
      expect(button, isNot(contains(word)), reason: word);
    }
  });

  test('nothing opens the gift sheet on its own: one call site, reached '
      'only from a tap', () {
    final tap = RegExp(r'\bonPressed\b|\bonTap\b');
    final method = RegExp(
      r'^\s*(?:static\s+)?(?:Future<[^>]*>|void)\s+(_?\w+)\s*\(',
    );
    bool nearTap(List<String> lines, int i) =>
        tap.hasMatch(lines.sublist(math.max(0, i - 4), i + 1).join('\n'));

    final calls = <String>[];
    for (final file in dartFilesUnder('lib')) {
      final lines = file.readAsLinesSync();
      for (final (i, line) in lines.indexed) {
        final code = line.split('//').first;
        if (!code.contains('GiftSheet.show(')) continue;
        calls.add('${file.path}:${i + 1}');
        if (nearTap(lines, i)) continue;
        // Inside a helper: every use of that helper must be a tap.
        String? helper;
        for (var j = i; j >= 0 && helper == null; j--) {
          helper = method.firstMatch(lines[j])?.group(1);
        }
        expect(helper, isNotNull, reason: '${file.path}:${i + 1}');
        final uses = [
          for (final (j, use) in lines.indexed)
            if (use.split('//').first.contains('$helper(') &&
                !method.hasMatch(use))
              j,
        ];
        expect(uses, isNotEmpty, reason: '$helper is never called');
        for (final j in uses) {
          expect(
            nearTap(lines, j),
            isTrue,
            reason: '${file.path}:${j + 1} opens the sheet outside a tap',
          );
        }
      }
    }
    expect(calls, hasLength(1), reason: calls.join('\n'));
  });
}
