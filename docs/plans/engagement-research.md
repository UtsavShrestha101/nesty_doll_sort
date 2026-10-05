# Engagement research and the kid path (after M7, D259–D260)

Date: 2026-10-04. Status:
- **Proposals ER1–ER11** are for the owner. Nothing is decided and no code
  exists. Q173 asks which to build.
- **The kid path (ER12)** is the owner's decision (D260): under-13s become a
  target too. Its details are Q174's defaults.

[GAME_SPEC.md](../GAME_SPEC.md) is not edited. Section 6.4 has paste-ready
text for §1 and §17.

The order stays D237:
1. Close M7.
2. Build the local habits the owner picks (Q162).
3. Build the proposals the owner picks here, with the kid path's local part.
4. M4, M5, M6 and M8.

The kid path's local part must land before M4, because M4's analytics must
not start before a player's age is known.

The respect rules, the six-question ethics checklist and the ideas already
adopted, parked or rejected are in
[offline-game-brainstorm.md](offline-game-brainstorm.md) §5–§7. The local
habits are in [local-habits-brainstorm.md](local-habits-brainstorm.md). This
file does not repeat them.

## How this was made

Three read-only lanes ran on 2026-10-04:
- **The repo's features:** the spec, the plans, PROGRESS, BACKLOG and the
  feature folders.
- **What top puzzle and casual games do:** about 40 searches and source
  reads, 2024–2026.
- **Psychology, age groups, ethics and law:** about 60 searches and 45 pages
  read.

The lead then checked two things:
- the kid path's rules, against the primary pages: Google Play Families, the
  FTC's COPPA FAQ, Apple's App Review Guidelines and AdMob's child-directed
  settings;
- the code facts the proposals lean on: the skins' shared geometry, Bonus
  Endless's unlock, the 1.3× text cap and `SaveRecords`.

**How good the evidence is.**
- Most retention numbers are company-reported (Duolingo, Spotify, Google).
- No public source isolates one feature's lift in a sort game
  ([GGA](https://gamegrowthadvisor.com/blog/2026-03-17-mobile-game-retention-strategies-2026/)).
- (A) marks an analyst or trade-press figure. (S) marks a figure seen only in
  a search summary. (U) marks a claim that could not be verified.

## 1. Where Nesty stands

**Built** (M2, M3, M7 phases 1–4):

| Area | What players have |
|---|---|
| Play | Dolls nest by colour and size. Mechanics arrive over the levels: towers (L16), glass cases (L31), ice (L51), tall dolls (maxSize 5 from L71, 6 from L130). Undo, hint and +1 Slot; restart is free. The soft-stuck banner. Relaxed mode makes undo free (E6) |
| Daily habit | One seeded daily from L2, medium Monday to Friday and hard at weekends. The gentle streak: a missed day pauses it and never lowers it (E2). One weekly freeze. A chest every 7th streak day. The opt-in reminder (E4). The spoiler-free share text (E3) |
| Progress | 200 levels in 10 chapters. 1–3 stars against the solver's par (D125). Replay and best moves (E7). Records and 12 lifetime badges (E8). A reward every 10 levels: the milestone chest at each chapter's level 10 (E5) and a figurine at its end |
| Collection | The Museum's 10 figurines. 7 doll skins and 10 chapter themes, bought with coins |
| Modes | vs Computer from L20, with 3 rivals always labelled "Computer" (D93). Bonus Endless, but only after L200 (spec §7.1) |
| Comfort and access | Reduce motion (E14). Colour symbols, Large by default (D91). Haptics, sound and music. Screen readers on every menu, but not yet on the board (Q154, v1.1). 48 dp targets. Menu text up to 1.3× (spec §16) |

**In progress:** M7 phase 5. That is translations (5B), then the review and
the `/milestone M7` gate (5C), plus the owner's VoiceOver pass.

**Planned:**
- **The local habits (Q162):** welcome back, a month of played days, the last
  7 dailies, and a home-screen widget. Optional: today's visitor and a
  picture share.
- **The pass-and-play proposal:** options A, B and C.
- **M4:** cloud levels and skins, Remote Config, analytics.
- **M5:** the admin.
- **M6:**
  - Interstitials from L8: every 3 wins, at least 90 s apart, only on Win →
    Continue.
  - Rewarded placements.
  - 6 IAP products.
  - UMP consent and ATT.
- **M8:** release.
- **v1.1:** the gold doll.
- **BACKLOG "Later":**
  - seasonal skins and weekend events;
  - a level-sharing code;
  - a Museum diorama or sticker album;
  - a Daily Duel and a ghost race;
  - a weekly puzzle;
  - doll micro-expressions;
  - a dyslexia-friendly font;
  - about 20 new levels a week.

**Rejected** (brainstorm §7, local-habits "Out"):
- lives and energy;
- loot boxes and random chests;
- a streak that breaks, a streak repair or a streak purchase;
- time attack;
- a move counter during play;
- an expert bot;
- world leaderboards;
- escalating login calendars that restart after a missed day (D268 adopts
  a cumulative daily gift instead: [plan-login-gift.md](plan-login-gift.md));
- "today only" skins.

**The gaps the research points at:**
1. **No player-chosen difficulty before L200.** Kids, older players and
   experts all climb one ladder. The only free play opens after the last
   level.
2. **Progress is recorded but never celebrated or summed up.** Records is a
   list of numbers.
3. **No way to play with or against people you know,** beyond the daily's
   share text.
4. **No self-expression.** Matryoshkas are a painted craft, and nothing in
   the game uses that.
5. **Menu text stops at 1.3×,** below what many older players need.
6. **No healthy-play cues** for parents or long sessions.
7. **Platform surfaces are unused:** the widget is a local habit, and there
   are no icon actions and no achievements.

## 2. What the research says

### 2.1 The genre

**Sort puzzles grew up fast.**
- They went from ad-only templates (under $2M a year for the whole category
  before 2023) to IAP scale. Hexa Sort peaked at $4M a month, and Magic Sort
  passed $40M in its first year
  ([DoF](https://www.deconstructoroffun.com/blog/2026/2/6/sort-puzzles-how-a-new-subgenre-is-born)).
- Pixel Flow passed $105M IAP in ten months (A,
  [GGA](https://gamegrowthadvisor.com/blog/2026-04-16-hybrid-casual-game-design-strategy-2026/)).

**The leaders are light on meta.**
- Pixel Flow has deterministic boards and no rewarded shortcuts
  ([DoF](https://www.deconstructoroffun.com/blog/2026/2/13/pixel-flow-the-publishers-dream)).
- Magic Sort had no secondary progression at first
  ([Gamigion](https://www.gamigion.com/magic/)).
- So a real meta layer is how a doll game stands apart, not table stakes.
- Hybrid-casual puzzle revenue splits block 71%, screw 20%, sort 9% (A,
  [Gamigion](https://www.gamigion.com/2025-hybridcasual-market-overview-with-real-data/)).

**The doll-sort rivals.** They look indie: coins and No Ads, with no daily
and no meta layer (a limited check,
[App Store](https://apps.apple.com/us/app/-/id6502882556)). Their match-3
burn rules differ from Nesty's nest-by-size rule (brainstorm §1).

**The casual leaders run on events, but mostly with timers and forfeits.**
- Royal Match keeps "at least a couple" of events live and ships new levels
  every two weeks (A,
  [Udonis](https://www.blog.udonis.co/mobile-marketing/mobile-games/royal-match-analysis)).
- Its 2021–22 launches lifted 30-day revenue:
  - Royal Pass +31%;
  - Sky Race +12%;
  - Lightning Rush +9%;
  - Piñata Party +6% (three milestone tiers, no losers).
  These lifts came in a growth phase, so they are confounded
  ([Naavik](https://naavik.co/deep-dives/royal-match/)).
- Win streaks spread to eight puzzle apps in 2023–24. Royal Match reportedly
  gained +38% month-on-month revenue (A, paywalled,
  [Liquid & Grit](https://liquidandgrit.com/?p=13687)).
- Deconstructor of Fun names the mechanism: higher stakes raise the
  end-of-level offer's conversion
  ([DoF](https://deconstructoroffun.com/blog/2024/8/5/win-streak-the-gift-that-keeps-on-giving)).
  That is exactly what respect rule 4 rules out.
- Seasonal events work without timers' pressure too: Screw Master 3D's
  Valentine event drew 21% of players and added 3% revenue (A,
  [Gamigion](https://www.gamigion.com/2025-hybridcasual-market-overview-with-real-data/)).

### 2.2 The daily ritual and streaks

**NYT Games.** Players solved 11.2B puzzles in 2025, and Wordle results were
shared 46 times a second
([Today](https://www.today.com/popculture/hardest-wordle-connections-puzzle-2025-new-york-times-games-rcna251022)).
Over half of weekly players play more than one puzzle a day
([Creative Review](https://www.creativereview.co.uk/new-york-times-games-wordle-crossplay-design-jonathan-knight/)).

**Duolingo's streak experiments** (company-reported):
- A 7-day streak makes finishing a course 3.6× likelier.
- Two freezes held at once gave +0.38% DAU, and three were no better than
  two.
- A better milestone animation gave +1.7% 7-day retention
  ([Duolingo](https://blog.duolingo.com/duolingo-streak-research/)).
- Decoupling the streak from the daily goal raised 14-day retention 3.3%
  ([Duolingo](https://blog.duolingo.com/improving-the-streak)).
- The Weekend Amulet (rest-day protection) gave +4% return after a week and
  5% less streak loss
  ([Duolingo](https://blog.duolingo.com/how-streaks-keep-duolingo-learners-committed-to-their-language-goals)).

**Forgiveness pays.** Duolingo's June 2026 Streak Revival restored 15.4M
streaks, nearly 8M of them for users with no active streak
([SEC 8-K](https://www.sec.gov/Archives/edgar/data/0001562088/000162828026053299/q2fy26duolingo6-30x26share.htm)).

**Independent work agrees.**
- In seven studies, broken streaks lowered later engagement, more when
  people blamed themselves and less when the streak could be repaired
  ([Colorado](https://www.colorado.edu/business/faculty-research/2023/04/19/or-track-how-broken-streaks-affect-consumer-decisions)).
- Habits tolerate a missed day: automaticity took 66 days on average
  ([BPS on Lally et al.](https://bps.org.uk/research-digest/how-form-habit)).

**Nesty is already on the safe side.** Its streak never lowers (E2), so
Duolingo's freeze data, which assumes a streak can break, adds little here.
A second freeze is not proposed.

**Friend streaks.** Learners with one are 22% likelier to finish the daily
lesson
([Duolingo](https://blog.duolingo.com/product-lessons-friend-streak/)).
They need accounts. ER4 is the offline cousin.

### 2.3 Progress that feels impressive

**Recaps.**
- Spotify Wrapped 2025 had 200M engaged users in 24 hours (+19%) and about
  500M shares (+41%)
  ([TechCrunch](https://techcrunch.com/2025/12/04/spotify-says-wrapped-2025-is-its-biggest-yet-with-200m-users-in-its-first-day)).
- Duolingo's Year in Review raised lessons and time spent. Its top 10% of
  earners made over half the shares until personas ("learner styles")
  widened sharing
  ([Duolingo](https://blog.duolingo.com/year-in-review-behind-the-scenes)).
- NYT launched Year in Games on 16 Dec 2025
  ([Engadget](https://www.engadget.com/gaming/nyt-games-has-a-year-in-review-thing-now-too-203000878.html)).

**Achievements.** Google advises 15+ incremental achievements, about 5 of
them earnable in the first two hours, and 40+ for the most engaging games
([Android Developers Blog](https://android-developers.googleblog.com/2025/06/get-ready-for-next-generation-gameplay-play-games-services.html)).

**Monthly fills.**
- Sudoku.com gives trophies for daily challenges
  ([App Store](https://apps.apple.com/us/app/sudoku-com-number-games/id1193508329)).
- Microsoft Solitaire's daily challenges fill monthly badges (S,
  [Giant Bomb](https://www.giantbomb.com/microsoft-solitaire-collection/3030-39318)).

**Restoration is the genre's long-tail engine.** Royal Kingdom made $301.1M
in its first year
([PocketGamer.biz](https://www.pocketgamer.biz/royal-kingdom-surpasses-300m-in-first-year-beating-royal-match/)).
Its art cost is large.

**Player-made levels.** No mobile-puzzle retention figures exist (U,
[arXiv survey](https://arxiv.org/pdf/2412.13743)).

### 2.4 Why it works

**Needs.** Autonomy, competence and relatedness each predict enjoyment and
future play. Low need satisfaction predicts "have-to" play and tension
afterwards
([Ryan, Rigby, Przybylski](https://acuresearchbank.acu.edu.au/item/8q128/the-motivational-pull-of-video-games-a-self-determination-theory-approach);
[Przybylski et al.](https://acuresearchbank.acu.edu.au/item/89x90/having-to-versus-wanting-to-play-background-and-consequences-of-harmonious-versus-obsessive-engagement-in-video-games)).

**Difficulty.** Self-chosen moderate difficulty motivated most. When
difficulty was assigned blindly, the easiest version won (20,000+ plays,
[CMU](https://hcii.cmu.edu/news/chi-preview-researchers-hcii-believe-difficulty-can-be-overrated-games)).

**Rewards.**
- Expected tangible rewards undermine intrinsic motivation, more so for
  children. Positive feedback raises it (128 experiments,
  [Deci, Koestner, Ryan](https://depts.washington.edu/techdocs/papers/deciExtrinsicRewardsAndIntrinsicMotivation99.pdf)).
- Points and badges raise performance without raising intrinsic motivation
  ([Mekler et al.](https://hcds.itu.dk/bibliography/mekler2013points)).
- So celebrations should inform, not pay.

**Progress effects.**
- Endowed progress: pre-stamped cards were redeemed 34% vs 19%
  ([Nunes & Drèze](https://msbfile03.usc.edu/digitalmeasures/jnunes/intellcont/Endowed%20Progress%20Effect-1.pdf)).
- The IKEA effect: things we make gain value only once finished
  ([Norton, Mochon, Ariely](https://dash.harvard.edu/handle/1/12136084)).
- Fresh starts: motivation rises at a new week, month or year
  ([Dai, Milkman, Riis](https://faculty.wharton.upenn.edu/wp-content/uploads/2014/06/Dai_Fresh_Start_2014_Mgmt_Sci.pdf)).
- The peak and the ending shape memory of a session
  ([CHI 2016](https://dx.doi.org/10.1145/2858036.2858419)).
- The Zeigarnik effect is weaker than folklore: no memory advantage, but a
  real urge to resume
  ([2025 meta-analysis](https://ideas.repec.org/a/pal/palcom/v12y2025i1d10.1057_s41599-025-05000-w.html)).

**Stopping cues.** Removing them lengthens sessions
([arXiv](https://arxiv.org/pdf/2407.18803)). The UK ICO endorses "pause and
save" and break nudges
([ICO standard 13](https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/childrens-information/childrens-code-guidance-and-resources/age-appropriate-design-a-code-of-practice-for-online-services/13-nudge-techniques/)).

### 2.5 What each age wants

| Age | What moves them | What they need | Good for them | Keep away |
|---|---|---|---|---|
| 6–8 | Play over competition (Toca Boca). 38% of 5–7s played online in 2022 ([Ofcom](https://tiga.org/news/ofcom-publishes-report-on-media-use-amongst-children-and-parents)) | Icon-first, few words, big forgiving targets, instant feedback, no failure state | Free Play on Easy, the Workshop, stories, co-op with a parent | Streaks with pressure, timers, purchases or links without a grown-up |
| 9–12 | Collecting, making, showing a parent. 69% of 8–11s played online (Ofcom 2022). Tangible rewards backfire more for children ([Deci](https://depts.washington.edu/techdocs/papers/deciExtrinsicRewardsAndIntrinsicMotivation99.pdf)) | Short concrete text, hints, visible progress | Milestones, challenge codes to family, the Workshop, chosen difficulty | Coins for ads, public leaderboards, chat, timed offers |
| 13–17 | 85% of US teens play, about 4 in 10 daily ([Pew](https://www.pewresearch.org/internet/2024/05/09/teens-and-video-games-today/)). Competition is strongest when young ([Quantic Foundry](https://quanticfoundry.com/age-report/), S) | No childish tone, autonomy, opt-in sharing | Challenge codes, Hard Free Play, the monthly recap, vs Computer | Spend nudges, fake scarcity, night-time pings |
| 18–54 | The average US player is 36. 81% play to relieve stress and 81% to stimulate the mind ([ESA](https://www.theesa.com/resources/essential-facts-about-the-us-video-game-industry/2025-data/)) | 2–5 minute sessions, interruption-safe play, few taps | The daily ritual, recaps, mastery, calm | Guilt streaks, ads after failure, hidden prices |
| 55+ | 45% of people 50+ game, 84% of them on a phone. 73% play puzzle and logic games, 78% to stay sharp, and 20% with children or grandchildren ([AARP 2023](https://www.aarp.org/pri/topics/social-leisure/activities-interests/2023-gamers-50-plus/)) | 66% report age-related decline and 50% hit a barrier. They ask for larger fonts, less noise and effects, adjustable difficulty and easy onboarding ([AARP](https://www.aarp.org/pri/topics/technology/internet-media-devices/gamer-accessibility-preferences-older-adults/)) | Larger text, Free Play on Easy, milestones, challenge codes with grandchildren | Ads that gate progress (a top frustration), tiny text, time pressure |

**Families play together.**
- 82% of parents who play games play with their kids, and 55% of Gen Alpha
  play with their parents
  ([ESA](https://www.theesa.com/annual-esa-study-reveals-video-games-universal-appeal-across-generations/)).
- Kids' apps keep one profile per child on a shared device, for example 3
  child profiles in
  [ABCmouse](https://support.abcmouse.com/hc/en-us/articles/360048174313)
  and up to 6 in
  [Kahoot!](https://support.kahoot.com/hc/en-us/articles/4815253732371).

### 2.6 Platforms and benchmarks

**Notifications.**
- The 2025 median opt-in rate is 48.85% on iOS and 53.3% on Android (S,
  [Airship](https://growth.airship.com/rs/313-QPJ-195/images/Airship-2025-Push-Notification-Benchmarks-EN.pdf?version=0)).
- Android 13+ starts with notifications off, so ask in context
  ([Android](https://developer.android.com/develop/ui/views/notifications/notification-permission)).

**Widgets.** In Gratitude, widget users retained 25% better, and 10% of DAU
adopted a widget. The users chose the widget themselves, so this isn't
causal
([Android Developers Blog](https://android-developers.googleblog.com/2026/05/how-gratitude-widgets-boosted-user-retention-25-percent.html)).

**Apple's iOS 26 Games app** has three features
([WWDC25 214](https://developer.apple.com/videos/play/wwdc2025/214),
[215](https://developer.apple.com/videos/play/wwdc2025/215/)):
- **Challenges:** built on leaderboards, lasting 1 day, 3 days or a week.
- **Activities:** deep links into a level.
- **Play Together.**

**Google Play's Q2 2026 update** adds three
([Google Play](https://google.play/the-latest/2026-q2/)):
- a Streaks Overview, with notifications before a streak is lost (Nesty must
  not opt into this);
- Playtime Trophies;
- Leagues.

**Live Activities.** They suit tasks with a start and an end, so they fit a
daily puzzle poorly (S,
[9to5Mac](https://9to5mac.com/2022/09/26/iphone-14-pro-live-activities-guidelines/)).

**Benchmarks.** GameAnalytics' 2025 data on 16,262 mobile games
([GameDev Reports](https://gamedevreports.substack.com/p/gameanalytics-mobile-and-pc-game)):
- **Retention, median:** D1 about 22%, D7 just under 4%, D30 0.69–0.79%.
- **Retention, top 10%:** D1 about 40%, D7 11–12%.
- **Sessions, median:** 3.1–3.5 minutes each, 3.8–3.9 a day.

The widely quoted puzzle figures (D1 31.85%, D7 12.18%, D30 5.35%) date from
AppsFlyer Q3 2022
([Segwise](https://segwise.ai/blog/mobile-gaming-app-user-retention-strategies)).

## 3. The proposals (ER1–ER11)

Each one works offline unless marked, and passes the six questions as
designed. On the kid path (section 6), sharing and links sit behind the
parental gate.

Each one also needs, like every feature (D169):
- Claude Design's frames and copy, in 9 languages;
- host tests;
- a `nesty-test` device step;
- a TEST_COVERAGE row.

Ages: K kids 6–12, T teens, A adults, S 55+, F family co-play.

| # | Proposal | Ages | Size | Wave |
|---|---|---|---|---|
| ER1 | Free Play by difficulty | all, K and S first | M | 1 |
| ER2 | Milestones you can feel | all | S–M | 1 |
| ER3 | Your month in dolls | T A S K | M | 1 |
| ER4 | Challenge codes | F T A S | M | 1 |
| ER5 | Healthy-play kit | F K S A | S | 1 |
| ER6 | Doll Workshop | K T A | M–L | 2 |
| ER7 | Larger text | S, also K and A | M | 2 |
| ER8 | Seasons that come back | all | S code, M art each season | 2 |
| ER9 | Stories of the doll families | K A S | M | 2 |
| ER10 | Family profiles | F K | L | 3 |
| ER11 | Platform surfaces | T A | (a) S, (b) M | (a) 1–2, (b) with M4/M8 |

### ER1. Free Play by difficulty (wave 1)

**What.**
- Choose Easy, Medium or Hard for endless boards, generated on the device at
  the stage of the player's highest level, so no unseen mechanic appears.
  Seeds come from a new range.
- It pays nothing, like a replay. It never moves `currentLevel` and never
  counts toward the chest, the Museum or stars.
- Default for the owner: it counts toward the lifetime dolls and families in
  Records.

**Ages.** All. Kids and older players get an easy, calm game whenever they
like. Experts get Hard.

**Why.**
- Self-chosen difficulty motivates most, and blindly assigned difficulty
  favours the easiest
  ([CMU](https://hcii.cmu.edu/news/chi-preview-researchers-hcii-believe-difficulty-can-be-overrated-games)).
- Older players ask for adjustable difficulty (AARP).
- Sudoku.com's difficulty picker sits behind its 4.8-star, all-ages rating
  ([App Store](https://apps.apple.com/us/app/sudoku-com-number-games/id1193508329)).
- Today the only free play opens after L200 (spec §7.1).

**Reuses.**
- The generator's tiers and the curve (`DifficultyCurve`), and generated
  boards that are solvable by construction.
- The Bonus Endless path in `default_level_resolver.dart`, plus a new
  `PlayRequest` case.
- The board, and the win card with moves only.

**Needs.**
- Spec-prop text: the mode, its unlock (default after the tutorial chapter),
  its seed range, what it pays and counts.
- A board in progress is not resumed, as with a race, so no save step.
- Claude Design: the picker and its Home entry.

**Ethics.** Questions 1, 3 and 5: nothing to buy, no timer, and nothing to
fail.

### ER2. Milestones you can feel (wave 1)

**What.**
- Tiered lifetime milestones:
  - dolls nested: 100, 500, 1,000, 5,000, 10,000;
  - families: 50, 250, 1,000;
  - dailies solved: 10, 50, 100, 365, counted over a lifetime and never in a
    row;
  - levels won: 50, 100, 150, 200.
- Each milestone plays a short ceremony: a doll opens to show its mark.
- Records shows the next one ("Next: 1,000 dolls").
- Each milestone offers a share card.
- Claude Design writes friendly comparisons ("a stack taller than a
  giraffe").
- Celebrations pay nothing.

**Ages.** All. Kids love marks, adults like milestones, and older players
like visible proof that they are staying sharp.

**Why.**
- Duolingo's milestone animation gave +1.7% 7-day retention.
- Its milestone cards reportedly multiplied organic sharing 5–10× (A,
  [DoF](https://duolingo.deconstructoroffun.com/mechanics/streaks)).
- Google's guidance is 15+ incremental achievements, 5 of them in the first
  two hours.
- Informational feedback raises motivation, while points alone don't
  (section 2.4).

**Reuses.**
- `SaveRecords` (families, dolls, dailies) and `BadgeRules` (lifetime
  triggers).
- The chest's opening FX (`features/fx/chest/`), the toast queue and
  Records.

**Needs.**
- Spec-prop §7.8 text: tiers beside the 12 badges, triggers still lifetime.
- A save step for the ceremonies already seen.
- Claude Design: the tier marks and the ceremony.

**Ethics.** Questions 2 and 5. Every mark is known in advance, nothing is
random, and nothing counts consecutive days.

### ER3. Your month in dolls (wave 1)

**What.**
- On the first open of a new month, a few cards show the month:
  - dailies solved and dolls nested;
  - the longest run and the hardest level won;
  - races won;
  - a play-style persona, for example "the Careful Planner" (few undos),
    "the Collector" (a figurine) or "the Explorer" (replays).
- A yearly recap opens in January.
- Each recap is shareable as a picture.
- A quiet month gets one warm line, never a comparison. It never compares
  players.

**Ages.** Teens, adults and older players share. Kids enjoy it.

**Why.**
- Spotify Wrapped and Duolingo's personas (section 2.3).
- NYT Year in Games.
- The fresh-start effect.

**Reuses.** Records' counters, `ShareService`, and the local habits' picture
share. ER3 needs that renderer, so picking ER3 picks it too.

**Needs.**
- A save step for per-month counters (the year sums the months).
- A §10.2 spec-prop line.
- Claude Design: the cards, and the personas' names and lines.

**Ethics.** Questions 5 and 6. Nothing shames a quiet month, and the recap is
a dismissible card, never a notification.

### ER4. Challenge codes (wave 1)

**What.**
- After a win (campaign, replay or bonus) or the daily, "Challenge someone"
  shares a short code and one line ("Can you nest it in 18 moves?").
- The code names the board and the moves:
  - a level id and version, or the daily's date, or a bonus seed;
  - the generator version.
- The recipient enters it, or taps it once M8's store link and app links
  exist. They play the same board offline and see both counts privately.
- No accounts, server, free text, names or strangers.

**Ages.** Families, teens, adults and older players: a child challenging a
parent, or grandparents and grandchildren.

**Why.**
- Wordle's share loop (section 2.2).
- Duolingo's friend streak, +22%, which works through relatedness.
- 20% of players over 50 play with children or grandchildren.
- There is no public data on challenge codes in puzzles (U).

**Reuses.**
- Bundle ids, `DifficultyCurve.dailySeed` and the bonus seed rule.
- `LevelResolver`, with a new play request.
- The win card's Moves and Best, and `ShareService`.

**Needs.**
- Spec-prop text: the code format; that a challenge pays nothing, doesn't
  move `currentLevel` and doesn't mark a level won.
- What a code for a level the recipient hasn't reached does. Default: it
  plays, like a replay.
- What a different generator version does. Default: "update to play".
- Claude Design: the challenge card, the code entry and the result line.

**Ethics.** Question 5: both results are warm ("You both nested it!"), and
there is no ranking. On the kid path, sharing asks for a grown-up first.
Entering a code collects nothing.

**Later.** ER4's code format is the first step toward BACKLOG Later's
"level-sharing code", and a maker whose boards the solver checks (rule 8)
could follow. That maker's impact is unverified.

### ER5. Healthy-play kit (wave 1)

**What.**
- The pause sheet shows today's play ("Today: 6 levels · 12 min").
- Records shows this week's time.
- An optional break card appears at a level's end after a chosen time (30,
  45 or 60 minutes of play).
  - It is off by default.
  - On the kid path, a grown-up sets it in the parent area.
  - Its copy is gentle, one tap keeps playing, and nothing locks.

**Ages.** Parents, kids, older players and adults.

**Why.**
- Stopping cues and the ICO's endorsement of break nudges (section 2.4).
- The evidence that break pop-ups work is weak: in a gambling study they
  helped only a small number of players stop
  ([PMC](https://pmc.ncbi.nlm.nih.gov/articles/PMC4369874)).
- Parents value seeing play time.

**Reuses.** `AppClock`, the pause sheet, Records and Settings.

**Needs.** Play-time counters (a save step), a Settings row, and Claude
Design's lines and card.

**Ethics.** Questions 3 and 6. The card never interrupts a level, and it is
off unless chosen.

### ER6. Doll Workshop (wave 2)

**What.**
- Make your own doll look from the parts of skins you own:
  - the face (`face`);
  - the apron and lid detail (`bottom_detail`, `top_detail`);
  - the shine (`shine_*`).
- Add pattern stamps inspired by real matryoshka schools:
  - Sergiev Posad: 3–4 colours with black outlines;
  - Semyonov: a big bouquet on the apron;
  - Polkhov-Maidan: no hands, one lush flower.
  ([Wikipedia](https://en.wikipedia.org/wiki/Matryoshka_doll),
  [Gallerix](https://en.gallerix.ru/lib/matreshka-kak-simvol-rossii-ot-igrushki-do-suvenira))
- The game's colours never change. The tinted masks (`bottom_mask`,
  `top_mask`) are untouched, so every rule and colour symbol works as before.
- The made doll plays as a skin, stands on Home and appears in shares. It is
  made in a few taps, because the IKEA effect needs a finished thing.

**Ages.** Kids and teens (self-expression), and adults (cozy).

**Why.**
- The IKEA effect and autonomy.
- The theme's own craft: the first matryoshka (1890) was Malyutin's painted
  design.
- No doll-sort rival offers it (limited check).

**Reuses.**
- All 7 skins share one geometry, checked 2026-10-04:
  - artboard 512×768 and `splitY` 400;
  - the same 8 groups and the same tinted masks.
- `SkinLoader`, `SkinCache`, the part rasters, `doll_tint.dart`, and the
  Shop's owned skins.

**Needs.**
- Claude Design: confirm which part mixes work (Forest Bear's silhouette may
  not), draw the stamps and the workshop frames.
- A composite skin id in the cache key, rasterized once (rule 8).
- A save step for the made doll.
- Spec-prop text (§12, a composite skin).

**Ethics.** Question 2. Nothing is random, nothing new is sold, and only
owned skins mix.

### ER7. Larger text (wave 2)

**What.**
- Menus follow the system text size up to 2.0× instead of 1.3×, and layouts
  reflow (rows wrap, sheets scroll).
- The board keeps its own scale, with colour symbols Large by default (D91).

**Ages.** Older players first, then young readers and low-vision players.

**Why.**
- AARP: 66% of gamers 50+ report age-related decline, 50% hit a barrier,
  larger fonts top their asks, and 74% want inclusive design to be a
  priority.
- Children and older adults need larger targets
  ([NN/g](https://www.nngroup.com/articles/usability-for-senior-citizens/)).

**Reuses.**
- `screen_harness.dart`, which tests at 1.0 and 1.3 today.
- The overflow suite (overflow, 48 dp targets, labels, cut text), and
  `CreamPage` and `SheetRow`.

**Needs.**
- The owner's change to spec §16 ("up to 1.3×").
- Claude Design: large-text variants of the dense screens (Records, the
  Shop, Settings, the win card).
- The harness adds 2.0×.

**Ethics.** Not applicable.

### ER8. Seasons that come back (wave 2)

**What.**
- The device's date (`AppClock`) dresses Home, the daily card and the board
  backgrounds for the season: winter, spring, summer, autumn, and a few
  region-neutral festive looks.
- The same look returns every year. Nothing is bought, nothing expires, and
  there is no seasonal-only reward or figurine.
- If picked, it replaces Later's "Seasonal skins" and "Weekend events with
  special skins" (both §19).

**Ages.** All. Kids love holidays.

**Why.**
- Screw Master 3D's seasonal event (section 2.1).
- The fresh-start effect.
- PEGI rates time-limited offers 12+ (section 6.2), so the looks carry no
  offer at all.

**Reuses.** `AppClock`, the theme loader and the daily card.

**Needs.**
- One art set per season from Claude Design.
- A spec-prop line: looks only.
- An owner choice on the southern hemisphere. Default: region-neutral art by
  month.

**Ethics.** Question 3. No scarcity: every look returns, and none holds a
reward.

### ER9. Stories of the doll families (wave 2)

**What.**
- Each chapter opens and closes with a short illustrated beat about its doll
  family: 20 beats, with very few words.
- They are re-readable in the Museum beside the figurine and its bio (Q73).

**Ages.** Kids, adults and older players: a light narrative meta at a
fraction of a restoration meta's art cost.

**Why.**
- Story and restoration carry the genre's long tail (section 2.3).
- The claim that story meta lifts D1 is unverified (U,
  [WN Hub](https://wnhub.io/news/analytics/item-2330), 2019).

**Reuses.** The chapter-complete flow and the Museum.

**Needs.** Claude Design's 20 illustrations and copy, and a §10.2 spec-prop
line. Seen beats can come from chapter progress, so no save step.

**Ethics.** Not applicable. Every beat can be skipped.

### ER10. Family profiles (wave 3)

**What.**
- Up to 4 players on one phone, each with their own progress, streak,
  Museum, Records and stars, picked by a doll face at launch.
- A typed name stays on the device.
- Owned skins, purchases, settings and the reminder stay device-wide.

**Ages.** Families with kids: siblings and parents sharing a tablet. It
matters more now that under-13s are a target (D260).

**Why.** Kids' apps keep a profile per child (section 2.5). Shared progress
frustrates siblings.

**Reuses.** `SaveService` / `HiveSaveService` and `DatabaseService`.

**Needs.**
- A save design: one save per profile in new boxes. Box names are a contract,
  so the existing save box becomes profile 1 and is never renamed.
- Migrations.
- The age question per profile.
- A spec-prop line (§13.3).
- Claude Design: the picker.

**Ethics.** Not applicable.

### ER11. Platform surfaces

**(a) Icon actions (wave 1–2, offline).**
- Long-press the app icon for "Today's puzzle" and "Continue level N".
- Uses the flutter.dev `quick_actions` plugin, with a rule-9 reason.
- Size S.

**(b) Game Center and Play Games (with M4/M8, network and accounts).**
- Achievements that mirror the badges and ER2's tiers.
- A friends-only "fewest moves" leaderboard on the daily, so the iOS 26
  Challenges and Activities work.
- Sign-in stays optional.
- Never Google Play's Streaks surface, which sends notifications before a
  streak is lost (respect rule 7).
- Needs:
  - the owner's store-console setup;
  - a package, `games_services` (check its maintenance first: 5.2.0 was
    retracted);
  - a Texas SB 2420 check, since it may add data categories.
- Off on the kid path. Size M.

**Ages.** Teens and adults.

**Why.**
- Google's achievement guidance.
- Hay Day's quests gave +177% installs over 14 days (Google-reported).
- The iOS 26 Games app (section 2.6).

## 4. Existing items the research supports

No new backlog lines for these:
- **Pass-and-play,** option C ("solve together") first. The co-play data in
  section 2.5 favours a mode with no loser for a parent and a child, and for
  grandparents
  ([pass-and-play-proposal.md](pass-and-play-proposal.md)).
- **The widget and the picture share** (local habits 4 and "Wider concepts").
  The widget data is in section 2.6. ER3 needs the picture share's renderer.
- **The level-sharing code** (Later). ER4 is its first step.
- **The Museum diorama** (Later). It is the genre's long-tail engine, at a
  large art cost.
- **About 20 new levels a week** (Later, M4 and M5). New content is the
  respectful form of live ops.

## 5. Don't copy

| Pattern seen in top games | Why not | Instead |
|---|---|---|
| A win streak that resets on a loss (Royal Match, Candy Crush; reportedly +38% revenue) | Shames a loss and raises fail-offer conversion (section 2.1). Checklist question 5 | ER2's lifetime milestones |
| Timed events and weekly dashes (Lava Quest, Lightning Rush, King's Cup) | Countdowns and scarcity (rule 3). PEGI rates time-limited offers 12+ | ER8, and the untimed race |
| A season pass (Royal Pass) | FOMO and a paid track | New content (M4), and ER2 |
| Random sticker packs with duplicates and deadlines (Monopoly GO) | Loot-box-like (rule 2). PEGI 16. Brazil bans paid loot boxes for under-18s from 17 Mar 2026 ([PocketGamer.biz](https://www.pocketgamer.biz/brazil-bans-loot-boxes-for-under-18s-in-online-child-safety-measure/)) | The Museum's fixed figurines |
| Team events with fake teammates, or bots shown as people | Dishonest (rule 5) | Pass-and-play, ER4 |
| Loss-framed or pre-loss streak notifications, including Play's Streaks | Rule 7. PEGI rates a penalty for not returning 12+ | The opt-in reminder (E4) |
| Leagues and public leaderboards | Anxiety and speed, and unsafe for kids | Private bests, ER4 |
| A streak wager or streak repair (Duolingo's +14% wager) | Sells loss aversion (rule 4) | The gentle streak (E2) |
| Ads that gate progress | Older players' top frustration ([AARP](https://www.aarp.org/pri/topics/social-leisure/activities-interests/2023-gamers-50-plus/)). Rule 1 | Already so |

## 6. The kid path (ER12, decided by the owner, D260)

### 6.1 The decision

The owner chose on 2026-10-04 to make under-13s a target audience too.
Nesty becomes a mixed audience: adults stay the core, and children are a
real audience.

This changes spec §1 ("The game is not designed for children") and §17
("don't market to children"), and D92's "not made for or marketed to
under-13s". Until the owner pastes section 6.4's text, D260 is the rule
(CLAUDE.md: the decisions log adds to the spec by the owner's decision).

The respect rules (spec-prop §1.1) apply to every age unchanged. The kid
path adds to them.

### 6.2 What the rules require

Checked against the primary pages on 2026-10-04. The owner confirms the
legal details for their own situation, as §17 already says.

| Rule | What it requires of a mixed-audience game |
|---|---|
| [Google Play Families](https://support.google.com/googleplay/android-developer/answer/9893335) | A neutral age screen. For children and players of unknown age: ads only from Families self-certified SDKs, no interest-based ads or remarketing, and no AAID, SIM, build serial, BSSID, MAC, SSID, IMEI or IMSI sent. No interstitial at launch, and nothing "not closeable after 5 seconds". Coins kept apart from real money. Nothing "emotionally manipulative" pushes ads or purchases. SDKs not approved for children run only behind the age screen. Social features need an online-safety reminder and adult action before a child shares personal information |
| [FTC COPPA FAQ](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions) (rule amended 22 Apr 2025, compliance from 22 Apr 2026, [FTC](https://www.ftc.gov/news-events/news/press-releases/2025/01/ftc-finalizes-changes-childrens-privacy-rule-limiting-companies-ability-monetize-kids-data)) | No personal information, persistent identifiers included, before the age is asked. Month and year are entered freely, with no 13+ default. Children can't be blocked, only routed. Nothing is collected from an under-13 without notice and parental consent. The amended rule adds separate consent for third-party disclosures, a written retention policy and a security programme |
| [Apple App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) 1.3, 2.3.8, 5.1.4, 2.5.18 | Outside the Kids Category, no name, subtitle, icon, screenshot or description may imply children are the main audience. "For Kids" wording is reserved for that category. Ads must suit the age rating, with no behavioural ads from kids. A parental gate is required only inside the Kids Category, but it is good practice here |
| [AdMob child-directed treatment](https://support.google.com/admob/answer/6223431) | Tag children's requests child-directed, with max ad content rating G. Use GMA SDK Android ≥ 20.6.0 or iOS ≥ 7.67.0, so no ad ID is sent. Non-certified sources are blocked, so fewer ads fill |
| Texas SB 2420 ([text](https://capitol.texas.gov/tlodocs/89R/billtext/html/SB02420F.HTM); in force, [InfoLawGroup](https://www.infolawgroup.com/insights/2026/7/7/supreme-court-clears-the-way-texass-app-store-accountability-act-is-now-enforceable); Apple applies it from 4 Jun 2026, [Apple](https://developer.apple.com/news/?id=f5zj08ey)) | Stores pass on an age category (under 13, 13–15, 16–17, 18+). The developer assigns a rating and notifies the stores before a "significant change" (new ads, purchases or data categories), which re-asks parents. Age data may be used only for compliance and safety |
| Utah (6 May 2027), Louisiana (1 Jul 2027), California AB 1043 (1 Jan 2027) ([Loeb](https://www.loeb.com/en/insights/passle/2026/05/update-on-utah-app-store-law--another-waiting-game), [Wikipedia](https://en.wikipedia.org/wiki/California_Digital_Age_Assurance_Act)) | The same model. California deems a developer who requests the age signal to have actual knowledge of it. Recheck all three before M8 |
| [PEGI](https://pegi.info/news/pegi-expands-age-rating-criteria-interactive-risk-categories) (new submissions from June 2026) | A reward for returning means at least PEGI 7. A penalty for not returning, or a time-limited offer, means at least 12. Paid random items mean 16. The gentle streak and no offers keep Nesty at 7 |
| [UK Children's Code](https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/childrens-information/childrens-code-guidance-and-resources/age-appropriate-design-a-code-of-practice-for-online-services/13-nudge-techniques/) and [the ICO's mobile-games review](https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/childrens-information/childrens-code-guidance-and-resources/children-s-code-strategy-progress-update-august-2026/our-work-with-mobile-gaming-services/) (Dec 2025; update Aug 2026) | High-privacy defaults, no nudging children to weaken privacy, and break nudges endorsed. A DPIA |
| [GDPR Art. 8](https://gdpr-info.eu/art-8-gdpr/) | Consent from 16 by default. Member states may lower it to 13. Below it, the parent consents |
| [FTC v. HoYoverse](https://www.ftc.gov/news-events/news/press-releases/2025/01/genshin-impact-game-developer-will-be-banned-selling-lootboxes-teens-under-16-without-parental) (Jan 2025, $20M) and [FTC v. Epic](https://www.ftc.gov/news-events/news/press-releases/2022/12/fortnite-video-game-maker-epic-games-pay-more-half-billion-dollars-over-ftc-allegations) (2022) | No loot boxes to under-16s without parental consent. Prices are clear, not hidden behind currency. Purchase flows have no dark patterns. Nesty already has no loot boxes (rule 2) |

**Age signals.** Apple's Declared Age Range (iOS 26+) and Google Play's Age
Signals can stand in for the question. The
[`age_range_signals`](https://pub.dev/packages/age_range_signals) plugin
wraps both.

### 6.3 What Nesty does (Q174's defaults)

| Part | When | Default |
|---|---|---|
| A neutral age question: month and year, no default, never blocks a child | Local phase, after M7 and the local habits, before M4 | Asked after the first win, so L1 stays instant (E9, E13). Stored on the device only. Unanswered means the kid path. Store age signals replace it where available (M6) |
| A parent area behind a parental gate | Local phase | Holds the daily reminder and its time, sharing, links out (privacy policy, support) and, from M6, purchases. On the kid path, a child is never offered the reminder, and Share and the links ask for a grown-up |
| Analytics and crash data by age | M4 | Nothing is collected before the age answer, and ad-ID collection is off for everyone. For under-13 and unknown age, analytics is off until the owner's legal check, and crash reports run for the app's own operation only |
| Ads by age | M6 | Requests for under-13 and unknown age are child-directed, rated G, from certified sources and never personalized. §9.1's pacing stays (no ad before L8, so none at launch). Every ad is closeable within 5 s. No rewarded placements on the kid path. EU players under their country's consent age get AdMob's under-age-of-consent tag (check at M6). Expect lower fill (Q86) |
| Purchases by age | M6 | On the kid path, the paid Shop tabs, the starter pack and the Remove Ads offer sit behind the gate, and a child is shown no purchase offer. Coins are always shown apart from real money |
| Store listing | M8 | Play Console declares the under-13 bands plus 13+. Default 9–12; add 6–8 only after a readability pass of the tutorial and copy. The App Store gets a family tone with no "for kids" wording, outside the Kids Category. The IARC, PEGI, Data Safety and App Privacy answers match D260 |
| A legal check | Before M4's analytics and before release | The owner (§17): COPPA, the Play Families declaration, a UK Children's Code DPIA, GDPR Art. 8 ages, Texas |

### 6.4 Spec text for the owner to paste

**§1 Target players.** Replace the second bullet ("Store listing age target:
13+ or 18+ (see §17). The game is not designed for children.") with:

```markdown
- A mixed audience (D260): adults 18–55 stay the core, and children are a real audience too. Every player under 13, and every player of unknown age, gets the kid path (§17). Store listing: the under-13 age bands the owner picks plus 13+ on Google Play; a family tone and no "for kids" wording on the App Store, outside the Kids Category (§17).
```

**§17.** Replace "Declare the target audience honestly in Play Console and
don't market to children. If under-13 players are ever included, the
Families policy applies (certified ad SDKs only, no personalized ads)." with:

```markdown
- Declare the target audience honestly in Play Console, including its under-13 age bands. The Google Play Families policy applies: a neutral age screen; for children and players of unknown age, ads only from Families self-certified SDKs, child-directed and rated G, never interest-based or remarketing, and no advertising ID or other device identifier sent; no interstitial at launch; every ad closeable after 5 seconds; coins always kept apart from real money; nothing emotionally manipulative pushes an ad or a purchase.
- COPPA (a mixed audience): nothing personal, including a persistent identifier, is collected before the age is known, and nothing from a player under 13 without a parent's consent. The age question takes month and year with no default and never blocks a child.
- The kid path, for every player under 13 or of unknown age: a parental gate before purchases, sharing and links out; the daily reminder only when a grown-up turns it on; no rewarded ads; analytics off until the owner's legal check (crash reports allowed for the app's own operation).
- App Store: not in the Kids Category, and no metadata implies children are the main audience (guidelines 2.3.8, 5.1.4).
```

### 6.5 Claude Design request for the kid path

Paste everything between the lines into Claude Design, in the Nesty project.

---

**Nesty: Doll Sort, the kid path (a small round)**

Nesty now welcomes children as well as adults. Players under 13, and anyone
who hasn't told us their age, play the same game on a "kid path". The game
asks their age once, and a grown-up controls a few things behind a simple
check. Keep every convention of the existing handoff: `tokens.json` stays
the single source of values, new screens get App Flow frame ids, and copy
goes in copy.md with ids. Everything stays warm and never pushy. No
countdowns, nothing random for sale, and no "for kids" wording anywhere in
the app's store art.

1. **The age question** (after the first win, before Home).
   - One calm screen with a month and year picker, with no value
     pre-selected.
   - A line saying it stays on this phone, and one Continue button.
   - Readable by a 9-year-old, and passes at 1.3× text.
   - States: empty (Continue disabled) and filled.
2. **The parental gate.**
   - A small sheet that a grown-up passes in seconds and a child can't pass
     by chance. For example: type a number written in words, localizable in
     9 languages.
   - States: asking, wrong (a gentle retry, never a scolding), and passed.
3. **The parent area** (reached from Settings, behind the gate).
   - Rows: Daily reminder and its time, Sharing on/off, Privacy policy,
     Support, Purchases (shown from the ads-and-purchases round), and a short
     "About the kid path" text.
4. **Kid-path states of existing frames.**
   - The daily win without the reminder offer (10.2).
   - The Share button (10.1) and the Settings links (8.1) when they need a
     grown-up.
   - The Shop's Coins and No Ads tabs (7.1, 7.8) behind the gate.
5. **Copy** for all of the above, with ids, in the existing voice.

---

## 7. Open questions

- **Q173. Which proposals to build, and in what order** (after M7 and the
  local habits, D259)?
  - Default: wave 1 first (ER1 Free Play, ER2 milestones, ER3 the monthly
    recap with the picture share, ER4 challenge codes, ER5 the healthy-play
    kit), then the wave 2 items you pick (ER6–ER9), with ER10 and ER11 later.
- **Q174. The kid path's details (D260).** Defaults, as in section 6.3:
  - Play bands 9–12 plus 13+.
  - The age question after the first win, with store signals where
    available.
  - Kid-path ads child-directed, G and certified, with no rewarded
    placements.
  - Purchases behind the gate.
  - The reminder and sharing are turned on by a grown-up.
  - Analytics off for under-13 and unknown age until the legal check.
  - Not in Apple's Kids Category.
  - Or: no ads at all on the kid path, or younger bands.

## Sources

Grouped by section. A (S) or (U) mark beside a figure in the text applies
here too.

**Genre and market**
- [Deconstructor of Fun, sort puzzles](https://www.deconstructoroffun.com/blog/2026/2/6/sort-puzzles-how-a-new-subgenre-is-born)
- [Deconstructor of Fun, Pixel Flow](https://www.deconstructoroffun.com/blog/2026/2/13/pixel-flow-the-publishers-dream)
- [Deconstructor of Fun, win streaks](https://deconstructoroffun.com/blog/2024/8/5/win-streak-the-gift-that-keeps-on-giving)
- [Game Growth Advisor, hybrid-casual 2026](https://gamegrowthadvisor.com/blog/2026-04-16-hybrid-casual-game-design-strategy-2026/)
- [Game Growth Advisor, retention 2026](https://gamegrowthadvisor.com/blog/2026-03-17-mobile-game-retention-strategies-2026/)
- [Gamigion, hybrid-casual 2025](https://www.gamigion.com/2025-hybridcasual-market-overview-with-real-data/)
- [Gamigion, Magic Sort](https://www.gamigion.com/magic/)
- [Naavik, Royal Match](https://naavik.co/deep-dives/royal-match/)
- [Udonis, Royal Match](https://www.blog.udonis.co/mobile-marketing/mobile-games/royal-match-analysis)
- [Liquid & Grit](https://liquidandgrit.com/?p=13687)
- [PocketGamer.biz, Royal Kingdom](https://www.pocketgamer.biz/royal-kingdom-surpasses-300m-in-first-year-beating-royal-match/)

**Daily ritual, streaks and recaps**
- NYT Games:
  [Today](https://www.today.com/popculture/hardest-wordle-connections-puzzle-2025-new-york-times-games-rcna251022),
  [Creative Review](https://www.creativereview.co.uk/new-york-times-games-wordle-crossplay-design-jonathan-knight/),
  [Engadget](https://www.engadget.com/gaming/nyt-games-has-a-year-in-review-thing-now-too-203000878.html)
- Duolingo:
  [streak research](https://blog.duolingo.com/duolingo-streak-research/),
  [improving the streak](https://blog.duolingo.com/improving-the-streak),
  [streaks and commitment](https://blog.duolingo.com/how-streaks-keep-duolingo-learners-committed-to-their-language-goals),
  [friend streak](https://blog.duolingo.com/product-lessons-friend-streak/),
  [Year in Review](https://blog.duolingo.com/year-in-review-behind-the-scenes),
  [Q2 FY26 8-K](https://www.sec.gov/Archives/edgar/data/0001562088/000162828026053299/q2fy26duolingo6-30x26share.htm),
  [DoF on Duolingo's streaks](https://duolingo.deconstructoroffun.com/mechanics/streaks)
- [TechCrunch, Spotify Wrapped 2025](https://techcrunch.com/2025/12/04/spotify-says-wrapped-2025-is-its-biggest-yet-with-200m-users-in-its-first-day)
- [Sudoku.com on the App Store](https://apps.apple.com/us/app/sudoku-com-number-games/id1193508329)
- [Giant Bomb, Microsoft Solitaire Collection](https://www.giantbomb.com/microsoft-solitaire-collection/3030-39318)

**Psychology**
- Self-determination theory:
  [Ryan, Rigby, Przybylski](https://acuresearchbank.acu.edu.au/item/8q128/the-motivational-pull-of-video-games-a-self-determination-theory-approach),
  [Przybylski et al.](https://acuresearchbank.acu.edu.au/item/89x90/having-to-versus-wanting-to-play-background-and-consequences-of-harmonious-versus-obsessive-engagement-in-video-games)
- Difficulty: [CMU](https://hcii.cmu.edu/news/chi-preview-researchers-hcii-believe-difficulty-can-be-overrated-games)
- Rewards:
  [Deci, Koestner, Ryan](https://depts.washington.edu/techdocs/papers/deciExtrinsicRewardsAndIntrinsicMotivation99.pdf),
  [Mekler et al.](https://hcds.itu.dk/bibliography/mekler2013points)
- Progress effects:
  [Nunes & Drèze](https://msbfile03.usc.edu/digitalmeasures/jnunes/intellcont/Endowed%20Progress%20Effect-1.pdf),
  [Norton, Mochon, Ariely](https://dash.harvard.edu/handle/1/12136084),
  [Dai, Milkman, Riis](https://faculty.wharton.upenn.edu/wp-content/uploads/2014/06/Dai_Fresh_Start_2014_Mgmt_Sci.pdf),
  [peak-end in games](https://dx.doi.org/10.1145/2858036.2858419),
  [Zeigarnik meta-analysis](https://ideas.repec.org/a/pal/palcom/v12y2025i1d10.1057_s41599-025-05000-w.html)
- Habits and streaks:
  [BPS on habit formation](https://bps.org.uk/research-digest/how-form-habit),
  [Colorado on broken streaks](https://www.colorado.edu/business/faculty-research/2023/04/19/or-track-how-broken-streaks-affect-consumer-decisions)
- Stopping cues:
  [stopping cues](https://arxiv.org/pdf/2407.18803),
  [break pop-ups](https://pmc.ncbi.nlm.nih.gov/articles/PMC4369874)

**Ages and families**
- Surveys:
  [ESA 2025](https://www.theesa.com/resources/essential-facts-about-the-us-video-game-industry/2025-data/),
  [ESA generations](https://www.theesa.com/annual-esa-study-reveals-video-games-universal-appeal-across-generations/),
  [Pew, teens](https://www.pewresearch.org/internet/2024/05/09/teens-and-video-games-today/),
  [Ofcom via TIGA](https://tiga.org/news/ofcom-publishes-report-on-media-use-amongst-children-and-parents),
  [Quantic Foundry](https://quanticfoundry.com/age-report/)
- Older players:
  [AARP 2023, gamers 50+](https://www.aarp.org/pri/topics/social-leisure/activities-interests/2023-gamers-50-plus/),
  [AARP, accessibility](https://www.aarp.org/pri/topics/technology/internet-media-devices/gamer-accessibility-preferences-older-adults/),
  [NN/g, seniors](https://www.nngroup.com/articles/usability-for-senior-citizens/)
- Child profiles:
  [ABCmouse](https://support.abcmouse.com/hc/en-us/articles/360048174313),
  [Kahoot!](https://support.kahoot.com/hc/en-us/articles/4815253732371)
- Matryoshka:
  [Wikipedia](https://en.wikipedia.org/wiki/Matryoshka_doll),
  [Gallerix](https://en.gallerix.ru/lib/matreshka-kak-simvol-rossii-ot-igrushki-do-suvenira)

**Platforms and benchmarks**
- Google:
  [Play Games Services](https://android-developers.googleblog.com/2025/06/get-ready-for-next-generation-gameplay-play-games-services.html),
  [Gratitude widgets](https://android-developers.googleblog.com/2026/05/how-gratitude-widgets-boosted-user-retention-25-percent.html),
  [Google Play Q2 2026](https://google.play/the-latest/2026-q2/)
- Apple: [WWDC25 214](https://developer.apple.com/videos/play/wwdc2025/214),
  [WWDC25 215](https://developer.apple.com/videos/play/wwdc2025/215/)
- Notifications:
  [Android notification permission](https://developer.android.com/develop/ui/views/notifications/notification-permission),
  [Airship 2025](https://growth.airship.com/rs/313-QPJ-195/images/Airship-2025-Push-Notification-Benchmarks-EN.pdf?version=0),
  [9to5Mac on Live Activities](https://9to5mac.com/2022/09/26/iphone-14-pro-live-activities-guidelines/)
- Benchmarks:
  [GameAnalytics via GameDev Reports](https://gamedevreports.substack.com/p/gameanalytics-mobile-and-pc-game),
  [Segwise](https://segwise.ai/blog/mobile-gaming-app-user-retention-strategies)
- Packages: [`age_range_signals`](https://pub.dev/packages/age_range_signals),
  [`games_services`](https://pub.dev/packages/games_services/versions/5.2.0)
- [WN Hub on story meta](https://wnhub.io/news/analytics/item-2330),
  [arXiv survey on player-made levels](https://arxiv.org/pdf/2412.13743)

**Law and ratings**
- Google: [Play Families](https://support.google.com/googleplay/android-developer/answer/9893335),
  [AdMob child-directed treatment](https://support.google.com/admob/answer/6223431)
- Apple: [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/),
  [Apple developer news](https://developer.apple.com/news/?id=f5zj08ey)
- FTC:
  [COPPA FAQ](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions),
  [COPPA final rule](https://www.ftc.gov/news-events/news/press-releases/2025/01/ftc-finalizes-changes-childrens-privacy-rule-limiting-companies-ability-monetize-kids-data),
  [HoYoverse](https://www.ftc.gov/news-events/news/press-releases/2025/01/genshin-impact-game-developer-will-be-banned-selling-lootboxes-teens-under-16-without-parental),
  [Epic](https://www.ftc.gov/news-events/news/press-releases/2022/12/fortnite-video-game-maker-epic-games-pay-more-half-billion-dollars-over-ftc-allegations)
- US states:
  [Texas SB 2420](https://capitol.texas.gov/tlodocs/89R/billtext/html/SB02420F.HTM),
  [InfoLawGroup on Texas](https://www.infolawgroup.com/insights/2026/7/7/supreme-court-clears-the-way-texass-app-store-accountability-act-is-now-enforceable),
  [Loeb on Utah](https://www.loeb.com/en/insights/passle/2026/05/update-on-utah-app-store-law--another-waiting-game),
  [California AB 1043](https://en.wikipedia.org/wiki/California_Digital_Age_Assurance_Act)
- Ratings and loot boxes:
  [PEGI](https://pegi.info/news/pegi-expands-age-rating-criteria-interactive-risk-categories),
  [PocketGamer.biz on Brazil](https://www.pocketgamer.biz/brazil-bans-loot-boxes-for-under-18s-in-online-child-safety-measure/)
- UK and EU:
  [ICO nudge standard](https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/childrens-information/childrens-code-guidance-and-resources/age-appropriate-design-a-code-of-practice-for-online-services/13-nudge-techniques/),
  [ICO mobile games](https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/childrens-information/childrens-code-guidance-and-resources/children-s-code-strategy-progress-update-august-2026/our-work-with-mobile-gaming-services/),
  [GDPR Art. 8](https://gdpr-info.eu/art-8-gdpr/)
