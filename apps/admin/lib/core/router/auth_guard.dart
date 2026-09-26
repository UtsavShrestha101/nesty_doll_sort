import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_admin/core/models/admin_user.dart';
import 'package:nesty_admin/core/router/app_router.dart';
import 'package:nesty_admin/core/services/auth/auth_service.dart';

/// The admin panel's whole access policy (spec §15 Auth), in one place.
///
/// Each session state has exactly one top-level route it may see
/// ([allowedRouteFor]); this guard sits on all three, and any navigation to
/// the wrong one is replaced by the right one. That covers bookmarks and
/// typed URLs too: a signed-out `/levels/L0024` lands on Login, and a signed-in
/// admin opening `/login` lands on the Dashboard.
///
/// It aborts and replaces rather than using `resolver.redirectUntil`: nothing
/// resumes a held resolver here, because `App` re-enters the router after
/// every session change and this guard decides again from scratch.
///
/// TODO(M5): resume the originally requested deep link after sign-in, if the
/// owner wants it; Firebase keeps web sessions, so this only affects the
/// first sign-in on a browser.
@lazySingleton
class AuthGuard extends AutoRouteGuard {
  AuthGuard(this._auth);

  final AuthService _auth;

  /// The one top-level route [user] may be on.
  static PageRouteInfo<void> allowedRouteFor(AdminUser? user) => switch (user) {
    null => const LoginRoute(),
    // Signed in, but no admins/{uid} document (spec §14.1).
    AdminUser(isAdmin: false) => const NotAuthorizedRoute(),
    AdminUser() => const AdminShellRoute(),
  };

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final allowed = allowedRouteFor(_auth.currentUser);
    if (resolver.routeName == allowed.routeName) {
      resolver.next();
      return;
    }
    // replaceAll, not push: a gate page must never have a page it guards
    // underneath it on the back stack.
    unawaited(router.replaceAll([allowed]));
    resolver.next(false);
  }
}
