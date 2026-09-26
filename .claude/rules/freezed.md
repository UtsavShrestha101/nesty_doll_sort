---
name: freezed
description: freezed 3 conventions for app models and states (not used in nesty_core).
paths:
  - "apps/*/lib/**/model/**"
  - "apps/*/lib/**/models/**"
  - "apps/*/lib/**/*_state.dart"
  - "apps/*/lib/**/*_cubit.dart"
  - "apps/*/lib/core/base/**"
---

# freezed rules (freezed 3.2.5 + freezed_annotation 3.1.0)

Nesty uses **freezed 3**. Snippets written for freezed 2 do not compile. The
class must be `abstract` or `sealed`.

```dart
// Single-constructor data class (states, DTOs):
@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(1) int currentLevel,
    @Default(<String>[]) List<String> ownedSkins,
  }) = _HomeState;

  factory HomeState.fromJson(Map<String, dynamic> json) =>
      _$HomeStateFromJson(json); // only when it is really serialized
}

// Union: sealed + PUBLIC case classes so callers can pattern-match.
@freezed
sealed class AsyncValue<T> with _$AsyncValue<T> {
  const factory AsyncValue.data({required T data}) = AsyncValueData<T>;
  const factory AsyncValue.error({required AppException exception, T? data}) =
      AsyncValueError<T>;
}
```

- Add a private constructor `const Foo._();` only when the class declares its
  own getters or methods.
- Use `@Default(...)` instead of a nullable field wherever a sensible default
  exists.
- Consume unions with an exhaustive `switch` (`AsyncValueData(:final data) => ...`).
  freezed 3.1 brought back `when`/`map`, but the `switch` is checked by the
  compiler, so prefer it.
- Don't create a new async union. Every async screen state is `AsyncValue<T>`
  from `core/base/base_async_state.dart`.
- After editing, run `cd apps/<app> && dart run build_runner build`.
  Never hand-edit `*.freezed.dart` or `*.g.dart`, and commit them with the source.

## Where freezed does NOT go

- **`nesty_core`**: pure Dart with no codegen. CLAUDE.md asks for immutable
  models with hand-written `==`/`hashCode`, and the solver uses its own compact
  int state encoding (spec §6.2). Don't add freezed or json_serializable to
  core without a `/plan` and a reason in `docs/PROGRESS.md` (rule 9).
- **Level JSON** (spec §5.1): it is parsed by core's `LevelCodec`. Never add a
  second parser to an app, because that would be a second implementation of
  the rules (rule 2).
- **Hive-stored types**: hive_ce can generate adapters for freezed classes via
  `@GenerateAdapters`. See `hive.md` for the typeId contract before storing one.
