import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/records/badge.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/records/widgets/badge_grid.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

/// The Records badge grid (E8; docs/plans/m7-design.md §12, §15.2): every
/// badge, earned or not, its semantics and its 55 % locked opacity.
void main() {
  setUpAll(loadBundledFonts);

  testWidgets('shows all twelve badges, in BadgeId order', (tester) async {
    await pumpScreen(tester, const Material(child: BadgeGrid(earned: [])));
    for (final badge in BadgeId.values) {
      expect(find.text(_nameOf(badge)), findsOneWidget, reason: badge.id);
    }
  });

  testWidgets('an earned badge draws its earned art and shows its own line', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const Material(child: BadgeGrid(earned: [BadgeId.firstFamily])),
    );
    expect(find.bySemanticsLabel('Snug as a Doll, earned'), findsOneWidget);
    expect(find.text('You nested your first family.'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is UiArtImage && w.art == UiArt.badgeFirstFamily,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (w) => w is UiArtImage && w.art == UiArt.badgeFirstFamilyLocked,
      ),
      findsNothing,
    );
  });

  testWidgets('an unearned badge draws its locked art, says "Not earned '
      'yet" and keeps the how-to in its screen-reader label only', (
    tester,
  ) async {
    await pumpScreen(tester, const Material(child: BadgeGrid(earned: [])));
    expect(
      find.bySemanticsLabel('Glass Act, not earned yet. Open a glass case'),
      findsOneWidget,
    );
    expect(find.text('Not earned yet'), findsNWidgets(12));
    expect(find.text('Open a glass case'), findsNothing);
    expect(find.text('You opened your first glass case.'), findsNothing);
    final arts = tester
        .widgetList<UiArtImage>(find.byType(UiArtImage))
        .map((a) => a.art)
        .toList();
    expect(arts, [
      for (final badge in BadgeId.values) UiArt.badge(badge, earned: false),
    ]);
  });

  testWidgets('three columns of 56 dp art, a row\'s cells the same height', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const Material(child: BadgeGrid(earned: [BadgeId.firstFamily])),
    );
    final art = find.byType(UiArtImage);
    expect(art, findsNWidgets(12));
    expect(tester.getSize(art.first), const Size.square(56));
    final cards = [
      for (var i = 0; i < 12; i++)
        tester.getRect(
          find
              .ancestor(of: art.at(i), matching: find.byType(NestySurface))
              .first,
        ),
    ];
    expect(cards[0].top, cards[1].top);
    expect(cards[1].top, cards[2].top);
    expect(cards[0].height, cards[1].height);
    expect(cards[3].top, greaterThan(cards[0].bottom));
    expect(cards[3].left, cards[0].left);
  });

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets(
        'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text',
        (tester) async {
          await pumpScreen(
            tester,
            const Material(
              child: SingleChildScrollView(
                child: BadgeGrid(earned: BadgeId.values),
              ),
            ),
            size: size,
            textScale: scale,
          );
          await expectAccessibleLayout(tester);
        },
      );
    }
  }
}

/// The English name of [badge] (copy.md G.8's `badgeName`).
String _nameOf(BadgeId badge) => switch (badge) {
  BadgeId.firstFamily => 'Snug as a Doll',
  BadgeId.glassBreaker => 'Glass Act',
  BadgeId.iceMelter => 'Ice Breaker',
  BadgeId.tallOrder => 'Tall Order',
  BadgeId.grandNest => 'Grand Nest',
  BadgeId.level100 => 'Halfway Home',
  BadgeId.level200 => 'Top Shelf',
  BadgeId.dailies7 => 'Puzzle Pal',
  BadgeId.dailies30 => 'Old Friend',
  BadgeId.firstRace => 'First Past the Shelf',
  BadgeId.allRivals => 'Rival Round-Up',
  BadgeId.museumFull => 'Full House',
};
