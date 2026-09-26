import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/dev/level_picker_sheet.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/overlays/all_levels_done.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';
import 'package:nesty_game/features/home/cubit/home_cubit.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/home/showcase/showcase_dolls.dart';

import '../../core/ui/support/ui_harness.dart';
import '../../helpers/level_fixtures.dart';
import '../../helpers/test_dependencies.dart';
import '../support/screen_harness.dart';

/// Frame 2.1's hero (spec §10.2 #2; m2-lottie-design §15): the coin pill,
/// the small wordmark, the gear (Settings is M3), five idling dolls under
/// twinkles, and PLAY with the level and its tier badge. The dev flavor
/// adds the level picker.
void main() {
  setUpAll(() async {
    await loadBundledFonts();
    // Tests run as the dev flavor (the picker is dev-only).
    FlavorConfig(flavor: Flavor.dev, values: testFlavorValues);
  });

  final level = levelFrom(tutorialLevelJson);
  FakeLevelRepository levels() => FakeLevelRepository(
    entries: [
      entryFor(level),
      entryFor(level, order: 2, tier: Tier.hard),
      entryFor(level, order: 3, tier: Tier.superhard, chapterId: 'ch02'),
    ],
  );

  Future<void> pumpHome(
    WidgetTester tester, {
    AsyncValue<HomeState> state = const AsyncValue.data(
      data: HomeState(currentLevel: 56, tier: Tier.hard, coins: 830),
    ),
    ValueChanged<int>? onPlay,
    VoidCallback? onRetry,
    FakeLevelRepository? repository,
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    await pumpScreen(
      tester,
      HomeView(
        state: state,
        onRetry: onRetry ?? () {},
        onPlay: onPlay ?? (_) {},
        library: FakeFxLibrary(),
        levels: repository,
      ),
      size: size,
      textScale: textScale,
    );
    await tester.pump();
  }

  testWidgets('frame 2.1: coins, wordmark, gear, five idle dolls, twinkles '
      'and PLAY with its level and tier', (tester) async {
    await pumpHome(tester);
    expect(find.text('830'), findsOneWidget);
    expect(find.byType(Wordmark), findsOneWidget);
    final gear = tester.widget<IconTactileButton>(
      find.byWidgetPredicate(
        (w) => w is IconTactileButton && w.semanticLabel == 'Settings',
      ),
    );
    expect(gear.onPressed, isNull, reason: 'Settings is M3');

    final dolls = tester.widgetList<LottieDoll>(find.byType(LottieDoll));
    expect(dolls.map((d) => d.color), [
      DollColor.orange,
      DollColor.green,
      DollColor.red,
      DollColor.blue,
      DollColor.purple,
    ]);
    expect(dolls.every((d) => d.id == FxId.dollIdle), isTrue);
    final speeds = dolls.map((d) => d.speed).toList();
    expect(speeds.every((s) => s >= 0.8 && s <= 1.2), isTrue);
    expect(speeds.toSet(), hasLength(5), reason: 'seeded, each its own');
    expect(find.byType(LottieTwinkle), findsNWidgets(4));

    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('Level 56'), findsOneWidget);
    expect(find.text('HARD'), findsOneWidget);
    expect(find.bySemanticsLabel('Play level 56, Hard'), findsOneWidget);
  });

  testWidgets('the same seeded shelf on every visit', (tester) async {
    await pumpHome(tester);
    final first = [
      for (final d in tester.widgetList<LottieDoll>(find.byType(LottieDoll)))
        (d.speed, d.phaseMs),
    ];
    await pumpScreen(tester, const SizedBox());
    await pumpHome(tester);
    final second = [
      for (final d in tester.widgetList<LottieDoll>(find.byType(LottieDoll)))
        (d.speed, d.phaseMs),
    ];
    expect(second, first);
  });

  testWidgets('PLAY opens the current level', (tester) async {
    final played = <int>[];
    await pumpHome(tester, onPlay: played.add);
    await tester.tap(find.text('Level 56'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(played, [56]);
  });

  testWidgets('every level won: PLAY names no level and shows All Levels '
      'Done (4.9, review FIDELITY-5)', (tester) async {
    final played = <int>[];
    await pumpHome(
      tester,
      state: const AsyncValue.data(
        data: HomeState(currentLevel: 31, levelCount: 30, allLevelsDone: true),
      ),
      onPlay: played.add,
    );
    expect(find.text('Level 31'), findsNothing);
    expect(find.text('PLAY'), findsOneWidget);
    expect(
      find.bySemanticsLabel("You've finished all levels!"),
      findsOneWidget,
    );
    await tester.tap(find.text('All done!'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(played, isEmpty);
    expect(find.byType(AllLevelsDone), findsOneWidget);
    expect(find.text("You've finished all levels!"), findsOneWidget);

    await tester.tap(find.text('Back to Home'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(AllLevelsDone), findsNothing);
  });

  testWidgets('the shelf keeps its art while a level covers Home, so the '
      'way back never flashes placeholder dolls (review FIDELITY-4)', (
    tester,
  ) async {
    final showcase = ShowcaseDolls(FakeSkinService(), FakeDatabaseService());
    addTearDown(showcase.dispose);
    await pumpScreen(
      tester,
      HomeView(
        state: const AsyncValue.data(data: HomeState()),
        onRetry: () {},
        onPlay: (_) {},
        library: FakeFxLibrary(),
        showcase: showcase,
      ),
    );
    await tester.pump();
    final art = showcase.current.value;
    expect(art, isNotNull);
    bool dollsHaveArt() => tester
        .widgetList<LottieDoll>(find.byType(LottieDoll, skipOffstage: false))
        .every((d) => identical(d.images, art!.images));
    expect(dollsHaveArt(), isTrue);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(
      navigator.push(MaterialPageRoute<void>(builder: (_) => const Scaffold())),
    );
    await tester.pumpAndSettle();
    expect(showcase.current.value, same(art), reason: 'kept while covered');

    navigator.pop();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(dollsHaveArt(), isTrue, reason: 'frame $i of the way back');
    }
    await tester.pumpAndSettle();
    expect(showcase.current.value, same(art));
  });

  testWidgets('a failed load offers a retry', (tester) async {
    var retries = 0;
    await pumpHome(
      tester,
      state: const AsyncValue.error(
        exception: AppException(AppExceptionKind.content, message: 'bundle'),
      ),
      onRetry: () => retries++,
    );
    expect(find.text('PLAY'), findsNothing);
    await tester.tap(find.text('Try again'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(retries, 1);
  });

  testWidgets('the dev flavor jumps to any level from the picker', (
    tester,
  ) async {
    final played = <int>[];
    await pumpHome(tester, onPlay: played.add, repository: levels());
    expect(LevelPickerSheet.isAvailable, isTrue);
    await tester.tap(find.text('Jump to a level'));
    await tester.pumpAndSettle();
    expect(find.byType(LevelPickerSheet), findsOneWidget);
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();
    expect(find.byType(LevelPickerSheet), findsNothing);
    expect(played, [2]);
  });

  testWidgets('no picker without the level list', (tester) async {
    await pumpHome(tester);
    expect(find.text('Jump to a level'), findsNothing);
  });

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets('fits ${size.width.toInt()}×${size.height.toInt()} at '
          '$scale× text', (tester) async {
        await pumpHome(
          tester,
          state: const AsyncValue.data(
            data: HomeState(
              currentLevel: 188,
              tier: Tier.superhard,
              coins: 1234567,
            ),
          ),
          repository: levels(),
          size: size,
          textScale: scale,
        );
        expectNoLayoutErrors(tester);
        final play = tester.getRect(find.byType(PlayButton));
        expect(play.left, greaterThanOrEqualTo(0));
        expect(play.right, lessThanOrEqualTo(size.width));
        expect(play.bottom, lessThanOrEqualTo(size.height));
      });
    }
  }
}
