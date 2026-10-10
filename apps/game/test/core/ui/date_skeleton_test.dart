import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nesty_game/core/ui/date_skeleton.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// The design tokens' date skeletons through intl (D313): a CLDR skeleton's
/// field order means nothing, but intl only reads its own spellings, so
/// 'EEEEdMMMM' was printed as a pattern ("Sunday1November").
void main() {
  setUpAll(initializeDateFormatting);

  final day = DateTime(2026, 11, 1);

  // A letter outside intl's order (here `a`, am/pm) keeps its place
  // among the unknown ones, after every known field: no token uses one
  // today, and this pins what a new one would get.
  test('a letter intl does not order goes last', () {
    expect(intlSkeleton('aMMMd'), 'MMMda');
    expect(intlSkeleton('jmaz'), 'jmaz');
  });

  test('fields go in intl order', () {
    expect(intlSkeleton('EEEEdMMMM'), 'MMMMEEEEd');
    expect(intlSkeleton('MMMEd'), 'MMMEd');
    expect(intlSkeleton('dMMMy'), 'yMMMd');
    expect(intlSkeleton('LLLL'), 'LLLL');
  });

  test("the past day's dates read as the locale writes them", () {
    expect(
      skeletonDateFormat(HabitsPastDayTokens.winDateSkeleton, 'en').format(day),
      'Sunday, November 1',
    );
    expect(
      skeletonDateFormat(HabitsPastDayTokens.winDateSkeleton, 'de').format(day),
      'Sonntag, 1. November',
    );
    expect(
      skeletonDateFormat(
        HabitsPastDayTokens.cardTitleDateSkeleton,
        'en',
      ).format(day),
      'Sun, Nov 1',
    );
  });

  test('every skeleton token resolves to a pattern, in every locale', () {
    const tokens = [
      HabitsPastDayTokens.winDateSkeleton,
      HabitsPastDayTokens.cardTitleDateSkeleton,
      HabitsPastDayTokens.boardDateSkeleton,
    ];
    const locales = ['en', 'es', 'pt', 'pt_BR', 'id', 'hi', 'de', 'fr', 'tr'];
    for (final locale in [...locales, 'ja']) {
      for (final token in tokens) {
        // An unknown skeleton stays as written, its fields run together; a
        // known one becomes the locale's pattern with spaces, commas, dots
        // or the Japanese date characters between the fields.
        final pattern = skeletonDateFormat(token, locale).pattern!;
        expect(
          pattern.contains(RegExp('[^A-Za-z]')),
          isTrue,
          reason: '$token in $locale resolved to "$pattern"',
        );
      }
    }
  });
}
