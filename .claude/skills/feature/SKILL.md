---
name: feature
description: |
  Scaffold a new feature module in apps/game or apps/admin: freezed-3 state, a
  BaseAsyncCubit (@injectable), a @RoutePage page registered in AppRouter, an ARB title
  key, and a starter bloc_test + widget test. Triggered by "/feature <app> <name>",
  "scaffold feature X", "create a new screen called Y".
argument-hint: "<game|admin> <feature_name> [--no-route]"
---

# /feature: scaffold a feature module

## When to use
A new screen or flow with the standard shape: one cubit, one freezed state, one
page and room for widgets. For sheets or overlays that are not routes (the Out
of Moves sheet, the booster popup, spec §10.2), pass `--no-route`. For multi-page
features, run `/plan` first.

## Inputs
- `<app>`: `game` (apps/game, package `nesty_game`) or `admin` (apps/admin, package `nesty_admin`)
- `<feature_name>`: snake_case, `[a-z][a-z0-9_]+`, for example `daily_puzzle`
- `--no-route`: skip the `@RoutePage` and router registration

## Steps
1. **Validate** the name. Confirm `apps/<app>/lib/features/<feature_name>/` does not exist.
2. **Read the canon first**: `apps/game/lib/features/home/` (cubit, state,
   page), its test `apps/game/test/features/home/home_cubit_test.dart`, and
   `lib/core/base/base_async_cubit.dart`. This is the canonical shape for
   **both** apps, because the base layer is identical (docs/PROGRESS.md D6);
   swap the package name to `nesty_admin` for the admin. Don't copy admin
   `features/login/`: `LoginCubit extends BaseAsyncCubit<AdminUser>` with no
   state file is a deliberate exception (see its class comment). Conventions
   change, so copy what is there now, not this file.
3. **Read the spec entry** for the screen (§10.2), and find its frame(s) in
   `design/prototypes/Nesty App Flow.dc.html` by the ids in `design/README.md`
   "Screens". Scaffold only. Build no visuals beyond a placeholder, and leave
   `// TODO(design): ...` when there is no frame. Also add the gap to
   `docs/BACKLOG.md`.
4. **Create:**
   ```
   apps/<app>/lib/features/<feature_name>/
   ├── cubit/
   │   ├── <feature_name>_cubit.dart   (@injectable, extends BaseAsyncCubit<<Pascal>State>)
   │   └── <feature_name>_state.dart   (part of the cubit; @freezed abstract class)
   ├── pages/
   │   └── <feature_name>_page.dart    (@RoutePage, implements AutoRouteWrapper:
   │                                    wrappedRoute → BlocProvider(create: (_) => get<<Pascal>Cubit>()..load(), child: this))
   └── widgets/
   ```
   The state uses freezed 3 syntax:
   ```dart
   part of '<feature_name>_cubit.dart';

   @freezed
   abstract class <Pascal>State with _$<Pascal>State {
     const factory <Pascal>State({@Default(0) int placeholder}) = _<Pascal>State;
   }
   ```
   The page renders `AsyncValue` with an exhaustive `switch`
   (`AsyncValueData(:final data) => ...`) and maps `AsyncValueError` to an ARB
   string. It never shows `exception.message`.
5. **Route** (unless `--no-route`): add `AutoRoute(page: <Pascal>Route.page)` to
   `apps/<app>/lib/core/router/app_router.dart`.
6. **Strings:** add `<camelName>Title` to `apps/<app>/lib/l10n/app_en.arb` with
   an `@` description that cites the spec section. Use `/l10n` for more keys.
7. **Codegen**, from the app directory:
   ```bash
   cd apps/<app> && flutter gen-l10n && dart run build_runner build
   ```
8. **Tests** (flat per feature, as in `test/features/home/`):
   `test/features/<feature_name>/<feature_name>_cubit_test.dart` (bloc_test,
   fakes) and `test/features/<feature_name>/<feature_name>_page_test.dart`
   (pumps the page on `configureTestDependencies()`).
9. **Device coverage** (CLAUDE.md "Testing", D169): for a game feature, add
   its flow on a device. That is either a step with a screenshot in
   `apps/game/integration_test/playthrough_test.dart`, or its own
   `integration_test/<name>_test.dart` that `tools/scripts/nesty-test` drives.
   Also add its `features/<feature_name>` row to `docs/TEST_COVERAGE.md`. When
   a simulator can't drive the flow, the row says why and names the host test.
10. **CLAUDE.md:** add the feature to the Code map ("Other features" for the
   game, the admin line for the admin), per its "Keeping this file current"
   section.
11. **Verify:**
   - `cd apps/<app> && flutter analyze` prints "No issues found!"
   - `flutter test test/features/<feature_name>/` passes
   - `<Pascal>Route` is in `app_router.gr.dart`, and `<Pascal>Cubit` is in `lib/core/dependency_injection/di.config.dart`
   - `cd tools && dart test test/claude_md_test.dart test/test_coverage_test.dart` passes
   - the device step passes: `tools/scripts/nesty-test --device-only --only playthrough` (or the step's own `--only` name)

## Output
- The file tree created
- Codegen, analyze and test results
- Keys added, and the `TODO(design)` notes left
- Next steps (UI via `flutter-frontend-dev`, state via `bloc-architect`)

## Anti-patterns
- Game rules in the cubit. Gameplay state comes from `nesty_core` (CLAUDE.md rule 2).
- freezed 2 syntax (`class X with _$X`, no `abstract`/`sealed`).
- Skipping build_runner: the route won't exist and the cubit won't be in DI.
- Inline English strings, or visuals invented without a design.
