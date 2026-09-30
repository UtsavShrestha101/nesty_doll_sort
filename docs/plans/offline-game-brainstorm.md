# The offline game: research and brainstorm (M7, D92–D93)

Date: 2026-09-28. Owner decisions: D90 (offline first), D92 (audience,
respect rules, eight engagement features) and D93 (vs Computer) in
[PROGRESS.md](../PROGRESS.md). The work list is [BACKLOG.md](../BACKLOG.md)
"M7". Related documents:
- [mode-vs-computer.md](mode-vs-computer.md): the race;
- [spec-proposals-m7.md](spec-proposals-m7.md): the spec text for the owner;
- [claude-design-request-m7.md](claude-design-request-m7.md): the art and copy.

## How this was made

Two read-only research workflows ran on 2026-09-28:
- Six web researchers covered the genre, meta, modes, ethics, feel and level
  design (84 findings, 79 raw ideas).
- Two code mappers covered core and tools, and the app and design.
- Five topic clusters each had a synthesizer, two critics and an editor.
- A planner merged the result.

The lead then checked every claim that touches the code or the spec. The
research got several things wrong, corrected here:
- The simulator has exactly two bots, casual and smart (spec §6.4). There is
  no expert bot, and both are internal to nesty_core.
- The solver is A* and returns the optimal move list, so a par is computable.
- Size-pitched clacks and the `complete_1..5` combo chimes are already built
  (`apps/game/lib/features/gameplay/game/timeline/combo_tracker.dart`).
- The streak reset is spec §7.5's rule, not a bug.
- `bundle check` already enforces solvability (§5.3 rule 8) and the §6.4 tier
  bands.

**Audience (owner, D92):** 13+ with an all-ages feel. Spec §1 is unchanged:
adults 18–55 are the core, and the game is not made for or marketed to
under-13s. Engagement features are still designed as if children may use the
game. The UK Children's Code judges by who is *likely* to use a service, not
by its store rating, and cute doll art draws younger players. So
notifications are off by default, copy is value-framed and nothing nudges.

## 1. What the research says

**The genre** (sort puzzles grew fastest of any puzzle sub-genre in 2024–2026:
[PocketGamer.biz](https://www.pocketgamer.biz/one-genre-three-strategies-how-magic-sort-knit-out-and-pixel-flow-are-redefining-sort-puzzle-monetisation/),
[AppMagic](https://appmagic.rocks/research/casual-report-2025)):
- **Churn:** the top churn driver in reviews is a level that can't be passed
  without an ad or a paid booster (Ball Sort, Match Factory, Wood Block Jam
  store reviews). Titles that keep ads out of play get praised for it.
- **Difficulty:** nearly every top title uses a sawtooth curve. Easy levels
  build to a signposted hard "boss", then relief comes
  ([Mobile Game Doctor](https://mobilegamedoctor.com/2025/05/30/illuminating-level-creation-for-free-to-play-puzzle-games/)).
  §6.6's `E E M E M H M E M S` pattern already has this shape.
- **Mechanics:** new mechanics arrive on a staircase and then mix with known
  ones: teach, practise, combine, escalate
  ([PocketGamer.biz on Candy Crush](https://www.pocketgamer.biz/crafting-candy-crushs-difficulty-blockers-level-design-ai-and-the-complexity-staircase/),
  [Color Block Jam](https://medium.com/@elifecekusku/color-block-jam-evolution-of-puzzle-genre-e51c517d8a21)).
  Bots grade difficulty before release, as a support to human judgement,
  never a replacement.
- **Competitors:** the nesting-doll competitors on the stores use match-3 burn
  rules, not nest-by-size
  ([Nesting Dolls Jam](https://play.google.com/store/apps/details?id=com.boldcat.nesting.dolls.jam)).
  Nesty's core rule is distinctive.

**The daily habit:**
- **Retention benchmarks:** puzzle games retain about 30–32 % on day 1, 12 %
  on day 7 and 5 % on day 30
  ([Segwise](https://segwise.ai/blog/mobile-gaming-app-user-retention-strategies)).
  First-session value decides day 30.
- **Share card:** Wordle's spoiler-free share card is the reference for turning
  a daily puzzle into word of mouth
  ([The Verge](https://www.theverge.com/2022/2/4/22919172/wordle-sharing-buttons-new-york-times)).
- **Streaks:** a streak that punishes absence drives churn and shame. A
  freeze or grace design keeps the habit without the threat
  ([UX Magazine](https://uxmag.com/articles/the-psychology-of-hot-streak-game-design-how-to-keep-players-coming-back-every-day-without-shame)).
  PEGI's 2026 criteria rate "punishes non-return" mechanics higher than
  "rewards return" ([PEGI](https://pegi.info/news/pegi-expands-age-rating-criteria-interactive-risk-categories)).
- **Reminders:** they work when they are opt-in, value-framed, capped and
  respect quiet hours ([Braze](https://www.braze.com/resources/articles/push-notifications-best-practices)).
  The ICO wants non-essential notifications off by default where children may
  be users
  ([ICO Standard 5](https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/childrens-information/childrens-code-guidance-and-resources/age-appropriate-design-a-code-of-practice-for-online-services/5-detrimental-use-of-data/)).

**Meta and collection:**
- **Rewards:** deterministic chests and collections retain without loot-box
  risk
  ([GameRefinery](https://www.gamerefinery.com/attracting-and-retaining-players-with-collection-systems/)).
  A visible next goal uses the goal-gradient effect, but "always another bar"
  can feel like a treadmill
  ([Userpilot](https://userpilot.com/blog/progress-bar-psychology/)).
- **Records:** personal records and cosmetic badges suit two different
  motivations
  ([Trophy](https://trophy.so/blog/designing-achievements-for-optimal-user-engagement)).
- **Display:** a collection retains best when it can be shown off
  ([Yu-kai Chou](https://yukaichou.com/gamification-guest-posts/10-collection-experiences-cant-live-without/)).
- **Decoration:** it is match-3's long-tail engine, but its art cost is large
  ([GameRefinery](https://www.gamerefinery.com/how-to-crack-the-match-3-code-part-4-project-makeover/)).

**Modes and computer rivals:**
- **Label bots:** bots presented as humans are the clearest legal risk. In
  Skillz v. Papaya Gaming, the court found Solitaire Cash's bots were
  "masquerading as human players", and the case ended in a $420M judgment
  ([Front Office Sports](https://frontofficesports.com/espn-stephen-a-smith-mina-kimes-solitaire/)).
  Label every rival a computer, always.
- **Good models:** named personalities (chess apps,
  [Chessiverse](https://chessiverse.com/)) and a clearly labelled CPU mode
  (Tetris 99 "CPU Battle",
  [Digital Trends](https://www.digitaltrends.com/gaming/tetris-99-dlc-adds-offline-mode/))
  work. A rubber band players can see feels unfair
  ([TV Tropes](https://tvtropes.org/pmwiki/pmwiki.php/Main/RubberBandAI)).
- **Other modes:** zen modes with unlimited undo, endless modes and
  hot-seat play are proven offline modes
  ([Two Dots](https://blog.weplaydots.com/post/63747938993/introducing-endless-mode),
  [Hotseat](https://en.wikipedia.org/wiki/Hotseat_(multiplayer_mode))).

**Feel:**
- **Juice:** satisfaction comes from escalation tied to game state, such as
  pitch, hit-stop and squash-stretch. It doesn't come from timers or screen
  shake ([GDC "Juice it or lose it"](https://www.gdcvault.com/play/1016487/Juice-It-or-Lose),
  [The Design Lab](https://thedesignlab.blog/2025/01/06/making-gameplay-irresistibly-satisfying-using-game-juice/)).
- **Cozy games:** they share no timers, no wrong answers and a graceful
  stopping point ([ACM CHI](https://dl.acm.org/doi/fullHtml/10.1145/3491101.3519837)).
- **Accessibility:** colour-blind support, reduced motion and larger targets
  are now a baseline expectation
  ([Game Accessibility Guidelines](https://gameaccessibilityguidelines.com/resource/dyslexia-friendly-typography/)).

**Rules and ethics (2024–2026):**
- **Timers and loot boxes:** PEGI's 2026 criteria rate countdown offers at
  PEGI 12 or higher and loot boxes at PEGI 16.
- **Loot-box law:** Belgium bans paid loot boxes. The stores require odds
  disclosure ([Fenwick](https://www.fenwick.com/insights/publications/google-play-now-requires-disclosure-of-loot-box-odds)).
- **Virtual currency:** the EU CPC Network's key principles on in-game
  virtual currencies (March 2025) require real-money prices shown up front,
  and no forcing players to buy oversized packs.
- **Purchases and consent:** the FTC's Epic settlement set the precedent
  against confusing purchase UI and opt-out defaults for minors
  ([FTC](https://www.ftc.gov/news-events/news/press-releases/2022/12/fortnite-video-game-maker-epic-games-pay-more-half-billion-dollars-over-ftc-allegations)).
- **Children's audience:** Google Play judges "appeal to children" by itself,
  whatever the declared audience
  ([Play Families](https://support.google.com/googleplay/android-developer/answer/9867159)).
  Apple's 2025 ratings add 13+/16+/18+ and the
  [Declared Age Range API](https://developer.apple.com/documentation/declaredagerange/).
- **Still a proposal:** the EU Digital Fairness Act is not law yet, so this
  doc doesn't lean on it.

## 2. What Nesty already does right

This list keeps the brainstorm from re-pitching built work:
- no timers in normal levels, no lives, and hints, undo and restart always
  available (§1, §8);
- every bundled level is solver-proven from its start with no booster
  (§5.3 rule 8);
- the tier bands come from the bots (§6.4), and `bundle check` enforces both
  gates;
- the sawtooth tier pattern (§6.6);
- a figurine every 20 levels (§7.2), with its progress on the win card and
  on Home;
- the daily puzzle with its streak, chest and weekly freeze (§7.5);
- Bonus Endless (§7.1);
- size-pitched clacks, combo completion chimes and Lottie juice (§11);
- idle dolls on Home;
- the HARD and SUPER HARD badges;
- the soft-stuck banner and the booster glow;
- colour symbols on every doll (§12.3).

Figurine names, bios and the other catalog copy are already asked of Claude
Design (Q73).

## 3. Adopted for M7

The owner approved these in principle on 2026-09-28. Each one that adds or
changes a rule has its paragraph in [spec-proposals-m7.md](spec-proposals-m7.md).
Numbers are defaults behind Remote Config keys (CLAUDE.md rule 6), and the
open ones are Q76–Q87.

| Id | Feature | Why (research) | Rule | Design | Effort |
|---|---|---|---|---|---|
| E1 | Respect rules: the never list | Churn and regulatory findings above | §1 (new paragraph) | – | S (docs + tests) |
| E2 | Gentle streak | Absence-punishing streaks drive churn; PEGI 2026 | §7.5 (changed) | streak states | S–M |
| E3 | Daily share card | Wordle | §10.2 (new screen) | card + copy | M |
| E4 | Opt-in daily reminder | The top daily-habit lever, done ethically | §7.9 (new) | opt-in card, rows | M |
| E5 | Milestone chest | A visible reward every ~10 levels; deterministic | §7.3 (new rows) | win-card bar, modal | M |
| E6 | Relaxed mode | Zen modes; spec §19 already lists it | §8 (moved from §19) | Settings row | S |
| E7 | Replay and best moves | Replay is the classic long-tail of a puzzle ladder | §7.1 (new) | chapter list, win card | M–L |
| E8 | Records and badges | Records and awards suit two motivations | §7.8 (new) | screen, ~12 badges | M |
| E9 | First launch opens L1 | Time to first win decides day 30 | §10.1 (changed) | – | S |
| E10 | vs Computer race | The owner's race (D90, D93), labelled rivals | §7.7 (new) | section 09 | L |
| E11 | The chapter plan for L31–200 | Staircase, twist per chapter, finales | none (§3.7, §6.6) | themes 7–10 | L |
| E12 | Variety and quality gates in `bundle check` | Avoid reskins; human review of hard levels | none (tools) | – | S |
| E13 | Measure time to first win | First-session value | none | – | S |
| E14 | In-app reduce-motion row | Accessibility baseline (§16) | none (§16 has it) | Settings row | S |

The feature notes below give the rule itself in plain words. The exact spec
text is in spec-proposals-m7.md.
- **E1: the never list.**
  - Nesty never adds paid randomness (loot boxes, gacha, mystery chests),
    lives or energy, timers in normal levels, countdown or scarcity offers, or
    offers shown because a player failed.
  - It never sells a streak save, and it never shows a computer rival without
    a computer label.
  - Every level stays winnable from its start with no booster (already §5.3
    rule 8).
  - Notifications are opt-in and capped at one a day. M6 inherits all of it.
- **E2: gentle streak.**
  - A missed day never lowers the count. A missed day a freeze covers keeps
    the flame lit.
  - A missed day with no freeze puts the flame out ("paused"). The next solve
    relights it and adds one.
  - The weekly freeze stays (at most 1), and the chest still opens on every
    7th streak day.
  - Records keep the longest unbroken run. The streak copy is rewritten
    without loss framing.
  - Save: `DailyProgress` gains `lit`/`longestRun` fields in a schema step.
    `_reconcile` in `streak_daily_service.dart` stops zeroing the count.
- **E3: share card.**
  - After the Daily is solved, a Share button sends a spoiler-free text through
    the OS share sheet: the date, the families as doll glyphs, the moves and
    the streak day.
  - It never includes the board. It works offline: the share sheet queues the
    message. The store link is added in M8.
  - Package: `share_plus` (rule 9).
- **E4: opt-in reminder.**
  - It is offered once, on the Daily's done card after the first solve: "Want
    a note when tomorrow's puzzle is ready?"
  - It is off by default. It sends one local notification a day at a time the
    player picks, with value copy only and no badge count.
  - Settings has a toggle and the time. Declining is permanent until the
    player changes it in Settings.
  - Packages: `flutter_local_notifications` plus the time-zone support its
    daily schedule needs (rule 9), behind a `NotificationService` interface
    with a real and a fake implementation (rule 4 style).
- **E5: milestone chest.**
  - A fixed chest at level 10 of every chapter (L10, L30, … L190) and every
    10th Bonus level. Default: 100 coins + 1 hint (Q76).
  - The win card shows its progress ("3 levels to the chest") alternating with
    the figurine bar, so a reward is always within 10 levels.
  - Its contents are shown before it opens. It reuses the day-7 chest modal
    (frame 5.6).
- **E6: relaxed mode.** A Settings toggle.
  - With it on, undo is free and unlimited, with no price and no ad row.
    Coins are still earned.
  - It is off by default, and it lifts §19's "relaxed mode" into v1.
- **E7: replay and best moves.**
  - A chapter list (from Home and the Museum's chapters) shows each chapter's
    20 levels, won or not.
  - A won level can be replayed. A replay pays nothing, never moves
    `currentLevel` and never counts towards the chest.
  - Every win records the fewest moves for that level id and version. The win
    card shows "Moves 18 · Best 16". Save schema step.
- **E8: records and badges.**
  - A Records screen shows levels won, families completed, dolls nested,
    dailies solved, the longest unbroken streak, races won and Best moves.
  - About 12 badges with deterministic triggers. They are cosmetic only and
    pay no coins. Claude Code proposes the triggers and Claude Design names
    and draws them (Q83).
  - The draft badge list (Q83). Every trigger is deterministic and counted
    over the player's lifetime, never over consecutive days:
    1. `first_family`: complete a family;
    2. `glass_breaker`: open a glass case;
    3. `ice_melter`: shatter ice;
    4. `tall_order`: win a maxSize 5 level;
    5. `grand_nest`: win a maxSize 6 level;
    6. `level_100`: win level 100;
    7. `level_200`: win level 200;
    8. `dailies_7`: solve 7 dailies;
    9. `dailies_30`: solve 30 dailies;
    10. `first_race`: win a race;
    11. `all_rivals`: beat every rival;
    12. `museum_full`: collect every figurine.
- **E9: first launch opens L1.**
  - A fresh save goes from the splash straight into L1's tutorial (after the
    consent step once M6 adds it). Home appears after the first win.
  - Returning players are unchanged.
- **E10: vs Computer.** The race in [mode-vs-computer.md](mode-vs-computer.md)
  (D93).
- **E11: chapter plan.** Section 4.
- **E12: gates in `bundle check`.**
  - A layout signature per level (shelves × slots, tower count and depth,
    glass and ice count, colours, maxSize). Two consecutive levels with the
    same signature are an error, except inside the tutorial.
  - An expert-only level (smart win rate under 0.5), today a warning, becomes
    an error for L31–200.
- **E13: time to first win.**
  - The fresh-install playthrough records the time from launch to L1's first
    playable frame, and that no screen stands in between.
  - The owner's device check notes the real seconds.
- **E14: reduce motion in Settings.** A row that overrides the OS flag
  (`FxDrawableParams.reducedMotion` today follows the OS). It shortens motion
  and keeps sounds and haptics at full strength.

## 4. The chapter plan for levels 21–200

**Where the numbers come from:**
- The board for each tier and stage comes from the owner-confirmed curve
  (Q34, `packages/nesty_core/lib/src/generator/curve.dart`). Levels use at
  most 3 shelves and 4 slots per row.
- maxSize 6 appears only in the S slots from L130 (L130, L140 … L200): eight
  levels.
- Every chapter's 20th level falls on an S slot, so the chapter finale is
  always its super-hard level.
- The bundle may vary a level's params around its curve row (±1 colour,
  another layout shape, towers ±1). §6.6 asks only that chapters raise the
  baseline. BundlePolicy, the schedule and the tier must still pass.
- 4-shelf boards and 5-slot rows are not in the curve. Using them in chapters
  8–10 for variety is Q87 (needs Claude Design section B.1–B.2 and a curve
  change).

| Chapter | Levels | New | Twist (existing mechanics only) | Finale (S) |
|---|---|---|---|---|
| 2 | 21–40 (21–30 built) | glass at L31 | Teach glass in 4 steps: L31 alone and easy (one case, its colour obvious), L32–34 practice, L35–39 with towers | L40: towers and glass |
| 3 | 41–60 | ice at L51 | L41–50 glass variety (other unlock colours, a partial nest behind glass); L51 ice alone (counter 1); L52–59 ice and towers | L60: ice, glass and towers |
| 4 | 61–80 | maxSize 5 at L71 | L61–70 glass and ice together; L71 maxSize 5 alone (few colours, easy); L72–79 tall-doll planning | L80 |
| 5 | 81–100 | – | maxSize 5 settles in; deeper towers (depth 4); fewer empty slots | L100 |
| 6 | 101–120 | – (L101 ordinary; gold is v1.1) | Everything at maxSize 5; puzzle-y hard levels, relaxing easy ones | L120 |
| 7 | 121–140 | first maxSize 6 at L130 | L130 hand-tuned: the first super-hard maxSize 6 | L140 (maxSize 6) |
| 8 | 141–160 | – | "Tall towers": tower-heavy picks within the stage | L160 (maxSize 6) |
| 9 | 161–180 | – | "Glass and ice gallery": lock and ice mixes | L180 (maxSize 6) |
| 10 | 181–200 | – | "Grand tour": the most varied picks from larger candidate pools | L200 (maxSize 6), then Bonus Endless |

**How levels are made and accepted:**
- **Generation:** `nesty_levels generate` makes several seeded candidates per
  slot, and `bundle check` grades them with the existing gates (§5.3 rules
  1–8, §6.4 tier match, the schedule, the layout) plus E12's two new ones.
- **Hand-tuning:** the introduction levels (L31, L51, L71, L130) and the ten
  finales are tuned by hand and noted in `tools/levels/manifest.json`. The
  rest are picked from the candidates for variety.
- **Human review:** every H and S level is played by an agent through its
  solution and one casual run, and the report goes in the lane's checkpoint.
  Bots grade; they don't decide.
- **Playthrough:** a segment for each new mechanic (glass L31, ice L51,
  maxSize 5 L71, maxSize 6 L130).

## 5. Ethics: the checklist and the DO / DON'T list

Every M7 feature passes these six questions before it is merged, recorded in
its lane report:
1. Can a player finish every level without an ad, a purchase or a booster?
2. Is every reward shown in advance and deterministic, with no paid
   randomness?
3. Is there any timer, countdown, scarcity or fail-triggered offer? There
   must be none.
4. Is every computer rival labelled a computer on every screen?
5. Does anything punish absence or shame a loss, whether copy, streaks or
   notifications?
6. Is every non-essential prompt or notification off by default and
   value-framed, and can the player turn it off in Settings?

**DO:**
- Keep every level winnable from its start with nothing but free moves, undo
  and restart ([Ball Sort reviews](https://apps.apple.com/us/app/ball-sort-puzzle/id1494648714?see-all=reviews&platform=iphone)).
- Show every reward's contents before it opens.
- Make streaks additive: a missed day pauses and never deletes ([UX Magazine](https://uxmag.com/articles/the-psychology-of-hot-streak-game-design-how-to-keep-players-coming-back-every-day-without-shame)).
- Keep notifications off until the player opts in on a plain context screen
  ([ICO Standard 5](https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/childrens-information/childrens-code-guidance-and-resources/age-appropriate-design-a-code-of-practice-for-online-services/5-detrimental-use-of-data/)).
- Use value copy ("Today's puzzle is ready"), never guilt ("Don't lose your
  streak!").
- Label computer rivals persistently: name, glyph and "Computer" ([Skillz v. Papaya](https://frontofficesports.com/espn-stephen-a-smith-mina-kimes-solitaire/)).
- In M6, show the real-money price up front and never force oversized packs
  (EU CPC key principles, March 2025).
- Keep the store copy adult and family in tone, and declare the audience
  accurately ([Play Families](https://support.google.com/googleplay/android-developer/answer/9867159)).

**DON'T:**
- Add loot boxes, gacha or mystery rewards ([PEGI 2026](https://pegi.info/news/pegi-expands-age-rating-criteria-interactive-risk-categories), [Fenwick](https://www.fenwick.com/insights/publications/google-play-now-requires-disclosure-of-loot-box-odds)).
- Add lives or energy, even under monetization pressure ([Royal Match audit](https://www.darkpattern.games/game/29175/0/royal-match.html)).
- Run countdown or limited-time offers, or use scarcity framing.
- Show an offer because the player just failed ([AppMagic on fail offers](https://appmagic.rocks/blog/fail-offers)).
- Sell a streak save or a "repair" ([Naavik on Royal Match](https://naavik.co/digest/royal-match-finding-success-through-iteration/)).
- Blur a computer rival into a human: no human avatar, no "online" status, no
  chat framing.
- Hide a real cost behind currency maths.

## 6. Later or v1.1 (not M7)

| Idea | Why not now |
|---|---|
| Home-screen widget (daily and streak) | Native WidgetKit and AppWidget code in three flavors, plus a package: large for its value before launch |
| Weekly puzzle | A third cadence. The daily comes first |
| Par and stars, no-undo challenges | Stars make a win feel like a 1-star failure. Keep the ladder gentle, and revisit with Best moves data |
| Museum diorama, sticker album | Large art cost (up to 200 stickers). The Museum already displays the collection |
| Daily Duel (the daily against the computer) | Build after the race proves itself |
| Doll micro-expressions (blink, squint) | New face layers in all 7 skins |
| Dyslexia-friendly font option | A new bundled font for a small audience. Revisit with the accessibility audit |
| Ghost race against your own best | The owner chose the rival race. Kept as a cheaper extra |
| Hot-seat duel (pass and play) | A proposal at the end of M7 (D90): two players alternate turns on one board, and a family scores for whoever completes it |
| Time attack | Speed pressure is off-brand even outside normal levels |
| Welcome-back recap | Nice, but E8's Records covers it. Revisit after M7 |
| Favourite family on Home | Small personalization. Ask Claude Design where it would sit before building |

## 7. Rejected

| Idea | Reason |
|---|---|
| Alternating turns against the computer | Turn pressure and sabotage feel wrong for a cozy game. Alternating turns suit two humans (the hot-seat proposal) |
| Survival with lives or energy | Spec §1: no lives. A dark pattern |
| Random cosmetic chests for completions | Paid or unpaid randomness is out (E1); PEGI 16 |
| Levels that need boosters | The genre's top churn driver. §5.3 rule 8 forbids them |
| A streak-save purchase | Loss-aversion selling (E1) |
| An expert bot | The owner chose the two §6.4 bots plus pace (D93) |
| Remix or mirror levels | Bonus Endless already gives endless fresh boards, and mirrored boards play the same |
| A countdown "Today only" skin offer | E1 |
| A move counter during normal play | It adds pressure. Moves appear on the win card only (E7) |
