# Claude Code prompt: build the daily gift

Paste everything below the line into a fresh Claude Code session in the
repo. Run `/clear` first if the session already has another task in it. It
starts the next BACKLOG task: the daily gift (D268), which D272 lets start
while M7's owner sign-offs stay open.

---

Build the daily gift: the 7-day login reward I approved (PROGRESS D268, with
Q182's defaults). D272 lets it start now, while M7's sign-offs are still
open. Build it fully offline (D269).

**Read first, by section, not whole:**
- `docs/plans/plan-login-gift.md`. Its §7.5b is the rule, and it counts as
  spec until I paste it in.
- BACKLOG "Daily gift". That is the work list; tick each item with its
  evidence.
- PROGRESS D268, D269 and D272.
- CLAUDE.md's "Working within Claude's usage limits".

**Stages.** Each stage keeps a checkpoint file in `build/login-gift/`
(git-ignored) and appends its findings to its report as it goes.
1. **Rules and data, host only:**
   - `LoginGiftRules`, pure, beside `MilestoneChest`;
   - the Remote Config string key `login_gift_track`, with its bundled
     default and a fallback to it when malformed (rule 6);
   - save schema 2→3, done by `migrations-engineer`: `LoginGiftProgress`
     and `SaveService.claimLoginGift`, with the migration and contract
     tests.

   This stage's own lanes may run in parallel where their files don't
   overlap.
2. **State, UI and copy:**
   - `LoginGiftCubit`, then `GiftButton`, `GiftSheet` and `GiftDayTile` on
     Home;
   - the claim's flights, and Day 7 through `ChestRewardSequence`;
   - reduce motion and the screen-reader labels.

   Claude Design's frames (section 13 of `nesty-design-m7-5`) arrive after
   2026-10-07, so build on the tokens and house style with `TODO(design)`
   stand-ins, and leave the swap points easy to find. Then:
   - the strings in all nine catalogs, with the Opus translation review
     (D240);
   - the overflow suite in nine locales, and `gen_font_subsets` plus
     `build_fonts.sh` if a kanji is new;
   - `test/ethics/login_gift_respect_test.dart`;
   - `login_gift_claim` through `AnalyticsService` (the fake until M4).
3. **On a device (D169):**
   - `integration_test/login_gift_test.dart`, with the scenarios `ready`,
     `claimed`, `day7` and `clock_back`;
   - `nesty-test --only gift`, with its README and CLAUDE.md Commands lines;
   - the playthrough's Home shot and the TEST_COVERAGE row;
   - a pass on the iPhone 16e and on the Android emulator.

   Run the device steps as background scripts.
4. **Close:**
   - `/review` with the security scanner and the ethics lens, then fix what
     it finds;
   - PROGRESS gets the decisions from D276 and any questions from Q186;
   - BACKLOG ticked;
   - CLAUDE.md's Code map and Current state;
   - `dart run nesty_tools:todo_index`;
   - the full `nesty-test --only gates`.

**My standing rules (verbatim):**
- Never edit GAME_SPEC.md or anything in design/.
- Keep CLAUDE.md's facts current in the same change, and never change its
  rules.
- Rules come only from the spec, spec-proposals-m7.md and PROGRESS
  decisions, never from tokens.json. For the gift, the plan's §7.5b
  (approved, D268) counts as spec.
- If something is still ambiguous, stop and ask.
- Never reuse a Hive box name, typeId or field index. A new save field is a
  schema step with a migration.
- A new package or font needs its reason in PROGRESS.
- Every new or changed feature ships with host tests, a nesty-test device
  step and its TEST_COVERAGE row (D169).
- Leave my iPhone 15 Pro Max simulator alone (5D28401E-76FA-40BA-B458-5DCD9C8A9D55):
  - never boot, shut down, erase, install on or screenshot it;
  - never run `simctl shutdown all`;
  - always pass a UDID.

  Use the iPhone 16e (87BDED37-4095-49C4-811A-3E2B7D5FB38B) and the Android
  emulator (AVD `flutter_emulator`). Warm the emulator up for 90 s after it
  boots.
- Check for at least 20 GB free before each device run. If space is short,
  tell me instead of deleting anything outside the repo and the scratchpad.
- Don't commit until I say. Conventional commits, no attribution, never
  force-push. Never commit secrets or real AdMob IDs.
- The respect rules (D92, spec-prop §1.1):
  - every gift is visible before it is claimed;
  - no countdown, no timer and no "missed" mark;
  - a gap never lowers the track;
  - nothing pops up on its own;
  - no ad or purchase in the gift's paths.

Start with stage 1, and tell me when each stage is done.
