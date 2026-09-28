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

# Hive rules (hive_ce 2.20 + hive_ce_flutter 2.3)

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
- No type is stored through an adapter: settings are primitives and the
  save is one JSON string (below), so `hive_ce_generator` was removed (D80).
  If a type ever needs one, add `hive_ce_generator` back with a rule-9
  reason and prefer hive_ce's `@GenerateAdapters([AdapterSpec<Foo>()], reservedTypeIds: HiveTypeIds.reserved)`
  in `core/services/database/hive_adapters.dart` over
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

## The save document (spec §13.3; decided: D63, D67, D68)

The owner chose a Hive box (Q3, D63). The design is
`docs/plans/m3-design.md` §3:

- **One JSON text** under the key `doc` (`SaveBoxKeys.document`) of the box
  `save` (`HiveBoxes.save`), opened with the settings box in
  `HiveDatabaseService.open`. Only `SaveService` reads and writes it, through
  `DatabaseService.readSaveDocument`/`writeSaveDocument`; features never see
  the box. One `put` of one key is one CRC-checked frame, and a torn frame is
  dropped on reopen, so the previous document survives: that is §13.3's
  atomic write.
- **Schema and migrations:** the document carries `"schema": 1`
  (`SaveDocument.currentSchema`). `SaveMigrations.steps` maps schema `v` to
  the step to `v + 1`; schema 0 means "no document". Migrations run in
  `SaveService.load`, before any read. A migrated, newer or unreadable
  document is first backed up under `doc_backup_v<schema>` or
  `doc_backup_invalid` (never overwriting an earlier backup).
- **Lenient reads:** `SaveDocumentCodec` never throws; a wrong type or range
  is that field's default, unknown top-level keys are kept and written back.
  Raising the schema needs a migration step and a test that migrates a real
  document of the old schema.
- **Writes:** one serial queue that coalesces changes; flushed on
  `AppLifecycleState.paused`/`detached`. The in-progress board is saved after
  every applied move, undo, restart and +1 Slot, and restored only when its
  request, level id and `levelVersion` match.
- **Settings stay in the `settings` box** (a recorded §13.3 deviation, D67).
- If Hive can't open, the save runs on the in-memory `FakeDatabaseService`
  fallback and the game stays playable.

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
- The save's own tests use the same temp-directory Hive: round trip,
  migration, a corrupt or newer document, a torn write (m3-design §14).
