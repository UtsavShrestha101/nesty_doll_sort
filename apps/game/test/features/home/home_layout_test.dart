import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/features/home/widgets/home_layout.dart';

/// Where Home's blocks sit (frames 2.1 and 2.1b; tokens `layout.home` and
/// `layout.homeShort`): the two frames exactly, and a blend between them.
void main() {
  // The tall frame's body under its 59 dp status bar, and the short one's
  // under its 20.
  const tallBody = 738.0 - 59;
  const shortBody = 587.0 - 20;

  test('on the 390×844 frame every number is frame 2.1\'s', () {
    final layout = HomeLayout.forBody(tallBody);
    expect(layout.t, 0);
    expect(layout.chapterCardTop, HomeTokens.chapterCardTop - 59);
    expect(layout.plankTop, HomeTokens.plankTop - 59);
    expect(layout.playTop, HomeTokens.playButtonTop - 59);
    expect(layout.playHeight, HomeTokens.playButtonHeight);
    expect(layout.tilesTop, HomeTokens.tilesTop - 59);
    expect(layout.tilesHeight, HomeTokens.tilesHeight);
    expect(layout.dollScale, 1);
  });

  test('on the 390×693 frame every number is frame 2.1b\'s', () {
    final layout = HomeLayout.forBody(shortBody);
    expect(layout.t, 1);
    expect(layout.chapterCardTop, HomeShortTokens.chapterCard - 20);
    expect(layout.plankTop, HomeShortTokens.plankTop - 20);
    expect(layout.playTop, HomeShortTokens.playButtonTop - 20);
    expect(layout.playHeight, HomeShortTokens.playButtonHeight);
    expect(layout.tilesTop, HomeShortTokens.tilesTop - 20);
    expect(layout.tilesHeight, HomeShortTokens.tilesHeight);
    expect(layout.dollScale, HomeShortTokens.dollScale);
  });

  test('between them it blends, and a taller body stays the tall frame', () {
    final middle = HomeLayout.forBody((tallBody + shortBody) / 2);
    expect(middle.t, closeTo(0.5, 1e-9));
    expect(middle.playHeight, closeTo(92, 1e-9));
    expect(middle.dollScale, closeTo(0.91, 1e-9));

    expect(HomeLayout.forBody(tallBody + 300).t, 0);
    expect(HomeLayout.forBody(100).t, 1);
  });

  test('the hero block spans the plank\'s 192 dp lead to PLAY\'s edge', () {
    final layout = HomeLayout.forBody(tallBody);
    expect(layout.plankTop - layout.heroTop, 192);
    // Frame 2.1: the hero ends at design y 560 (PLAY's 542 plus its edge).
    expect(layout.heroBottom + 59, 560);
  });

  test('a body shorter than the short frame keeps the tiles 12 dp above '
      'its bottom, and never moves them down', () {
    final layout = HomeLayout.forBody(500);
    expect(
      layout.tilesTopIn(500),
      500 - HomeLayout.tilesBottomGap - layout.tilesHeight,
    );
    final tall = HomeLayout.forBody(tallBody);
    expect(tall.tilesTopIn(tallBody), tall.tilesTop);
  });

  group('the welcome-back card\'s place (14.1)', () {
    const minCard = HabitsWelcomeTokens.cardMinHeight;

    test('the card top is the design\'s on both frames', () {
      expect(
        HomeLayout.forBody(tallBody).welcomeCardTop + 59,
        HabitsWelcomeTokens.placeH844Top,
      );
      expect(
        HomeLayout.forBody(shortBody).welcomeCardTop +
            HomeShortTokens.statusBar,
        HabitsWelcomeTokens.placeH693Top,
      );
    });

    test('844: the dolls scale to 0.78 and stay', () {
      final dolls = HomeLayout.forBody(tallBody).dollsUnder(minCard);
      expect(
        dolls.scale,
        closeTo(HabitsWelcomeTokens.placeH844DollScale, 1e-6),
      );
      expect(dolls.opacity, 1);
    });

    test('693: the dolls fade out and the plank stays', () {
      final layout = HomeLayout.forBody(shortBody);
      final dolls = layout.dollsUnder(minCard);
      expect(dolls.opacity, 0);
      // Faded dolls keep the layout's own scale: they fade back in without
      // a size change.
      expect(dolls.scale, layout.dollScale);
    });

    test('a taller card (1.3x text) shrinks the dolls, then fades them', () {
      final layout = HomeLayout.forBody(tallBody);
      final small = layout.dollsUnder(minCard).scale;
      final taller = layout.dollsUnder(minCard + 12);
      expect(taller.scale, lessThan(small));
      expect(taller.scale, greaterThanOrEqualTo(0.6));
      expect(taller.opacity, 1);
      expect(layout.dollsUnder(minCard + 60).opacity, 0);
    });

    test('the tallest doll clears the card by 8 dp where they show', () {
      for (var body = tallBody; body >= shortBody; body -= 4) {
        final layout = HomeLayout.forBody(body);
        final dolls = layout.dollsUnder(minCard);
        expect(dolls.scale, lessThanOrEqualTo(layout.dollScale));
        if (dolls.opacity == 1) {
          expect(dolls.scale, greaterThanOrEqualTo(0.6), reason: '$body');
        }
        // Play stays below the card.
        expect(layout.welcomeCardTop + minCard, lessThan(layout.playTop));
      }
    });
  });
}
