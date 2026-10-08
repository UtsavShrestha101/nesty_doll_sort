# Plan: the local habits, 2026-10-08

Status: **§7.5c and its defaults are approved (Q189, 2026-10-08, D310); Q190
and Q191 keep their defaults.** Stages 1 (welcome back) and 2 (the month) are
built and pass on both devices (D302, D309). Stage 3 (the past dailies) is in
progress. Stage 4 (the widget) starts only
after 1–3 pass on both devices.

- **The pick:** all four, in order, the widget last (D274, Q162). They start
  now with M7's and the gift's sign-offs open (D297, as D272 did).
- **The proposal:** [local-habits-brainstorm.md](local-habits-brainstorm.md)
  "The four proposals". The rules are the ones in this plan.
- **The work list:** BACKLOG "Local habits". **The design request:**
  [claude-design-request-m7-6.md](claude-design-request-m7-6.md) (App Flow
  section 14). Until `nesty-design-m7-6` arrives, every new surface is a
  `TODO(design)` stand-in built from the existing tokens (spec §12).
- **Local first (D269):** nothing here needs a network, an account, an ad or
  a purchase. The two numbers the admin will tune are Remote Config keys with
  bundled defaults.

## The respect rules every habit keeps

From D92 and spec-prop §1.1, plus the owner's list for this build. The ethics
test `test/ethics/local_habits_respect_test.dart` checks them in code and in
the copy of all nine locales.

- Nothing pops up on its own, and there is no new notification.
- No countdown, no timer, and no "expires", "last chance", "missed", "lost",
  "broken", "hurry" or "today only".
- No red mark, no X and no broken chain. A blank day is not a failure.
- A gap never lowers anything. An old day never repairs or moves the streak.
- No ad or purchase in any habit's path, and nothing paid unlocks a past day.

The Daily's existing "Next puzzle in 14h 12m" line (frame 5.5) is designed and
outside these habits. No habit adds another.

## The rule (spec-prop text for the owner to paste, §7.5c)

```markdown
### 7.5c Past dailies
Besides today's puzzle, the Daily lets the player play the dailies of the
last 7 days: the local dates from today − 7 to today − 1 (Remote Config
`daily_archive_days`). A past day's board is the one that date's daily had:
generated from `seed = yyyymmdd` with the pinned `generatorVersion` and that
date's tier (or that date's admin override, as §7.5 says), so every phone
gets the same board. The window doesn't depend on when the player installed
the game or unlocked the Daily; it opens with the Daily (after level 2).

A past day is for fun:
- It pays nothing: no coins and no chest. Nothing is spent to open it, no ad
  or purchase is involved, and nothing paid unlocks a day. On its board only
  the boosters the player owns can be used: none can be bought with coins
  or an ad there, and Out of moves offers only those and Restart.
- It never moves the streak, never grants or spends a freeze, never counts
  toward the day-7 chest and can't relight a paused streak.
- It doesn't count in Records' dailies solved or the longest streak, nor
  toward the badges counted from them. Like a replay (§7.1), it still counts
  in the wins, moves, families and dolls nested.
- Its board in progress is kept apart from today's, which it never replaces.
- The month (§10.2 #11) marks a day solved this way as "played later",
  quieter than a day solved on its own date.
- A past day can be played again at any time while it is in the window, and
  pays nothing.
- A date leaves the window when it is more than 7 days old. Nothing counts
  down to that, and nothing calls it expired or a last chance. A board
  already open when its date leaves can still be finished.
```

**Defaults in it, for approval (Q189):**

| Point | Default | Why |
|---|---|---|
| What a past day pays | Nothing | It can't be farmed (brainstorm §7) |
| Records' dailies, longest run | Not counted | They count days solved on their date |
| Wins, moves, families, dolls | Counted, as a replay is (spec-prop §7.1) | Lifetime totals; badges pay no coins |
| The month | Lit as "played later", quieter | It was played; it isn't the streak |
| Replays | Allowed, paying nothing | It is for fun |
| Share on a past day's win | None | The share card is "today's daily" (E3) |
| In progress | One past-day board at a time, apart from today's | Starting another past day replaces it |
| The window's start | Independent of install date | A new player gets a week of puzzles |
| Boosters on a past day | Only owned ones; no coin or ad buy, and Out of moves offers only those and Restart | No spend or ad in a habit's path (m7-6 draws it, D301) |

**Also needed in the spec (for the owner's paste, beside §7.5c):**
- **§9.4:** `welcome_back_days 2` and `daily_archive_days 7`.
- **§10.2 #2 Home (addition):** after two or more days away, one dismissible
  welcome-back card that plays today's daily.
- **§10.2 #11 Daily (addition):** the current month of played days, and the
  last 7 days playable from it (§7.5c).
- **§10.2 (new) Home-screen widget:** today's puzzle (ready or solved) and the
  streak; a tap opens the Daily.
- **§13.3:** `"dailyArchive": {"played": ["2026-10-03"], "inProgress": null}`,
  and the settings `lastOpenDate` and `welcomeBackDate`.

## What the admin tunes later (D269, rule 6)

Two `RemoteConfigKey<int>` in `remote_config_keys.dart` (and `all`, the
defaults and the fake). A malformed or out-of-range value is clamped, never
thrown.

| Key | Default | Clamp | Read by |
|---|---|---|---|
| `welcome_back_days` | 2 | 2–60 | `WelcomeBackRules` |
| `daily_archive_days` | 7 | 0–28 (0 turns the archive off) | `DailyArchiveRules` |

The welcome-back gap stays at least 2: with a gap of 2 or more, at least one
day was missed, so a lit flame on return always means a freeze covered it.
That keeps the three card variants true. The window stays at most 28 days, so
every playable date is in the current month or the one before it (Q190).

## Shared pieces

- **Dates:** `AppClock.today()` and `LocalDate` everywhere. No `DateTime.now()`
  in rules, and no `Random`.
- **The week's first day:** the month starts its rows on the locale's first
  day, from `intl`'s `DateSymbols.FIRSTDAYOFWEEK`. The app's rendered locale
  drops the region (`en_GB` renders as `en`, whose week starts on Sunday).
  So the week start comes from the phone's first preferred locale whose
  language is the rendered one (`en_GB` → Monday), else from the rendered
  language. One pure helper, `WeekStart.of(rendered, deviceLocales)`, in
  `core/ui/`, tested for en_US, en_GB, de, pt_BR, ja, hi and tr.
- **Month and weekday names:** `intl` (`DateFormat.yMMMM` for the title, the
  standalone narrow weekdays for the header), in the rendered locale. Nothing
  for them goes in the ARB.
- **Analytics (`AnalyticsService`, the fake until M4):** `welcome_back_play`,
  `past_daily_complete {days_ago, again}` and `widget_open`. No event when
  the card or the month is only shown. The kid path keeps every one of them
  off for under-13s: BACKLOG M4's kid-path analytics item gains these three
  names, and each call site carries a `TODO(M4)` that points to it.
- **Ethics test:** `test/ethics/local_habits_respect_test.dart`, on the
  `login_gift_respect_test` pattern. It grows with each stage:
  - **The code scan:** the habits' folders import no `ads`, `purchase` or
    `dart:math` `Random`, and no `Timer.periodic` or countdown widget.
  - **The streak scan:** nothing in a habit's path writes `daily.streak`,
    `daily.lit`, `daily.run`, `daily.freezes`, `daily.done` or
    `records.dailies`. The past-day path is checked by a save-level test
    (stage 3).
  - **The copy scan:** every habit key, in all nine locales, has none of the
    banned words, against `test/l10n/locales/<code>.dart`'s lists plus the new
    words ("expire", "last chance", "missed", "lost", "broken", "hurry",
    "today only" and their translations).
  - **The pop-up scan:** no habit calls `showDialog`, `showModalBottomSheet`
    or a route push without a tap.
- **Strings:** English first, then the eight translations by an Opus pass
  with the Opus review (D240). Then `flutter gen-l10n`, `test/l10n`, and the
  overflow suite in nine locales. `gen_font_subsets` runs every stage; if it
  adds a hi or ja glyph, `build_fonts.sh` follows and its reason goes in
  PROGRESS.

## 1. Welcome back

**Data (settings, no schema step):** two keys in `settings_schema.dart`,
read and written only through `DatabaseService`. They are about this phone,
not the player's progress, so they stay out of the save.
- `lastOpenDate` (`yyyy-mm-dd`): the latest date the app was opened or
  resumed. It is a high-water mark: it never moves back, so a clock wound
  back neither writes an earlier date nor shows a card later.
- `welcomeBackDate` (`yyyy-mm-dd` or absent): the day a welcome-back card
  belongs to. It is set when an open finds the gap, and cleared on dismiss.

**Rules (`core/services/welcome_back/welcome_back_rules.dart`, pure, beside
`LoginGiftRules`):**
- On each open and resume, read `lastOpenDate` first, then write
  `max(lastOpenDate, today)`.
- If `today − lastOpenDate ≥ welcome_back_days`, `welcomeBackDate` becomes
  today. A first launch (no `lastOpenDate`) never counts as a gap.
- The card shows when all of these hold:
  - `welcomeBackDate == today`;
  - the Daily is unlocked;
  - today's daily isn't solved.
- It goes when today is solved, the date changes, or it is dismissed
  (`welcomeBackDate` cleared). It doesn't come back that day.

**State:** `WelcomeBackCubit` (`BaseAsyncCubit`, freezed state: `hidden`, or
`shown(variant, streak)`) in `features/welcome_back/cubit/`. It is fed by
`DatabaseService`, `DailyService.changes` and an `AppLifecycleListener`
resume, as `LoginGiftCubit` is. The open-date write happens in bootstrap,
before Home's first frame, so the gap is read before anything overwrites it.

**Variants (from `DailyStatus`):**
- **Freeze kept the flame:** `lit`, and `frozen` has a date since the last
  open.
- **Paused:** `!lit && streak > 0`, with the number kept.
- **No streak yet:** `streak == 0`.
- **None of these** (not reachable with a gap of 2 or more): the welcome line
  alone, with no streak line.

**UI (stand-in, `TODO(design)` for 14.1):** `WelcomeBackCard` in
`features/welcome_back/widgets/`, inline on Home. It is not a modal or a
sheet.
- **Placement:** on 2.1 it takes the hero band under the chapter card, over
  the twinkles and above the dolls' heads, and leaves Play and the tiles where
  they are. On 2.1b's short body, it takes the chapter card's slot while it
  shows; Records stays. `HomeLayout` gains `welcomeCardTop` and its height for
  both blends.
- **Parts:**
  - the flame in its lit or unlit look (`StreakLook`);
  - the headline and the variant's line;
  - one button, "Play today's puzzle", which pushes the daily's
    `GameplayRoute` as the Daily's Play does;
  - a close control with a 48 dp target and its screen-reader label.
- **Motion:** the entrance is a fade and rise, and a fade only with reduce
  motion.

**Strings (about 7):** `welcomeBackTitle` "Welcome back!",
`welcomeBackFreeze` "A freeze kept your flame lit.", `welcomeBackPaused`
"Your {count}-day streak is resting. Today's puzzle lights it again." (plural),
`welcomeBackNew` "Today's puzzle is ready for you.", `welcomeBackPlay`
"Play today's puzzle", `welcomeBackDismiss` "Close", and
`welcomeBackSemantics`.

**Host tests:**
- **`welcome_back_rules_test`:** gaps of 0, 1, 2, 3 and 30 days; a first
  launch; the clock wound back (no card, `lastOpenDate` kept); forward then
  back; a resume on a new date; Remote Config at 2, 5, 0 and a malformed value
  (clamped).
- **The cubit's `bloc_test`:** the three variants; hidden while locked;
  hidden once today is solved; dismissed stays dismissed on resume; gone on a
  new date.
- **Widget tests:** the card's parts, the 48 dp close target, Play's route,
  and reduce motion. `home_page_test` checks the card beside the gift button's
  ready dot on 2.1 and 2.1b.
- **The overflow suite:** `welcome_back_overflow_test` (five sizes × two text
  scales, nine locales).

**Device step (D169):** a new `daily_states` scenario, `welcome`: seeded save,
`lastOpenDate` = today − 3, a paused streak. Its shots are Home with the card,
then the card dismissed. The playthrough gets a Home shot with the card on
the freeze variant.

**TEST_COVERAGE row:** `features/welcome_back`.

## 2. A month of played days

**Data:** none new for stage 2. `daily.done` (lit) and `daily.frozen` (a
freeze's mark, Q191) are already in the save. `DailyProgress.maxDates` (31)
covers the current month, because every solved date in it is among the last
31 solved dates. Stage 3 adds `dailyArchive.played` ("played later") and, if
Q190 keeps its default, raises the cap to 62.

**Rules (`core/services/daily_month/daily_month.dart`, pure):**
`DailyMonth.of(today, weekStart, done, frozen, played, window)` → the grid's
cells, each one of: `blank` (out of month) or a day with a state of `solved`,
`playedLater`, `frozen`, `notPlayed` or `future`, plus `isToday` and
`playable` (stage 3). Rows run from the week holding the 1st to the week
holding the last day: 4–6 rows.

**UI (stand-in, `TODO(design)` for 14.2):** `MonthCard` in
`features/daily/widgets/`, under `PuzzleCard` on the Daily's scroll, below
`DayStrip` and `ChestRow`. `DayStrip` stays the streak's 7-day cycle.
- **Its parts:**
  - the title, from `DateFormat.yMMMM`;
  - a weekday header row;
  - a 7 × (4–6) grid whose cells fit a 360 dp phone (at least 40 dp each).
- **The day looks:**
  - **Solved:** a lit cell (`StreakLook`'s lit fill).
  - **Played later:** an outline ring in the same hue (stage 3).
  - **Frozen:** the `acUnit` glyph, quiet.
  - **Not played:** plain, the date number only.
  - **Future:** the date number at reduced contrast.
  - **Today:** an outline ring (the theme's accent), whether or not solved.
- **Semantics:** each day cell is one node, "7 October, solved". The grid
  isn't tappable in stage 2.

**Strings (about 6):** the day labels `dailyMonthSolved`,
`dailyMonthPlayedLater` (stage 3), `dailyMonthFrozen`, `dailyMonthNotPlayed`,
`dailyMonthToday` and `dailyMonthFuture`, each taking the date that
`DateFormat.MMMMd` formats.

**Host tests:**
- **`daily_month_test`:**
  - the 1st and the 31st of a month, and February in a leap year;
  - a month that starts on the week's first day, and one that needs 6 rows;
  - Monday and Sunday starts;
  - `done` with dates outside the month;
  - freezes;
  - a player who just unlocked the Daily (all blank).
- **`week_start_test`.**
- **`month_card_test`:**
  - the cells' looks and labels;
  - no red colour, no X glyph and no "missed" text in any state.
- **The overflow suite:** `daily_month_overflow_test` at five sizes and two
  text scales in nine locales, with the readability floor in `ja` and `hi`
  (the weekday header and the day numbers keep the scenes' minimum size, and
  nothing is cut).

**Device step:** a new `daily_states` scenario, `month`: `NESTY_FAKE_DATE` =
2026-10-31, with lit, frozen and blank days. Its shot is the Daily scrolled
to the month. The playthrough's Daily shot shows the month's top.

**TEST_COVERAGE:** the `features/daily` row gains the month.

## 3. The last 7 dailies, playable (Q189 approved, D310)

**Data (save schema 3 → 4, `migrations-engineer`):**
- **A new top-level `dailyArchive: DailyArchive`:**
  - `played: List<LocalDate>` (distinct, oldest first, at most
    `DailyProgress.maxDates`);
  - `inProgress: InProgressLevel?`, the one past-day board in progress, never
    `daily.inProgress`.
- **Step 3 → 4** in `save_migrations.dart`: it stamps the schema, with an
  empty archive.
- **A schema-3 fixture,** `fixtures/schema3_document.json`, taken from a real
  schema-3 save with a gift claim and a daily board in progress. Plus the
  migration test, the codec round trip, the Hive backup (`doc_backup_v3`) and
  the contract tests in both save services.
- **No Hive typeId** is assigned, and no box or field index changes (the save
  is one JSON string).
- **If Q190 keeps its default:** `DailyProgress.maxDates` becomes 62 for
  `done`, `frozen` and `played`, so the month before is known in full. The
  field's shape doesn't change, and the codec's trim reads old saves as they
  are.

**Rules (`core/services/daily_archive/daily_archive_rules.dart`, pure):**
- `window(today)`: the dates `today − daily_archive_days` … `today − 1`.
- `isPlayable(date, today, unlocked)`.
- `prune(archive, today)`: drops an `inProgress` whose date left the window.

**The request:**
- `PlayRequest.pastDaily(int yyyymmdd)` = `PastDailyPlay`, with a new
  `PlayKind.pastDaily('pastDaily')`. Its `tryCreate` checks the date's shape;
  `isGenerated` is true.
- `DefaultLevelResolver._pastDaily` builds the same level as `_daily` for that
  date (so the same board), with `rewardCoins: 0`. It refuses a date outside
  the window. The one exception is a board in progress, which may be
  finished.

**The save path:**
- `recordLevelWin` with a `PastDailyPlay` pays 0 and writes no `daily` field,
  no `records.dailies`, no `longestRun` and no `lastSolve`.
- It opens no chest and adds the date to `dailyArchive.played`.
- It counts in `stats.wins`, `stats.moves`, `records.families` and
  `records.dolls`, and the badges they feed, as a replay does.
- `saveInProgress` and `inProgressFor` route `PlayKind.pastDaily` to
  `dailyArchive.inProgress`.
- The bloc never calls `DailyService.progressAfterSolve` for it.

**UI (stand-ins, `TODO(design)` for 14.3):**
- **The picker (14.3a):** in `MonthCard`, the window's days are tappable
  (48 dp hit area). A date older than the window isn't tappable and shows no
  lock and no word. If Q190 keeps its default, a "‹ September" control (48 dp)
  pages back one month and forward again, never further.
- **The past day's card (14.3b):**
  - Tapping a day selects it, and `PuzzleCard` shows that date.
  - Its parts:
    - the title from `DateFormat.MMMEd` ("Wed, Oct 7");
    - "5 colors · Hard";
    - the preview;
    - Play, or Play again if it was played (14.3e);
    - one calm line, "Just for fun: your streak stays as it is.";
    - a "Back to today" link.
  - It has no coin chip. Selecting a day is page state in `DailyCubit`
    (`selectedPastDate`), not a new route.
- **The board (14.3c):** `gameplay_view`'s date pill formats the past date,
  as the daily's does.
- **The win (14.3d):**
  - `win_overlay`'s daily variant for a past day shows "Moves N".
  - It has no coins row, no streak card change, no chest, no Share and no
    reminder offer.
  - Its button goes back to the Daily, which the daily's page already does.

**Strings (about 6):** `pastDailyTitle`, `pastDailyNote`,
`pastDailyPlayAgain`, `pastDailyBackToToday`, `dailyMonthPlayable` ("{date},
play"), and `dailyMonthPrevious` / `dailyMonthNext` (labels for Q190's
control).

**Host tests:**
- **Core:** `test/generator/daily_past_dates_test.dart`.
  `DifficultyCurve.dailyParams(d)` and the generated level are identical for
  each of the 7 past dates on repeat runs, and equal to the level built when
  that date was today. It runs on the VM and in the web parity run.
- **`daily_archive_rules_test`:**
  - the window at the start of a month and of a year;
  - Remote Config at 0, 7 and 28, and a malformed value;
  - locked;
  - pruning.
- **The resolver:** `_pastDaily` pays 0. It refuses today, the future and a
  date older than the window.
- **The bloc and the save, in both save services:** a past-day win changes no
  `coins`, `daily` (every field), `records.dailies`, `longestRun`, `chests` or
  `lastSolve`. It adds the date to `played`, and a replay adds nothing more.
  - **Today's board survives:** today's daily in progress, then a past day
    played, saved and won, then today's board resumes move for move.
  - **Two past days:** starting a second past day replaces the first one's
    board.
- **The ethics test:** a 400-step walk of random past-day wins and replays
  never changes the streak's fields or coins.
- **Widget tests:** the past day's card (no coin chip, the note), the picker's
  taps and non-taps, and the win card's past variant.
- **Overflow:** the past day's card and the win variant, in nine locales.

**Device step:** a new `daily_states` scenario, `archive`. It seeds a save
with today's board in progress and a paused streak, plays a past day to its
win (`play_test_helpers`' solver path), and checks the streak card unchanged
and today's board resumable. Its shots are the month with the window, the past
day's card, the board's date pill and the win card.

**TEST_COVERAGE:** a new "The past dailies" row in "Across features". The
`features/daily` row names the archive's tests.

## 4. The home-screen widget (after 1–3 pass on both devices)

**The package question (rule 9): no package.** `home_widget` 0.10.0 (pub.dev,
checked 2026-10-08) is maintained and fits Flutter 3.41.2. But:
- its flavor support landed in Sep–Oct 2026 and is still changing (PRs #446,
  #469, #471, #472);
- it adds `path_provider` and a launch channel of its own;
- our widget is static: no buttons and no interactive intents, which iOS 14
  can't do anyway.

The native side needs only a shared key-value store and a reload call. Our
own channel, `com.futrix.nesty/home_widget`, follows `ChannelSystemSettings
Service`, so it adds no dependency. PROGRESS records this as D299. Only the
Android unit tests add test-only Gradle dependencies (JUnit 4, and Robolectric
if it stays cheap), each with its rule-9 row.

**What the app writes (`HomeWidgetService`, rule 4):** the interface
`publish(HomeWidgetSnapshot)` in `core/services/home_widget/`, with
`ChannelHomeWidgetService` (real) and `FakeHomeWidgetService` (records the
last snapshot).
- **The snapshot** is one JSON string, schema `v: 1`:
  - `unlocked`;
  - `days`: eight entries for today … today + 7, each `{date, streak, lit,
    solved}`;
  - `lines`: the state lines, already localized in the rendered language
    through `AppLocaleResolver`, as `DailyReminder` does;
  - `scheme`: the flavor's URL scheme.
- **The projection** comes from a new pure `DailyService.projection(from,
  days)`: the streak rule reconciled forward with no further solves. Native
  code only looks a date up, so no streak rule is re-implemented in Swift or
  Kotlin (hard rule 2's spirit). On a date past the last entry, the last
  entry is shown unsolved.
- **When it writes:**
  - on bootstrap and each resume;
  - on every `DailyService.changes` emission (a solve, a reconcile, a new
    day, a freeze);
  - when the language changes.

  A write identical to the last is skipped. After each write the native side
  reloads the widget's timelines (iOS `WidgetCenter.reloadAllTimelines()`,
  Android `AppWidgetManager.updateAppWidget` for every id).
- **The `HomeWidgetBridge` composer** (beside `DailyReminder`, with no
  interface of its own) wires `DailyService`, `LanguageCubit`'s code and
  `HomeWidgetService`. Bootstrap starts it.

**Tap → the Daily (an auto_route deep link):**
- **One URL scheme per flavor**, so three installs on one phone never
  collide: `nesty`, `nesty-dev`, `nesty-stg`.
  - iOS: an `APP_URL_SCHEME` build setting in the nine configurations, and
    `CFBundleURLTypes` with `$(APP_URL_SCHEME)`.
  - Android: `manifestPlaceholders["appUrlScheme"]` per flavor, and an
    intent-filter on `MainActivity`.
- **The engine's deep linking** is turned on explicitly
  (`FlutterDeepLinkingEnabled`, `flutter_deeplinking_enabled`).
- **The router:** `AppRouter.config(deepLinkBuilder:)` sends any link
  through the splash as usual. It keeps `/daily` as a pending launch target,
  which the splash honours once loading ends:
  - the Daily if it is unlocked, else Home;
  - a first launch's L1 rule wins.

  A warm link (app running) navigates to the Daily. A board on screen is
  already saved in progress on pause.
- **The tap's analytics:** `widget_open` is logged once per tap.

**iOS (WidgetKit, Swift, iOS 14+):**
- **The target:** a `NestyWidget` extension target added by a committed,
  idempotent `tools/ios/add_widget_target.rb`, using the `xcodeproj` gem that
  CocoaPods already ships. It covers:
  - the nine configurations;
  - bundle ids `$(app id).widget` (`com.futrix.nesty.widget`, `.dev.widget`,
    `.stg.widget`);
  - deployment target 14.0;
  - "Embed Foundation Extensions" ordered before "Thin Binary", to avoid
    Xcode 15's build cycle.
- **App Groups:** one per flavor, `group.com.futrix.nesty`, `.dev` and `.stg`,
  through an `APP_GROUP_ID` build setting.
  - It goes in `Runner.entitlements` and `NestyWidget.entitlements`, and in
    both Info.plists as `NestyAppGroup`.
  - The app and the extension read the group from there, never from a
    literal.
- **The store:** `UserDefaults(suiteName:)`, with the snapshot under one key.
- **The timeline:** entries at now and at each of the next eight local
  midnights (`Calendar.current`), with policy `.atEnd`. So the day rolls over
  with the app closed and spends no reload budget. A time zone change is
  caught on the next app write.
- **The views:** `systemSmall` and `systemMedium`, in light and dark, with
  iOS 17's `containerBackground` behind `#available` and iOS 18's tinted mode
  on its accented look. The face is the system rounded one until the design
  says Fredoka (14.4). `widgetURL` carries the flavor's link.
- **Pure logic:** `NestyWidgetCore.swift` (Foundation only) holds the date
  lookup, the next midnights and the snapshot decode. It is compiled into the
  extension and RunnerTests.

**Android (AppWidget, Kotlin, minSdk 24):**
- **The provider:** `com.futrix.nesty.widget.NestyWidgetProvider`, declared in
  the main manifest. It is the same class in every flavor; the applicationId
  suffix keeps the three apart.
- **`res/xml/nesty_widget_info.xml`:**
  - 2 × 2, resizable to 4 × 2;
  - `updatePeriodMillis="0"`;
  - `previewLayout` (API 31+) and `previewImage` (older).
- **The layouts:** `nesty_widget_small.xml` and `nesty_widget_medium.xml`
  (RemoteViews), in light and dark.
- **The store:** SharedPreferences `nesty_widget`, written by the channel.
- **Midnight:** an inexact `AlarmManager.set(RTC, next local midnight + 5 s)`.
  - It is scheduled in `onEnabled` and `onUpdate`, by the alarm itself, and on
    `TIMEZONE_CHANGED`, `TIME_SET`, `BOOT_COMPLETED` and `LOCALE_CHANGED`
    (exempt broadcasts; the boot permission already exists for the reminder).
    `onDisabled` cancels it.
  - It needs no exact-alarm permission. A late alarm still draws the right
    day, because the view looks today up at render time.
- **The tap:** `PendingIntent` (`FLAG_IMMUTABLE`) to `MainActivity`, with the
  flavor's `scheme://daily`.
- **Pure logic:** `WidgetTimeline.kt` holds the date lookup and the next
  midnight.

**Native strings:** the gallery's name and description, and the "open the
game" line before the app has written anything, exist before Dart runs.
- A new `nesty_tools` script, `gen_widget_strings`, writes them from the
  ARBs:
  - iOS `NestyWidget/<lang>.lproj/Localizable.strings`;
  - Android `res/values-<lang>/widget_strings.xml`.
- It has `--check` in CI, like the other generators. Every other widget line
  comes in the snapshot.

**Tests:**
- **Host (Dart):**
  - `HomeWidgetService`'s fake and contract;
  - `HomeWidgetBridge`: a write on each trigger, none when unchanged;
  - `DailyService.projection` against `refresh()` walked day by day, over 40
    seeded saves;
  - the snapshot's JSON shape (a golden);
  - the deep link: `/daily` from a cold start (locked → Home, unlocked → the
    Daily, first launch → L1) and warm;
  - `gen_widget_strings --check`.
- **Swift:** RunnerTests tests `NestyWidgetCore`:
  - the lookup on each date;
  - past the last entry;
  - a DST night (Europe/Amsterdam, America/Sao_Paulo);
  - the midnights list;
  - a malformed snapshot.

  It runs with `xcodebuild test -scheme dev` on the iPhone 16e by UDID.
- **Kotlin:** JVM unit tests for `WidgetTimeline`
  (`./gradlew :app:testDevDebugUnitTest`). If Robolectric stays cheap, also a
  layout test that inflates both sizes in each state.
- **Device (`integration_test/home_widget_test.dart`, scenarios `ready`,
  `solved`, `paused`, `locked`):**
  - it seeds a save and boots;
  - it reads the shared store back through a debug-only channel method;
  - it asserts the snapshot (on iOS, also that the App Group container
    resolves);
  - it pushes `scheme://daily` through `handlePushRouteInformation` and checks
    the Daily.
- **`nesty-test --only widget`** adds these checks:
  - the cold OS path: `xcrun simctl openurl <16e UDID> nesty-dev://daily` and
    `adb shell am start -W -a android.intent.action.VIEW -d nesty-dev://daily
    com.futrix.nesty.dev`, each with a judged screenshot;
  - the extension is embedded: `PlugIns/NestyWidget.appex`;
  - the provider is registered: `adb shell dumpsys appwidget`.
- **Builds:** `flutter build ios --no-codesign --flavor <f> -t
  lib/main_<f>.dart` for dev, stg and prod, and the three APKs.
- **Why a simulator can't do it all (the TEST_COVERAGE row):**
  - `flutter drive` can't place a home-screen widget or tap one;
  - neither simulator nor emulator can be scripted to add a widget without a
    person.

  The row names the host, Swift and Kotlin tests and the store and link checks
  that cover it, and the owner's real-phone check.

**For the owner (BACKLOG "Owner inputs needed"):**
- **The Apple Developer account:**
  - register the three App Groups;
  - add the App Groups capability to the three app ids and to three new
    widget ids;
  - let Xcode's automatic signing refresh the profiles.

  The exact steps are written when stage 4 starts.
- **A real-phone check on iPhone and Android:** add the widget in both sizes;
  see it ready, solve the daily, see it solved; wait past midnight with the
  app closed and see it ready; tap it to reach the Daily.

## Files

| Member | Path | | What |
|---|---|---|---|
| game | `lib/core/services/database/settings_schema.dart` | modify | `lastOpenDate`, `welcomeBackDate` (stage 1) |
| game | `lib/core/services/remote_config/remote_config_keys.dart` (+ fake, defaults, `all`) | modify | `welcome_back_days` (1), `daily_archive_days` (3) |
| game | `lib/core/services/welcome_back/welcome_back_rules.dart` | create | Stage 1's pure rule |
| game | `lib/features/welcome_back/{cubit,widgets}/` | create | `WelcomeBackCubit`, `WelcomeBackCard` |
| game | `lib/features/home/pages/home_page.dart`, `widgets/home_layout.dart` | modify | The card's place on 2.1 and 2.1b |
| game | `lib/bootstrap.dart` | modify | The open-date write (1), the widget bridge (4) |
| game | `lib/core/ui/week_start.dart` | create | `WeekStart.of` (2) |
| game | `lib/core/services/daily_month/daily_month.dart` | create | The grid's cells (2, 3) |
| game | `lib/features/daily/widgets/month_card.dart`, `puzzle_card.dart`, `pages/daily_page.dart`, `cubit/daily_cubit.dart` | create / modify | The month, the picker, the past day's card (2, 3) |
| game | `lib/core/services/save/{save_document,save_document_codec,save_migrations,save_service,hive_save_service,in_memory_save_service}.dart` | modify | `DailyArchive`, schema 4, the past-day win and in progress (3) |
| game | `lib/core/services/daily_archive/daily_archive_rules.dart` | create | The window (3) |
| game | `lib/core/models/play_request.dart`, `core/repository/{default,fake}_level_resolver.dart` | modify | `PastDailyPlay`, `_pastDaily` (3) |
| game | `lib/features/gameplay/{bloc/gameplay_bloc,pages/gameplay_view,overlays/win_overlay}.dart` | modify | No streak path, the date pill, the win variant (3) |
| game | `lib/core/services/daily/{daily_service,streak_daily_service,fake_daily_service}.dart` | modify | `projection` (4) |
| game | `lib/core/services/home_widget/` | create | `HomeWidgetService`, channel and fake, `HomeWidgetSnapshot`, `HomeWidgetBridge` (4) |
| game | `lib/core/router/app_router.dart`, `lib/app/app.dart`, `features/splash/` | modify | The deep link and the pending launch (4) |
| game | `lib/l10n/app_*.arb` (×9) | modify | About 7 + 6 + 6 + 9 keys |
| game | `ios/` (`NestyWidget/`, entitlements, Info.plist, project, RunnerTests) | create / modify | Stage 4 |
| game | `android/app/` (manifest, `widget/`, `res/`, `build.gradle.kts`, `src/test/`) | create / modify | Stage 4 |
| game | `integration_test/daily_states_test.dart`, `home_widget_test.dart`, `playthrough_test.dart` | modify / create | The `welcome`, `month` and `archive` scenarios; the widget check; shots |
| game | `test/ethics/local_habits_respect_test.dart` + the tests above | create | — |
| core | `test/generator/daily_past_dates_test.dart` | create | Stage 3 (no `lib/` change) |
| tools | `bin/gen_widget_strings.dart`, `ios/add_widget_target.rb`, `scripts/nesty-test` | create / modify | `--only widget`; the `daily_states` loop gains `welcome month archive` |
| docs | PROGRESS, BACKLOG, TEST_COVERAGE, CLAUDE.md (Code map, Commands, Current state), README, TODO_INDEX | modify | Each stage |

`nesty_core`'s `lib/` and `nesty_render` don't change.

## Stages, lanes and runs

Each stage keeps `build/local-habits/checkpoints/stage<N>.md` and appends to
`build/local-habits/reports/stage<N>.md` after each batch (D238).
- **Stage 1 and stage 2 run in parallel.** The lead writes both stages'
  English strings and runs `gen-l10n` once. Then two lanes own disjoint
  folders: lane A has `welcome_back` and Home, lane B has `daily_month` and the
  Daily's month. Codegen goes through the lock script. The lead integrates,
  runs the translations with the Opus review, the ethics test and the gate.
- **Stage 3** (after Q189) is serial: save → core test → resolver and bloc →
  UI. `migrations-engineer` owns the save step.
- **Stage 4** is serial: Dart side and projection → iOS → Android → device
  checks. Builds run detached under `watch-run`.
- **Device runs:** the full `nesty-test` on the iPhone 16e
  (87BDED37-4095-49C4-811A-3E2B7D5FB38B) and the Android emulator
  (`flutter_emulator`, 90 s warm-up), as background scripts under
  `watch-run` (`--stall 900`), with 20 GB free checked first. They run once
  after stage 3 and again after stage 4. Every new shot is judged against
  this plan's stand-in intent. The owner's iPhone 15 Pro Max simulator is
  never touched.

## Risks

- **Clock changes:** the high-water `lastOpenDate` means a clock set far
  ahead and back hides the card until that date passes. That is accepted as
  Q188 accepted it for the gift, until M4's server time.
- **Two "weeks" on the Daily:** the 7-day strip (the streak's cycle) and the
  window (the last 7 dates) could read as one. The month carries the window,
  and the strip stays the cycle. The design settles the look.
- **The month boundary:** see Q190. Without paging, on the 1st–7th part of the
  window isn't in the current month.
- **The widget's native work is the largest risk:** the project edit, the
  signing, and simulator App Groups (believed to work unsigned, verified at
  stage 4 before anything else). The Xcode project change goes through a
  script so it can be redone.
- **Generator drift:** a future `Generator.version` bump would change past
  days' boards. §7.5 pins the daily's version, and the past-dates test
  catches drift.

## Open questions

- **Q189. §7.5c and its defaults.** Approve the text above and its table:
  - a past day pays nothing;
  - it doesn't count in Records' dailies;
  - it counts in wins, moves, families and dolls, as a replay;
  - the month marks it "played later";
  - replays are allowed, paying nothing;
  - there is no Share on a past day;
  - one past-day board is in progress at a time;
  - the window doesn't depend on the install date;
  - on a past day's board only owned boosters work, with no coin or ad
    buy (added after m7-6 drew it, D301).

  Stage 3's code waits for this.
- **Q190. The window across a month boundary.** On the 1st–7th, some of the
  last 7 dates are in the previous month.
  - **Default:** the month card can page back exactly one month (a 48 dp
    control) and forward again. The window's days there are tappable, and
    `maxDates` rises from 31 to 62, so the month before is shown in full.
  - **Or:** the grid's first row reaches back to the window's first date, with
    no paging.
  - **Or:** only the current month's part of the window is offered.
- **Q191. A frozen day in the month.**
  - **Default:** a quiet frost mark (the `acUnit` glyph), neither lit nor
    blank. A freeze kept the flame that day, which is good news.
  - **Or:** blank like any day not played. The design (14.2) may restyle
    either.
