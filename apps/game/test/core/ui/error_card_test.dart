import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

import '../../features/support/screen_harness.dart';
import 'support/ui_harness.dart';

/// `ErrorCard` and `RetryView` (frames 12.6, 12.10, 12.11, 9.3f;
/// ui-spec-game §1 "ErrorCard"): the icon disc in two tones, the head, the
/// body, one primary and an optional text link with a 48 dp hit box.
void main() {
  setUpAll(loadBundledFonts);

  Widget card({
    ErrorCardTone tone = ErrorCardTone.warm,
    bool compact = false,
    String? secondary = 'Back to Home',
    VoidCallback? onPrimary,
    VoidCallback? onSecondary,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: ErrorCard(
      icon: IconUses.retry,
      tone: tone,
      compact: compact,
      title: 'The shelves need a moment',
      body: 'This level didn’t set up. Try again, or head back home.',
      primaryLabel: 'Try again',
      onPrimary: onPrimary ?? () {},
      secondaryLabel: secondary,
      onSecondary: onSecondary ?? () {},
    ),
  );

  testWidgets('the full card: a 96 disc with a 52 glyph, the head, the '
      'body, Try again and the text link', (tester) async {
    await pumpUi(tester, card());
    expect(find.text('The shelves need a moment'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);
    expect(tester.widget<Icon>(find.byIcon(IconUses.retry)).size, 52);
    final disc = tester.getSize(
      find
          .ancestor(
            of: find.byIcon(IconUses.retry),
            matching: find.byType(NestySurface),
          )
          .first,
    );
    expect(disc, const Size(96, 96));
  });

  testWidgets('the head balances its lines and the body never ends on one '
      'word (CSS balance and pretty, frames 12.6 and 12.10)', (tester) async {
    await pumpUi(tester, card());
    // 12.6: "The shelves / need a moment", not "The shelves need a / moment".
    final head = find.text('The shelves need a moment');
    final lines = tester.renderObject<RenderParagraph>(head);
    final box = lines.getBoxesForSelection(
      const TextSelection(baseOffset: 0, extentOffset: 25),
    );
    expect(box.map((b) => b.top.round()).toSet(), hasLength(2));
    final firstLine = box.where((b) => b.top.round() == box.first.top.round());
    final secondLine = box.where((b) => b.top.round() != box.first.top.round());
    double width(Iterable<TextBox> l) =>
        l.map((b) => b.right).reduce((a, b) => a > b ? a : b) -
        l.map((b) => b.left).reduce((a, b) => a < b ? a : b);
    expect((width(firstLine) - width(secondLine)).abs(), lessThan(60));
    expect(
      find.text('This level didn’t set up. Try again, or head back\u00A0home.'),
      findsOneWidget,
    );
    expect(bindLastWord('one'), 'one');
    expect(bindLastWord('a b c'), 'a b\u00A0c');
  });

  testWidgets('compact: a 56 disc with a 30 glyph (the splash\'s)', (
    tester,
  ) async {
    await pumpUi(tester, card(compact: true));
    expect(tester.widget<Icon>(find.byIcon(IconUses.retry)).size, 30);
    final disc = tester.getSize(
      find
          .ancestor(
            of: find.byIcon(IconUses.retry),
            matching: find.byType(NestySurface),
          )
          .first,
    );
    expect(disc, const Size(56, 56));
  });

  testWidgets('the warm and versus tones colour the disc and glyph', (
    tester,
  ) async {
    await pumpUi(tester, card());
    expect(
      tester.widget<Icon>(find.byIcon(IconUses.retry)).color,
      const Color(0xFFC4631E),
    );
    await pumpUi(tester, card(tone: ErrorCardTone.versus));
    expect(
      tester.widget<Icon>(find.byIcon(IconUses.retry)).color,
      AppColorTokens.versusEdge,
    );
    // Versus takes the versus button.
    final button = tester.widget<TactileButton>(find.byType(TactileButton));
    expect(button.variant, TactileButtonVariant.versus);
  });

  testWidgets('both buttons fire; the link\'s hit box is 48 dp', (
    tester,
  ) async {
    var primary = 0;
    var secondary = 0;
    await pumpUi(
      tester,
      card(onPrimary: () => primary++, onSecondary: () => secondary++),
    );
    await tester.tap(find.text('Try again'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.text('Back to Home'));
    await tester.pump(const Duration(milliseconds: 200));
    expect((primary, secondary), (1, 1));
    final hit = tester.getSize(
      find
          .ancestor(
            of: find.text('Back to Home'),
            matching: find.byType(ConstrainedBox),
          )
          .first,
    );
    expect(hit.height, greaterThanOrEqualTo(48));
  });

  testWidgets('without a link there is one call to action', (tester) async {
    await pumpUi(tester, card(secondary: null));
    expect(find.text('Back to Home'), findsNothing);
  });

  testWidgets('the head is a live header', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpUi(tester, card());
    final node = tester.getSemantics(find.text('The shelves need a moment'));
    expect(node.getSemanticsData().flagsCollection.isHeader, isTrue);
    expect(node.getSemanticsData().flagsCollection.isLiveRegion, isTrue);
    handle.dispose();
  });

  group('RetryView', () {
    testWidgets('storage and content say different things; neither shows '
        'the log message', (tester) async {
      var retries = 0;
      await pumpUi(
        tester,
        RetryView(
          exception: const AppException(
            AppExceptionKind.storage,
            message: 'secret detail',
          ),
          onRetry: () => retries++,
        ),
      );
      expect(find.text('Your phone is nearly full'), findsOneWidget);
      expect(find.textContaining('secret detail'), findsNothing);
      await tester.tap(find.text('Try again'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(retries, 1);

      await pumpUi(
        tester,
        RetryView(
          exception: const AppException(AppExceptionKind.unknown),
          onRetry: () {},
        ),
      );
      expect(find.text('The shelves didn’t unpack'), findsOneWidget);
    });
  });

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets(
        'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text',
        (tester) async {
          await pumpScreen(
            tester,
            Scaffold(body: SingleChildScrollView(child: card())),
            size: size,
            textScale: scale,
          );
          await expectAccessibleLayout(tester);
        },
      );
    }
  }
}
