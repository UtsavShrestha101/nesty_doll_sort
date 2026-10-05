import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nesty_core/nesty_core.dart' show DollColor;
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/features/daily/share/daily_share_text.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

import 'support/test_locale.dart';

/// The daily's Share text in each language (build/m7-p5/p5/l10n.md §1.3,
/// §7.1): the date is the locale's `MMMd` (copy.md G.6's "Sep 30" in
/// English; de "30. Sept.", ja "9月30日", hi "30 सित॰" as l10n.md §1.3
/// gives them), the moves and the streak day keep their digits, and the
/// glyphs stay emoji. A locale whose catalog isn't in yet is skipped.
/// Run from `apps/game`.
void main() {
  setUpAll(initializeDateFormatting);

  final data = (
    date: LocalDate(2026, 9, 30),
    families: [DollColor.red, DollColor.blue, DollColor.gold],
    moves: 18,
    streakDay: 4,
    streakLit: true,
  );

  const dates = {
    'en': 'Sep 30',
    'de': '30. Sept.',
    'ja': '9月30日',
    'hi': '30 सित॰',
  };

  for (final MapEntry(key: code, value: date) in dates.entries) {
    final locale = Locale(code);
    test('$code: the date reads "$date"; the moves, the day and the glyphs '
        'stay', () {
      final l10n = lookupAppLocalizations(locale);
      final text = DailyShareText.of(l10n, localeName: code, data: data);
      expect(text, contains(date));
      expect(text, contains('18'));
      expect(text, contains('4'));
      for (final color in data.families) {
        expect(text, contains(l10n.dailyShareGlyph(color.id)));
      }
      expect(text, contains('Nesty'), reason: 'the brand is never translated');
    }, skip: hasCatalog(locale) ? false : 'app_$code.arb is not in yet');
  }
}
