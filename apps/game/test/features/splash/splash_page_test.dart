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
import 'package:nesty_render/nesty_render.dart' show DollPainter;

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
    bool reduceMotion = false,
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
      reduceMotion: reduceMotion,
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
    // The crossfade (240 ms) leaves only the art.
    await tester.pump(const Duration(milliseconds: 300));
    for (final doll in tester.widgetList<LottieDoll>(find.byType(LottieDoll))) {
      expect(doll.images, same(skin.images));
      expect(doll.renderer, same(skin.restRenderer));
    }
  });

  /// The shelf dolls that are drawing right now.
  List<LottieDoll> shelfDolls(WidgetTester tester) =>
      tester.widgetList<LottieDoll>(find.byType(LottieDoll)).toList();

  Finder shelfSwitchers() => find.ancestor(
    of: find.byType(LottieDoll),
    matching: find.byType(AnimatedSwitcher),
  );

  testWidgets('the placeholder dolls draw from the first frame and crossfade '
      'to the art once it lands (F-SPL, supersedes Q58)', (tester) async {
    final skins = ControlledSkinService();
    final showcase = ShowcaseDolls(skins, FakeDatabaseService());
    addTearDown(showcase.dispose);
    await pumpSplash(tester, showcase: showcase);
    // Skin null: three red placeholder dolls, no fade hiding them.
    expect(shelfDolls(tester), hasLength(3));
    for (final doll in shelfDolls(tester)) {
      expect(doll.images, isNull);
      expect(doll.color, DollColor.red);
    }
    expect(
      find.ancestor(
        of: find.byType(LottieDoll),
        matching: find.byType(AnimatedOpacity),
      ),
      findsNothing,
    );
    expect(shelfSwitchers(), findsNWidgets(3));
    final wordmarkSwitcher = find.descendant(
      of: find.byType(Wordmark),
      matching: find.byType(AnimatedSwitcher),
    );
    expect(wordmarkSwitcher, findsOneWidget);
    expect(
      find.descendant(of: wordmarkSwitcher, matching: find.byType(CustomPaint)),
      findsWidgets,
    );

    final prepared = showcase.prepare(devicePixelRatio: 1);
    final skin = skins.completeShowcase(0);
    await tester.runAsync(() => prepared);
    await tester.pump();
    // Mid-fade both the old and the new doll are mounted.
    expect(shelfDolls(tester).length, greaterThan(3));
    await tester.pump(const Duration(milliseconds: 240));
    await tester.pump(const Duration(milliseconds: 20));
    expect(shelfDolls(tester), hasLength(3));
    for (final doll in shelfDolls(tester)) {
      expect(doll.images, same(skin.images));
    }
  });

  testWidgets('the wordmark\'s perched doll has a real 30x45 box at 88 px '
      '(it collapsed to 0x0 under AnimatedSwitcher)', (tester) async {
    await pumpSplash(tester);
    final paint = find.descendant(
      of: find.descendant(
        of: find.byType(Wordmark),
        matching: find.byType(AnimatedSwitcher),
      ),
      matching: find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is DollPainter,
      ),
    );
    expect(paint, findsOneWidget);
    final box = tester.getSize(paint);
    expect(box.width, closeTo(30, 0.01));
    expect(box.height, closeTo(45, 0.01));
  });

  testWidgets('under reduce motion the art replaces the placeholder in one '
      'pump', (tester) async {
    final skins = ControlledSkinService();
    final showcase = ShowcaseDolls(skins, FakeDatabaseService());
    addTearDown(showcase.dispose);
    await pumpSplash(tester, showcase: showcase, reduceMotion: true);
    final prepared = showcase.prepare(devicePixelRatio: 1);
    final skin = skins.completeShowcase(0);
    await tester.runAsync(() => prepared);
    await tester.pump();
    await tester.pump();
    expect(shelfDolls(tester), hasLength(3));
    for (final doll in shelfDolls(tester)) {
      expect(doll.images, same(skin.images));
    }
  });

  testWidgets('a showcase whose art fails keeps the placeholder dolls', (
    tester,
  ) async {
    final skins = ControlledSkinService();
    final showcase = ShowcaseDolls(skins, FakeDatabaseService());
    addTearDown(showcase.dispose);
    await pumpSplash(tester, showcase: showcase);
    final prepared = showcase.prepare(devicePixelRatio: 1);
    skins.failShowcase(0);
    await tester.runAsync(() => prepared.catchError((Object _) {}));
    await tester.pump(const Duration(milliseconds: 300));
    expect(shelfDolls(tester), hasLength(3));
    for (final doll in shelfDolls(tester)) {
      expect(doll.images, isNull);
    }
  });

  testWidgets('with no showcase coming, the placeholder dolls show at once '
      '(rule 3)', (tester) async {
    await pumpSplash(tester);
    expect(shelfDolls(tester), hasLength(3));
  });

  group('the two errors (frames 12.10, 12.11; ErrorCard)', () {
    testWidgets('content: "The shelves didn\'t unpack", the inventory glyph, '
        'one Try again; the art stays under a dim and the loader hides', (
      tester,
    ) async {
      var retries = 0;
      await pumpSplash(
        tester,
        error: const AppException(AppExceptionKind.content, message: 'bundle'),
        onRetry: () => retries++,
      );
      expect(find.byType(ErrorCard), findsOneWidget);
      expect(find.text('The shelves didn’t unpack'), findsOneWidget);
      expect(
        find.text(
          'Something went wrong while loading. Try again, or restart\u00A0Nesty.',
        ),
        findsOneWidget,
      );
      expect(
        tester.widget<Icon>(find.byIcon(IconUses.contentError)).size,
        30,
        reason: 'the splash card\'s 56 dp disc holds a 30 dp glyph',
      );
      // The wordmark stays, dimmed; the loader and caption are gone.
      expect(find.byType(Wordmark), findsOneWidget);
      expect(find.text('Dusting the shelves…'), findsNothing);
      expect(find.byType(NestyProgressBar), findsNothing);
      expect(
        tester.widget<ColoredBox>(
          find.byWidgetPredicate(
            (w) => w is ColoredBox && w.color == SplashView.errorDim,
          ),
        ),
        isNotNull,
      );
      await tester.tap(find.text('Try again'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(retries, 1);
    });

    testWidgets('storage: "Your phone is nearly full", what to do, and the '
        'size Q157 defaults to', (tester) async {
      await pumpSplash(
        tester,
        error: const AppException(AppExceptionKind.storage, message: 'disk'),
      );
      expect(find.text('Your phone is nearly full'), findsOneWidget);
      expect(
        find.text(
          'Nesty needs about 60 MB to set up the shelves. Free some space, '
          'then try\u00A0again.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(IconUses.storageError), findsOneWidget);
    });

    testWidgets('the card sits at y 470 of the design, 28 in from each side', (
      tester,
    ) async {
      await pumpSplash(
        tester,
        error: const AppException(AppExceptionKind.storage, message: 'disk'),
      );
      final card = tester.getRect(find.byType(ErrorCard));
      expect(card.left, closeTo(28, 0.01));
      expect(card.right, closeTo(390 - 28, 0.01));
      expect(card.top, closeTo(470, 0.5));
    });

    testWidgets('the head is a live region and the card names the route', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpSplash(
        tester,
        error: const AppException(AppExceptionKind.content, message: 'x'),
      );
      final head = tester.getSemantics(find.text('The shelves didn’t unpack'));
      expect(head.flagsCollection.isHeader, isTrue);
      expect(head.getSemanticsData().flagsCollection.isLiveRegion, isTrue);
      handle.dispose();
    });

    for (final size in overflowScreenSizes) {
      for (final scale in textScales) {
        for (final kind in [
          AppExceptionKind.storage,
          AppExceptionKind.content,
        ]) {
          testWidgets(
            '${kind.name} fits ${size.width.toInt()}×${size.height.toInt()} '
            'at $scale× text',
            (tester) async {
              await pumpSplash(
                tester,
                error: AppException(kind, message: 'x'),
                size: size,
                textScale: scale,
              );
              await expectAccessibleLayout(tester);
            },
          );
        }
      }
    }
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
