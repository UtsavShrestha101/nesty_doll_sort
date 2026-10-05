import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/extensions/a11y_join_extension.dart';
import 'package:nesty_game/l10n/app_localizations_en.dart';

/// Japanese-style separators: 、 and 。 with no space.
final class _Ja extends AppLocalizationsEn {
  @override
  String a11yJoinList(String first, String second) => '$first、$second';

  @override
  String a11yJoinSentences(String first, String second) => '$first。$second';
}

void main() {
  final en = AppLocalizationsEn();

  group('joinList', () {
    test('folds the parts through a11yJoinList', () {
      expect(en.joinList(['Level 12', '3 stars']), 'Level 12, 3 stars');
      expect(en.joinList(['a', 'b', 'c']), 'a, b, c');
    });

    test('skips empty parts; one part is itself; none is empty', () {
      expect(en.joinList(['', 'a', '', 'b']), 'a, b');
      expect(en.joinList(['only']), 'only');
      expect(en.joinList(const []), '');
    });

    test('a language writes its own separator', () {
      expect(_Ja().joinList(['レベル12', '星3つ']), 'レベル12、星3つ');
    });
  });

  group('joinSentences', () {
    test('folds the parts through a11yJoinSentences', () {
      expect(en.joinSentences(['One', 'Two', 'Three']), 'One. Two. Three');
    });

    test('a part that already ends in a full stop takes no second one', () {
      expect(en.joinSentences(['One.', 'Two']), 'One. Two');
      expect(en.joinSentences(['One', 'Two.', 'Three']), 'One. Two. Three');
    });

    test('closing ends the last sentence with the language\'s stop', () {
      expect(en.joinSentences(['One', 'Two'], closing: true), 'One. Two.');
      expect(en.joinSentences(['One.'], closing: true), 'One.');
      expect(en.joinSentences(const [], closing: true), '');
      expect(_Ja().joinSentences(['一つ', '二つ'], closing: true), '一つ。二つ。');
    });

    test('skips empty parts', () {
      expect(en.joinSentences(['', 'One', '', 'Two']), 'One. Two');
    });

    test('a language writes its own full stop', () {
      expect(_Ja().joinSentences(['一つ', '二つ。', '三つ']), '一つ。二つ。三つ');
    });

    // Hindi's parts end in its own stop (raceRivalCardSemantics,
    // chaptersLevelSemanticsWon): no "।।" (5b-copycheck).
    test('a part ending in the language\'s own stop takes no second one', () {
      final hi = _Hi();
      expect(hi.joinSentences(['एक।', 'दो']), 'एक। दो');
      expect(hi.joinSentences(['एक', 'दो'], closing: true), 'एक। दो।');
      expect(hi.joinSentences(['एक।', 'दो।'], closing: true), 'एक। दो।');
    });

    test('! and ? keep their mark: no stop after them, the gap only', () {
      expect(
        en.joinSentences(['Streak relit!', '5 days']),
        'Streak relit! 5 days',
      );
      expect(en.joinSentences(['Ready?', 'Go'], closing: true), 'Ready? Go.');
      expect(
        en.joinSentences(['One', 'New best!'], closing: true),
        'One. New best!',
      );
      expect(_Ja().joinSentences(['連続記録が復活！', '5日']), '連続記録が復活！5日');
    });
  });
}

/// Hindi's full stop, the danda, then a space.
final class _Hi extends AppLocalizationsEn {
  @override
  String a11yJoinSentences(String first, String second) => '$first। $second';
}
