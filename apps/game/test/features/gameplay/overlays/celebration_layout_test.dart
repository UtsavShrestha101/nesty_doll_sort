import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/gameplay/overlays/celebration_layout.dart';

/// The win card's y table (ui-spec-game §1 "CelebrationLayout"; tokens
/// `layout.winStars`, `winStarsShort`, `replayCard`; NestyMeta `L844`,
/// `L693`, `PLAIN`, `REPLAY`).
void main() {
  CelebrationLayout of(
    CelebrationVariant variant, {
    double height = 844,
    int families = 4,
  }) => CelebrationLayout.of(variant, screenHeight: height, families: families);

  test('the campaign card (11.2): stars 176, plank 366, dolls 88, chips 420, '
      'progress 500, note 602, buttons 646', () {
    final l = of(CelebrationVariant.campaign);
    expect(l.starsTop, 176);
    expect(l.plankTop, 366);
    expect(l.dollHeight, 88);
    expect(l.chipsTop, 420);
    expect(l.cardTop, 500);
    expect(l.noteTop, 602);
    expect(l.buttonsTop, 646);
    expect(l.hasStars, isTrue);
    expect(l.blockHeight, 646 - 59);
  });

  test('the short 16:9 card (11.2d): ribbon 70, stars 128, plank 300, dolls '
      '72, chips 342, progress 414, buttons 522, no note', () {
    final l = of(CelebrationVariant.campaign, height: 693);
    expect(l.ribbonCanvasTop, 70 - 23);
    expect(l.starsTop, 128);
    expect(l.plankTop, 300);
    expect(l.dollHeight, 72);
    expect(l.chipsTop, 342);
    expect(l.cardTop, 414);
    expect(l.buttonsTop, 522);
    expect(l.noteTop, isNull);
  });

  test('the replay card (11.4): moves chip 420, reason card 494, tip 612, '
      'button 668, ending above the booster bar at 734', () {
    final l = of(CelebrationVariant.replay);
    expect(l.chipsTop, 420);
    expect(l.cardTop, 494);
    expect(l.noteTop, 612);
    expect(l.buttonsTop, 668);
    // 668 + 58 + 6 edge = 732 < 734.
    expect(l.buttonsTop + 58 + 6, lessThan(734));
  });

  test('the card without stars (12.4, 10.1): plank 350, dolls 104 (88 past '
      'four families), chips 404, card 484, buttons 630', () {
    final l = of(CelebrationVariant.plain);
    expect(l.starsTop, isNull);
    expect(l.hasStars, isFalse);
    expect(l.plankTop, 350);
    expect(l.dollHeight, 104);
    expect(l.chipsTop, 404);
    expect(l.cardTop, 484);
    expect(l.buttonsTop, 630);
    expect(of(CelebrationVariant.plain, families: 5).dollHeight, 88);
  });

  test('every card ends its buttons above the home area on its own size', () {
    for (final (variant, height, buttons) in [
      (CelebrationVariant.campaign, 844.0, 646.0),
      (CelebrationVariant.campaign, 693.0, 522.0),
    ]) {
      final l = of(variant, height: height);
      expect(l.buttonsTop, buttons);
      // Two 58 dp buttons, the gap and the edge below the home indicator's
      // 34 dp.
      expect(l.buttonsTop + 58 + 10 + 58 + 6, lessThanOrEqualTo(height - 34));
    }
  });

  test('a y below the safe area top', () {
    expect(CelebrationLayout.below(59), 0);
    expect(CelebrationLayout.below(176), 117);
  });
}
