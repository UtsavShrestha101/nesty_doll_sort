import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/daily/cubit/daily_cubit.dart';
import 'package:nesty_game/features/daily/widgets/daily_background_loader.dart';
import 'package:nesty_game/features/daily/widgets/daily_theme_background.dart';
import 'package:nesty_game/features/daily/widgets/puzzle_card.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/shop/widgets/skin_doll_row.dart';
import 'package:nesty_render/nesty_render.dart'
    show ChapterTheme, DollArt, DollSymbols;

import '../../core/ui/support/ui_harness.dart';
import '../support/controlled_skin_service.dart';
import '../support/screen_harness.dart';

/// A [DailyBackgroundLoader] the test completes by hand (the same
/// `Completer`-per-call pattern as `ControlledSkinService`'s showcase
/// requests), so no test here touches flutter_svg's real decode.
class _FakeDailyBackgroundLoader implements DailyBackgroundLoader {
  final List<({ChapterTheme theme, Size box, double devicePixelRatio})>
  requests = [];
  final List<Completer<ui.Image?>> _pending = [];

  @override
  Future<ui.Image?> rasterize(
    ChapterTheme theme, {
    required Size box,
    required double devicePixelRatio,
  }) {
    requests.add((theme: theme, box: box, devicePixelRatio: devicePixelRatio));
    final completer = Completer<ui.Image?>();
    _pending.add(completer);
    return completer.future;
  }

  /// A tiny synchronous image (`toImageSync`, never the async `toImage`
  /// hazard `museum_page_test.dart` documents), so completing it needs no
  /// `runAsync`.
  ui.Image _blankImage() {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder);
    return recorder.endRecording().toImageSync(1, 1);
  }

  ui.Image complete(int index) {
    final image = _blankImage();
    _pending[index].complete(image);
    return image;
  }

  void fail(int index) => _pending[index].complete(null);
}

/// The Daily puzzle card's preview (frame 5.1, NestyMenus `isDaily`
/// `dailyDolls`): today's colours drawn in the equipped skin's art through
/// `SkinService.prepareShowcase` + [SkinDollRow], at the frame's varied
/// heights; the procedural placeholder only when the skin can't be
/// prepared (FIDELITY-2; CLAUDE.md "Dolls render from the design skins").
void main() {
  setUpAll(loadBundledFonts);

  final today = LocalDate(2026, 9, 26);
  const fiveColors = [
    DollColor.purple,
    DollColor.yellow,
    DollColor.red,
    DollColor.teal,
    DollColor.pink,
  ];

  DailyState state(List<DollColor>? colors, {bool failed = false}) =>
      DailyState(
        status: DailyStatus(
          today: today,
          tier: Tier.hard,
          colors: colors?.length ?? 5,
          unlocked: true,
          streak: 4,
          cycleDone: 4,
        ),
        previewColors: colors,
        previewFailed: failed,
      );

  Widget card(
    SkinService skins,
    DailyState state, {
    DatabaseService? database,
    DailyBackgroundLoader? background,
  }) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<SkinService>.value(value: skins),
      RepositoryProvider<DatabaseService>.value(
        value: database ?? FakeDatabaseService(),
      ),
      RepositoryProvider<FxLibrary>.value(value: FakeFxLibrary()),
      RepositoryProvider<DailyBackgroundLoader>.value(
        value: background ?? _FakeDailyBackgroundLoader(),
      ),
    ],
    child: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: PuzzleCard(state: state, onPlay: () {}, onPlayCampaign: () {}),
      ),
    ),
  );

  SkinDollRow row(WidgetTester tester) =>
      tester.widget<SkinDollRow>(find.byType(SkinDollRow));

  testWidgets('today’s colours are prepared in the skin’s art and drawn at '
      'the frame’s heights (74/58/86/48/66)', (tester) async {
    final skins = ControlledSkinService();
    await pumpScreen(tester, card(skins, state(fiveColors)));

    expect(skins.showcaseRequests, hasLength(1));
    expect(skins.showcaseRequests.single.colors, fiveColors);
    expect(skins.showcaseRequests.single.symbols, DollSymbols.large);
    // Until the art is ready the preview spins; it never flashes the
    // placeholder dolls first.
    expect(find.byType(SkinDollRow), findsNothing);

    final art = skins.completeShowcase(0);
    await tester.pump();
    expect(row(tester).skin, same(art));
    expect(row(tester).colors, fiveColors);
    expect(row(tester).heights, const [74.0, 58.0, 86.0, 48.0, 66.0]);
  });

  testWidgets('a skin that can’t be prepared falls back to the placeholder '
      'dolls', (tester) async {
    final skins = ControlledSkinService();
    await pumpScreen(tester, card(skins, state(fiveColors)));
    skins.failShowcase(0);
    await tester.pump();
    expect(row(tester).skin, isNull);
    expect(row(tester).colors, fiveColors);
  });

  testWidgets('the Subtle symbols setting is what the preview bakes', (
    tester,
  ) async {
    final skins = ControlledSkinService();
    final database = FakeDatabaseService();
    await database.setSymbolsMode(SymbolsMode.subtle);
    await pumpScreen(
      tester,
      card(skins, state(fiveColors), database: database),
    );
    expect(skins.showcaseRequests.single.symbols, DollSymbols.subtle);
    skins.completeShowcase(0);
    await tester.pump();
    expect(row(tester).symbols, DollSymbols.subtle);
  });

  // D91: the Daily page stays under a level, whose Pause opens Settings.
  testWidgets('a Color symbols change prepares the preview again in the new '
      'mode and releases the old art', (tester) async {
    final skins = ControlledSkinService();
    final database = FakeDatabaseService();
    await pumpScreen(
      tester,
      card(skins, state(fiveColors), database: database),
    );
    final large = skins.completeShowcase(0);
    await tester.pump();
    expect(row(tester).skin, same(large));

    await database.setSymbolsMode(SymbolsMode.subtle);
    await tester.pump();
    expect(skins.showcaseRequests, hasLength(2));
    expect(skins.showcaseRequests.last.symbols, DollSymbols.subtle);
    expect(skins.showcaseRequests.last.colors, fiveColors);
    expect(large.disposed, isTrue);

    final subtle = skins.completeShowcase(1);
    await tester.pump();
    expect(row(tester).skin, same(subtle));
    expect(row(tester).symbols, DollSymbols.subtle);

    // The same mode again prepares nothing.
    await database.setSymbolsMode(SymbolsMode.subtle);
    await tester.pump();
    expect(skins.showcaseRequests, hasLength(2));
  });

  testWidgets('a new day’s colours prepare again and release the old art', (
    tester,
  ) async {
    final skins = ControlledSkinService();
    await pumpScreen(tester, card(skins, state(fiveColors)));
    final first = skins.completeShowcase(0);
    await tester.pump();

    const next = [DollColor.blue, DollColor.green, DollColor.orange];
    await pumpScreen(tester, card(skins, state(next)));
    expect(skins.showcaseRequests, hasLength(2));
    expect(skins.showcaseRequests.last.colors, next);
    final second = skins.completeShowcase(1);
    await tester.pump();
    expect(first.disposed, isTrue);
    expect(row(tester).skin, same(second));
    expect(row(tester).colors, next);
    expect(second.disposed, isFalse);
  });

  testWidgets('leaving the screen releases the art, even mid-prepare', (
    tester,
  ) async {
    final skins = ControlledSkinService();
    await pumpScreen(tester, card(skins, state(fiveColors)));
    final ready = skins.completeShowcase(0);
    await tester.pump();
    await pumpScreen(tester, card(skins, state(null)));
    expect(ready.disposed, isTrue);

    await pumpScreen(tester, card(skins, state(fiveColors)));
    await pumpScreen(tester, const SizedBox());
    final late = skins.completeShowcase(1);
    await tester.pump();
    expect(late.disposed, isTrue);
  });

  testWidgets('no colours yet: the spinner, and nothing asked', (tester) async {
    final skins = ControlledSkinService();
    await pumpScreen(tester, card(skins, state(null)));
    expect(skins.showcaseRequests, isEmpty);
    expect(find.byType(SkinDollRow), findsNothing);
  });

  // m7-design §18 "the Daily puzzle card's preview": the chapter background
  // under the plank (the `TODO(M7)` `puzzle_card.dart` carried, now fixed
  // by `DailyThemeBackground` + `DailyBackgroundLoader`).
  group('the theme background under the plank', () {
    testWidgets('asks for Seaside Market at the card\'s own box size, and '
        'paints the flat fallback colour until it lands', (tester) async {
      final skins = ControlledSkinService();
      final background = _FakeDailyBackgroundLoader();
      await pumpScreen(
        tester,
        card(skins, state(fiveColors), background: background),
      );
      expect(background.requests, hasLength(1));
      expect(background.requests.single.theme, ChapterTheme.ch03);
      expect(background.requests.single.box.height, 120);
      expect(background.requests.single.box.width, greaterThan(0));

      final backgroundState = tester.state<DailyThemeBackgroundState>(
        find.byType(DailyThemeBackground),
      );
      expect(backgroundState.image, isNull);

      final image = background.complete(0);
      await tester.pump();
      expect(backgroundState.image, same(image));
    });

    testWidgets('a background that fails to rasterize keeps the flat '
        'fallback colour (rule 3), and never throws', (tester) async {
      final skins = ControlledSkinService();
      final background = _FakeDailyBackgroundLoader();
      await pumpScreen(
        tester,
        card(skins, state(fiveColors), background: background),
      );
      background.fail(0);
      await tester.pump();
      final backgroundState = tester.state<DailyThemeBackgroundState>(
        find.byType(DailyThemeBackground),
      );
      expect(backgroundState.image, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the real Seaside Market SVG rasterizes to a non-null '
        'image (the fix\'s real asset, not just the fake)', (tester) async {
      const loader = AssetDailyBackgroundLoader();
      ui.Image? image;
      await tester.runAsync(() async {
        image = await loader.rasterize(
          ChapterTheme.ch03,
          box: const Size(320, 120),
          devicePixelRatio: 2,
        );
      });
      expect(image, isNotNull);
      expect(image!.width, greaterThan(0));
      expect(image!.height, greaterThan(0));
    });
  });

  for (final size in screenSizes) {
    testWidgets('six colours fit the ${size.width.toInt()}-wide preview '
        'without overlapping', (tester) async {
      final skins = ControlledSkinService();
      const six = [...fiveColors, DollColor.navy];
      await pumpScreen(tester, card(skins, state(six)), size: size);
      skins.completeShowcase(0);
      await tester.pump();
      final dolls = row(tester);
      expect(dolls.colors, six);
      final width = tester.getSize(find.byType(SkinDollRow)).width;
      final dollsWidth = dolls.heights.fold<double>(
        0,
        (sum, h) => sum + h * DollArt.width / DollArt.height,
      );
      expect(dolls.gap, greaterThanOrEqualTo(4));
      expect(
        dollsWidth + dolls.gap * (six.length - 1),
        lessThanOrEqualTo(width + 0.001),
      );
      expectNoLayoutErrors(tester);
    });
  }
}
