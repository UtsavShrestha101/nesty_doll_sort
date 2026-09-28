import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/app/app.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/museum/pages/museum_page.dart';
import 'package:nesty_game/features/shop/pages/shop_page.dart';

import '../../core/ui/support/ui_harness.dart';
import '../../helpers/test_dependencies.dart';

/// The bottom-nav shell (frame 2.1, m3-design §10.1): `NestyBottomNav`
/// switches Shop · Home · Museum, and a Shop/Museum back press returns to
/// Home instead of leaving the shell (`AutoTabsRouter.homeIndex`).
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

  Future<void> pumpToHome(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(App(router: get<AppRouter>()));
    await tester.pump();
    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.byType(HomePage), findsOneWidget);
  }

  /// The bottom nav's own label, disambiguated from same-named text
  /// elsewhere on the page (Home's Museum tile also reads "Museum").
  Finder navLabel(String label) => find.descendant(
    of: find.byType(NestyBottomNav),
    matching: find.text(label),
  );

  testWidgets('the wood bottom nav shows Shop, Home and Museum, Home active', (
    tester,
  ) async {
    await pumpToHome(tester);
    for (final label in ['Shop', 'Home', 'Museum']) {
      expect(navLabel(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('tapping Museum switches to the Museum tab, and a back press '
      'returns to Home', (tester) async {
    await pumpToHome(tester);

    await tester.tap(navLabel('Museum'));
    await tester.pumpAndSettle();
    expect(find.byType(MuseumPage), findsOneWidget);
    // The tabs router keeps a visited tab's page alive offstage (an
    // `IndexedStack`, state preservation), so Home is still in the tree —
    // just not on screen.
    expect(find.byType(HomePage), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(MuseumPage), findsNothing);
  });

  testWidgets('tapping Shop switches to the Shop tab, and a back press '
      'returns to Home', (tester) async {
    await pumpToHome(tester);

    await tester.tap(navLabel('Shop'));
    await tester.pumpAndSettle();
    expect(find.byType(ShopPage), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(ShopPage), findsNothing);
  });

  testWidgets('a back press on Home itself is not swallowed by the shell', (
    tester,
  ) async {
    await pumpToHome(tester);
    // Home is already the shell's homeIndex: nothing above it to return to,
    // so the pop is not handled by the tabs router (it would otherwise try
    // to exit the app; this just confirms the shell doesn't hang or crash).
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
