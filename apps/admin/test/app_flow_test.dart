import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_admin/app/app.dart';
import 'package:nesty_admin/core/dependency_injection/di.dart';
import 'package:nesty_admin/core/error/app_exception.dart';
import 'package:nesty_admin/core/router/app_router.dart';
import 'package:nesty_admin/features/dashboard/pages/dashboard_page.dart';
import 'package:nesty_admin/features/levels/pages/level_editor_page.dart';
import 'package:nesty_admin/features/login/pages/login_page.dart';
import 'package:nesty_admin/features/not_authorized/pages/not_authorized_page.dart';
import 'package:nesty_admin/features/shell/pages/admin_shell_page.dart';
import 'package:nesty_admin/features/skins/pages/skins_page.dart';

import 'helpers/test_dependencies.dart';

/// Spec §15 Auth through the real router, guard and pages on fake services.
void main() {
  setUp(configureTestDependencies);
  tearDown(resetDependencies);

  /// The admin's target viewport (docs/DESIGN_BRIEF.md Prompt 14).
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(App(router: get<AppRouter>()));
    await tester.pumpAndSettle();
  }

  Future<void> signIn(
    WidgetTester tester, {
    String email = 'owner@example.com',
    String password = 'pw',
  }) async {
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), email);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      password,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
  }

  Finder railLabel(String label) => find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(label),
  );

  group('AuthGuard', () {
    testWidgets('signed out, the app root redirects to Login', (tester) async {
      await pumpApp(tester);

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(AdminShellPage), findsNothing);
    });

    testWidgets('an admin signs in and lands on the Dashboard in the shell', (
      tester,
    ) async {
      await pumpApp(tester);
      await signIn(tester);

      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(AdminShellPage), findsOneWidget);
      expect(find.byType(DashboardPage), findsOneWidget);
      expect(find.text('Coming in M5'), findsOneWidget);
      expect(
        tester
            .widget<NavigationRail>(find.byType(NavigationRail))
            .selectedIndex,
        0,
      );
    });

    testWidgets('a non-admin sees Not authorized, and can sign out', (
      tester,
    ) async {
      fakeAuth.isAdmin = false;
      await pumpApp(tester);
      await signIn(tester, email: 'guest@example.com');

      expect(find.byType(NotAuthorizedPage), findsOneWidget);
      expect(find.byType(AdminShellPage), findsNothing);
      expect(find.text('Not authorized'), findsOneWidget);
      expect(find.text('Signed in as guest@example.com'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Sign out'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(NotAuthorizedPage), findsNothing);
    });

    testWidgets('signing out of the shell returns to Login', (tester) async {
      await pumpApp(tester);
      await signIn(tester);

      await tester.tap(find.byTooltip('Sign out'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(AdminShellPage), findsNothing);
      expect(fakeAuth.currentUser, isNull);
    });

    testWidgets('a signed-out deep link to a guarded screen shows Login', (
      tester,
    ) async {
      await pumpApp(tester);

      await get<AppRouter>().navigatePath('/levels/L0024');
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(LevelEditorPage), findsNothing);
    });

    testWidgets('a signed-in admin opening /login is sent to the shell', (
      tester,
    ) async {
      await pumpApp(tester);
      await signIn(tester);

      await get<AppRouter>().navigatePath('/login');
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsNothing);
      expect(find.byType(DashboardPage), findsOneWidget);
    });

    testWidgets('an unknown URL falls back to the root', (tester) async {
      await pumpApp(tester);

      await get<AppRouter>().navigatePath('/no-such-page');
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });
  });

  group('Login form', () {
    testWidgets('empty fields show validation messages and send nothing', (
      tester,
    ) async {
      await pumpApp(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your email.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);
      expect(fakeAuth.signInCount, 0);
    });

    testWidgets('rejected credentials show a localized error on Login', (
      tester,
    ) async {
      fakeAuth.failSignInWith = AppExceptionKind.invalidCredentials;
      await pumpApp(tester);
      await signIn(tester, password: 'wrong');

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.text('Wrong email or password.'), findsOneWidget);
    });
  });

  group('Shell', () {
    testWidgets('the rail switches between spec §15 sections', (tester) async {
      await pumpApp(tester);
      await signIn(tester);

      await tester.tap(railLabel('Skins'));
      await tester.pumpAndSettle();

      expect(find.byType(SkinsPage), findsOneWidget);
      expect(
        tester
            .widget<NavigationRail>(find.byType(NavigationRail))
            .selectedIndex,
        4,
      );
    });

    testWidgets('the level editor is a child of Levels, addressed by id', (
      tester,
    ) async {
      await pumpApp(tester);
      await signIn(tester);

      await get<AppRouter>().navigatePath('/levels/L0024');
      await tester.pumpAndSettle();

      final editor = tester.widget<LevelEditorPage>(
        find.byType(LevelEditorPage),
      );
      expect(editor.levelId, 'L0024');
      expect(find.text('Edit level L0024'), findsOneWidget);
      expect(
        tester
            .widget<NavigationRail>(find.byType(NavigationRail))
            .selectedIndex,
        1,
      );
    });
  });
}
