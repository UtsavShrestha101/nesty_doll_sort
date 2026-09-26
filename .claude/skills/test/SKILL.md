---
name: test
description: |
  Write and run tests for a Nesty target: nesty_core rules/codec/solver/generator,
  a feature's cubit (bloc_test) and page (widget test with fake services), or a
  service (contract tests). Spawns test-writer and test-runner. Triggered by
  "/test <target>", "write tests for X".
argument-hint: "<core[/<area>]|render|game/<feature>|admin/<feature>|<path>> [--cubit-only|--widget-only]"
---

# /test: write and run tests

## Map source to tests
| Source | Test | Runner |
|---|---|---|
| `packages/nesty_core/lib/src/<x>.dart` | `packages/nesty_core/test/<x>_test.dart` (+ `test/fixtures/`) | `dart test` |
| `packages/nesty_render/lib/src/<x>.dart` | `packages/nesty_render/test/<x>_test.dart` | `flutter test` |
| `apps/<app>/lib/features/<f>/cubit/<f>_cubit.dart` | `apps/<app>/test/features/<f>/<f>_cubit_test.dart` | `flutter test` |
| `apps/<app>/lib/features/<f>/pages/<f>_page.dart` | `apps/<app>/test/features/<f>/<f>_page_test.dart` | `flutter test` |
| `apps/<app>/lib/core/services/<s>/…` | `apps/<app>/test/core/services/<s>/…` (+ a shared `*_contract.dart`) | `flutter test` |
| Cross-feature flows (Splash → Home → Gameplay, admin sign-in) | `apps/<app>/test/app_flow_test.dart` | `flutter test` |

Feature tests sit flat in `test/features/<f>/` (see `apps/game/test/features/home/`).
Everything else mirrors `lib/`.

## Steps
1. Read the source **and the spec section it implements**. Expected values come from the spec.
2. Spawn `test-writer`, splitting the work into parallel runs where the files are independent (cubit and page, for example). It needs:
   - the source files and the spec section;
   - for core: the rule list to cover, including every invalid move;
   - for apps: which fakes to use (`configureTestDependencies()` from `test/helpers/`).
3. Run the tests through `test-runner` or directly, from the member directory:
   ```bash
   cd packages/nesty_core && dart test -r failures-only
   cd apps/game && flutter test -r failures-only test/features/<f>/
   ```
4. Triage. Test bugs go back to `test-writer`. Production bugs are reported and
   handed to the owner (`nesty-core-engineer`, `bloc-architect`,
   `flutter-frontend-dev`, `flame-engineer`, `services-engineer`).

## Output
- Tests created or updated (paths)
- Pass/fail counts per member
- Production bugs found (handed off, not fixed here)

## Anti-patterns
- Assertions copied from the implementation's own output.
- Network, real Hive paths or platform channels in tests.
- Running `flutter` or `dart` through a version-manager wrapper. This repo uses them from PATH (CLAUDE.md Commands).
