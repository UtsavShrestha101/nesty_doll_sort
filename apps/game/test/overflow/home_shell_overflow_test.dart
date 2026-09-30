import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/home/cubit/home_cubit.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/home/widgets/home_chapter_card.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';
import '../helpers/level_fixtures.dart';

/// M7 overflow suite (m7-design §18 "overflow"): the bottom-nav shell's own
/// chrome (`NestyBottomNav`, frame 2.1) and Home (frame 2.1's hero) at the
/// five acceptance sizes and both text scales.
///
/// The shell is pumped through its chrome directly rather than through the
/// full `App`/router (as `test/features/shell/main_shell_page_test.dart`
/// does over `configureTestDependencies()`): the gameplay-bloc lane's E9
/// ("first launch opens Level 1") changes what a fresh fake save's splash
/// opens to, which would make a full-`App` pump land on a level instead of
/// Home depending on lane-landing order. `NestyBottomNav` and `HomeView` are
/// both plain, cubit-free widgets (the same pattern
/// `test/features/home/home_page_test.dart` already uses), so this suite
/// stays deterministic regardless of that other lane's timing.
void main() {
  setUpAll(loadBundledFonts);

  Future<void> pumpShell(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1,
  }) => pumpScreen(
    tester,
    Scaffold(
      bottomNavigationBar: NestyBottomNav(
        items: const [
          NestyBottomNavItem(icon: NestyIcons.storefront, label: 'Shop'),
          NestyBottomNavItem(icon: NestyIcons.home, label: 'Home'),
          NestyBottomNavItem(icon: NestyIcons.museum, label: 'Museum'),
        ],
        selectedIndex: 1,
        onChanged: (_) {},
      ),
      body: const SizedBox.expand(),
    ),
    size: size,
    textScale: textScale,
  );

  final level = levelFrom(tutorialLevelJson);

  /// Home's states (frames 2.1, 12.1-12.3, 9.1): the worst-case long chapter
  /// name and star total, Bonus Endless, a new player's locked tiles, the
  /// race unlocked, ads removed (two wide tiles) and every streak look.
  final states = <String, HomeState>{
    'a Hard level, chapter 3 (2.1)': const HomeState(
      playRequest: PlayRequest.campaign(56),
      tier: Tier.hard,
      coins: 830,
      chapterNumber: 3,
      chapterId: 'ch03',
      chapterStars: 39,
      chapterStarsPossible: 60,
      dailyUnlocked: true,
      dailyStreak: 4,
      dailyLit: true,
      raceUnlocked: true,
    ),
    'the worst case: a long name, 3 digit level, a huge balance (12.1)':
        const HomeState(
          playRequest: PlayRequest.campaign(188),
          tier: Tier.superhard,
          coins: 1234567,
          chapterNumber: 2,
          chapterId: 'ch02',
          chapterStars: 60,
          chapterStarsPossible: 60,
          dailyUnlocked: true,
          dailyStreak: 132,
          dailyLit: true,
          raceUnlocked: true,
          museumDone: 15,
        ),
    'Bonus Endless (12.2)': const HomeState(
      playRequest: PlayRequest.bonus(777),
      coins: 6420,
      chapterNumber: 10,
      chapterId: 'ch10',
      isBonus: true,
      chapterStars: 552,
      chapterStarsPossible: 600,
      dailyUnlocked: true,
      raceUnlocked: true,
    ),
    'a new player, Daily and vs Computer locked (12.3, 9.1)': const HomeState(
      playRequest: PlayRequest.campaign(2),
      coins: 10,
      chapterStars: 3,
      chapterStarsPossible: 60,
    ),
    'ads removed: two wide tiles': const HomeState(
      playRequest: PlayRequest.campaign(21),
      adsRemoved: true,
      dailyUnlocked: true,
      dailyStreak: 9,
      raceUnlocked: true,
    ),
    'a paused streak': const HomeState(
      playRequest: PlayRequest.campaign(21),
      dailyUnlocked: true,
      dailyStreak: 9,
    ),
    'a relit streak': const HomeState(
      playRequest: PlayRequest.campaign(21),
      dailyUnlocked: true,
      dailyStreak: 9,
      dailyLit: true,
      streakRelit: true,
    ),
  };

  Future<void> pumpHome(
    WidgetTester tester,
    HomeState state, {
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    // Inside a shell with its bottom nav, so the body is the real one: the
    // 390×844 frame's 738 to the nav, a shorter phone's less (frame 2.1b).
    await pumpScreen(
      tester,
      Scaffold(
        bottomNavigationBar: NestyBottomNav(
          items: const [
            NestyBottomNavItem(icon: NestyIcons.storefront, label: 'Shop'),
            NestyBottomNavItem(icon: NestyIcons.home, label: 'Home'),
            NestyBottomNavItem(icon: NestyIcons.museum, label: 'Museum'),
          ],
          selectedIndex: 1,
          onChanged: (_) {},
        ),
        body: HomeView(
          state: AsyncValue.data(data: state),
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
      size: size,
      textScale: textScale,
    );
    await tester.pump();
  }

  group('the bottom-nav shell (frame 2.1)', () {
    for (final size in overflowScreenSizes) {
      for (final scale in textScales) {
        testWidgets(
          'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text',
          (tester) async {
            await pumpShell(tester, size: size, textScale: scale);
            await expectAccessibleLayout(tester);
            for (final label in ['Shop', 'Home', 'Museum']) {
              expect(find.text(label), findsOneWidget, reason: label);
            }
          },
        );
      }
    }
  });

  group('Home (frames 2.1, 2.1b, 12.1-12.3, 9.1)', () {
    for (final entry in states.entries) {
      for (final size in overflowScreenSizes) {
        for (final scale in textScales) {
          testWidgets(
            '${entry.key} fits ${size.width.toInt()}×${size.height.toInt()} '
            'at $scale× text',
            (tester) async {
              await pumpHome(tester, entry.value, size: size, textScale: scale);
              await expectAccessibleLayout(tester);
              final play = tester.getRect(find.byType(PlayButton));
              expect(play.left, greaterThanOrEqualTo(0));
              expect(play.right, lessThanOrEqualTo(size.width));
              // PLAY stays clear of the tiles under it and the card above.
              final tiles = tester.getRect(find.byType(HomeTile).first);
              expect(play.bottom, lessThanOrEqualTo(tiles.top));
              final card = tester.getRect(find.byType(HomeChapterCard));
              expect(card.bottom, lessThanOrEqualTo(play.top));
              expect(card.left, greaterThanOrEqualTo(0));
              final records = tester.getRect(find.byType(HomeRecordsButton));
              expect(records.right, lessThanOrEqualTo(size.width));
              expect(records.left, greaterThanOrEqualTo(card.right));
            },
          );
        }
      }
    }
  });
}
