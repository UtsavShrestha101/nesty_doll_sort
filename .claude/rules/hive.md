---
name: hive
description: hive_ce local storage rules for apps/game (boxes, typeIds, field indexes, fakes).
paths:
  - "apps/game/lib/core/services/database/**"
  - "apps/game/lib/core/services/save/**"
  - "apps/game/lib/core/dependency_injection/database_module.dart"
  - "apps/game/lib/**/hive*"
  - "apps/game/test/core/services/database/**"
---

# Hive rules (hive_ce 2.20 + hive_ce_flutter 2.3 + hive_ce_generator 1.11)

`hive_ce` is the maintained fork of Hive 2 with the same API. Import
`package:hive_ce/hive_ce.dart` or `package:hive_ce_flutter/hive_ce_flutter.dart`,
never `package:hive/...`. Hive is used **only in apps/game**. The admin is
Flutter Web and keeps its data in Firestore, so it has no local database.
`nesty_core` never touches storage.

## Opening

- Hive is opened **once**, during `configureDependencies()`. `DatabaseModule`
  is `@preResolve`d and calls `HiveDatabaseService.openOrFallback()`, and
  bootstrap awaits it before `runApp`. Never call `Hive.openBox` or
  `Hive.box(...)` from a feature, cubit or widget.
- Features depend on the `DatabaseService` interface (or a higher-level
  service built on it, such as `SaveService`), never on `HiveDatabaseService`
  or a `Box`.
- If Hive cannot open, the game logs and falls back to the in-memory
  `FakeDatabaseService`, so it is still playable (CLAUDE.md rule 3). Keep that
  fallback working whenever the interface grows.
- Box names live in `HiveBoxes` (`core/services/database/hive_boxes.dart`) and
  are a contract: renaming a box orphans the data in the old one.

## typeIds and field indexes are a contract with players' devices

- The registry is `HiveTypeIds` (`core/services/database/hive_type_ids.dart`).
  Never reuse a typeId, even after the type is deleted: move it to "Retired".
  Ids 200 and 201 are reserved by hive_ce_flutter (`Color`, `TimeOfDay`).
- Prefer hive_ce's `@GenerateAdapters([AdapterSpec<Foo>()], reservedTypeIds: HiveTypeIds.reserved)`
  in `core/services/database/hive_adapters.dart` (create it with the first
  stored type; today settings are primitives, so neither file exists yet) over
  per-field `@HiveType`/`@HiveField` annotations. build_runner then writes
  `hive_adapters.g.yaml`, the schema that
  pins every typeId and field index. **Commit it.** It is the one generated
  file that may need a manual edit during a migration, so the block-generated
  hook allows it.
- Field indexes are never reused. New fields take the next index. A removed
  field leaves a gap.
- Changing a field's type, or removing a non-nullable field, needs an explicit
  migration step that runs in `open` before any read. Plan it with the
  `migrations-engineer` agent.
- Reads are type-checked and fall back to defaults instead of throwing (see
  `_readBool` in `hive_database_service.dart`). A corrupt or future-schema
  value must never crash the game.
- Register adapters in `HiveDatabaseService.open` with `Hive.registerAdapters()`
  (the generated `HiveRegistrar` extension), before any box opens.

## The save document (spec §13.3) is an open M3 decision

Spec §13.3 describes the save as an atomic JSON file (write to a temp file,
then rename) with a schema version and migrations. Today the Hive box holds
only device **settings**. Whether the M3 save document lives in a Hive box or
in the spec's JSON file is an open question for the owner, so don't decide it
silently. Either way the spec's contract holds: a `schema` version, forward
migrations, a save on every move and on app pause, and restore-on-resume only
when `levelVersion` still matches.

## Sensitive data

Hive boxes are plain files. No secrets, tokens or purchase receipts go in an
unencrypted box. v1 has none: receipts are verified on the client (spec §9.2).
If one ever appears, use an encrypted box with a key from secure storage. That
needs a new package, so add a `/plan` and a `docs/PROGRESS.md` reason first
(rule 9).

## Tests

- Unit tests use `FakeDatabaseService`, or `HiveDatabaseService.open(directory: tempDir)`,
  which is pure-Dart `Hive.init` with no platform channels, for round-trip tests.
- Every `DatabaseService` implementation must pass the shared contract in
  `test/core/services/database/database_service_contract.dart`. Extend the
  contract whenever the interface grows.
- After changing an adapter, run `cd apps/game && dart run build_runner build`.
