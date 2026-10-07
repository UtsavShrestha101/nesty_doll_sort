import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/services/login_gift/login_gift_reward.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/home/cubit/home_cubit.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_chest_modal.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/login_gift/support/gift_harness.dart';
import '../features/support/screen_harness.dart';
import '../helpers/level_fixtures.dart';

/// Overflow suite for the daily gift (plan-login-gift section 7.5b): the
/// sheet in every state, Home's header with the gift button beside the gear,
/// and the Day 7 chest, at the overflow sizes of this run's locale and both
/// text scales. Behaviour is in `test/features/login_gift/`.
void main() {
  setUpAll(loadBundledFonts);

  // A long balance and big counts: the worst a tuned track could show.
  const wideTrack =
      '[{"coins":100000},{"coins":99999,"hints":99},{"hints":99,"slots":99},'
      '{"coins":40},{"coins":50},{"hints":1},'
      '{"coins":1000000,"hints":99,"slots":99}]';

  final yesterday = giftToday.addDays(-1);
  final states = <String, GiftRig Function()>{
    'ready (Day 1)': GiftRig.new,
    'ready, a tuned track with big counts': () => GiftRig(trackJson: wideTrack),
    'claimed today': () => GiftRig(
      progress: LoginGiftProgress(
        claims: 2,
        lastClaim: giftToday,
        latestSeen: giftToday,
      ),
    ),
    'claimed today, the tuned track': () => GiftRig(
      trackJson: wideTrack,
      progress: LoginGiftProgress(
        claims: 3,
        lastClaim: giftToday,
        latestSeen: giftToday,
      ),
    ),
    'waiting (clock back)': () => GiftRig(
      progress: LoginGiftProgress(
        claims: 2,
        lastClaim: giftToday.addDays(1),
        latestSeen: giftToday.addDays(1),
      ),
    ),
    'Day 7 is today': () => GiftRig(
      progress: LoginGiftProgress(
        claims: 6,
        lastClaim: yesterday,
        latestSeen: yesterday,
      ),
    ),
    'Day 7 claimed (the whole track done)': () => GiftRig(
      progress: LoginGiftProgress(
        claims: 7,
        lastClaim: giftToday,
        latestSeen: giftToday,
      ),
    ),
  };

  group('the gift sheet (frames 13.2-13.5)', () {
    for (final entry in states.entries) {
      for (final size in overflowScreenSizes) {
        for (final scale in textScales) {
          testWidgets(
            '${entry.key} fits ${size.width.toInt()}×${size.height.toInt()} '
            'at $scale× text',
            (tester) async {
              final rig = entry.value();
              await rig.pump(tester, size: size, textScale: scale);
              await openGiftSheet(tester);
              await expectAccessibleLayout(tester);
              await rig.dispose(tester);
            },
          );
        }
      }
    }
  });

  group("Home's header with the gift button (frame 13.1)", () {
    final homeStates = {
      'a Hard level': const HomeState(
        playRequest: PlayRequest.campaign(56),
        tier: Tier.hard,
        coins: 830,
        chapterNumber: 3,
        chapterId: 'ch03',
        dailyUnlocked: true,
      ),
      'a huge balance': const HomeState(
        playRequest: PlayRequest.campaign(188),
        tier: Tier.superhard,
        coins: 1234567,
        chapterNumber: 2,
        chapterId: 'ch02',
        dailyUnlocked: true,
      ),
    };
    final level = levelFrom(tutorialLevelJson);

    for (final entry in homeStates.entries) {
      for (final size in overflowScreenSizes) {
        for (final scale in textScales) {
          testWidgets(
            '${entry.key} fits ${size.width.toInt()}×${size.height.toInt()} '
            'at $scale× text',
            (tester) async {
              final rig = GiftRig();
              await pumpScreen(
                tester,
                Scaffold(
                  body: BlocProvider.value(
                    value: rig.cubit,
                    child: HomeView(
                      state: AsyncValue.data(data: entry.value),
                      onRetry: () {},
                      onPlay: (_) {},
                      onDaily: () {},
                      onMuseum: () {},
                      onShop: (_) {},
                      onSettings: () {},
                      library: FakeFxLibrary(),
                      levels: FakeLevelRepository(entries: [entryFor(level)]),
                    ),
                  ),
                ),
                size: size,
                textScale: scale,
              );
              await tester.runAsync(rig.cubit.load);
              await tester.pump();
              await expectAccessibleLayout(tester);
              // The wordmark stays centred with the button beside the gear.
              expect(
                tester.getCenter(find.byType(Wordmark)).dx,
                closeTo(size.width / 2, 1),
              );
              await rig.dispose(tester);
            },
          );
        }
      }
    }
  });

  group("Day 7's chest (frame 13.6)", () {
    for (final size in overflowScreenSizes) {
      for (final scale in textScales) {
        testWidgets(
          'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text',
          (tester) async {
            await pumpScreen(
              tester,
              Scaffold(
                body: GiftChestModal(
                  reward: const LoginGiftReward(coins: 1000, slots: 2),
                  library: FakeFxLibrary(),
                  onCoinsRevealed: (_) {},
                  onCollect: () {},
                ),
              ),
              size: size,
              textScale: scale,
            );
            await tester.pump(const Duration(milliseconds: 700));
            await expectAccessibleLayout(tester);
          },
        );
      }
    }
  });
}
