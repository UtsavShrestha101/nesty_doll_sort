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
import 'package:nesty_game/features/daily/widgets/puzzle_card.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/shop/widgets/skin_doll_row.dart';
import 'package:nesty_render/nesty_render.dart' show DollArt, DollSymbols;

import '../../core/ui/support/ui_harness.dart';
import '../support/controlled_skin_service.dart';
import '../support/screen_harness.dart';

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
  }) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<SkinService>.value(value: skins),
      RepositoryProvider<DatabaseService>.value(
        value: database ?? FakeDatabaseService(),
      ),
      RepositoryProvider<FxLibrary>.value(value: FakeFxLibrary()),
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
    expect(skins.showcaseRequests.single.symbols, DollSymbols.subtle);
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

  testWidgets('the Large symbols setting is what the preview bakes', (
    tester,
  ) async {
    final skins = ControlledSkinService();
    final database = FakeDatabaseService();
    await database.setSymbolsMode(SymbolsMode.large);
    await pumpScreen(
      tester,
      card(skins, state(fiveColors), database: database),
    );
    expect(skins.showcaseRequests.single.symbols, DollSymbols.large);
    skins.completeShowcase(0);
    await tester.pump();
    expect(row(tester).symbols, DollSymbols.large);
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
