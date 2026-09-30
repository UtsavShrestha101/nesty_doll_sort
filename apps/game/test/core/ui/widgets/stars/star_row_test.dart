import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';

import '../../support/ui_harness.dart';

/// `StarRow`/`StarsTotal` (docs/plans/star-rating.md; docs/plans/m7-design.md
/// P3.7, P4.7; frames 11.1–11.3): the star art at rest, the `ui_stars`
/// reveal's timing (each segment's start, the flourish) and reduce motion
/// (Q146). The win overlay's own cue-playing wiring is
/// `test/features/gameplay/overlays/win_overlay_test.dart`. Without a
/// composition (`FakeFxLibrary`) the reveal draws its fallback stars, which
/// is what these read.
void main() {
  setUpAll(loadBundledFonts);

  Finder filled(int star) =>
      find.byKey(StarRow.fallbackKey(star, filled: true));
  Finder empty(int star) =>
      find.byKey(StarRow.fallbackKey(star, filled: false));

  group('StarRow (at rest)', () {
    testWidgets('counts 0–3, filled first, clamped beyond 3', (tester) async {
      for (final count in [0, 1, 2, 3, 5]) {
        await pumpUi(tester, StarRow(count: count));
        final shown = count.clamp(0, 3);
        for (var star = 1; star <= 3; star++) {
          expect(
            filled(star),
            star <= shown ? findsOneWidget : findsNothing,
            reason: 'star $star of $count',
          );
          expect(empty(star), star <= shown ? findsNothing : findsOneWidget);
        }
        expect(
          find.bySemanticsLabel(
            shown == 1 ? '1 of 3 stars' : '$shown of 3 stars',
          ),
          findsOneWidget,
        );
      }
    });

    testWidgets('the four sizes, and a larger middle star', (tester) async {
      expect(
        (StarRow.sizeWin, StarRow.sizeCard, StarRow.sizeCell),
        (44.0, 20.0, 11.0),
      );
      await pumpUi(tester, const StarRow(count: 1, size: StarRow.sizeCell));
      expect(tester.getSize(find.byType(StarRow)).height, StarRow.sizeCell);
      await pumpUi(tester, const StarRow(count: 3, size: 40, middleSize: 48));
      expect(tester.getSize(filled(1)).width, 40);
      expect(tester.getSize(filled(2)).width, 48);
      expect(tester.getSize(filled(3)).width, 40);
    });

    testWidgets('an unearned star is the empty art, never a grey fill', (
      tester,
    ) async {
      await pumpUi(tester, const StarRow(count: 1));
      // Every star is a UiArtImage: the art itself, empty or filled.
      expect(
        find.descendant(
          of: find.byType(StarRow),
          matching: find.byType(UiArtImage),
        ),
        findsNWidgets(3),
      );
      expect(
        find.descendant(
          of: find.byType(StarRow),
          matching: find.byType(CustomPaint),
        ),
        findsNothing,
      );
    });

    testWidgets('a new best says so to a screen reader', (tester) async {
      await pumpUi(
        tester,
        StarRow.reveal(count: 3, newBest: true, library: FakeFxLibrary()),
      );
      expect(find.bySemanticsLabel('New best, 3 of 3 stars'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });
  });

  group('StarRow.reveal', () {
    Widget reveal({
      int count = 3,
      Duration delay = Duration.zero,
      void Function(int)? onStar,
      VoidCallback? onFlourishEnd,
    }) => StarRow.reveal(
      count: count,
      delay: delay,
      onStar: onStar,
      onFlourishEnd: onFlourishEnd,
      library: FakeFxLibrary(),
    );

    testWidgets('is the ui_stars canvas, 240 × 110', (tester) async {
      await pumpUi(tester, reveal());
      expect(tester.getSize(find.byType(StarRow)), const Size(240, 110));
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('rests on three empty stars, then star_1…star_n start 333 '
        'ms apart from the delay, onStar 1-based in order', (tester) async {
      final landed = <int>[];
      await pumpUi(
        tester,
        reveal(
          count: 2,
          delay: const Duration(milliseconds: 500),
          onStar: landed.add,
        ),
      );
      for (var star = 1; star <= 3; star++) {
        expect(empty(star), findsOneWidget);
      }
      await tester.pump(const Duration(milliseconds: 499));
      expect(landed, isEmpty);

      await tester.pump(const Duration(milliseconds: 2));
      expect(landed, [1]);
      expect(filled(1), findsOneWidget);
      expect(empty(2), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 331));
      expect(landed, [1]);
      await tester.pump(const Duration(milliseconds: 3));
      expect(landed, [1, 2]);
      expect(filled(2), findsOneWidget);
      // The unearned third stays empty.
      expect(empty(3), findsOneWidget);
    });

    testWidgets('the flourish follows star 3 only, and its end fires '
        'onFlourishEnd once (1,000 ms later)', (tester) async {
      var ends = 0;
      await pumpUi(tester, reveal(onFlourishEnd: () => ends++));
      // Three segments (999.99 ms), then the flourish's 1,000 ms.
      await tester.pump(const Duration(milliseconds: 1990));
      expect(ends, 0);
      await tester.pump(const Duration(milliseconds: 20));
      expect(ends, 1);
      await tester.pump(const Duration(seconds: 3));
      expect(ends, 1);
    });

    testWidgets('no flourish below 3 stars', (tester) async {
      var ends = 0;
      await pumpUi(tester, reveal(count: 2, onFlourishEnd: () => ends++));
      await tester.pump(const Duration(seconds: 4));
      expect(ends, 0);
    });

    testWidgets('reduce motion (Q146): the last frame at once, onStar '
        'fires once for the highest star, no flourish', (tester) async {
      final landed = <int>[];
      var ends = 0;
      await pumpUi(
        tester,
        StarRow.reveal(
          count: 3,
          onStar: landed.add,
          onFlourishEnd: () => ends++,
          library: FakeFxLibrary(),
        ),
        reduceMotion: true,
      );
      await tester.pump(const Duration(milliseconds: 1));
      expect(landed, [3]);
      for (var star = 1; star <= 3; star++) {
        expect(filled(star), findsOneWidget);
      }
      await tester.pump(const Duration(seconds: 4));
      expect(landed, [3]);
      expect(ends, 0);
    });

    testWidgets('a win with no stars plays nothing', (tester) async {
      final landed = <int>[];
      await pumpUi(tester, reveal(count: 0, onStar: landed.add));
      await tester.pump(const Duration(seconds: 4));
      expect(landed, isEmpty);
    });
  });

  group('StarsTotal', () {
    testWidgets('one star art + "{earned}/{total}"', (tester) async {
      await pumpUi(tester, const StarsTotal(earned: 38, total: 60));
      expect(find.text('38/60'), findsOneWidget);
      expect(find.bySemanticsLabel('38 of 60 stars'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(StarsTotal),
          matching: find.byType(UiArtImage),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shown even at 0', (tester) async {
      await pumpUi(tester, const StarsTotal(earned: 0, total: 0));
      expect(find.text('0/0'), findsOneWidget);
    });
  });
}
