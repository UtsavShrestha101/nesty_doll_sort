// The board's "+N" tower tag and ice badge (ARB
// `boardTowerHidden`/`boardIceCount`, spec §16; m2-lottie-design §8, §9.6):
// `SlotDecor` only measures and paints whatever label and direction it is
// handed through `BoardLabels`; it never builds "+N" from a raw count
// itself (BACKLOG "the Flame board's '+N' tower tag and the ice badge's
// digits through ARB", `slot_decor.dart`).
import 'dart:ui' show TextDirection;

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/gameplay/game/components/slot_decor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BoardLabels.fallback', () {
    test('reproduces the ARB\'s own English pattern: "+N" and "N", '
        'left-to-right', () {
      expect(BoardLabels.fallback.towerTag(3), '+3');
      expect(BoardLabels.fallback.iceBadge(2), '2');
      expect(BoardLabels.fallback.textDirection, TextDirection.ltr);
    });
  });

  group('SlotDecor', () {
    test('a null label drops the tag and the badge', () {
      final decor = SlotDecor()
        ..setTag('+3', 1, TextDirection.ltr)
        ..setBadge('2', 1, 20, TextDirection.ltr);
      expect(decor.hasTag, isTrue);
      expect(decor.hasBadge, isTrue);

      decor
        ..setTag(null, 1, TextDirection.ltr)
        ..setBadge(null, 1, 20, TextDirection.ltr);
      expect(decor.hasTag, isFalse);
      expect(decor.hasBadge, isFalse);
      expect(decor.tagLabel, isNull);
      expect(decor.badgeLabel, isNull);
      decor.dispose();
    });

    test('paints exactly the label and direction it is handed, never a '
        'raw count of its own (a stand-in for a non-English locale)', () {
      // A stand-in for a locale whose `AppLocalizations` writes different
      // digits in the other direction: proves the label text and
      // direction reach the painted tag and badge untouched, whatever
      // they are, not just the fallback's "+N"/"N".
      String easternTag(int count) => '٩+'; // a fake "+9"
      String easternBadge(int count) => '٤'; // a fake "4"
      final labels = BoardLabels(
        towerTag: easternTag,
        iceBadge: easternBadge,
        textDirection: TextDirection.rtl,
      );

      final decor = SlotDecor()
        ..setTag(labels.towerTag(9), 1, labels.textDirection)
        ..setBadge(labels.iceBadge(4), 1, 20, labels.textDirection);

      expect(decor.tagLabel, '٩+');
      expect(decor.badgeLabel, '٤');
      expect(decor.tagDirection, TextDirection.rtl);
      expect(decor.badgeDirection, TextDirection.rtl);
      decor.dispose();
    });

    test('the same label, scale and direction again is a no-op: the '
        'painted text is unchanged (only a new value relays out)', () {
      final decor = SlotDecor()..setTag('+1', 1, TextDirection.ltr);
      expect(decor.tagLabel, '+1');
      decor.setTag('+1', 1, TextDirection.ltr);
      expect(decor.tagLabel, '+1');

      decor.setTag('+2', 1, TextDirection.ltr);
      expect(decor.tagLabel, '+2');
      decor.dispose();
    });
  });
}
