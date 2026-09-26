---
name: milestone
description: |
  Close out (or check) a milestone per CLAUDE.md Workflow: run the baseline gate
  (codegen drift, format, analyze, all four test suites, app builds), then the
  milestone's own spec §18 acceptance criteria, classify each as pass / fail / needs
  owner or device / blocked, and update docs/PROGRESS.md. Triggered by "/milestone
  M<N>", "close out M1", "are M2's acceptance criteria met?".
argument-hint: "<M0..M8> [--check-only]"
---

# /milestone: verify acceptance criteria, then record them

CLAUDE.md Workflow: don't start the next milestone until the current one's
acceptance criteria pass. At the end of each milestone, run `flutter analyze`
and all tests, then update `docs/PROGRESS.md`. This skill does both, with
evidence.

## Inputs
- `M<N>`: the milestone. M1–M8 are spec §18. M0, the architecture skeleton,
  is defined in `docs/PROGRESS.md`: analyze clean, every test passes, every app builds.
- `--check-only`: run and report, but leave `docs/PROGRESS.md` unchanged.

## Steps

### 1. Read the criteria
- The spec §18 entry: scope and the ✅ line.
- `docs/PROGRESS.md`: the status table, that milestone's section, blockers
  (B*) and open questions (Q*) that affect it. A question the owner hasn't
  answered is BLOCKED, never quietly resolved.
- Turn the ✅ line (and any scope item without which it can't be true) into a
  numbered checklist.

### 2. Baseline gate (every milestone)
Run from the repo root, in this order, and keep each exit code:
```bash
flutter pub get                    # the root pubspec.lock must not change
(cd apps/game  && flutter gen-l10n && dart run build_runner build)
(cd apps/admin && flutter gen-l10n && dart run build_runner build)
flutter analyze --fatal-infos --fatal-warnings
(cd packages/nesty_core   && dart test)
(cd packages/nesty_render && flutter test)
(cd apps/game  && flutter test)
(cd apps/admin && flutter test)
```
- **Codegen drift**: with git, `git status --porcelain` must be empty after
  codegen. Without git, take a checksum of every generated file
  (`*.freezed.dart`, `*.g.dart`, `*.gr.dart`, `di.config.dart`,
  `lib/l10n/app_localizations*.dart`) with `shasum` before and after, and diff them.
- **Format**: `dart format --output=none --set-exit-if-changed` on the
  hand-written Dart files (CI's list: `.github/workflows/ci.yaml`).
- **Builds**. The game always needs `--flavor <f> -t lib/main_<f>.dart`:
  ```bash
  (cd apps/game  && flutter build apk --debug --flavor dev  -t lib/main_dev.dart)
  (cd apps/game  && flutter build apk --flavor prod -t lib/main_prod.dart)
  (cd apps/game  && flutter build ios --no-codesign --flavor dev -t lib/main_dev.dart)   # macOS only
  (cd apps/admin && flutter build web -t lib/main_prod.dart)
  ```
Any failure here fails the milestone. Report it; don't paper over it.

### 3. Milestone checks (spec §18)
Automate what can be automated. Write out the manual steps for the rest.

| M | Criterion | How to verify |
|---|---|---|
| M0 | Analyze clean, every test passes, every app builds | The baseline gate is the whole check |
| M1 | All §4 rules unit-tested | Map each §4 rule (and each invalid move) to a test name in `packages/nesty_core/test/`. List any rule with no test |
| M1 | Solver fixtures pass | Known-solvable and known-unsolvable levels in `test/fixtures/` all pass. An exhausted budget is `unknown`, never `unsolvable` |
| M1 | Generator is deterministic | The same seed and params give identical output in a test (twice in one run, and across runs). Also run `dart test -p chrome` if Chrome is installed, because the admin runs core in the browser |
| M1 | 100 generated levels validate and solve | A test (or `tools/generate_levels` once it exists) over 100 seeds |
| M2 | Levels 1–30 playable at 60 fps on a mid-range Android | Automated: all 30 bundled levels validate and solve. Manual: play 1–30 in profile mode on the device, with numbers from `/perf-profile` |
| M3 | Kill mid-level, resume exactly | Save/restore round-trip tests (state, undo, `levelVersion` match). Manual: swipe the app away mid-level on a device and relaunch |
| M3 | Daily puzzle identical on two devices | A test that seed `yyyymmdd` gives the same level every run. Manual: two devices, same date |
| M4 | Airplane mode on first launch, fully playable | Tests with the network services failing. Manual: fresh install with networking off, then play |
| M4 | Published levels appear on the next resume | Manual against `cd firebase && firebase emulators:start` (or stg): publish in the admin, resume the game |
| M5 | Build, solve, simulate, playtest and publish a level; an uploaded skin shows up in the game | An owner walkthrough on emulators or stg, plus the Firestore/Storage rules tests |
| M6 | Every §9.1 pacing rule unit-tested with a fake clock | Map each §9.1 rule to a test with an injected clock |
| M6 | Offline ad buttons fall back to coins | A widget test with a fake `AdsService` that has no fill. Manual: airplane mode |
| M7 | Matches the design screens | Compare against `design/screens/*.png` (`ui-designer`). The owner signs off |
| M7 | No overflows on 5 screen sizes | Widget tests at small Android, standard phone, tall phone, small iPhone and iPad portrait, at 1.0× and 1.3× text scale |
| M8 | Release builds on real devices with production Firebase | Owner-run. Also check app size < 60 MB: `flutter build appbundle --release --flavor prod -t lib/main_prod.dart --analyze-size --target-platform android-arm64` (one ABI per run), and the iOS equivalent on macOS |

### 4. Classify every criterion
- **PASS**: with the command and the relevant output line.
- **FAIL**: with the evidence, and who fixes it (the owning agent).
- **NEEDS OWNER / DEVICE**: Claude can't run it (a physical device, two
  devices, store or production Firebase access, design sign-off). Write the
  exact steps.
- **BLOCKED**: with the blocker or question id from `docs/PROGRESS.md`.

The milestone is **done** only when every criterion is PASS, or the owner has
explicitly confirmed the NEEDS OWNER items. Otherwise it stays "in progress".

### 5. Update `docs/PROGRESS.md` (unless `--check-only`)
Follow the existing structure (the `docs-writer` agent owns this shape):
- **Status table**: that milestone's row and status, with the date when done.
- **Milestone section** `## M<N> — <name> — <status>`: Done, Decisions (with
  reasons), Packages added (each with its rule-9 reason, and whether spec
  §13.2 lists it), Open questions, and a dated **Verification** table
  (command | outcome) covering every gate and criterion above.
- The **Last updated** date and the **Next step** section.
- New open questions get the next free `Q<n>` id.

Never edit `docs/GAME_SPEC.md` or `CLAUDE.md` to make a criterion pass.
Propose spec changes as open questions.

## Output
```
## M<N> — <name>: done | in progress | blocked
| # | Criterion | Result | Evidence |
|---|---|---|---|
| 1 | ... | PASS / FAIL / NEEDS OWNER / BLOCKED | <command → output line> |

Baseline: pub get <lock unchanged?> · codegen drift <none/N files> · format <ok> ·
analyze <clean> · tests core a/b, render a/b, game a/b, admin a/b · builds <apk dev/prod, ios, web>

PROGRESS.md: updated (<sections>) / not updated (--check-only)
Next: <what must happen before M<N+1> can start>
```

## Anti-patterns
- Marking a milestone done with a failing, skipped or unverified criterion.
- Reporting device, performance or two-device checks that were never run.
- Starting the next milestone's work inside the close-out.
- Loosening a test, a lint or an analyzer flag to get green.
- Rewriting earlier milestones' entries in `docs/PROGRESS.md` instead of appending.
