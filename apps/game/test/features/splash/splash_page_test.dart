import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';
import 'package:nesty_game/features/home/showcase/showcase_dolls.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';

import '../../core/ui/support/ui_harness.dart';
import '../support/controlled_skin_service.dart';
import '../support/lottie_library.dart';
import '../support/screen_harness.dart';

/// Frame 1.1 (spec §10.2 #1; m2-lottie-design §15): the wordmark, the
/// "DOLL SORT" chip, three idling cherry dolls, `ui_splash_loader` on the
/// real load progress, and the caption. The route itself (load → Home) is
/// covered by `test/app_flow_test.dart`.
void main() {
  setUpAll(loadBundledFonts);

  Future<void> pumpSplash(
    WidgetTester tester, {
    double progress = 0.4,
    AppException? error,
    VoidCallback? onRetry,
    FakeFxLibrary? library,
    ShowcaseDolls? showcase,
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    await pumpScreen(
      tester,
      SplashView(
        progress: progress,
        error: error,
        onRetry: onRetry ?? () {},
        library: library ?? FakeFxLibrary(),
        showcase: showcase,
      ),
      size: size,
      textScale: textScale,
    );
    await tester.pump();
  }

  SemanticsData loaderSemantics(WidgetTester tester) =>
      tester.getSemantics(find.bySemanticsLabel('Loading…')).getSemanticsData();

  testWidgets('frame 1.1: the wordmark, DOLL SORT, three cherry dolls, the '
      'loader and its caption', (tester) async {
    await pumpSplash(tester);
    expect(find.byType(Wordmark), findsOneWidget);
    expect(find.text('DOLL SORT'), findsOneWidget);
    expect(find.text('Dusting the shelves…'), findsOneWidget);
    final dolls = tester.widgetList<LottieDoll>(find.byType(LottieDoll));
    expect(dolls, hasLength(3));
    for (final doll in dolls) {
      expect(doll.id, FxId.dollIdle);
      expect(doll.color, DollColor.red);
    }
    expect(loaderSemantics(tester).value, '40%');
  });

  testWidgets('without its file the loader is the striped bar (rule 3)', (
    tester,
  ) async {
    await pumpSplash(tester, progress: 0.25);
    final bar = tester.widget<NestyProgressBar>(find.byType(NestyProgressBar));
    expect(bar.value, 0.25);
    expect(bar.striped, isTrue);
  });

  testWidgets('ui_splash_loader follows the progress and never plays', (
    tester,
  ) async {
    final library = (await tester.runAsync(widgetLottieLibrary))!;
    await pumpSplash(tester, progress: 0.25, library: library);
    expect(find.byType(NestyProgressBar), findsNothing);
    final view = tester.widget<LottieFxView>(
      find.byWidgetPredicate(
        (w) => w is LottieFxView && w.id == FxId.uiSplashLoader,
      ),
    );
    final controller = view.controller!;
    expect(controller.player.frame, closeTo(25, 1e-9));
    expect(controller.isPlaying, isFalse);

    await pumpSplash(tester, progress: 0.9, library: library);
    expect(controller.player.frame, closeTo(90, 1e-9));
    expect(loaderSemantics(tester).value, '90%');
    expect(tester.takeException(), isNull);
  });

  testWidgets('the shelf dolls use the prepared art once it lands', (
    tester,
  ) async {
    final skins = ControlledSkinService();
    final showcase = ShowcaseDolls(skins, FakeDatabaseService());
    addTearDown(showcase.dispose);
    await pumpSplash(tester, showcase: showcase);
    expect(
      tester.widget<LottieDoll>(find.byType(LottieDoll).first).images,
      isNull,
    );
    final prepared = showcase.prepare(devicePixelRatio: 1);
    final skin = skins.completeShowcase(0);
    await tester.runAsync(() => prepared);
    await tester.pump();
    for (final doll in tester.widgetList<LottieDoll>(find.byType(LottieDoll))) {
      expect(doll.images, same(skin.images));
      expect(doll.renderer, same(skin.restRenderer));
    }
  });

  /// The fade around each shelf doll, in shelf order.
  List<double> shelfOpacities(WidgetTester tester) => tester
      .widgetList<AnimatedOpacity>(
        find.byWidgetPredicate(
          (w) => w is AnimatedOpacity && w.child is LottieDoll,
        ),
      )
      .map((fade) => fade.opacity)
      .toList();

  testWidgets('the dolls wait for the prepared art and fade in, instead of '
      'flashing the placeholder first (Q58)', (tester) async {
    final skins = ControlledSkinService();
    final showcase = ShowcaseDolls(skins, FakeDatabaseService());
    addTearDown(showcase.dispose);
    await pumpSplash(tester, showcase: showcase);
    expect(shelfOpacities(tester), [0, 0, 0]);
    expect(tester.widget<Wordmark>(find.byType(Wordmark)).dollShown, isFalse);

    final prepared = showcase.prepare(devicePixelRatio: 1);
    skins.completeShowcase(0);
    await tester.runAsync(() => prepared);
    await tester.pump();
    expect(shelfOpacities(tester), [1, 1, 1]);
    expect(tester.widget<Wordmark>(find.byType(Wordmark)).dollShown, isTrue);
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('with no showcase coming, the placeholder dolls show at once '
      '(rule 3)', (tester) async {
    await pumpSplash(tester);
    expect(shelfOpacities(tester), [1, 1, 1]);
    expect(tester.widget<Wordmark>(find.byType(Wordmark)).dollShown, isTrue);
  });

  testWidgets('offline content that failed to load offers a retry', (
    tester,
  ) async {
    var retries = 0;
    await pumpSplash(
      tester,
      error: const AppException(AppExceptionKind.content, message: 'bundle'),
      onRetry: () => retries++,
    );
    expect(find.byType(RetryView), findsOneWidget);
    expect(find.text('DOLL SORT'), findsNothing);
    await tester.tap(find.text('Try again'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(retries, 1);
  });

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets('fits ${size.width.toInt()}×${size.height.toInt()} at '
          '$scale× text', (tester) async {
        await pumpSplash(tester, size: size, textScale: scale);
        expectNoLayoutErrors(tester);
        // The caption stays on screen.
        final caption = tester.getRect(find.text('Dusting the shelves…'));
        expect(caption.bottom, lessThanOrEqualTo(size.height));
        expect(caption.left, greaterThanOrEqualTo(0));
        expect(caption.right, lessThanOrEqualTo(size.width));
      });
    }
  }
}
