---
name: refactor
description: |
  Behavior-preserving restructuring in any workspace member: rename, extract a widget
  or method, split a file, move a feature or move code between members. Analyze and
  tests run before, after every step, and at the end. Triggered by "/refactor
  <target>", "refactor X to Y", "rename X", "move X to Y".
argument-hint: "<what to restructure, and into what>"
---

# /refactor: behavior-preserving structural change

## When to use
- Rename a class, method, file, feature or directory.
- Extract a widget out of a page, a method out of a large class, or a constant.
- Split a large file into focused ones.
- Move code between members, for example pure layout math from `apps/game`
  into `packages/nesty_render`.

## When NOT to use
- A bug fix: `/debug`. New behavior: `/plan`, then implement.
- Formatting and imports only: the `dart-formatter` agent.

## Hard rules
- **Behavior must not change.** Analyze is clean and tests pass before AND after
  every step. If behavior can't be preserved, stop and escalate to `/plan`.
- **`nesty_core` output stays identical**: same rule results, same `MoveEvent`
  order, byte-identical generator output. Otherwise it is not a refactor (it
  needs a `generatorVersion` bump, spec §6.5).
- **Persisted names are contracts, not refactor targets**: Hive box names
  (`HiveBoxes`), typeIds (`HiveTypeIds`), field indexes, save and level JSON
  keys, analytics event names (§14.4), Remote Config keys (§9.4) and product
  ids (§9.2). Renaming the Dart class behind a Hive adapter is fine only if its
  typeId stays. Anything else goes to `migrations-engineer`.
- **Dependency direction**: `nesty_core` ← `nesty_render` ← `apps/*`. Never
  move Flutter or Flame code into core, or Flame into `nesty_render`.
- **Generated files are regenerated, never edited.** ARB key renames go
  through `/l10n` (RENAME).

## Steps
1. **Baseline**, in every member you will touch:
   ```bash
   flutter analyze                                  # at the repo root
   cd packages/nesty_core && dart test -r failures-only
   cd apps/<app> && flutter test -r failures-only
   ```
   Also run `git status` once the repo is a git repository. Before that, keep
   a list of every file you touch. If anything is red before you start, stop
   and report it; don't mix it into the refactor.
2. **Plan the steps.** Name the smallest behavior-preserving unit and the
   order. If the code you're moving has no tests, write them first with `/test`.
3. **Apply ONE step**, then:
   ```bash
   cd apps/<app> && dart run build_runner build     # if annotated or part files moved
   flutter analyze
   <the member's tests>
   ```
   Green: continue. Red: undo that step and rethink.
4. **Repeat** until done.
5. **Final pass**: `dart-formatter` for imports and format, then
   `code-reviewer` to confirm that no behavior leaked.

## Recipes

### Rename a class `FooBar` to `BazQux`
1. Find the uses: `grep -rnw FooBar apps packages tools --include='*.dart'` (ignore generated files).
2. Rename the file (`git mv` once git exists, `mv` before), and update
   `part '...freezed.dart'` / `part of` directives to the new file name.
3. Update the declarations and `package:` imports, for example with Edit `replace_all`.
4. For `@freezed`, `@injectable`, `@RoutePage` or `@GenerateAdapters` classes, run build_runner in the app.
   A renamed page changes its generated route name (`FooBarRoute` becomes `BazQuxRoute`).
5. Analyze, then test.

### Extract a widget
1. Find the boundary: values in through the constructor, no closure over parent state.
2. Create `apps/<app>/lib/features/<feature>/widgets/<name>.dart`, importing `common_imports.dart`.
3. Replace the inline tree with it (`const` where possible), then analyze and test.

### Move a feature
1. Move `apps/<app>/lib/features/<old>` and its tests in `apps/<app>/test/features/<old>`.
2. Update the `package:nesty_<app>/features/...` imports and the entry in `AppRouter`.
3. Run build_runner, then analyze and test.

### Move code into a package
1. Check the target's rules: `nesty_core` is pure Dart with no DI and no
   codegen; `nesty_render` is Flutter without Flame.
2. Move the code and its tests, export it from the package barrel
   (`lib/nesty_core.dart` / `lib/nesty_render.dart`), and switch the apps to the barrel import.
3. Run core's `architecture_guard_test.dart` along with the rest of its tests.

## Output
- A step-by-step log, with the analyze and test result after each step
- Final summary: files renamed, moved or extracted, and codegen runs

## Anti-patterns
- Refactor plus new behavior in one change. Split them.
- "I'll write the tests after." Write them first, or stop.
- Skipping analyze or tests between steps.
- Hand-editing generated files instead of regenerating them.
- Rewriting history or force-pushing to tidy intermediate commits.
