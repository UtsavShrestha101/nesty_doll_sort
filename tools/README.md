# tools/

Developer scripts for Nesty. **Nothing is implemented yet** — this file lists the
planned scripts so they land in the right place, in the right milestone.

## Ground rules for every script here

- **No game rules here.** Scripts import `nesty_core` for parsing, validation,
  solving and generation (CLAUDE.md rule 2). If a script needs a rule that
  `nesty_core` does not expose, add it to core first.
- **Deterministic.** Anything that generates or orders levels takes an explicit
  seed and uses core's PRNG (CLAUDE.md rule 7, spec §6.5). The same input gives
  byte-identical output, so the bundle diffs cleanly in review.
- **Pure Dart where possible** (`dart run`, no Flutter), so scripts run in CI.
- **No secrets.** Firestore access goes through the owner's own credentials at
  run time (for example `GOOGLE_APPLICATION_CREDENTIALS` pointing outside the
  repo), never a committed key.
- Adding a script needs a Dart package: make `tools/` a workspace member (root
  `pubspec.yaml` + `resolution: workspace`) and write down why each new
  dependency is needed in `docs/PROGRESS.md` (CLAUDE.md rule 9).

## Planned scripts

| Script | Milestone | Purpose |
|---|---|---|
| `validate_levels` | M2 | Load a level JSON file or `apps/game/assets/levels/bundle.json`, run the spec §5.3 validator and the solver (admin budget, §6.3) on every level, print a per-level report, exit non-zero on any failure. CI runs it on the bundled levels. |
| `export_level_bundle` | M5 | Headless version of the admin's "Export bundle" (spec §15 screen 9): read the first N `levels` where `status == published` ordered by `order` (the query and composite index from spec §13.4 / `firebase/firestore.indexes.json`), validate each one, and write `apps/game/assets/levels/bundle.json` with stable key order and `order`-sorted levels. The admin button stays the primary path; the script exists so a bundle can be rebuilt reproducibly in CI or on a release branch. |
| `generate_levels` | M1–M2 | Batch-run the core generator (spec §6.5) with explicit params and seed to produce fixtures or draft levels, including `generatorVersion`. Used for the M1 acceptance check ("100 generated levels pass validation and solve"). |
| `simulate_levels` | M1–M5 | Run the casual and smart bots (spec §6.4) over a file of levels and print win rates and the suggested tier. It is the same computation as the admin's Simulate button. |

Each script prints a short summary. With `--json`, it prints machine-readable
output for CI.
