---
name: auto-route
description: auto_route 11.1.0 navigation conventions for the Nesty apps.
paths:
  - "apps/*/lib/core/router/**"
  - "apps/*/lib/**/pages/**"
  - "apps/*/lib/**/*_page.dart"
---

# auto_route rules (auto_route 11.1.0 / auto_route_generator 10.5)

- **Version pin:** both apps pin `auto_route: 11.1.0` exactly. 11.2.0 calls
  `Viewport(scrollCacheExtent: ...)`, which Flutter 3.41.2 (the SDK this repo
  and CI build with) doesn't have. See docs/PROGRESS.md B1, resolved by this
  pin, and D15. Don't bump it unless the Flutter SDK is upgraded at the same
  time (PROGRESS.md Q23). Then update the B1 entry and the auto_route row
  under Package reasons (CLAUDE.md rule 9). Read the API docs for 11.1.0, not
  the latest version.
- One router per app, in `lib/core/router/app_router.dart`: `@AutoRouterConfig()`
  on `class AppRouter extends RootStackRouter`, registered `@lazySingleton`.
  `app_router.gr.dart` is a generated `part`. Never hand-edit it.
- Every screen is a widget annotated `@RoutePage()` in `features/<name>/pages/<name>_page.dart`.
  Add `AutoRoute(page: FooRoute.page)` to `routes`, then run
  `cd apps/<app> && dart run build_runner build`.
- A page that owns a cubit implements `AutoRouteWrapper` and provides it in
  `wrappedRoute`: `BlocProvider(create: (_) => get<FooCubit>()..load(), child: this)`
  (see `apps/game/lib/features/home/pages/home_page.dart`).
- Navigate with `context.router.push(const FooRoute())`,
  `context.router.replace(...)` and `context.router.replaceAll([...])`. Never
  call `Navigator.push` for a screen.
- Pass arguments through the generated constructor (`GameplayRoute(levelNumber: 3)`).
  Don't encode them in path or query strings.
- Guards implement `AutoRouteGuard.onNavigation(resolver, router)`. auto_route
  11 renamed `resolver.redirect` to `resolver.redirectUntil` and removed the
  `*Named` navigation APIs, so don't copy older snippets. The admin's access
  policy (sign-in and the spec §15 "Not authorized" gate) is `AuthGuard`
  (`apps/admin/lib/core/router/auth_guard.dart`, docs/PROGRESS.md D10). Put
  any new gate there, not in a second guard.
- Game flow is spec §10.1: Splash → (first-launch consent, M6) → Home → Gameplay
  → Win → [interstitial] → next Gameplay. Overlays such as the Out of Moves sheet,
  the booster popup, the mechanic intro card and the soft-stuck banner (§10.2)
  are sheets or Flutter overlays above the `GameWidget`, not routes, unless a
  plan decides otherwise.
- The Flame game is not a route target. `GameplayPage` hosts a `GameWidget`,
  and navigation away from gameplay goes through the page, never from inside a
  Flame component.
