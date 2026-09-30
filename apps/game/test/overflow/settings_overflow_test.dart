import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/app/localization_cubit/language_cubit.dart';
import 'package:nesty_game/core/models/reduce_motion_mode.dart';
import 'package:nesty_game/core/models/reminder_settings.dart';
import 'package:nesty_game/core/services/app_info/fake_app_info_service.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/daily/fake_daily_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/links/fake_link_launcher.dart';
import 'package:nesty_game/core/services/links/link_launcher.dart';
import 'package:nesty_game/core/services/notifications/fake_notification_service.dart';
import 'package:nesty_game/core/services/notifications/notification_service.dart';
import 'package:nesty_game/core/services/reminder/daily_reminder.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/settings/cubit/settings_cubit.dart';
import 'package:nesty_game/features/settings/pages/settings_page.dart';
import 'package:nesty_game/features/settings/widgets/language_sheet.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';

/// M7 overflow suite (m7-design §18 "overflow"): Settings (frames 8.1, 8.2)
/// and the language sheet at the five acceptance sizes and both text
/// scales. Behaviour is covered by `test/features/settings/
/// settings_page_test.dart` and `language_sheet_test.dart`.
///
/// Settings is built directly over its cubit and fakes, bypassing
/// `SettingsPage.wrappedRoute` (DI) and the router (the same pattern
/// `test/features/daily/daily_page_test.dart` and `museum_page_test.dart`
/// use), rather than pumping the full `App` through
/// `configureTestDependencies()` as `settings_page_test.dart` does: the
/// gameplay-bloc lane's E9 ("first launch opens Level 1") changes what a
/// fresh fake save's splash opens to, so a full-`App` pump would depend on
/// that other lane's landing order. This keeps the sweep deterministic.
void main() {
  setUpAll(loadBundledFonts);

  Future<void> pumpSettings(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1,
    bool reminderUnlocked = false,
    bool reminderOn = false,
    bool reminderBlocked = false,
    bool relaxed = false,
    ReduceMotionMode reduceMotion = ReduceMotionMode.system,
  }) async {
    final database = FakeDatabaseService();
    final notifications = FakeNotificationService()
      ..permissionAnswer = reminderBlocked
          ? NotificationPermission.denied
          : NotificationPermission.granted;
    final daily = FakeDailyService(FakeClock())..unlocked = reminderUnlocked;
    final reminder = DailyReminder(notifications, database, daily);
    addTearDown(reminder.dispose);
    await database.setRelaxedMode(relaxed);
    await database.setReduceMotion(reduceMotion);
    if (reminderOn) {
      await database.setReminder(const ReminderSettings(on: true, hour: 19));
    }
    final cubit = SettingsCubit(
      database,
      FakeAppInfoService(),
      FakeSaveService(),
      reminder,
    );
    addTearDown(cubit.close);
    final language = LanguageCubit(database);
    addTearDown(language.close);
    await pumpScreen(
      tester,
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<LinkLauncher>.value(value: FakeLinkLauncher()),
          RepositoryProvider<SkinService>.value(value: FakeSkinService()),
          RepositoryProvider<FxLibrary>.value(value: FakeFxLibrary()),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<SettingsCubit>.value(value: cubit),
            BlocProvider<LanguageCubit>.value(value: language),
          ],
          child: const SettingsPage(),
        ),
      ),
      size: size,
      textScale: textScale,
    );
    await cubit.load();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  group('Settings (frames 8.1, 8.2)', () {
    for (final size in overflowScreenSizes) {
      for (final scale in textScales) {
        testWidgets(
          'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text',
          (tester) async {
            await pumpSettings(tester, size: size, textScale: scale);
            await expectAccessibleLayout(tester);
          },
        );
      }
    }
  });

  group('the Daily reminder rows (E4; m7-design P3.10)', () {
    for (final size in overflowScreenSizes) {
      for (final scale in textScales) {
        testWidgets('off, fits ${size.width.toInt()}×${size.height.toInt()} at '
            '$scale× text', (tester) async {
          await pumpSettings(
            tester,
            size: size,
            textScale: scale,
            reminderUnlocked: true,
          );
          expect(find.text('Daily reminder'), findsOneWidget);
          await expectAccessibleLayout(tester);
        });

        testWidgets('on with its time row, fits '
            '${size.width.toInt()}×${size.height.toInt()} at $scale× text', (
          tester,
        ) async {
          await pumpSettings(
            tester,
            size: size,
            textScale: scale,
            reminderUnlocked: true,
            reminderOn: true,
          );
          expect(find.text('Time'), findsOneWidget);
          await expectAccessibleLayout(tester);
        });

        testWidgets('blocked, with Open phone settings, fits '
            '${size.width.toInt()}×${size.height.toInt()} at $scale× text', (
          tester,
        ) async {
          await pumpSettings(
            tester,
            size: size,
            textScale: scale,
            reminderUnlocked: true,
            reminderOn: true,
            reminderBlocked: true,
          );
          await tester.pump();
          expect(find.text('Off in your phone’s settings'), findsOneWidget);
          expect(find.text('Open phone settings'), findsOneWidget);
          expect(find.text('Time'), findsNothing);
          await expectAccessibleLayout(tester);
        });
      }
    }
  });

  Future<void> openLanguageSheet(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: GestureDetector(
              onTap: () => LanguageSheet.show(
                context,
                selectedCode: 'en',
                onSelect: (_) {},
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      size: size,
      textScale: textScale,
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('the language sheet (frame 8.2)', () {
    for (final size in overflowScreenSizes) {
      for (final scale in textScales) {
        testWidgets(
          'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text',
          (tester) async {
            await openLanguageSheet(tester, size: size, textScale: scale);
            expect(find.byType(LanguageSheet), findsOneWidget);
            await expectAccessibleLayout(tester);
          },
        );
      }
    }
  });

  group('Relaxed mode and the Reduce motion control (E6, E14; frames '
      '10.2e, 10.2f)', () {
    for (final mode in ReduceMotionMode.values) {
      for (final size in overflowScreenSizes) {
        for (final scale in textScales) {
          testWidgets('${mode.name}, relaxed on, fits ${size.width.toInt()}×'
              '${size.height.toInt()} at $scale× text', (tester) async {
            await pumpSettings(
              tester,
              size: size,
              textScale: scale,
              reminderUnlocked: true,
              reminderOn: true,
              relaxed: true,
              reduceMotion: mode,
            );
            expect(find.text('Unlimited free undo'), findsOneWidget);
            for (final label in ['Off', 'On', 'System']) {
              expect(find.text(label), findsOneWidget);
            }
            await expectAccessibleLayout(tester);
          });
        }
      }
    }
  });
}
