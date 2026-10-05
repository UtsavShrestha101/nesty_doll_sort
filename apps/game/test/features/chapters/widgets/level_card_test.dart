import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/chapters/cubit/chapters_cubit.dart';
import 'package:nesty_game/features/chapters/widgets/level_card.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

/// The level card (frame 10.4b; menus spec 3): the ribbon, the stars, the
/// 3-star target, the "Best" chip and Play, which replays the level.
void main() {
  setUpAll(loadBundledFonts);

  const won = ChapterLevel(
    order: 62,
    status: ChapterLevelStatus.won,
    bestMoves: 16,
    stars: 2,
    target: 15,
  );

  /// A page with a button that opens the card, like a cell would.
  Widget host(ChapterLevel level, List<PlayRequest> played) => Material(
    child: Builder(
      builder: (context) => Center(
        child: TextButton(
          onPressed: () =>
              LevelCard.show(context, level: level, onPlay: played.add),
          child: const Text('open'),
        ),
      ),
    ),
  );

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the "Level 62" ribbon, the target and the best', (
    tester,
  ) async {
    await pumpScreen(tester, host(won, []));
    await open(tester);

    expect(find.text('Level 62'), findsOneWidget);
    expect(find.text('3 stars at 15 moves or fewer'), findsOneWidget);
    expect(find.text('Best 16'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.byIcon(IconUses.bestMoves), findsOneWidget);
    expect(find.bySemanticsLabel('2 of 3 stars'), findsOneWidget);
  });

  testWidgets('the target line is Nunito 16/23 and the best chip 18 '
      '(NestyMeta:60-62)', (tester) async {
    await pumpScreen(tester, host(won, []));
    await open(tester);
    final target = tester.widget<Text>(
      find.text('3 stars at 15 moves or fewer'),
    );
    expect(target.style!.fontSize, 16);
    expect(target.style!.height, closeTo(23 / 16, 1e-9));
    expect(target.style!.color, AppColorTokens.textBrown);
    expect(tester.widget<Text>(find.text('Best 16')).style!.fontSize, 18);
  });

  testWidgets('its text has the app\'s defaults, never the no-Material '
      'underline: a general dialog brings no Material of its own', (
    tester,
  ) async {
    // The device run (2026-09-30) found "Level 62", "Best 16" and Play
    // underlined in yellow: the fallback style Text gets with no Material
    // above it.
    await pumpScreen(tester, host(won, []));
    await open(tester);
    for (final text in [
      'Level 62',
      '3 stars at 15 moves or fewer',
      'Best 16',
    ]) {
      final paragraph = tester.renderObject<RenderParagraph>(find.text(text));
      final decorations = <TextDecoration?>[];
      paragraph.text.visitChildren((InlineSpan span) {
        decorations.add(span.style?.decoration);
        return true;
      });
      expect(
        decorations.where((d) => d != null && d != TextDecoration.none),
        isEmpty,
        reason: text,
      );
    }
  });

  testWidgets('the stars are 40, 48 and 40 dp: earned filled, the rest the '
      'empty outline, never grey', (tester) async {
    await pumpScreen(tester, host(won, []));
    await open(tester);

    final stars = tester
        .widgetList<UiArtImage>(find.byType(UiArtImage))
        .toList();
    expect([for (final s in stars) s.size.width], [40, 48, 40]);
    expect(
      [for (final s in stars) s.art],
      [UiArt.starFilled, UiArt.starFilled, UiArt.starEmpty],
    );
  });

  testWidgets('a 3-star level has no target line', (tester) async {
    await pumpScreen(tester, host(won.copyWith(stars: 3), []));
    await open(tester);
    expect(find.textContaining('3 stars at'), findsNothing);
    expect(find.text('Best 16'), findsOneWidget);
  });

  testWidgets('a level won before best moves were kept has no Best chip, '
      'and one with no par no target', (tester) async {
    await pumpScreen(
      tester,
      host(
        const ChapterLevel(order: 5, status: ChapterLevelStatus.won, stars: 1),
        [],
      ),
    );
    await open(tester);
    expect(find.textContaining('Best'), findsNothing);
    expect(find.textContaining('3 stars at'), findsNothing);
    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('Play closes the card, then replays that level', (tester) async {
    final played = <PlayRequest>[];
    await pumpScreen(tester, host(won, played));
    await open(tester);

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    expect(played, [const PlayRequest.replay(62)]);
    expect(find.byType(LevelCard), findsNothing);
  });

  testWidgets('the close disc closes without playing, and is 48 dp', (
    tester,
  ) async {
    final played = <PlayRequest>[];
    await pumpScreen(tester, host(won, played));
    await open(tester);

    final close = find.byType(NestyCloseButton);
    expect(tester.getSize(close).shortestSide, greaterThanOrEqualTo(48));
    await tester.tap(close);
    await tester.pumpAndSettle();
    expect(played, isEmpty);
    expect(find.byType(LevelCard), findsNothing);
  });

  testWidgets('a level that cannot be played (locked) opens nothing', (
    tester,
  ) async {
    await pumpScreen(tester, host(const ChapterLevel(order: 70), []));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(LevelCard), findsNothing);
  });

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets('fits ${size.width.toInt()}×${size.height.toInt()} at '
          '$scale× text', (tester) async {
        await pumpScreen(tester, host(won, []), size: size, textScale: scale);
        await open(tester);
        await expectAccessibleLayout(tester);
      });
    }
  }
}
