import 'dart:ui' as ui show Image;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fake_level_resolver.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/daily/fake_daily_service.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/music/fake_music_service.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/services/notifications/fake_notification_service.dart';
import 'package:nesty_game/core/services/notifications/notification_service.dart';
import 'package:nesty_game/core/services/reminder/daily_reminder.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/share/fake_share_service.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/services/system_settings/fake_system_settings_service.dart';
import 'package:nesty_game/features/daily/cubit/daily_cubit.dart';
import 'package:nesty_game/features/daily/cubit/reminder_offer_cubit.dart';
import 'package:nesty_game/features/daily/pages/daily_page.dart';
import 'package:nesty_game/features/daily/widgets/daily_background_loader.dart';
import 'package:nesty_game/features/daily/widgets/daily_chest_modal.dart';
import 'package:nesty_game/features/daily/widgets/reminder_offer_dialog.dart';
import 'package:nesty_game/features/fx/chest/chest_reward_sequence.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_render/nesty_render.dart' show ChapterTheme;

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';

/// A [DailyBackgroundLoader] that never produces art: `DailyThemeBackground`
/// keeps its flat fallback colour (its own rule 3), so this suite never
/// touches a real SVG decode (the same reason `puzzle_card_test.dart` fakes
/// this loader).
final class _NoDailyBackground implements DailyBackgroundLoader {
  @override
  Future<ui.Image?> rasterize(
    ChapterTheme theme, {
    required Size box,
    required double devicePixelRatio,
  }) async => null;
}

/// M7 overflow suite (m7-design §18 "overflow"): Daily (frames 5.1-5.6) in
/// every state, and its day-7 chest modal, at the five acceptance sizes and
/// both text scales. Behaviour is covered by `test/features/daily/
/// daily_page_test.dart` and `daily_chest_modal_test.dart`; this file only
/// sweeps the wider size/scale grid, following the same real-`DailyCubit`
/// pattern over a scripted `FakeDailyService`.
void main() {
  setUpAll(loadBundledFonts);

  final today = LocalDate(2026, 9, 26);

  // Lit unless a state is about the paused look: `DailyStatus.lit`
  // defaults to false, which with a streak reads as paused (m7-design §8).
  DailyStatus status({
    bool unlocked = true,
    int streak = 12,
    bool lit = true,
    int freezes = 1,
    bool solvedToday = false,
    int cycleDone = 4,
    bool chestPending = false,
    LocalDate? freezeNotice,
    DailySolve? solve,
  }) => DailyStatus(
    today: today,
    tier: Tier.superhard,
    colors: 5,
    unlocked: unlocked,
    streak: streak,
    lit: lit,
    run: lit ? streak : 0,
    freezes: freezes,
    solvedToday: solvedToday,
    cycleDone: cycleDone,
    chestPending: chestPending,
    freezeNotice: freezeNotice,
    solve: solve,
  );

  // A solved day with a known solve (E3; m7-design P3.4): the daily's
  // `lastSolve` (its Share is on the daily win card now, D188).
  DailySolve solved() =>
      DailySolve(date: today, moves: 18, families: 5, minuteOfDay: 1150);

  ({DailyCubit cubit, FakeDailyService daily}) build(DailyStatus status) {
    final save = FakeSaveService(initial: const SaveDocument(coins: 1234567));
    final levels = FakeLevelRepository();
    final resolver = FakeLevelResolver(levels, save, FakeRemoteConfigService());
    final daily = FakeDailyService(FakeClock(), status: status);
    return (
      cubit: DailyCubit(
        daily,
        resolver,
        save,
        FakeRemoteConfigService(),
        FakeShareService(),
      ),
      daily: daily,
    );
  }

  Future<void> pumpDaily(
    WidgetTester tester,
    DailyCubit cubit, {
    Size size = const Size(390, 844),
    double textScale = 1,
    Widget? reminderOffer,
  }) async {
    await pumpScreen(
      tester,
      MultiBlocProvider(
        providers: [BlocProvider<DailyCubit>.value(value: cubit)],
        child: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<JingleCues>.value(
              value: JingleCues(FakeMusicService(), FakeAudioService()),
            ),
            RepositoryProvider<SkinService>.value(value: FakeSkinService()),
            RepositoryProvider<DatabaseService>.value(
              value: FakeDatabaseService(),
            ),
            RepositoryProvider<FxLibrary>.value(value: FakeFxLibrary()),
            RepositoryProvider<DailyBackgroundLoader>.value(
              value: _NoDailyBackground(),
            ),
          ],
          // The view without the page's reminder offer (m7-design P3.10):
          // the offer card needs its DI-built cubit; its own tests cover it.
          // [reminderOffer] stands in for it where this file checks the
          // slot's size, never its real cubit-driven behaviour.
          child: DailyView(reminderOffer: reminderOffer),
        ),
      ),
      size: size,
      textScale: textScale,
    );
    await cubit.load();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  final states = {
    'locked before Level 2': status(unlocked: false),
    'unlocked, lit streak': status(),
    'solved today': status(solvedToday: true, cycleDone: 5),
    // A solved day with a known solve (Share moved to the daily win card,
    // frame 10.1, D188: the card itself has none).
    'solved today with a known solve': status(
      solvedToday: true,
      cycleDone: 5,
      solve: solved(),
    ),
    'a full week': status(solvedToday: true, streak: 7, cycleDone: 7),
    'the day-7 chest modal': status(chestPending: true),
    'a freeze notice': status(freezeNotice: LocalDate(2026, 9, 25)),
    // E2, the gentle streak (m7-design §8, §15.7): the neutral paused card
    // and badge, and its longest subline, with a 3-digit count.
    'a paused streak': status(streak: 132, lit: false, freezes: 0),
    'a long lit streak': status(streak: 132, cycleDone: 6),
    // The gentle streak's zero state (10.7): no number, the start line.
    'a streak never lit': status(
      streak: 0,
      lit: false,
      freezes: 0,
      cycleDone: 0,
    ),
    // The day strip's lifted Today (ui-spec-menus §6.6) in a lit week.
    'a fresh week': status(streak: 7, cycleDone: 0),
  };

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      for (final MapEntry(key: name, value: state) in states.entries) {
        testWidgets(
          'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× '
          'text ($name)',
          (tester) async {
            final built = build(state);
            await pumpDaily(tester, built.cubit, size: size, textScale: scale);
            await expectAccessibleLayout(tester);
            if (name == 'a freeze notice') {
              // Lets the freeze notice's own `NestyToast` auto-dismiss timer
              // (3 s) and fade-out finish, so no timer is left pending at
              // teardown (`daily_page_test.dart`'s same precaution).
              await tester.pump(const Duration(seconds: 4));
            }
            await built.cubit.close();
          },
        );
      }
    }
  }

  group('the reminder offer over the solved Daily screen (frames 10.2, '
      '10.2d)', () {
    for (final denied in [false, true]) {
      for (final size in overflowScreenSizes) {
        for (final scale in textScales) {
          testWidgets('${denied ? 'denied' : 'ask'} fits ${size.width.toInt()}×'
              '${size.height.toInt()} at $scale× text', (tester) async {
            final built = build(
              status(solvedToday: true, cycleDone: 5, solve: solved()),
            );
            final settings = FakeDatabaseService();
            addTearDown(settings.close);
            final notifications = FakeNotificationService();
            if (denied) {
              notifications.permissionAnswer = NotificationPermission.denied;
            }
            final reminder = DailyReminder(
              notifications,
              settings,
              built.daily,
            );
            addTearDown(reminder.dispose);
            final offer = ReminderOfferCubit(
              reminder,
              settings,
              built.daily,
              FakeClock(),
              systemSettings: FakeSystemSettingsService(),
            );
            addTearDown(offer.close);
            await pumpDaily(
              tester,
              built.cubit,
              size: size,
              textScale: scale,
              reminderOffer: BlocProvider.value(
                value: offer,
                child: const ReminderOfferDialog(),
              ),
            );
            await offer.load();
            await tester.pump(const Duration(milliseconds: 300));
            if (denied) {
              // A short screen at 1.3× scrolls the card: bring the button in.
              await tester.ensureVisible(find.text('Yes, remind me'));
              await tester.tap(find.text('Yes, remind me'));
              await tester.pump();
              await tester.pump(const Duration(milliseconds: 400));
              expect(find.text('Open phone settings'), findsOneWidget);
            } else {
              expect(find.text('Yes, remind me'), findsOneWidget);
            }
            await expectAccessibleLayout(tester);
            // Share left the solved card (D188).
            expect(find.bySemanticsLabel("Share today's result"), findsNothing);
            await built.cubit.close();
          });
        }
      }
    }
  });

  group('the day-7 chest modal on its own (frame 5.6)', () {
    for (final size in overflowScreenSizes) {
      for (final scale in textScales) {
        testWidgets(
          'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text',
          (tester) async {
            await pumpScreen(
              tester,
              Scaffold(body: DailyChestModal(coins: 300, onCollect: () {})),
              size: size,
              textScale: scale,
            );
            await expectAccessibleLayout(tester);
          },
        );

        // The chest opens closed now (owner-chest): its open step, with
        // the lid up and Collect, at the same sizes.
        testWidgets('open fits ${size.width.toInt()}×${size.height.toInt()} at '
            '$scale× text', (tester) async {
          await pumpScreen(
            tester,
            Scaffold(body: DailyChestModal(coins: 300, onCollect: () {})),
            size: size,
            textScale: scale,
          );
          await tester.pump(
            const Duration(milliseconds: ChestRewardSequence.arrivalMs + 50),
          );
          await tester.tap(find.text('Open'));
          await tester.pump(
            const Duration(
              milliseconds:
                  ChestRewardSequence.wiggleMs +
                  ChestRewardSequence.burstMs +
                  100,
            ),
          );
          expect(find.text('Collect'), findsOneWidget);
          await expectAccessibleLayout(tester);
        });
      }
    }
  });
}
