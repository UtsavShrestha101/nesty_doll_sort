import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/home/cubit/home_cubit.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/welcome_back/cubit/welcome_back_cubit.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';
import '../helpers/level_fixtures.dart';

/// Overflow suite for welcome back (plan-local-habits §1): Home with the
/// card, in each variant, at the overflow sizes of this run's locale and
/// both text scales. Behaviour is in `test/features/welcome_back/`.
void main() {
  setUpAll(loadBundledFonts);

  const home = HomeState(
    playRequest: PlayRequest.campaign(56),
    tier: Tier.hard,
    coins: 830,
    chapterNumber: 3,
    chapterId: 'ch03',
    dailyUnlocked: true,
  );
  final level = levelFrom(tutorialLevelJson);

  final variants = {
    'paused, a long streak': const WelcomeBackShown(
      variant: WelcomeBackVariant.paused,
      streak: 1234,
    ),
    'no streak yet': const WelcomeBackShown(
      variant: WelcomeBackVariant.newStreak,
      streak: 0,
    ),
    'freeze kept': const WelcomeBackShown(
      variant: WelcomeBackVariant.freezeKept,
      streak: 12,
    ),
    'plain': const WelcomeBackShown(
      variant: WelcomeBackVariant.plain,
      streak: 12,
    ),
  };

  for (final entry in variants.entries) {
    for (final size in overflowScreenSizes) {
      for (final scale in textScales) {
        testWidgets('Home with the card, ${entry.key}, fits '
            '${size.width.toInt()}×${size.height.toInt()} at $scale× text', (
          tester,
        ) async {
          await pumpScreen(
            tester,
            Scaffold(
              body: HomeView(
                state: const AsyncValue.data(data: home),
                onRetry: () {},
                onPlay: (_) {},
                onDaily: () {},
                onMuseum: () {},
                onShop: (_) {},
                onSettings: () {},
                library: FakeFxLibrary(),
                levels: FakeLevelRepository(entries: [entryFor(level)]),
                welcome: entry.value,
              ),
            ),
            size: size,
            textScale: scale,
          );
          await tester.pumpAndSettle();
          await expectAccessibleLayout(tester);
        });
      }
    }
  }
}
