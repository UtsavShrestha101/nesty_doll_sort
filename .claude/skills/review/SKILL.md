---
name: review
description: |
  Review the current diff (staged + unstaged, or a given file list before git exists)
  against Nesty's hard rules, conventions, security, the player respect rules (the
  ethics lens) and missing tests/l10n. Spawns code-reviewer and security-scanner in
  parallel. Run after writing code, before /commit.
---

# /review: quality gate before commit

## Steps
1. **Scope.** In a git repo:
   ```bash
   git diff --stat
   git diff --cached --stat
   ```
   Otherwise, ask for or derive the list of changed files.
2. **In parallel**, spawn `code-reviewer` (conventions, hard rules, tests) and
   `security-scanner` (secrets, real ad IDs, Firebase config and rules, storage),
   giving both the file list.
3. **Hardcoded strings.** Grep the changed Dart files under `apps/*/lib`:
   ```bash
   grep -nE "Text\(\s*['\"]|tooltip:\s*['\"]|semanticsLabel:\s*['\"]" <files>
   ```
   Any hit that does not come from `context.localizations` is a P1.
4. **Rules outside core.** Grep app changes for logic that belongs in
   `nesty_core`: legality checks, size arithmetic on dolls, completion or
   unlock logic, level JSON parsing (`jsonDecode` on level data). Any hit is a P0.
5. **Ethics lens** (E1, D92). Read the player respect rules in
   `docs/plans/spec-proposals-m7.md` §1.1 (the approved rule text until the owner
   pastes it into the spec, Q85) and check the diff against each of them and the six
   questions of `docs/plans/offline-game-brainstorm.md` §5:
   1. Can every level still be won from its start without an ad, a purchase or a
      booster?
   2. Is every reward shown before it opens and deterministic: no paid or unpaid
      randomness, no loot box, gacha or mystery chest?
   3. Is there any timer, countdown, limited-time offer or scarcity framing, or an
      offer shown because the player failed, got stuck or is about to lose a streak?
      There must be none, and a streak is never sold back.
   4. Is every computer rival labelled "Computer" on every screen it appears on,
      never with a human avatar, an "online" status or chat?
   5. Does anything punish absence or shame a loss, in copy, streaks or
      notifications? A missed day never takes away anything earned.
   6. Is every non-essential prompt or notification off by default, value-framed,
      at most one a day, and switchable in Settings?

   Look hardest at new or changed ARB values (loss, guilt, urgency or scarcity
   wording), reward and save paths (`Random`, `DateTime.now`), anything that opens
   after a loss (out of moves, soft stuck, a paused streak), rival surfaces, and the
   defaults of prompts and notifications. Run the E1 tests:
   `cd apps/game && flutter test test/ethics/`. A failing answer or a failing E1
   test is a P0; copy that only reads close to the line is a P1. The rules are the
   owner's: a finding says what breaks a rule, it never proposes a new one.
6. **Codegen freshness.** If `@freezed`, `@injectable`, `@RoutePage`,
   `@AutoRouterConfig`, `@GenerateAdapters` or `.arb` sources changed, the
   matching generated files must be in the diff. If not, ask the user to run
   `flutter gen-l10n`, then `dart run build_runner build`, in that app.
7. **Test coverage** (CLAUDE.md "Testing", D169). A new or changed feature
   with no device step in `tools/scripts/nesty-test`, or no row in
   `docs/TEST_COVERAGE.md`, is a P1. Run `cd tools && dart test
   test/test_coverage_test.dart`.
8. **Checks.** Run `flutter analyze` at the repo root (it must print "No issues
   found!"). If core changed, also run `cd packages/nesty_core && dart test -r failures-only`.
9. **Aggregate** everything into one report.

## Output format
```
## Review summary
- Files: N | +X / -Y | Risk: low/medium/high
- analyze: clean / N issues · core tests: pass / fail / not run

## P0 (must fix before commit)
- path:line — description
  Fix: <one line>
## P1 (should fix)
## P2 (nice to fix)

## Ethics lens (spec-prop §1.1; brainstorm §5)
- Per feature the diff touches: the six answers (yes / no / n.a.), each with
  its evidence `path:line`; any "no" is also listed under P0
- E1 tests (`test/ethics/`): pass / fail

## Codegen
- build_runner: needed / fresh · gen-l10n: needed / fresh / n.a.

## What looks good
- ...
```

## Anti-patterns
- Findings without `path:line`, or findings with no suggested fix.
- Skipping the security pass, the ethics lens or the "what looks good" section.
