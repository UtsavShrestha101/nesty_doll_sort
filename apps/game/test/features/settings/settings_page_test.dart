import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/app/app.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/models/reduce_motion_mode.dart';
import 'package:nesty_game/core/models/reminder_settings.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/notifications/fake_notification_service.dart';
import 'package:nesty_game/core/services/notifications/notification_service.dart';
import 'package:nesty_game/core/services/reminder/daily_reminder.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/services/system_settings/fake_system_settings_service.dart';
import 'package:nesty_game/core/services/system_settings/system_settings_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/widgets/home/text_link.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/settings/pages/settings_page.dart';
import 'package:nesty_game/features/settings/widgets/color_symbols_picker.dart';
import 'package:nesty_game/features/settings/widgets/language_sheet.dart';
import 'package:nesty_game/features/shop/widgets/skin_doll_row.dart';

import '../../core/ui/support/ui_harness.dart';
import '../../helpers/test_dependencies.dart';
import '../support/screen_harness.dart';

/// Settings (frames 8.1, 8.2; spec §10.2 #13; m3-design §10.2), reached
/// through the whole app so its close button (`context.router`), the
/// app-wide `LanguageCubit` and every service resolve for real over the
/// fake env.
void main() {
  setUpAll(loadBundledFonts);
  setUp(() async {
    await configureTestDependencies();
    // These start at Home: a fresh save opens Level 1 (E9).
    await seedSavePastFirstLevel();
  });
  tearDown(resetDependencies);

  Future<void> pumpFor(WidgetTester tester, Duration duration) async {
    const step = Duration(milliseconds: 50);
    for (var t = Duration.zero; t < duration; t += step) {
      await tester.pump(step);
    }
  }

  Future<void> pumpSettings(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(App(router: get<AppRouter>()));
    await tester.pump();
    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.byType(HomePage), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Settings'));
    await pumpFor(tester, const Duration(milliseconds: 500));
    expect(find.byType(SettingsPage), findsOneWidget);
  }

  testWidgets('the toggles, Color symbols, Language, the disabled rows and '
      'the footer', (tester) async {
    await pumpSettings(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Sound'), findsOneWidget);
    expect(find.text('Music'), findsOneWidget);
    expect(find.text('Haptics'), findsOneWidget);
    expect(find.text('Color symbols'), findsOneWidget);
    expect(find.text('Subtle'), findsOneWidget);
    expect(find.text('Large'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Restore Purchases'), findsOneWidget);
    expect(find.text('Privacy choices'), findsOneWidget);
    // The owner hasn't supplied a privacy URL or support email yet: both
    // rows stay hidden (m3-design §10.2, Q73).
    expect(find.text('Privacy Policy'), findsNothing);
    expect(find.text('Support'), findsNothing);
    // The footer sits below the fold of the taller tiled rows.
    await tester.dragUntilVisible(
      find.textContaining('Nesty: Doll Sort · v1.0.0 (build 42)'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(
      find.textContaining('Nesty: Doll Sort · v1.0.0 (build 42)'),
      findsOneWidget,
    );
  });

  /// The [NestyToggle] itself: tapping the row's label does nothing, only
  /// the switch responds (`SettingsToggleRow`).
  Finder toggleFor(String label) => find.byWidgetPredicate(
    (w) => w is NestyToggle && w.semanticLabel == label,
  );

  testWidgets('Sound writes DatabaseService only', (tester) async {
    await pumpSettings(tester);
    final database = get<DatabaseService>();
    expect(database.soundEnabled, isTrue);

    await tester.tap(toggleFor('Sound'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(database.soundEnabled, isFalse);
  });

  // E6 relaxed mode (m7-design §10, §15.5).
  testWidgets('Relaxed mode writes DatabaseService only, with its subtitle', (
    tester,
  ) async {
    await pumpSettings(tester);
    final database = get<DatabaseService>();
    expect(database.relaxedMode, isFalse);
    expect(find.text('Relaxed mode'), findsOneWidget);
    expect(find.text('Unlimited free undo'), findsOneWidget);

    await tester.tap(toggleFor('Relaxed mode'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(database.relaxedMode, isTrue);
  });

  // E14 reduce motion (m7-design §14; Q146): an inline Off · On · System
  // control replaces the sheet (frames 10.2e, 10.2f).
  testWidgets('Reduce motion is an inline Off · On · System control, System '
      'by default; a tap writes DatabaseService', (tester) async {
    await pumpSettings(tester);
    final database = get<DatabaseService>();
    expect(database.reduceMotion, ReduceMotionMode.system);
    expect(find.text('Reduce motion'), findsOneWidget);
    expect(find.byType(SettingsSegmentedRow<ReduceMotionMode>), findsOneWidget);
    for (final label in ['Off', 'On', 'System']) {
      expect(find.text(label), findsOneWidget);
    }

    await tester.tap(find.text('On'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(database.reduceMotion, ReduceMotionMode.on);

    await tester.tap(find.text('Off'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(database.reduceMotion, ReduceMotionMode.off);

    await tester.tap(find.text('System'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(database.reduceMotion, ReduceMotionMode.system);
    // No sheet, no route: still on Settings.
    expect(find.byType(SettingsPage), findsOneWidget);
  });

  testWidgets('the Reduce motion control tells a screen reader which '
      'segment is active, and reads as one group', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpSettings(tester);
    Tristate selected(String label) => tester
        .getSemantics(
          find.descendant(
            of: find.byType(SettingsSegmentedRow<ReduceMotionMode>),
            matching: find.text(label),
          ),
        )
        .getSemanticsData()
        .flagsCollection
        .isSelected;
    expect(selected('System'), Tristate.isTrue);
    expect(selected('On'), Tristate.isFalse);
    expect(selected('Off'), Tristate.isFalse);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Reduce motion'))
          .getSemanticsData()
          .value,
      'System',
    );
    handle.dispose();
  });

  testWidgets('frame 8.1: Color symbols is the visibility row and two '
      'doll-preview cards, not a text switch (FIDELITY-8)', (tester) async {
    await pumpSettings(tester);
    expect(find.byType(ColorSymbolsPicker), findsOneWidget);
    expect(find.byIcon(NestyIcons.visibility), findsOneWidget);
    await tester.pump();
    final previews = find.descendant(
      of: find.byType(ColorSymbolsPicker),
      matching: find.byType(SkinDollRow),
    );
    expect(previews, findsNWidgets(2));
    expect(find.byType(NestySegmentedTabs), findsNothing);
  });

  testWidgets('Color symbols switches DollSymbols mode', (tester) async {
    await pumpSettings(tester);
    final database = get<DatabaseService>();
    // Large on a fresh install (owner, PROGRESS D91).
    expect(database.symbolsMode.dollSymbols.name, 'large');

    await tester.tap(find.text('Subtle'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(database.symbolsMode.dollSymbols.name, 'subtle');

    await tester.tap(find.text('Large'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(database.symbolsMode.dollSymbols.name, 'large');
  });

  testWidgets(
    'the Language row shows the language\'s own name and opens the '
    '8.2 sheet; a row applies at once and the sheet stays open; Done closes it',
    (tester) async {
      await pumpSettings(tester);

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      expect(find.byType(LanguageSheet), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);

      // Every launch language has a catalog: a tap applies at once, the sheet
      // stays open and redraws in that language (frame 8.2).
      await tester.tap(find.text('Español'));
      await tester.pumpAndSettle();
      expect(find.byType(LanguageSheet), findsOneWidget);
      expect(find.text('Listo'), findsOneWidget);

      await tester.tap(find.text('Listo'));
      await tester.pumpAndSettle();
      expect(find.byType(LanguageSheet), findsNothing);
      expect(find.byType(SettingsPage), findsOneWidget);
    },
  );

  testWidgets('the close button pops back to Home', (tester) async {
    await pumpSettings(tester);
    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
  });

  group('the daily reminder row (E4; m7-design P3.10; Q139)', () {
    /// Level 2 won (`DailyService.isUnlocked`), unlike [seedSavePastFirstLevel]'s
    /// Level 1 only, so the reminder rows are shown.
    Future<void> seedDailyUnlocked() async {
      await get.unregister<SaveService>();
      get.registerSingleton<SaveService>(
        FakeSaveService(initial: const SaveDocument(highestLevel: 3)),
      );
    }

    testWidgets('hidden before Level 2 is won', (tester) async {
      await pumpSettings(tester);
      expect(find.text('Daily reminder'), findsNothing);
    });

    testWidgets('shown, off, once Level 2 is won', (tester) async {
      await seedDailyUnlocked();
      await pumpSettings(tester);
      expect(find.text('Daily reminder'), findsOneWidget);
      expect(find.text('Time'), findsNothing);
    });

    testWidgets(
      'granted: turns it on, asks the OS once, and shows the time row',
      (tester) async {
        await seedDailyUnlocked();
        await pumpSettings(tester);
        final notifications =
            get<NotificationService>() as FakeNotificationService;

        await tester.tap(toggleFor('Daily reminder'));
        await tester.pump(const Duration(milliseconds: 300));

        expect(notifications.requestCount, 1);
        expect(get<DatabaseService>().reminder.on, isTrue);
        expect(find.text('Time'), findsOneWidget);
      },
    );

    testWidgets('denied: the reminder stays on and the row is blocked, with '
        'Open phone settings, no Time row and no toast (D190)', (tester) async {
      await seedDailyUnlocked();
      await pumpSettings(tester);
      final notifications =
          get<NotificationService>() as FakeNotificationService
            ..permissionAnswer = NotificationPermission.denied;

      await tester.tap(toggleFor('Daily reminder'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(get<DatabaseService>().reminder.on, isTrue);
      expect(find.text('Off in your phone’s settings'), findsOneWidget);
      expect(find.text('Open phone settings'), findsOneWidget);
      expect(find.text('Time'), findsNothing);
      // The toggle is drawn off while blocked.
      final toggle = tester.widget<NestyToggle>(toggleFor('Daily reminder'));
      expect(toggle.value, isFalse);
      expect(notifications.scheduled, isNotNull);
    });

    testWidgets('blocked: the pill and the toggle both open the phone\'s '
        'settings; coming back allowed clears the row', (tester) async {
      await seedDailyUnlocked();
      await pumpSettings(tester);
      final notifications =
          get<NotificationService>() as FakeNotificationService
            ..permissionAnswer = NotificationPermission.denied;
      await tester.tap(toggleFor('Daily reminder'));
      await tester.pump(const Duration(milliseconds: 300));
      final system = get<SystemSettingsService>() as FakeSystemSettingsService;

      await tester.tap(find.text('Open phone settings'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(system.openCalls, 1);

      await tester.tap(toggleFor('Daily reminder'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(system.openCalls, 2);
      expect(get<DatabaseService>().reminder.on, isTrue);

      // The player allowed notifications; the app resumes.
      notifications.permissionAnswer = NotificationPermission.granted;
      await tester.runAsync(() => get<DailyReminder>().refresh());
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Off in your phone’s settings'), findsNothing);
      expect(find.text('Open phone settings'), findsNothing);
      expect(find.text('Time'), findsOneWidget);
    });

    testWidgets('blocked: the pill and Turn off share one line at 390 dp '
        '(frame 10.2f), and stack at 1.3x text', (tester) async {
      await seedDailyUnlocked();
      await pumpSettings(tester);
      (get<NotificationService>() as FakeNotificationService).permissionAnswer =
          NotificationPermission.denied;
      await tester.tap(toggleFor('Daily reminder'));
      await tester.pump(const Duration(milliseconds: 300));
      final pill = tester.getRect(find.byType(SettingsPillButton));
      final off = tester.getRect(find.byType(TextLink));
      expect(
        (pill.center.dy - off.center.dy).abs(),
        lessThan(4),
        reason: 'one line',
      );
      expect(off.left - pill.right, greaterThanOrEqualTo(18 - 1));
    });

    testWidgets('blocked: Turn off stops the reminder in the app, no phone '
        'settings, and the row reads Off (10.2f, 10.2h, Q158)', (tester) async {
      await seedDailyUnlocked();
      await pumpSettings(tester);
      (get<NotificationService>() as FakeNotificationService).permissionAnswer =
          NotificationPermission.denied;
      await tester.tap(toggleFor('Daily reminder'));
      await tester.pump(const Duration(milliseconds: 300));
      final system = get<SystemSettingsService>() as FakeSystemSettingsService;
      expect(find.text('Turn off'), findsOneWidget);
      expect(
        tester.getSize(find.byType(TextLink)).height,
        greaterThanOrEqualTo(48),
      );

      await tester.tap(find.text('Turn off'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(system.openCalls, 0);
      expect(get<DatabaseService>().reminder.on, isFalse);
      expect(find.text('Turn off'), findsNothing);
      expect(find.text('Open phone settings'), findsNothing);
      expect(find.text('Time'), findsNothing);
      final toggle = tester.widget<NestyToggle>(toggleFor('Daily reminder'));
      expect(toggle.value, isFalse);
    });

    testWidgets('a time the store refused shows no "Reminder set" toast', (
      tester,
    ) async {
      await seedDailyUnlocked();
      final database = _RefusingReminderDatabase();
      await get.unregister<DatabaseService>();
      get.registerSingleton<DatabaseService>(database);
      await pumpSettings(tester);
      await tester.tap(toggleFor('Daily reminder'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Time'), findsOneWidget);

      database.refuse = true;
      await tester.tap(find.text('Time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await pumpFor(tester, const Duration(milliseconds: 500));

      expect(find.textContaining('Reminder set'), findsNothing);
    });

    testWidgets('a stored time shows the "Reminder set" toast', (tester) async {
      await seedDailyUnlocked();
      await pumpSettings(tester);
      await tester.tap(toggleFor('Daily reminder'));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await pumpFor(tester, const Duration(milliseconds: 500));

      expect(find.textContaining('Reminder set'), findsOneWidget);
    });

    testWidgets('off again cancels the schedule and hides the time row', (
      tester,
    ) async {
      await seedDailyUnlocked();
      await pumpSettings(tester);
      await tester.tap(toggleFor('Daily reminder'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Time'), findsOneWidget);

      await tester.tap(toggleFor('Daily reminder'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(get<DatabaseService>().reminder.on, isFalse);
      expect(find.text('Time'), findsNothing);
    });
  });

  group('phase 5: page frame (F-SET, F-SAFE)', () {
    testWidgets('cream page, start-aligned title, and the list runs to the '
        'bottom edge while its last row clears the home indicator', (
      tester,
    ) async {
      await pumpSettings(tester);
      expect(find.byType(CreamPage), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Settings').first).dx,
        lessThan(120),
        reason: 'start-aligned: the title sits left, not centred',
      );
      // A home indicator: the bottom inset is the view's, not the page's.
      tester.view
        ..padding = const FakeViewPadding(bottom: 34)
        ..viewPadding = const FakeViewPadding(bottom: 34);
      addTearDown(tester.view.resetPadding);
      await tester.pump();
      await tester.pump();
      final list = find.byType(ListView);
      expect(tester.getRect(list).bottom, 844, reason: 'to the screen edge');
      await tester.drag(list, const Offset(0, -5000));
      await tester.pumpAndSettle();
      final lastRow = find.byType(SettingsSection).last;
      expect(tester.getRect(lastRow).bottom, lessThanOrEqualTo(844 - 34));
    });
  });

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets('fits ${size.width.toInt()}×${size.height.toInt()} at '
          '$scale× text', (tester) async {
        await pumpSettings(tester, size: size);
        tester.binding.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(
          tester.binding.platformDispatcher.clearTextScaleFactorTestValue,
        );
        await tester.pump();
        expectNoLayoutErrors(tester);
      });
    }
  }
}

/// A store whose reminder write can be made to fail, as a full disk would.
class _RefusingReminderDatabase extends FakeDatabaseService {
  bool refuse = false;

  @override
  Future<void> setReminder(ReminderSettings reminder) async {
    if (refuse) throw StateError('disk full');
    await super.setReminder(reminder);
  }
}
