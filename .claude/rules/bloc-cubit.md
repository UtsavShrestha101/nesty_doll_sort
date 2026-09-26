---
name: bloc-cubit
description: Cubit/Bloc conventions for the Nesty game and admin apps (BaseAsyncCubit + AsyncValue).
paths:
  - "apps/*/lib/**/cubit/**"
  - "apps/*/lib/**/bloc/**"
  - "apps/*/lib/**/*_cubit.dart"
  - "apps/*/lib/**/*_bloc.dart"
  - "apps/*/lib/**/*_state.dart"
  - "apps/*/lib/core/base/**"
  - "apps/*/test/**/*_cubit_test.dart"
  - "apps/*/test/**/*_bloc_test.dart"
---

# Cubit / Bloc rules

CLAUDE.md rule 10 and spec §13.1: Cubit-first `flutter_bloc`, resolved through
`get_it` + `injectable` (the owner's choice, docs/PROGRESS.md D1). **Flame
components never own game truth.**

## Shape

- **Default to Cubit.** Use `BaseAsyncBloc<E, S>` only when events must be handled
  strictly in order. The expected case is the M2 gameplay controller, which
  queues pick, drop, undo and hint. Anything else needs a `/plan`.
- `BaseAsyncBloc` registers the bloc's only handler itself (sequential, FIFO
  across every event type; bloc 9 is concurrent by default). Subclasses
  implement `handleEvent(event, emit)` with an exhaustive `switch` over the
  sealed event type and never call `on<...>`, which throws.
- Every async cubit extends `BaseAsyncCubit<T>` (`apps/game/lib/core/base/base_async_cubit.dart`)
  and emits `AsyncValue<T>` (`base_async_state.dart`). That is a freezed sealed
  union of `AsyncValueInitial | AsyncValueLoading | AsyncValueData | AsyncValueError`.
  `T` is a freezed data class (`@freezed abstract class FooState with _$FooState`).
- Exception: app-lifetime cubits that mirror a persisted store or auth stream
  and always hold a value (game `LanguageCubit`, admin `SessionCubit`) extend
  `Cubit<S>` directly and do an optimistic update with rollback. New feature
  cubits, including the M3 Settings toggles, use `BaseAsyncCubit`.
- The state file is a `part of` the cubit file, so there is one generated
  `<name>_cubit.freezed.dart` (see `apps/game/lib/features/home/cubit/`, the
  canonical shape for both apps). Don't copy the admin's `features/login/`:
  `LoginCubit extends BaseAsyncCubit<AdminUser>` with no state file is a
  deliberate exception (see its class comment).

```dart
part 'foo_cubit.freezed.dart';
part 'foo_state.dart';

@injectable
class FooCubit extends BaseAsyncCubit<FooState> {
  FooCubit(this._save);

  final SaveService _save; // an interface, never HiveDatabaseService

  Future<void> load() async {
    emit(AsyncValue.loading(data: state.data));
    await runGuarded(() async => FooState(currentLevel: _save.currentLevel));
  }
}
```

- `runGuarded` does not emit `loading` itself. Emit it first when the screen
  shows progress. On failure it emits `AsyncValue.error(exception:, data: <previous data>)`.
  If `onError` returns non-null, that value is emitted as data (the rollback path).
  `AppExceptionKind.cancelled` emits nothing. It checks `isClosed` before and
  after the body. Add `if (isClosed) return;` yourself only after an `await`
  that sits outside `runGuarded`.
- Nesty cubits start unseeded, unlike aquabuildr's
  `AsyncValue.initial(data: FooState())`, so `state.data` is null until the
  first data emit. Never write `state.data!`. To change existing data, take it
  once and handle null explicitly:
  `final current = state.data; if (current == null) return; await runGuarded(() async => current.copyWith(...));`.
  Use `(state.data ?? const FooState()).copyWith(...)` only when the defaults
  are a valid starting point. Never build a fresh state object that silently
  drops fields.
- Render with an exhaustive Dart 3 `switch` over the sealed cases
  (`AsyncValueData(:final data) => ...`). Don't use `is` chains.

## Errors

- Throw or propagate `AppException(AppExceptionKind.x)` (`core/error/app_exception.dart`).
  The UI maps the **kind** to an ARB string. It never shows `exception.message`,
  which is for logs only.
- Failures in network-backed services are not error states. The service fails
  silently and the cubit carries on with offline data (CLAUDE.md rule 3). Only
  local failures the player must act on (for example, bundled levels failing to
  load) become an `AsyncValueError`.

## Game truth (CLAUDE.md rules 2 and 10)

- A cubit or bloc that drives gameplay holds a `nesty_core` `GameSession` (M1)
  and calls its API: `tryMove`, `undo`, `addExtraSlot`, `hint`. It emits the
  resulting core state plus the `MoveEvent` list for Flame to animate. It never
  re-checks legality, detects completion or edits board data itself. If core
  lacks something, add it to core.
- Flame components and widgets send **intents** (for example "slot r0c2 tapped")
  to the cubit or bloc. They never change state.
- Solver work (hint, soft-stuck check, spec §2.3) runs in an isolate (rule 8)
  and never blocks input. If a move makes a result stale, drop it through
  `AppExceptionKind.cancelled`.

## Lifetime and DI

- Page cubits are `@injectable` factories provided at the route boundary: the
  page implements `AutoRouteWrapper` and returns
  `BlocProvider(create: (_) => get<FooCubit>()..load(), child: this)` from `wrappedRoute`.
- App-lifetime cubits (for example `LanguageCubit` in `lib/app/`) are `@lazySingleton`
  and provided once in `App` with `BlocProvider.value`.
- Dependencies arrive through the constructor, typed as interfaces. Don't call
  `get<T>()` inside methods.
- No `BuildContext`, navigation or localized strings inside a cubit. Handle
  side effects with a `BlocListener` in the page.

## Tests

- Use `bloc_test` + `mocktail`. Prefer the existing fakes
  (`core/services/**/fake_*.dart`, `core/repository/fake_*.dart`) to mocks.
- Call `registerFallbackValue(...)` in `setUpAll` for non-primitive arguments.
  Write one scenario per `blocTest`, and use `seed:` for the starting `AsyncValue`.
