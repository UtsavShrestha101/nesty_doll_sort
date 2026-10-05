import 'package:nesty_tools/src/fonts/font_subsets.dart';
import 'package:test/test.dart';

void main() {
  group('isExemptCharacter', () {
    test('controls, format characters, spaces and emoji', () {
      for (final c in [
        0x0A, // Cc
        0x00A0, // Zs no-break space
        0x202F, // Zs narrow no-break space (intl's fr grouping)
        0x2060, // Cf word joiner (kickerRangeDash)
        0x200B, // Cf zero-width space
        0xFE0F, // emoji presentation selector
        0x2B50, // ⭐
        0x2764, // ❤
        0x1F525, // 🔥
        0x1FA86, // 🪆
      ]) {
        expect(isExemptCharacter(c), isTrue, reason: c.toRadixString(16));
      }
    });

    test('letters, digits, punctuation and kana are drawn', () {
      for (final c in 'Aé1·–…।あ日'.runes) {
        expect(isExemptCharacter(c), isFalse, reason: String.fromCharCode(c));
      }
    });
  });

  test('the OS-drawn keys are the share text and the notification', () {
    for (final key in [
      'dailyShareText',
      'dailyShareTextNoStreak',
      'dailyShareGlyph',
      'reminderNotificationTitle',
      'reminderChannelName',
    ]) {
      expect(isOsDrawnArbKey(key), isTrue, reason: key);
    }
    expect(isOsDrawnArbKey('dailyShare'), isFalse, reason: 'the button');
    expect(isOsDrawnArbKey('dailyShareSemantics'), isFalse);
  });

  test('parseAutonyms reads the LaunchLanguage list', () {
    expect(
      parseAutonyms('''
const launchLanguages = [
  LaunchLanguage('en', 'English'),
  LaunchLanguage('hi', 'हिन्दी'),
  LaunchLanguage(
    'ja',
    '日本語',
  ),
];'''),
      {'en': 'English', 'hi': 'हिन्दी', 'ja': '日本語'},
    );
    expect(() => parseAutonyms('const x = 1;'), throwsFormatException);
  });

  test('arbValues skips metadata and non-string values', () {
    expect(
      arbValues(
        '{"@@locale": "ja", "a": "日本", "@a": {"description": "x"}, '
        '"n": 3}',
      ),
      {'a': '日本'},
    );
  });

  test('intl dates: the weekday and month names a locale prints', () async {
    final ja = await intlDateText('ja');
    expect(ja, contains('月曜日'));
    expect(ja, contains('9月28日'));
    final hi = await intlDateText('hi');
    expect(hi.runes.any((c) => c >= 0x0900 && c <= 0x097F), isTrue);
  });

  group('subsetListSource', () {
    final jpan = scriptSubsets.firstWhere((s) => s.script == 'jpan');
    SubsetSources sources(String text) => SubsetSources(
      characters: {
        for (final c in text.runes)
          if (!isExemptCharacter(c)) c,
      },
      arbFiles: const ['apps/game/lib/l10n/app_ja.arb'],
      missingArbFiles: const [],
      sdkFiles: const ['material_ja.arb'],
      autonyms: const ['日本語'],
    );

    test('blocks whole, then the characters outside them and Latin', () {
      final list = subsetListSource(
        jpan,
        sources('レベル 5 クリア！日本語の星→'),
        latin: {for (final c in 'レ 5'.runes) c},
        designFamily: 'M PLUS Rounded 1c',
      );
      final entries = [
        for (final line in list.split('\n'))
          if (line.startsWith('U+')) line.split(' #').first,
      ];
      expect(entries, [
        'U+3000-303F',
        'U+3041-309F',
        'U+30A0-30FF',
        'U+31F0-31FF',
        'U+FF01-FF5E',
        // Sorted, outside the blocks and the Latin faces: → 日 星 本 語.
        'U+2192',
        'U+65E5',
        'U+661F',
        'U+672C',
        'U+8A9E',
      ]);
      expect(list, startsWith('# GENERATED'));
      expect(list, contains('U+65E5 # 日'));
      expect(list, endsWith('\n'));
    });

    test('says when no character is outside the blocks', () {
      final deva = scriptSubsets.firstWhere((s) => s.script == 'deva');
      final list = subsetListSource(
        deva,
        sources('हिन्दी। 5'),
        latin: {for (final c in '5'.runes) c},
        designFamily: 'Baloo 2',
      );
      expect(list, contains('U+0900-097F # Devanagari'));
      expect(list, contains('U+25CC # dotted circle'));
      expect(list, contains('# (none)'));
    });

    test('names an ARB that does not exist yet', () {
      final list = subsetListSource(
        jpan,
        SubsetSources(
          characters: const {},
          arbFiles: const [],
          missingArbFiles: const ['apps/game/lib/l10n/app_ja.arb'],
          sdkFiles: const [],
          autonyms: const ['日本語'],
        ),
        latin: const {},
        designFamily: 'M PLUS Rounded 1c',
      );
      expect(list, contains('app_ja.arb (not written yet: rerun when it is)'));
    });
  });
}
