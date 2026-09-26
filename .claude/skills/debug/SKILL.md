---
name: debug
description: |
  Structured 5-hypothesis debugging for Nesty: reproduce, enumerate causes across
  core / Flame / cubit / DI / storage, narrow to one, fix at the right layer, add a
  regression test that fails without the fix. Triggered by "/debug", "this is broken",
  "this crashes", "why does X not work".
argument-hint: "<symptom, stack trace or failing test>"
---

# /debug: find the root cause, then fix

## When to use
- A crash, exception or wrong behavior with a repro (or a failing test).
- Tests pass but the app misbehaves, or the reverse.
- "It worked yesterday" regressions.

## When NOT to use
- Unsure what to build: `/plan`.
- "How do I do X in Flame / auto_route / hive_ce": `/research`.
- A move the player thinks should be legal. Check spec §4 first: if the code
  matches the spec, it is a spec question for the owner, not a bug.

## Steps

### 1. Reproduce
Get a deterministic repro. Ask for anything missing:
- App (`game` or `admin`), flavor (dev/stg/prod), platform and device
  (Android/iOS model and RAM, or the browser for the admin), debug or profile build.
- Level id and the move sequence for gameplay bugs. For generated levels,
  the seed and params (spec §6.5) reproduce them exactly.
- Real or fake services (`--dart-define=NESTY_FAKE_SERVICES=true`), online or offline.
- The stack trace or log lines, verbatim. Logs are `developer.log` with names
  such as `nesty.bootstrap`, `nesty.database`, or the cubit's class name
  (`runGuarded`).

Run it the same way:
```bash
cd apps/game && flutter run --flavor dev -t lib/main_dev.dart
cd apps/admin && flutter run -d chrome -t lib/main_dev.dart --dart-define=NESTY_FAKE_SERVICES=true
```
If there is no repro, STOP and ask. Don't guess.

### 2. Enumerate 5 hypotheses
Five distinct causes in different layers. Typical Nesty candidates:
1. **Rule bug in `nesty_core`**: `tryMove` legality, nesting, completion or the
   `MoveEvent` order differs from spec §4.
2. **Flame owns truth** (CLAUDE.md rule 10): a component keeps a stale copy of
   the board, or plays events out of core's order.
3. **Cubit lifecycle**: an emit after `close` outside `runGuarded`, a swallowed
   `AppExceptionKind.cancelled`, or data dropped by building a fresh state
   instead of `copyWith`.
4. **DI environment**: the wrong implementation bound for `AppEnv.real` /
   `AppEnv.fake`, or a stale `di.config.dart` / `app_router.gr.dart` after an
   annotation change (build_runner not run).
5. **Storage**: Hive failed to open and the game silently fell back to
   `FakeDatabaseService` (look for the `nesty.database` log), or a stored value
   has the wrong type.
6. **Web-only integer behavior** (admin): bitwise ops truncate to 32 bits under
   dart2js (spec §6.2 hashing).
7. **Native flavor config**: a missing `--flavor`, the wrong iOS scheme, or a
   bundle-id mismatch.

### 3. Narrow to one
For each hypothesis, run the cheapest test that rules it in or out:
- `grep -rn` the symbol from the stack trace across `apps/` and `packages/`
  (or ask `code-explorer`).
- Replay the move sequence in a throwaway `nesty_core` test: if core already
  misbehaves, the app is innocent.
- Regenerate: `cd apps/<app> && flutter gen-l10n && dart run build_runner build`.
  If the symptom changes, it was stale codegen.
- Recent changes: `git log --oneline -20 -- <path>` once the repo is a git
  repository. Before that, ask the user what changed.

Stop when ONE hypothesis is clearly confirmed. Don't fix until you are sure.

### 4. Fix at the right layer
- The smallest change, with no collateral cleanup (a bug fix is not a refactor).
- A rule bug is fixed in `nesty_core` only (CLAUDE.md rule 2), citing the spec
  section, via `nesty-core-engineer`. If the spec is ambiguous, stop, ask the
  owner and record the question in `docs/PROGRESS.md`.
- Never hide a failure with `try { } catch (_) {}`. Map it to
  `AppException(kind)`. Network failures stay silent by design (rule 3), local
  ones do not.

### 5. Regression test
- Core rule: a `dart test` case with the spec's expected events, including the invalid move.
- Cubit: a `bloc_test` for the broken transition.
- UI or flow: a widget test on `configureTestDependencies()`.
- Service: extend the shared contract (for example `database_service_contract.dart`).

Prove it: the new test FAILS without the fix and PASSES with it (toggle the
fix once). Run it from the member's directory (`dart test` in
`packages/nesty_core`, `flutter test` elsewhere).

## Output format
```
## Repro
<exact steps, app, flavor, device>

## Hypotheses considered
1. <h1> — ruled out because <evidence>
2. <h2> — CONFIRMED: <evidence>
3. <h3> — not investigated (h2 confirmed)
...

## Root cause
<one paragraph, with the spec section if a rule is involved>

## Fix
<path:line list, one line each>

## Regression test
<test path> — fails without the fix, passes with it
```

## Anti-patterns
- "Try this and see." If you can't say why the fix works, it isn't a fix.
- Fixing a rule in a cubit, widget or Flame component, or "fixing" the spec to match the code.
- Catching exceptions as the fix.
- Skipping the hypothesis list on an "obvious" bug.
- A regression test that was never seen failing.
