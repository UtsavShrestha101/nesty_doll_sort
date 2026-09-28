import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/app/app.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
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
  setUp(configureTestDependencies);
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
    expect(database.symbolsMode.dollSymbols.name, 'subtle');

    await tester.tap(find.text('Large'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(database.symbolsMode.dollSymbols.name, 'large');
  });

  testWidgets('the Language row opens the 8.2 sheet: English selected, the '
      'others disabled with "Coming soon"; Done closes it', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSheet), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
    expect(find.text('Spanish'), findsOneWidget);
    expect(find.text('Coming soon'), findsWidgets);

    // Tapping a disabled language changes nothing.
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSheet), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSheet), findsNothing);
    expect(find.byType(SettingsPage), findsOneWidget);
  });

  testWidgets('the close button pops back to Home', (tester) async {
    await pumpSettings(tester);
    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsNothing);
    expect(find.byType(HomePage), findsOneWidget);
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
