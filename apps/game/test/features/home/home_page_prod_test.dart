import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/features/dev/level_picker_sheet.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/home/cubit/home_cubit.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';

import '../../core/ui/support/ui_harness.dart';
import '../../helpers/level_fixtures.dart';
import '../../helpers/test_dependencies.dart';
import '../support/screen_harness.dart';

/// The prod flavor has no "Jump to a level" (F-HOME, phase 5). Its own file
/// because `FlavorConfig` is process-wide and the first call wins: the dev
/// picker's tests live in `home_page_test.dart`, which sets the dev flavor.
void main() {
  setUpAll(() async {
    await loadBundledFonts();
    FlavorConfig(flavor: Flavor.prod, values: testFlavorValues);
  });

  testWidgets('prod: no level picker, even with the level list in hand', (
    tester,
  ) async {
    final level = levelFrom(tutorialLevelJson);
    await pumpScreen(
      tester,
      HomeView(
        state: const AsyncValue.data(
          data: HomeState(
            playRequest: PlayRequest.campaign(56),
            tier: Tier.hard,
            coins: 830,
          ),
        ),
        onRetry: () {},
        onPlay: (_) {},
        onDaily: () {},
        onMuseum: () {},
        onChapters: () {},
        onRecords: () {},
        onVsComputer: () {},
        onShop: (_) {},
        onSettings: () {},
        library: FakeFxLibrary(),
        levels: FakeLevelRepository(entries: [entryFor(level)]),
      ),
    );
    await tester.pump();

    expect(LevelPickerSheet.isAvailable, isFalse);
    expect(find.text('Jump to a level'), findsNothing);
    expect(find.text('PLAY'), findsOneWidget, reason: 'the page is up');
  });
}
