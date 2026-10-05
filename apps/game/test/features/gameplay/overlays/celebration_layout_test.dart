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
    bool withNote = false,
  }) => CelebrationLayout.of(
    variant,
    screenHeight: height,
    families: families,
    withNote: withNote,
  );

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
      '72, chips 342, progress 414, buttons 522 (no note showing)', () {
    final l = of(CelebrationVariant.campaign, height: 693);
    expect(l.ribbonCanvasTop, 70 - 23);
    expect(l.starsTop, 128);
    expect(l.plankTop, 300);
    expect(l.dollHeight, 72);
    expect(l.chipsTop, 342);
    expect(l.cardTop, 414);
    expect(l.buttonsTop, 522);
    expect(l.buttonsGap, 10);
  });

  test('the short card with its note (11.2d, notePill.withTip): plank 286, '
      'dolls 64, chips 322, progress 392, note 486, buttons 548', () {
    final l = of(CelebrationVariant.campaign, height: 693, withNote: true);
    expect(l.ribbonCanvasTop, 70 - 23);
    expect(l.starsTop, 128);
    expect(l.plankTop, 286);
    expect(l.dollHeight, 64);
    expect(l.chipsTop, 322);
    expect(l.cardTop, 392);
    expect(l.noteTop, 486);
    expect(l.buttonsTop, 548);
    expect(l.noteGap, 486 - 392 - 86, reason: 'the pill sits at 486');
  });

  test('between 693 and 844 every number is a straight blend by height '
      '(layout.sizeBlend), clamped outside; no 760 switch', () {
    final short = of(CelebrationVariant.campaign, height: 693);
    final tall = of(CelebrationVariant.campaign);
    expect(CelebrationLayout.blendOf(600), 0);
    expect(CelebrationLayout.blendOf(693), 0);
    expect(CelebrationLayout.blendOf(844), 1);
    expect(CelebrationLayout.blendOf(932), 1);
    expect(CelebrationLayout.blendOf(768.5), closeTo(0.5, 1e-9));
    final mid = of(CelebrationVariant.campaign, height: 768.5);
    double mix(double a, double b) => a + (b - a) / 2;
    expect(mid.starsTop, mix(short.starsTop!, tall.starsTop!));
    expect(mid.plankTop, mix(short.plankTop, tall.plankTop));
    expect(mid.dollHeight, mix(short.dollHeight, tall.dollHeight));
    expect(mid.chipsTop, mix(short.chipsTop, tall.chipsTop));
    expect(mid.cardTop, mix(short.cardTop, tall.cardTop));
    expect(mid.buttonsTop, mix(short.buttonsTop, tall.buttonsTop));
    expect(mid.buttonsGap, 12);
    // Just either side of the old 760 switch the card moves by a hair, not
    // a jump.
    final below = of(CelebrationVariant.campaign, height: 759);
    final above = of(CelebrationVariant.campaign, height: 761);
    expect((above.plankTop - below.plankTop).abs(), lessThan(1));
    expect((above.buttonsTop - below.buttonsTop).abs(), lessThan(2));
    // With a note, it blends against the with-tip short end.
    final note = of(CelebrationVariant.campaign, height: 768.5, withNote: true);
    expect(note.plankTop, mix(286, 366));
    expect(note.noteTop, mix(486, 602));
    expect(note.noteGap, mix(8, 16));
    // Taller than the reference: the 844 card.
    expect(of(CelebrationVariant.campaign, height: 932).plankTop, 366);
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

  test('every card ends its button above the home area on its own size, '
      'with and without a note', () {
    for (final height in [693.0, 731.0, 760.0, 800.0, 844.0, 932.0]) {
      for (final withNote in [false, true]) {
        final l = of(
          CelebrationVariant.campaign,
          height: height,
          withNote: withNote,
        );
        // One 58 dp button and its edge above the home indicator's 34 dp.
        expect(
          l.buttonsTop + 58 + 6,
          lessThanOrEqualTo(height - 34),
          reason: '$height, note $withNote',
        );
        // The note pill (24 tall) ends above the button.
        if (withNote) {
          expect(l.noteTop! + 28, lessThanOrEqualTo(l.buttonsTop));
        }
      }
    }
  });

  test('a y below the safe area top', () {
    expect(CelebrationLayout.below(59), 0);
    expect(CelebrationLayout.below(176), 117);
  });
}
