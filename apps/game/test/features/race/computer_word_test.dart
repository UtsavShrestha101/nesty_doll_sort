import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';
import 'package:nesty_game/features/home/cubit/home_cubit.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/race/cubit/race_cubit.dart';
import 'package:nesty_game/features/race/widgets/rival_strip.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

import '../../core/ui/support/ui_harness.dart';
import '../../helpers/test_dependencies.dart';
import '../support/screen_harness.dart';

/// D192 and spec-prop §1.1 rule 5: "A computer opponent is always labelled a
/// computer". At 360 dp and wider and up to 1.3x text, in every locale, the
/// localized word shows and nothing overflows: on the rival strip the tag
/// keeps its word for every rival with 8 families, all text readable (the
/// strip makes room, D271); on the Home vs Computer tile and the race Pause
/// header the label ("vs Computer…") carries it, so their tag may fall to
/// its glyph (5C ethics).
void main() {
  setUpAll(() async {
    await loadBundledFonts();
    FlavorConfig(flavor: Flavor.dev, values: testFlavorValues);
  });

  const sizes = [
    (Size(360, 640), 1.0),
    (Size(360, 640), 1.3),
    (Size(390, 844), 1.0),
    (Size(390, 844), 1.3),
  ];

  for (final locale in AppLocalizations.supportedLocales) {
    final word = lookupAppLocalizations(locale).raceComputerTag;
    for (final (size, scale) in sizes) {
      final where =
          '${locale.toLanguageTag()} at ${size.width.toInt()} dp, '
          '${scale}x';

      for (final rival in [1, 2, 3]) {
        testWidgets('$where: the strip shows "$word" (rival $rival)', (
          tester,
        ) async {
          await pumpUi(
            tester,
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 76, right: 16),
                child: RivalStripView(
                  data: (
                    rival: rival,
                    activity: RivalActivity.thinking,
                    rivalSets: 1,
                    totalSets: 8,
                    rivalMoves: 0,
                    held: false,
                    over: false,
                  ),
                ),
              ),
            ),
            width: size.width,
            height: size.height,
            textScale: scale,
            locale: locale,
          );
          expect(tester.takeException(), isNull);
          expect(find.text(word), findsOneWidget);
          expectReadableText(tester);
          expectNoCutText(tester);
        });
      }

      testWidgets('$where: the Home tile shows "$word"', (tester) async {
        await pumpScreen(
          tester,
          HomeView(
            state: const AsyncValue.data(
              data: HomeState(
                playRequest: PlayRequest.campaign(21),
                raceUnlockLevel: 20,
                raceUnlocked: true,
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
          ),
          size: size,
          textScale: scale,
          locale: locale,
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.textContaining(word), findsWidgets);
      });

      testWidgets('$where: the Pause header shows "$word"', (tester) async {
        await pumpScreen(
          tester,
          PauseDialog(
            race: const RacePauseInfo(rival: 2),
            settings: const PauseSettings(
              sound: true,
              music: true,
              haptics: true,
            ),
            library: FakeFxLibrary(),
            onSoundChanged: (_) {},
            onMusicChanged: (_) {},
            onHapticsChanged: (_) {},
            onResume: () {},
            onRestart: () {},
            onSettings: () {},
            onLeaveRace: () {},
          ),
          size: size,
          textScale: scale,
          locale: locale,
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
        expect(find.textContaining(word), findsWidgets);
      });
    }
  }
}
