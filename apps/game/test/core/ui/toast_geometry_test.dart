import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

import 'support/ui_harness.dart';

/// m7-4 1.5 (tokens.json `toast`): the app toast sits 4 dp under the safe
/// top with its own geometry; an in-place toast keeps its design y; the
/// pill is the 7.10 shape.
void main() {
  setUpAll(loadBundledFonts);

  Future<ToastQueue> pumpHost(
    WidgetTester tester, {
    required bool app,
    double safeTop = 47,
    double top = ToastHost.boardTop,
    double textScale = 1,
    bool screenReader = false,
  }) async {
    late BuildContext inner;
    await pumpUi(
      tester,
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: EdgeInsets.only(top: safeTop),
            accessibleNavigation: screenReader,
          ),
          child: app
              ? ToastHost.app(
                  child: Builder(
                    builder: (c) {
                      inner = c;
                      return const SizedBox.expand();
                    },
                  ),
                )
              : ToastHost(
                  top: top,
                  child: Builder(
                    builder: (c) {
                      inner = c;
                      return const SizedBox.expand();
                    },
                  ),
                ),
        ),
      ),
      textScale: textScale,
    );
    return ToastHost.maybeOf(inner)!;
  }

  testWidgets('the app toast: top safe + 4, side 16, 40 dp disc, 26 dp glyph, '
      '17 / 13 text, radius 22', (tester) async {
    final queue = await pumpHost(tester, app: true);
    queue.enqueue(
      const ToastSpec(
        tone: ToastTone.info,
        icon: NestyIcons.acUnit,
        title: 'Streak saved!',
        message: 'A freeze covered Friday.',
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 300));
    final card = find.byType(ToastCard);
    final rect = tester.getRect(card);
    expect(rect.top, closeTo(47 + ToastLayoutTokens.appTopBelowSafeTop, 0.5));
    expect(rect.left, ToastLayoutTokens.appSide);
    expect(rect.right, 390 - ToastLayoutTokens.appSide);
    expect(tester.widget<ToastCard>(card).placement, ToastPlacement.app);
    final disc = find.byWidgetPredicate(
      (w) => w is SizedBox && w.width == 40 && w.height == 40,
    );
    expect(disc, findsOneWidget);
    final decoration =
        tester
                .widget<DecoratedBox>(
                  find.descendant(
                    of: disc,
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .decoration
            as BoxDecoration;
    expect(decoration.gradient, ToastLayoutTokens.appIconDiscInfo);
    expect(tester.widget<Icon>(find.byType(Icon)).size, 26);
    final title = tester.widget<Text>(find.text('Streak saved!'));
    expect(title.style!.fontSize, 17);
    expect(title.style!.height, 1.1);
    expect(title.style!.color, AppColors.infoTitle);
    final message = tester.widget<Text>(find.text('A freeze covered Friday.'));
    expect(message.style!.fontSize, 13);
    expect(message.style!.color, AppColors.infoText);
    // The icon's left edge is the padding (12) in; the text starts 12 after
    // the 40 dp disc.
    expect(tester.getTopLeft(disc).dx - rect.left, 12);
    expect(
      tester.getTopLeft(find.text('Streak saved!')).dx -
          tester.getTopRight(disc).dx,
      12,
    );
    queue.clear();
    await tester.pump();
  });

  testWidgets('T1: a toast stays 2.5 s for sighted play and 10 s while a '
      'screen reader is on', (tester) async {
    const spec = ToastSpec(
      tone: ToastTone.badge,
      title: 'Badge earned · Snug as a Doll',
    );
    for (final reader in [false, true]) {
      final queue = await pumpHost(tester, app: false, screenReader: reader);
      queue.enqueue(spec);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(spec.title), findsOneWidget);
      // 3 s in: gone for sighted play (after its fade), up for a reader.
      await tester.pump(const Duration(milliseconds: 2650));
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        find.text(spec.title),
        reader ? findsOneWidget : findsNothing,
        reason: 'screenReader=$reader',
      );
      await tester.pump(const Duration(seconds: 8));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(spec.title), findsNothing);
      queue.clear();
      await tester.pump();
    }
  });

  testWidgets('the success app toast reads its green ink and flat disc', (
    tester,
  ) async {
    final queue = await pumpHost(tester, app: true);
    queue.enqueue(
      const ToastSpec(
        tone: ToastTone.success,
        icon: NestyIcons.check,
        title: 'Purchases restored',
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 300));
    final title = tester.widget<Text>(find.text('Purchases restored'));
    expect(title.style!.color, AppColors.successToastTitle);
    final disc = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 40 && w.height == 40,
        ),
        matching: find.byType(DecoratedBox),
      ),
    );
    expect(
      (disc.decoration as BoxDecoration).color,
      AppColorTokens.toastSuccessAccent,
    );
    queue.clear();
    await tester.pump();
  });

  testWidgets('an in-place toast keeps its design y (152 on a 59 dp safe '
      'area), side 20, 32 dp disc and 15 / 12 text', (tester) async {
    final queue = await pumpHost(tester, app: false, safeTop: 59);
    queue.enqueue(
      const ToastSpec(
        tone: ToastTone.warning,
        icon: NestyIcons.sentimentNeutral,
        title: 'Hmm, this looks stuck',
        message: 'Try Restart?',
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 300));
    final card = find.byType(ToastCard);
    final rect = tester.getRect(card);
    expect(rect.top, closeTo(152, 0.5));
    expect(rect.left, ToastLayoutTokens.inPlaceSide);
    expect(tester.widget<ToastCard>(card).placement, ToastPlacement.inPlace);
    expect(tester.widget<Icon>(find.byType(Icon)).size, 20);
    final title = tester.widget<Text>(find.text('Hmm, this looks stuck'));
    expect(title.style!.fontSize, 15);
    expect(title.style!.color, AppColorTokens.textPrimary);
    expect(tester.widget<Text>(find.text('Try Restart?')).style!.fontSize, 12);
    queue.clear();
    await tester.pump();
  });

  testWidgets('the app toast fits two lines at 1.3x on a narrow phone', (
    tester,
  ) async {
    final queue = await pumpHost(tester, app: true, textScale: 1.3);
    queue.enqueue(
      const ToastSpec(
        tone: ToastTone.info,
        icon: NestyIcons.acUnit,
        title: 'Streak saved!',
        message: 'A freeze covered Friday. You will earn a new one next week.',
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
    queue.clear();
    await tester.pump();
  });

  testWidgets('ToastPill is the 7.10 shape: radius 24, 32 dp disc, 15 text', (
    tester,
  ) async {
    await pumpUi(
      tester,
      const Center(
        child: ToastPill(icon: NestyIcons.check, text: 'Ads removed'),
      ),
    );
    final text = tester.widget<Text>(find.text('Ads removed'));
    expect(text.style!.fontSize, 15);
    expect(text.style!.fontWeight, FontWeight.w700);
    expect(
      find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == 32 && w.height == 32,
      ),
      findsOneWidget,
    );
    final surface = tester.widget<NestySurface>(find.byType(NestySurface));
    expect(surface.style.color, ToastLayoutTokens.pillFace);
  });
}
