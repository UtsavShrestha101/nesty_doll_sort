---
name: plan
description: |
  Produce an implementation plan BEFORE coding for any change that spans two or more
  workspace members or features, touches an app's lib/core/ or nesty_core's public
  API, adds a package, or changes a persisted format. Writes docs/plans/plan-<slug>.md
  and waits for the user's approval. Triggered by "/plan", or when the user describes
  a non-trivial change.
argument-hint: "<goal in one sentence>"
---

# /plan: design before code

## When to use
- A change spanning 2 or more workspace members (`packages/nesty_core`,
  `packages/nesty_render`, `apps/game`, `apps/admin`), or 2 or more features.
- Anything in an app's `lib/core/` (base, DI, router, services) or in
  `nesty_core`'s public API (`lib/nesty_core.dart`).
- A new package (CLAUDE.md rule 9: the reason goes in `docs/PROGRESS.md`).
- A persisted-format change: Hive boxes, typeIds or field indexes, the save
  document (§13.3), level `schemaVersion` (§5.1) or `generatorVersion` (§6.5).
  Bring in `migrations-engineer`.
- A new service, an isolate boundary, or an auto_route restructure.
- Breaking the next milestone (spec §18) into ordered steps.

## When NOT to use
- A single-file bug fix: `/debug`.
- A behavior-preserving restructure: `/refactor`.
- One more l10n key: `/l10n`. A standard new screen: `/feature`.

## Steps
1. **Restate the goal** in one sentence and confirm it with the user.
2. **Read the sources of truth**: the spec section(s) (`docs/GAME_SPEC.md`),
   `CLAUDE.md`, and `docs/PROGRESS.md` (decisions D*, open questions Q*,
   blockers). If the spec is ambiguous or contradicts the code, stop and ask.
   Never invent a game rule.
3. **Explore.** Spawn `code-explorer` to map the affected files, and
   `web-researcher` for library questions. For architectural choices, spawn
   `architect` and use its recommendation.
4. **Check the constraints:**
   - Rules only in `nesty_core` (rule 2), which stays pure Dart and web-safe
     (no `dart:io` / `dart:isolate`, 32-bit-safe bit ops).
   - Offline-first, with silent network failure (rule 3).
   - Interface + real + fake, bound per `AppEnv` (rule 4).
   - Deterministic core (rule 7) and 60 fps on 2 GB Android (rule 8).
   - Cubits extend `BaseAsyncCubit`, freezed 3 states, annotation-only DI,
     `@RoutePage` + `AppRouter`, ARB strings, `TODO(design)` when an export is missing.
   - Generated files are never edited; say which codegen runs.
5. **Choose ONE approach.** Name what you rejected and why, in one line each.
6. **Write `docs/plans/plan-<slug>.md`** (create `docs/plans/` if needed):
   - **Context**: why, the spec sections, the milestone
   - **Approach**: one paragraph
   - **Files**: a table per workspace member (path, create/modify, what changes)
   - **Reused code**: existing patterns to lean on (paths)
   - **Codegen**: `flutter gen-l10n`, then `dart run build_runner build`, in which app and when
   - **Packages**: each new one with its rule-9 reason, or "none"
   - **Verification**: the exact commands (analyze, the tests per member) and
     manual flows with flavor and device
   - **Risks**: the top 2–3, one line each
   - **Open questions** for the owner, if any
7. **Stop and ask for approval.** Write no production code until the user says yes.

## Output
- The plan path
- A 3-bullet TL;DR
- The number of files touched per member
- "Approved? If yes, I'll start with step 1: <step>."

## Anti-patterns
- Writing code first and "documenting" the plan afterwards.
- Several alternatives with pros/cons tables and no pick.
- Plans over ~150 lines. They don't get read.
- A plan that restates the request without reading the code or the spec.
- Skipping the verification section, or planning next-milestone work early.
