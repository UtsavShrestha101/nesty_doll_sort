---
name: review
description: |
  Review the current diff (staged + unstaged, or a given file list before git exists)
  against Nesty's hard rules, conventions, security and missing tests/l10n. Spawns
  code-reviewer and security-scanner in parallel. Run after writing code, before /commit.
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
5. **Codegen freshness.** If `@freezed`, `@injectable`, `@RoutePage`,
   `@AutoRouterConfig`, `@GenerateAdapters` or `.arb` sources changed, the
   matching generated files must be in the diff. If not, ask the user to run
   `flutter gen-l10n`, then `dart run build_runner build`, in that app.
6. **Checks.** Run `flutter analyze` at the repo root (it must print "No issues
   found!"). If core changed, also run `cd packages/nesty_core && dart test -r failures-only`.
7. **Aggregate** everything into one report.

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

## Codegen
- build_runner: needed / fresh · gen-l10n: needed / fresh / n.a.

## What looks good
- ...
```

## Anti-patterns
- Findings without `path:line`, or findings with no suggested fix.
- Skipping the security pass or the "what looks good" section.
