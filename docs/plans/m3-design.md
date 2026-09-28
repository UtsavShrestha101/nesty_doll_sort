# M3 design — App shell and meta (authoritative)

Status: written 2026-09-27 by the M3 contracts stage from the approved
[plan-m3.md](plan-m3.md). Every lane after the contracts stage follows this
document; where it and the plan differ, this document wins. BACKLOG cites it
as "m3 §n". Decisions are PROGRESS D66–D80; the owner questions are Q67–Q75.
A default below that the owner may still overturn says "(default, Qn)".

Sources, in the CLAUDE.md order: spec (rules) → `design/tokens.json` → the App
Flow frames → `design/README.md`; the owner's decisions D18–D23 and D63–D65
win over both. Frames are read from the HTML/JS of
`design/prototypes/{Nesty App Flow,NestyMenus,NestyOverlay,NestyShop,NestyBoard}.dc.html`
(390 × 844). The copy quoted here was taken from that source.

M3's acceptance (spec §18): **kill the app mid-level and it resumes exactly
where it was; the daily puzzle is identical on two devices on the same date.**

## 1. What the contracts stage froze

These files exist, compile, are documented and have minimal tests. A lane
may add to them only where its section below says so, and never changes a
frozen signature; a needed change goes in its report for the integrator.

| Area | Files (frozen) |
|---|---|
| Core | `nesty_core`: `codec/game_session_codec.dart` (API; the codec lane implements it), `Generator.generateWithRetries` / `retrySeed` / `maxRetries` / `retryStream`, `GeneratorParams.withSeed` (implemented, tested on VM and Chrome), the barrel export, `public_api_test` |
| Models | `apps/game/lib/core/models/{play_request,play_entry,booster,intro_mechanic}.dart` |
| Clock | `core/services/clock/{app_clock,system_clock,fake_clock,local_date}.dart` (implemented) |
| Save | `core/services/save/{save_service,save_document,save_document_codec,save_migrations,in_memory_save_service,fake_save_service}.dart` (the in-memory rules and the lenient codec are implemented); `HiveBoxes.save`, `SaveBoxKeys`; `DatabaseService.{read,write}SaveDocument`, `{read,write}SaveBackup`, `flushSave` (implemented in Hive and the fake; the save box opens with the settings box) |
| Catalog | `core/repository/{catalog_repository,catalog_models,bundled_catalog_repository,fake_catalog_repository}.dart` (the bundled data is complete) |
| Generation | `core/services/generator/{level_generator_service,fake_level_generator_service}.dart`; `core/repository/{level_resolver,fake_level_resolver}.dart` |
| Daily | `core/services/daily/{daily_service,daily_status,fake_daily_service}.dart` |
| Remote Config | `reward_medium` 10 (D64), `reward_chapter` 150 (default, Q68); `winRewardFor` reads `reward_medium` |
| Routes | `MainShellPage` (tabs Shop · Home · Museum), `SettingsPage`, `DailyPage`, `MuseumPage`, `ShopPage(initialTab)` + `ShopTab`, `SkinDetailPage(skinId)`, `GameplayPage(request)`; `AppRouter`; `ContentReadyGuard`; the splash and Pause/All-levels "Home" go to `MainShellRoute(children: [HomeRoute()])` |
| Gameplay bloc | `GameplayStarted(PlayRequest)`; the constructor `(levels, solver, remoteConfig, save, analytics, resolver, daily, clock)`; the M3 `GameplayState` fields and events of §6.4 (no behaviour yet: no-op handlers) |

DI today: every new service registers its fake for **both** environments
except `AppClock` (real `SystemClock`) and `CatalogRepository` (real
`BundledCatalogRepository`). The services lane swaps in the real ones (§11).

## 2. Stages, lanes and codegen

1. **Contracts** (done): this document, the frozen files, PROGRESS, BACKLOG,
   packages.
2. **Parallel lanes**: core-codec, services, gameplay-bloc, ui-kit-arb.
   **Codegen owner: ui-kit-arb** (`flutter gen-l10n`, then `dart run
   build_runner build`, never at the same time). The other three write code
   that needs no new generated output, construct classes directly in unit
   tests, and list their codegen needs. ui-kit-arb runs build_runner as its
   last step so the services lane's new annotations land; whatever is still
   stale is the integrator's.
3. **Screens**: shell-home-settings, daily-museum-tools, shop,
   gameplay-screens. **Codegen owner: shell-home-settings.** The other three
   write their freezed states and `@RoutePage`s compile-ready and ask for a
   run; the owner runs build_runner whenever asked and once at the end.
4. **Integrator** (every cross-lane edit, the device checks), then **one
   three-lens reviewer**, then **fix-and-close** (`/milestone` gate).

Lane ownership and test plans are §14.

## 3. The save document (D63; spec §13.3)

One JSON text under the key `doc` of the Hive box `save`, reached only
through `DatabaseService` by `SaveService`. The §13.3 `settings` object is
**not** in it: settings stay in the `settings` box, where Pause, the music
and `LanguageCubit` already read them (a recorded §13.3 deviation, D67).

### 3.1 Schema 1

Written in this key order by `SaveDocumentCodec.encode`; unknown top-level
keys follow, sorted.

| Key | Type (JSON) | Default | Notes |
|---|---|---|---|
| `schema` | int | 1 | `SaveDocument.currentSchema` |
| `currentLevel` | int ≥ 1 | 1 | The campaign order PLAY starts. Past the last level it stays `levelCount + 1` (§7.4) |
| `highestLevel` | int ≥ currentLevel | 1 | Max `currentLevel` ever; the dev picker never lowers it; the daily unlocks at 3 |
| `coins` | int ≥ 0 | 0 | Q46 |
| `inventory` | `{"hint": int, "slot": int}` | `{3, 2}` | Spec §8 starter gift |
| `adsRemoved` | bool | false | M6 |
| `ownedSkins` | [string] | `["classic"]` | `classic` always first |
| `selectedSkin` | string | `"classic"` | Always owned |
| `ownedThemes` | [string] | `["ch01"]` | Bought themes; a reached chapter's theme is owned without being listed (§9.4) |
| `selectedTheme` | string or null | null | null = "Match each chapter" |
| `museum` | [chapter id] | [] | In collection order |
| `museumCollected` | {chapter id: "yyyy-mm-dd"} | {} | **Addition** (frame 6.2; D22) |
| `daily` | object | see §8.2 | `streak`, `lastDate`, `freezes` (0–1), `freezeWeek` (isoYear·100+week), `done` [date], `frozen` [date], `noticeDate`, `chestPending`, **`inProgress`** (addition) |
| `inProgress` | object or null | null | The campaign **or** bonus board (§3.4) |
| `adCounters` | `{winsSinceInterstitial, lastAdAt, interstitialsShown}` | zeros | M6 reads them |
| `stats` | `{wins, moves, boostersUsed: {undo, hint, slot}}` | zeros | Every win (all kinds) counts |
| `seenIntros` | ["towers" \| "glass" \| "ice"] | [] | **Addition** |
| `tutorialDone` | bool | false | **Addition**: set when L2's scripted swallow is made |
| `bonus` | `{"next": int ≥ 1}` | `{1}` | **Addition**: the "Bonus Level N" PLAY starts |
| `playerId` | "XXXX-XXXX" hex | made on first load | **Addition** (frame 8.1; default, Q74) |

Dates are local calendar dates, `yyyy-mm-dd` (`LocalDate.toIso`). `done` and
`frozen` keep the last 31, sorted. The Dart model is `SaveDocument` and its
parts (`save_document.dart`, freezed 3); the codec is hand-written (no
json_serializable).

### 3.2 Storage, migrations, backups, writes (the services lane's `HiveSaveService`)

- **Hive facts relied on:** one `put` of one key is one CRC-checked frame;
  a frame torn by a crash is discarded when the box reopens, so the previous
  document survives. That is §13.3's atomic write (D63).
- **Load** (`SaveService.load`, idempotent, never throws), before any read:
  1. `text = database.readSaveDocument()`; `SaveDocumentCodec.read(text)`
     parses, migrates and decodes leniently (§3.3).
  2. If `read.needsBackup` (migrated, newer schema, or not a JSON object):
     `writeSaveBackup(SaveBoxKeys.backup(storedSchema) or
     SaveBoxKeys.invalidBackup, text)` **unless that key already holds a
     backup**, and only then may anything overwrite `doc`.
  3. A document without `playerId` gets `InMemorySaveService.newPlayerId()`
     (Random.secure, app code).
  4. `adopt(document)`; write it once if migrated, invalid or given a new id.
- **Migrations:** `SaveMigrations.steps` maps schema `v` to the step from `v`
  to `v + 1`. Schema **0 = no document** (a fresh install; M2 never persisted
  a save, D13); step 0 stamps schema 1 and the decoder fills the defaults. A
  document without a readable `schema` is read as schema 1. A **newer**
  schema is read leniently, its unknown keys kept, and written back as
  schema 1 after its backup (D68).
- **Writes: one serial, coalescing queue.** Every change calls `persist(doc)`
  (the `InMemorySaveService` hook). At most one `writeSaveDocument` is in
  flight; changes during it mark the queue dirty, and when it finishes the
  latest document is written once. A failed write is logged (M4:
  Crashlytics non-fatal) and retried by the next change or flush; nothing
  throws to callers. The text is `SaveDocumentCodec.write(doc)` (≈ 5–60 KB
  with a long undo history).
- **Flush** (`SaveService.flush`): await the write in flight, write if dirty,
  then `database.flushSave()`. Called on `AppLifecycleState.paused` and
  `detached` by `SaveLifecycleFlusher` (an `AppLifecycleListener` started
  in `bootstrap` after DI; services lane) and by `dispose`.
- **Hive can't open:** `DatabaseModule` already falls back to the in-memory
  `FakeDatabaseService`; `HiveSaveService` runs on it unchanged, so the game
  is fully playable and nothing persists this session (rule 3).
- `HiveSaveService extends InMemorySaveService` (the rules are shared) and
  takes `DatabaseService`, `RemoteConfigService`; `@LazySingleton(as:
  SaveService, env: [AppEnv.real])`, dispose → `dispose()`. The annotation
  moves off `InMemorySaveService`, which stays as the fake's base.

### 3.3 Lenient reads (`SaveDocumentCodec`, implemented)

- Never throws. Not JSON or not an object → the defaults
  (`SaveReadKind.invalid`).
- Integers are read by value (3.0 is 3, like `LevelCodec`, D29); a value of
  the wrong type or below its minimum is its default (coins < 0 → 0,
  `currentLevel` < 1 → 1, `highestLevel` < `currentLevel` → `currentLevel`).
- A missing `inventory` object is the starter gift; a bad count inside a real
  one is 0 (a damaged save never re-grants boosters).
- Lists: non-strings, empties and duplicates dropped; `classic` / `ch01`
  always present; `selectedSkin` not owned → `classic`; `freezes` capped at 1.
- `museumCollected` keeps only ids in `museum` with a real date.
- An `inProgress` missing any of kind, number, level id, level version or
  session is dropped; a generated board without its `level` is dropped; a
  daily board is read only from `daily.inProgress`, the others only from the
  top level.
- `playerId` not matching `^[0-9A-F]{4}-[0-9A-F]{4}$` → null (a new one on
  load).
- Unknown **top-level** keys are kept (`SaveDocument.unknown`) and written
  back; unknown keys inside nested objects are dropped (a later schema that
  nests new fields migrates them). A stray `settings` key is dropped.

### 3.4 Boards in progress

`InProgressLevel` = `{"kind", "number", "levelId", "levelVersion", "tier"?,
"level"?, "session"}`; `session` is `GameSessionCodec.encode` (§4), so
§13.3's `state` and `undo` sit inside `session` (D67).

- Slots: `inProgress` holds the **main line** (a campaign or a bonus board);
  `daily.inProgress` holds today's daily. Playing the daily never loses the
  campaign board.
- **Generated boards** (bonus, daily) also store `level =
  LevelCodec.encode(level)` and `tier`, so a resume never regenerates or
  re-simulates them.
- **Restore** (the bloc, at `GameplayStarted`): the saved board of the
  request's kind is used only when its `request` equals the request **and**
  `levelId == play.level.id` **and** `levelVersion == play.levelVersion`
  (§13.3), and `GameSessionCodec.decode(session, play.level)` is ok. Anything
  else clears that slot and starts the level fresh. A daily board of another
  date is cleared when today's daily starts (it never counts).
- **Writes** (the bloc): `saveInProgress` after every applied move, undo,
  restart and +1 Slot, never for a rejected move, a selection or a hint.
  **The selection and the hint are not saved.** A win clears the board in
  the same update (§3.5). Leaving a level (Home) keeps it.
- Out of moves is just a saved board: on restore core says it is out of
  moves and the sheet opens (§2.3).

### 3.5 Wins in one update

`SaveService.recordLevelWin(LevelWinRecord)` (implemented in memory):
coins `+ rewardCoins`; `stats.wins + 1`, `stats.moves + moves`; then by kind:

- **campaign(order):** `currentLevel = max(currentLevel, order + 1)`,
  `highestLevel` follows; its board cleared; if `completedChapterId` is not
  yet in `museum`: append it, `museumCollected[id] = date`, coins `+
  chapterReward` (only the first time).
- **bonus(n):** `bonus.next = max(next, n + 1)`; its board cleared;
  `currentLevel` untouched.
- **daily:** `daily = win.daily` (from `DailyService.progressAfterSolve`)
  with the daily board cleared.

`recordWin(levelOrder, rewardCoins)` (M2) is the campaign shorthand.

### 3.6 The SaveService surface (frozen)

`load`, `document`, `changes`; `currentLevel` (get/set), `highestLevel`,
`nextBonus`; `coins`, `addCoins`, `spendCoins`, `boosterCount`,
`useBooster`, `addBoosters`, `freeUndosPerLevel`, `unlimitedBoosters`,
`recordBoosterUse(BoosterType)`; `recordWin`, `recordLevelWin`;
`inProgressFor(PlayKind)`, `saveInProgress`, `clearInProgress(PlayKind)`;
`purchaseSkin(id, price)`, `selectSkin(id)`, `purchaseTheme(id, price)`,
`selectTheme(id?)`; `markIntroSeen(IntroMechanic)`, `markTutorialDone`;
`writeDaily(DailyProgress, {addCoins})`; `playerId`; `flush`, `dispose`.
Each mutation is one document update and fires `changes` only when the
document changed. Doc comments in `save_service.dart` are the reference.

## 4. `GameSessionCodec` (nesty_core; the core-codec lane implements)

Web-safe pure Dart (D11), exported from the barrel. API (frozen):
`GameSessionCodec.format = 1`, `encode(GameSession) → Map<String, Object?>`,
`decode(Object? json, Level level) → GameSessionDecodeResult {session?,
issues}`.

```text
{ "format": 1, "levelId": "L0024", "undosUsed": 1,
  "state":   <board>,
  "history": [ {"before": <board>, "move": ["r0c2", "r0c0"]}, … ]  // oldest first
}
<board> = { "moves": 12, "sets": 1, "extra": 1, "opened": ["r1c0"],
            "slots": { "r0c0": [["red4", "red3"]], "r0c1": [], "x0": [] } }
```

- `slots` holds exactly `GameState.slotIds` of that board (grid row-major,
  then the active extras), each slot's nests **bottom to top**, each nest
  outer→inner in the level codec's tokens (`red4`). Encode writes them in
  `slotIds` order. Ice and broken locks are derived from `sets`, so not
  stored; `opened` = the engine's opened mask (towers that emptied, cases
  that broke) as ids in `slotIds` order.
- `history[i].before` is `UndoEntry.before` with its own extra count; the
  move's events are **not** stored.
- **Decode** reads integers by value; checks in this order and stops at the
  first failing group (one issue per problem, JSON pointers, codes below):
  1. `format` is 1 (else `session.unsupportedFormat`, nothing more read);
     required keys and types (`schema.missingField`, `schema.wrongType`,
     `schema.unknownField`, `doll.badToken`).
  2. `levelId == level.id` (`session.levelMismatch`).
  3. Every board is a board of `level` the engine accepts: the slot key set
     equals that board's ids for `extra` (0–2); nests valid (§2.1: same
     color, consecutive, not a full set); open-like slots ≤ 1 nest, towers ≤
     their start depth, `sets` ≤ `totalSets`, the dolls left equal the
     level's minus `sets` whole sets, and the same invariants
     `SolverSnapshot.decode` enforces (factor its checks into a shared
     internal helper rather than copying them) (`session.badBoard`).
  4. The history replays: for each entry, `Rules.tryMove(before, move)` is
     `MoveApplied`, completes no set, and its state equals the next board
     (the next `before`, or `state`) after raising extra slots to that
     board's count (extras only grow and a new one is empty);
     `state.moves == before.moves + 1` follows. Re-derived events become the
     entry's `events` (`session.badHistory`).
  5. `undosUsed` ≥ 0.
- Result: `GameSession.restore(level, state, history, undosUsed:)`.
- New issue codes (append to `IssueCodes` and `all`): `session.unsupportedFormat`
  (args `found`), `session.levelMismatch` (`expected`, `found`),
  `session.badBoard` (`board`: `state` or `history/i`), `session.badHistory`
  (`index`).
- Tests: round trip of state, history (events included) and `undosUsed` on
  boards with towers (a reveal), locks (one broken), ice (cracked), 0/1/2
  extra slots (one added mid-history), a restart, an undo; `jsonEncode`
  stability; each rejection; a history that doesn't replay; VM and `dart
  test -p chrome test/codec/game_session_codec_test.dart`.

## 5. Generator retries and goldens (core-codec lane)

- **Retries (frozen, implemented):** `Generator.generateWithRetries(params)`
  runs `generate(params)`; on a `GeneratorFailure` with attempts > 0 it
  retries with `retrySeed(seed, r) = Prng.derive(seed, 0x52455452 /* 'RETR'
  */, r)` for r = 1..3 (`maxRetries`), keeping `params.id`; the level
  records the seed that produced it. A first-try success is exactly
  `generate`'s output, so no existing golden moves and `Generator.version`
  stays 1. The app always calls `generateWithRetries`.
- **Goldens (new, `test/generator/daily_golden_test.dart`):** Hash64
  digests (as `golden_test.dart`) of `generateWithRetries` for **28
  consecutive dates 2026-09-21 … 2026-10-18** (`dailyParams`) and bonus
  **orders 1–20 and 31–50** (`bonusParams`), plus attempt, tier, retry seed
  used. Run on the VM and `-p chrome` (add them to the parity suite; the
  retry-seed vectors in `generator_retry_test.dart` too). Tag `slow` if the
  VM run passes 30 s.
- Doc-only fixes: the `TODO(M3)` in `curve.dart` (Q34 confirmed the table:
  "the owner's curve", no code change) and `Tier.medium`'s doc (it now pays
  `reward_medium`, D64).

## 6. What is played

### 6.1 `PlayRequest` (frozen, `core/models/play_request.dart`)

Freezed sealed: `PlayRequest.campaign(order)` (`CampaignPlay`),
`.bonus(number)` (`BonusPlay`), `.daily(yyyymmdd)` (`DailyPlay`); `kind`
(`PlayKind.campaign|bonus|daily`, stored ids), `number`, `isGenerated`,
`tryCreate(kind, number)`. It is `GameplayRoute(request:)`'s argument and
`GameplayStarted`'s payload.

### 6.2 `PlayEntry` and `LevelResolver` (services lane: `DefaultLevelResolver`)

`PlayEntry` (frozen): `request, level, tier, levelVersion, rewardCoins,
themeId, chapterId?, completesChapter, expertOnly, bundleEntry?`.

`DefaultLevelResolver` (`core/repository/default_level_resolver.dart`)
composes `LevelRepository`, `LevelGeneratorService`, `RemoteConfigService`,
`SaveService`, `CatalogRepository`; **one implementation for both
environments** (the fake env fakes its parts); `FakeLevelResolver` loses its
annotation and stays for unit tests.

| Request | Level | tier | levelVersion | rewardCoins | chapterId / themeId |
|---|---|---|---|---|---|
| campaign(n) | `entryAt(n)` (null past `levelCount`) | bundle | bundle `version` | `winRewardFor(tier)` | its chapter / that chapter's `themeId` (catalog, else the id) |
| bonus(n) | `bonusParams(levelCount + n)` generated | simulated (Q31) | `generatorVersion` | `winRewardFor(tier)` | null / the last campaign level's chapter theme |
| daily(d) | `dailyParams(d)` generated (null for a non-date) | `dailyTier(d)` | `generatorVersion` | `daily_reward` | null / the chapter theme of `entryAt(currentLevel)` (else the last one) |

- `completesChapter` (campaign): the next entry exists with another
  `chapterId`, **or** there is no next entry and the chapter has
  `ChapterInfo.levels` (20) entries. So with the 30-level bundle L20 completes
  ch01 and L30 completes nothing (ch02 has 10 levels; D72). `TODO(M4)`: when
  sync adds levels to a chapter the player has passed, award its figurine
  then.
- A generated request first looks at `SaveService.inProgressFor(kind)`: when
  the saved `request` equals it, the entry is rebuilt from the saved
  `level` (`LevelCodec.decode`, rules 1–7 by `Validator` without the solver;
  bad JSON → regenerate) and `tier`.
- Generated entries are cached (the last 4 requests) and in-flight requests
  are shared: `prefetch` starts one, `resolve` joins it.
- `next(request)`: campaign(n) → campaign(n + 1) while it exists, else
  bonus(`nextBonus`); bonus(n) → bonus(n + 1); daily → null.
  `homeRequest`: campaign(`currentLevel`) while that exists, else
  bonus(`nextBonus`).
- Rule 3: `resolve` never throws; a generation that fails after the retries
  is null (the bloc shows its retry view).

### 6.3 `LevelGeneratorService` (services lane: `IsolateLevelGeneratorService`)

`generate(GeneratorParams) → Future<GeneratedLevel?>` (`level, tier,
tierMatched, expertOnly`), never throws; `dispose`. The real one runs
`Isolate.run(() => Generator.generateWithRetries(params))` per request (the
params are plain data; the level comes back as `LevelCodec.encode` JSON plus
the tier and flags, decoded on the main isolate), `env: [AppEnv.real]`;
`FakeLevelGeneratorService` (synchronous) keeps `AppEnv.fake`. The
`SolverSnapshot` "generate" task is dropped (D70).

### 6.4 The gameplay bloc (gameplay-bloc lane)

Frozen shape: `GameplayState` adds `play` (required), `offer`
(`BoosterOffer{type, price}`), `undoPrice`/`hintPrice`/`slotPrice`,
`tutorial` (`TutorialCue{step, kind, from, to}`), `intro`
(`IntroMechanic?`), `completedChapterId`, `chapterReward`, `dailyStreak`,
`nextRequest`, `restored`; `acceptsInput` also needs no `offer` and no
`intro`. `entry` stays for the M2 widgets: the bundle entry, or a stand-in
(order `levelCount + n` for Bonus n, the date for a daily, the theme as the
chapter). Events add `BoosterPurchaseConfirmed(BoosterType)`,
`BoosterPurchaseDismissed`, `IntroDismissed`.

Behaviour to build:

1. **Start** `GameplayStarted(request)`: emit `AsyncValue.loading(data:
   previous)` for a generated request; `resolver.resolve`; null → the content
   error (retry view). Restore per §3.4 (`restored: true`, effect
   `BoardResetEffect(start)` on the restored board). Then the tutorial cue
   (§10.4) and the first unseen intro card (§10.4). Analytics §12.
   `GameplayStarted` is also how All Levels Done's "Play Bonus Level N"
   starts the bonus level in the same page.
2. **Save** `saveInProgress(InProgressLevel(request, level.id, levelVersion,
   session: GameSessionCodec.encode(session), level: generated ?
   LevelCodec.encode(level) : null, tier: generated ? tier : null))` after
   every applied move, undo, restart and +1 Slot.
3. **Boosters** §7.3; **win** §7.1, §9.3, §8.5; `nextRequest =
   resolver.next(request)` at the win, and `resolver.prefetch(nextRequest)`
   when it is a bonus request. `NextLevelPressed`: campaign → the next
   campaign level, or `allLevelsDone` when `nextRequest` is a bonus; bonus →
   the next bonus level; daily → nothing (the page pops to Daily).
4. **Tutorial gating** §10.4 and **intro gating** §10.4.
5. Chapter numbers, figurine ids: from `play.chapterId` and
   `CatalogRepository` in the page; the bloc needs only the id.

## 7. Economy and boosters

### 7.1 Coins (spec §7.3; every number from Remote Config)

| Earn | Key | Default | Where |
|---|---|---|---|
| Win easy / medium | `reward_easy` / `reward_medium` | 10 / 10 | campaign and bonus wins (`winRewardFor`) |
| Win hard / superhard | `reward_hard` / `reward_superhard` | 25 / 50 | same |
| Chapter complete | `reward_chapter` | 150 | the chapter's last level's win, once per chapter (default key, Q68) |
| Daily solve | `daily_reward` | 50 | no ×3 (frame 5.4) |
| Day-7 chest | `streak7_reward` | 300 | Collect on 5.6 |
| ×3 on win | `rewarded_coin_multiplier` | 3 | M6 |

| Spend | Key / source | Default |
|---|---|---|
| Undo after the free ones | `price_undo` (free: `free_undos_per_level`) | 20 (2 free) |
| Hint with 0 held | `price_hint` | 60 |
| +1 Slot with 0 held | `price_slot` | 150 |
| Skins / themes | `CatalogRepository` prices (M4: Firestore) | §9.1 |

Starting coins 0 (Q46). The starter gift is 3 hints and 2 slots, in the
fresh document. The dev flavor keeps unlimited boosters and undos
(`unlimitedBoosters`, Q44); debug builds keep +1 Slot free (M2).

### 7.2 Where a booster comes from

`booster_use{type, source}`: `free` for a free undo, an inventory hint or
slot, a dev/debug free use (Q42's default); `coins` when bought; `ad` in M6.
Every use also calls `save.recordBoosterUse(type)`.

### 7.3 The purchase flow (bloc)

- **Undo pressed** with a move to undo: free undos left (or unlimited) →
  undo (`free`). Else → `offer = BoosterOffer(undo, price_undo)`.
- **Hint pressed** (existing preconditions): inventory > 0 (or unlimited) →
  as M2 (`free`, charged when the hint arrives). Else → offer(hint,
  `price_hint`).
- **+1 Slot pressed** while `session.canAddExtraSlot`: free in debug, or
  inventory > 0, or unlimited → as M2. Else → offer(slot, `price_slot`).
- While `offer` is set: board input, the boosters and the other booster
  events are ignored; Pause still works.
- **`BoosterPurchaseConfirmed(type)`** (from the popup, or directly from an
  out-of-moves coin row with no offer): undo → `spendCoins(price)` then
  `session.undo()`; slot → `spendCoins(price)` then `addExtraSlot()`; hint →
  close the offer and ask the solver with the hint marked `coins`; the coins
  are spent **when a move arrives**, and a proven dead end charges nothing
  (D22). Not enough coins → nothing changes (the button is disabled). Each
  success logs `source: coins`, clears `offer`, and saves the board.
- **`BoosterPurchaseDismissed`** clears `offer`.
- `canUndo` / `canHint` / `canAddSlot` now mean "the press does something"
  (free, inventory, or an offer); the page shows a count badge, the coin
  badge (`undoPrice`/`hintPrice`/`slotPrice`) or disabled.
- M3 has no ads (the fakes behave offline, D5): the popups and the
  out-of-moves rows show the coin price only; unaffordable → the coin button
  disabled with the balance line. "Connect to watch an ad" and the ▶ options
  are M6 (`TODO(M6)`).

### 7.4 Bonus Endless (spec §7.1; defaults, Q71)

- Outside the chapters: no chapter progress, no figurine, the last campaign
  chapter's theme. `currentLevel` stays `levelCount + 1`; `bonus.next`
  counts from 1. Bonus Level n = `bonusParams(levelCount + n)`, so levels
  published later (M4) are played first and never skipped.
- An expert-only level plays as its simulated tier; nothing is shown (Q31).
- Win → `reward` by tier, `bonus.next + 1`, the next bonus level prefetched
  during the win overlay; Continue plays it.
- Past the last campaign level: Continue shows All Levels Done (4.9) with
  "Play Bonus Level N" (teal) and "Back to Home"; Home's PLAY names "Bonus
  Level N" and starts it; the HUD pill is 4.10's teal "Bonus Level N".

## 8. The daily puzzle (spec §7.5; frames 5.1–5.6)

### 8.1 `AppClock` (frozen, implemented)

`now()`, `today()` (`LocalDate`, integer day arithmetic, ISO weeks).
`SystemClock` (real) honours `--dart-define=NESTY_FAKE_DATE=yyyymmdd` only
in dev-flavor **debug** builds (the date replaces today's, the time of day
stays; profile/release and stg/prod ignore it). `FakeClock` (fake env)
starts on Saturday 2026-09-26 12:00 (the design's daily frames) and is
settable. Core never reads a clock (rule 7); the date passes in as
`yyyymmdd`.

### 8.2 The streak (`StreakDailyService`, services lane; defaults, Q70)

```text
grant(d, day):  if d.freezeWeek != day.isoWeekKey:
                    d.freezes = min(1, d.freezes + 1); d.freezeWeek = day.isoWeekKey
reconcile(d, T):  // T = today
  if d.lastDate != null and d.lastDate < T:
    for day in d.lastDate + 1 .. T - 1:           // each missed day, in order
      grant(d, day)
      if d.freezes > 0: d.freezes -= 1; d.frozen += day; d.lastDate = day
      else:             d.streak = 0; d.lastDate = null; stop
  grant(d, T)
solve(d, T):       // progressAfterSolve(T)
  d = reconcile(d, T)
  if T in d.done: return d                         // solved already
  if d.lastDate != null and d.lastDate > T:        // the clock went back
    d.done += T; return d
  d.streak = (d.lastDate == T - 1) ? d.streak + 1 : 1
  d.lastDate = T; d.done += T
  if d.streak % 7 == 0: d.chestPending = true
```

A frozen day keeps the streak without adding to it; freezes cap at 1 and
are granted once per ISO week (the grant happens on the first reconciled
day of that week, missed days included). Only today's date counts toward the
streak (a daily of another date pays its coins and adds to `done` only).
`refresh()` = `reconcile(save.daily, today)`, written with `writeDaily` when
it changed; Home and Daily call it on open.

Worked table (fresh install, daily unlocked; the services lane's test runs
it verbatim):

| Date | Day (ISO wk) | Action | streak | lastDate | freezes | frozen (latest) | chest |
|---|---|---|---|---|---|---|---|
| 09-21 | Mon (39) | solve (grant W39) | 1 | 09-21 | 1 | — | |
| 09-22 | Tue | solve | 2 | 09-22 | 1 | — | |
| 09-23 | Wed | solve | 3 | 09-23 | 1 | — | |
| 09-24 | Thu | solve | 4 | 09-24 | 1 | — | |
| 09-26 | Sat | open: Fri missed, freeze covers it (banner 5.2) | 4 | 09-25 | 0 | 09-25 | |
| 09-26 | Sat | solve | 5 | 09-26 | 0 | 09-25 | |
| 09-27 | Sun | solve | 6 | 09-27 | 0 | 09-25 | |
| 09-28 | Mon (40) | solve (grant W40) | 7 | 09-28 | 1 | 09-25 | pending |
| 09-28 | Mon | Collect (+300) | 7 | 09-28 | 1 | 09-25 | — |
| 09-28 | Mon | solve again: no change | 7 | 09-28 | 1 | 09-25 | |
| 09-29 | Tue | solve | 8 | 09-29 | 1 | 09-25 | |
| 10-02 | Fri | open: Wed covered, Thu not → reset | 0 | null | 0 | 09-30 | |
| 10-02 | Fri | solve | 1 | 10-02 | 0 | 09-30 | |
| 10-04 | Sun | solve: Sat missed, no freeze → reset, then 1 | 1 | 10-04 | 0 | 09-30 | |
| 10-06 | Tue (41) | open: Mon missed, its own W41 grant covers it | 1 | 10-05 | 0 | 10-05 | |
| 10-06 | Tue | solve | 2 | 10-06 | 0 | 10-05 | |

The "Streak saved!" banner (5.2) shows while `frozen.last > (noticeDate ??
never)` and names `frozen.last`'s weekday; `acknowledgeFreezeNotice` sets
`noticeDate`. A lost streak has no design (`TODO(design)`, BACKLOG).

### 8.3 Unlock (default, Q67)

`isUnlocked = save.highestLevel >= 3` (Level 2, the tutorial, won). Home's
Daily tile shows a locked state before (no frame: `TODO(design)`: the tile
dimmed with a lock glyph and "After Level 2"). A daily board that meets a
mechanic first (the 31–50 boards have towers and a lock) shows its intro
card (§10.4).

### 8.4 States 5.1–5.6 (`DailyStatus`, frozen)

`today, tier, colors, unlocked, streak, freezes, solvedToday, cycleDone,
chestPending, freezeNotice, inProgress`; `daysToChest = 7 − cycleDone`.
`cycleDone` = `solvedToday ? (streak − 1) % 7 + 1 : streak % 7`.

- **Strip (5.1):** day i (1–7) is done (green check) for i ≤ cycleDone;
  day cycleDone + 1 is "Today" (raised orange, play glyph) when unsolved,
  or "Tmrw" (lock) when solved; later days locked; day 7 is the chest
  (redeem), open gold when done.
- Streak card: "N days"; sub "Play today to keep your streak" (unsolved,
  streak > 0), "Play today to start a streak" (streak 0, `TODO(design)`),
  "Done for today. See you tomorrow!" (solved), "A full week!" (solved on a
  7th day). Freeze chip "1 freeze" / "0 left".
- Chest row: "Day 7 chest · 300 coins" (the RC value); sub "N days to go,
  counting today" (unsolved), "N days to go" (solved), "Opened today"
  (chest day solved).
- Puzzle card: "Saturday’s puzzle" (the weekday, `intl`), "5 colors · Hard"
  (`colors`, `tier`), a preview of the puzzle's colors (the Daily cubit
  resolves today's request on open, prefetching the board; the card shows
  `ui_spinner` until it lands and hides the preview on failure), Play with
  the 50-coin chip (Play continues a saved board, `inProgress`).
- **5.2** the banner (above). **5.3** the board: `LevelPill` daily with the
  date chip ("Sep 26", `intl` `MMMd`), music_game. **5.4** won: see §8.5.
  **5.5** solved: the card shows "Solved · +50"; "Next puzzle in 14h 12m"
  (`untilNextPuzzle`, refreshed each minute) and "Play Level N" (Home's
  request). **5.6** chest modal on opening Daily with `chestPending`: "7-day
  streak!", the open chest, "+300", Collect → `collectChest()` then
  `JingleCues.reward()`; "Double it" hidden until M6.

### 8.5 The daily win

`LevelWinRecord(request: daily(d), rewardCoins: daily_reward, moves, daily:
DailyService.progressAfterSolve(date(d)))`; analytics `daily_complete{streak}`;
state `dailyStreak`. The win overlay's 5.4 variant: title "Daily solved!",
"+50", **no ×3**, the streak card ("5-day streak · Two more days to the Day
7 chest") instead of the chapter card, and "Back to Daily", which pops back
to the Daily route (the chest modal then opens there when pending).

## 9. Chapters, museum, catalog, cosmetics

### 9.1 The bundled catalog (frozen, `BundledCatalogRepository`)

- **Chapters** ch01–ch10, 20 levels each; themes ch01–ch06, then ch07–ch10
  cycle ch01–ch04 (Q38); figurines `01-classic` … `10-explorer`, art
  `assets/museum/NN-<id>.png` and `-locked.png` (the names of
  `design/museum/png/`).
- **Skins** (frame 7.3 order): classic 0, space 1,200 (the frame shows it
  owned; default, Q72), ocean 800, sweets 1,500, forest ("Forest Friends")
  2,000, winter 3,000; `forest-bear` ships unsold. Each lists its three card
  colors.
- **Themes** ch01 0, ch02 800 and ch03 1,000 (defaults, Q72), ch04 1,200,
  ch05 1,500, ch06 2,000.
- **Names**: ARB selects keyed by id (§13). Chapter names exist for ch01–ch06
  only (`chapterName`, keyed by the **chapter** id); ch07+ show "Chapter N".
  Figurines 4–10 are "The <Name> Family" (default, Q73); flavor text only
  for the Sailor Family, others hidden (Q47, Q73). Skin descriptions: only
  Ocean's exists ("Sailor collars, tiny anchors and wave trims."); others
  hidden until supplied (Q73).

### 9.2 `SkinService` growth (services lane; frozen signatures)

```dart
String get selectedSkinId;                        // the save's selectedSkin after load
Future<void> selectSkin(String skinId);           // loads its layers; boards prepared later use it;
                                                  // a failure keeps the current skin (§13.5); never throws
Future<LevelSkin?> prepareShowcase({              // Home shelf, Shop cards, skin detail
  required List<DollColor> colors,                //   a one-tower board of these colors
  required double devicePixelRatio,               //   (ShowcaseDolls' board, moved to
  required DollSymbols symbols,                   //   core/services/skin/showcase_board.dart)
  String? skinId,                                 // default: the selected skin
});
```

`AssetSkinService` takes `SaveService` (`load` awaits `save.load()` and
reads `selectedSkin`), caches at most two non-selected skins' layers (LRU),
and `ControlledSkinService`/`FakeSkinService` grow the same methods. Home's
`ShowcaseDolls` moves to `prepareShowcase` (shell-home-settings lane).

### 9.3 Chapter complete (frame 4.6)

- At the win of a campaign level with `play.completesChapter` whose chapter
  is not in `museum`: `LevelWinRecord(completedChapterId, chapterReward:
  reward_chapter, date: clock.today())`; state `completedChapterId`,
  `chapterReward`; analytics `chapter_complete{chapter: number}`.
- The page: Win (2.8, whose card reads "Chapter complete! Your prize is
  next.") → Continue → **Chapter complete overlay 4.6**: scrim
  `rgba(25,12,4,.86)`, spotlight, "CHAPTER N COMPLETE", the figurine art
  (310 px, earned PNG), "Added to your Museum!", "+150 coins", "Next: Chapter
  N+1 · Name" (hidden when there is no next chapter), `fx_twinkle`,
  Continue. Opening it calls `JingleCues.chapterComplete()` (music fades out
  400 ms, then `jingle_chapter` only, Q62); its Continue sends
  `NextLevelPressed` and calls `MusicService.playGame()` (fades in over 2000
  ms). The HUD keeps the pre-win balance until the next level (Q57).
- The win card's locked figurine uses `lockedArtAsset`; "Next up" hides for
  a figurine without a name.

### 9.4 Themes and skins (frame 7.7, spec §7.4)

- A theme is owned when listed in `ownedThemes` or when its chapter number ≤
  the reached chapter (the chapter of `entryAt(currentLevel)`, or the last
  published chapter in Bonus Endless) — `ThemeInfo.isOwned`.
- The board's background: `selectedTheme ?? play.themeId`; Home's:
  `selectedTheme ?? the current chapter's theme`.
- Buying a skin or theme: `purchaseSkin`/`purchaseTheme`, then
  `JingleCues.reward()`; a bought skin is equipped at once
  (`selectSkin` + `SkinService.selectSkin`, `skin_equip{skin}`). A theme
  unlocked by reaching its chapter plays no jingle (it coincides with
  Chapter complete, Q62).

### 9.5 Museum art (daily-museum-tools lane)

`sync_design_assets` ships `design/museum/png/*.png` (20 files, ≈ 2.3 MB)
to `apps/game/assets/museum/` byte for byte: validate the PNG signature,
600 × 600 RGBA, the 20 expected names; `--check` covers it and the pubspec
line `- assets/museum/`; tests; tools/README. The SVGs stay unshipped
(nested `<svg>`, mix-blend-mode; D18). The asset manifest test asserts the 20
ship.

## 10. Screens and flows

### 10.1 Routes, navigation, music

```text
SplashRoute ─replaceAll→ MainShellRoute[ShopRoute(initialTab) | HomeRoute | MuseumRoute]   (tabs, homeIndex 1)
  pushed over the shell (full screen, no nav): SettingsRoute · DailyRoute · SkinDetailRoute(skinId) · GameplayRoute(request)
```

- Always name the tab: `MainShellRoute(children: [HomeRoute()])` (a tabs
  router with no pending child shows its first tab). Tab switches use
  `context.tabsRouter`; Home's tiles: Museum → the Museum tab, Daily →
  push DailyRoute; the coin pill "+" → the Shop tab on `ShopTab.coins`; the
  Remove Ads tile → the Shop tab on `ShopTab.noAds`; the gear → push
  SettingsRoute; Pause's Settings tile → push SettingsRoute over the level
  (the level stays paused underneath).
- Back: Daily/Settings/Skin detail pop; the shell's Shop/Museum go back to
  Home (`homeIndex`); a level's Home → `navigate(MainShellRoute(children:
  [HomeRoute()]))`; the daily's "Back to Daily" → `maybePop` to DailyRoute.
- **Music** (`MusicRouteObserver`, root navigator): Splash none;
  `GameplayRoute` → `music_game` for every kind (campaign, bonus, daily);
  every other page (the shell and its tabs, Settings, Daily, Skin detail) →
  `music_home`. Settings opened from Pause therefore plays `music_home` and
  the level's loop resumes on return (AUDIO.md "Music rules"). The
  observer's `TODO(M3)` is resolved by the route tree (a comment edit).
- Jingle callers: `JingleCues.reward()` at a skin purchase (7.4), a theme
  purchase (7.7), the daily chest's Collect (5.6); `chapterComplete()` at
  4.6. (M6: purchases.)

### 10.2 Settings (frames 8.1, 8.2)

- Header "Settings" with a close button (it pops). Toggles Sound, Music,
  Haptics (`NestyToggle` on `ui_toggle`), writing `DatabaseService` only
  (the music follows `musicEnabledChanges`). "Color symbols": Subtle | Large
  cards (`setSymbolsMode`; boards rebuild their bodies, D45).
- Rows: Language · English (opens 8.2), Restore Purchases and Privacy
  choices (shown **disabled** until M6, `TODO(M6)`), Privacy Policy and
  Support · "Email us" (`AppLinks.privacyPolicyUrl` / `supportEmail`; a
  **row is hidden while its link is empty**, and they are empty until the
  owner supplies them, Q73).
- Footer "Nesty: Doll Sort · v1.0.0 (build 42) · Player ID 7F3A-21C9"
  (`AppInfoService` version and build; `SaveService.playerId`).
- 8.2 language sheet (`NestySheet`): the 9 launch languages with their
  autonyms (English, Español, Português (Brasil), Bahasa Indonesia, हिन्दी,
  Deutsch, Français, Türkçe, 日本語 — data, not ARB, as they read the same
  in every locale) and their names in the UI language (ARB); English is
  selectable, the others disabled until their ARB files exist (`TODO(M7)`);
  "Done" closes.
- `SettingsCubit extends BaseAsyncCubit<SettingsState>` (D14 note).
- Services (services lane): `AppInfoService` (`version`, `buildNumber`;
  `PackageAppInfoService` over `package_info_plus`, `FakeAppInfoService`
  "1.0.0"/"42"), `LinkLauncher` (`openUrl`, `email`; `UrlLinkLauncher` over
  `url_launcher` with `LaunchMode.externalApplication`, never
  `canLaunchUrl` so no `<queries>`/`LSApplicationQueriesSchemes` are needed;
  a false return is ignored; `FakeLinkLauncher` records), `AppLinks`
  (`core/services/links/app_links.dart`, two empty consts, `TODO(M8)`).

### 10.3 Home (frame 2.1)

- The M2 hero stays; background `selectedTheme ?? current chapter theme`.
- PLAY: `resolver.homeRequest` — "Level N" + tier badge, or "Bonus Level
  N" (target tier `DifficultyCurve.tierForLevel(levelCount + n)`); a saved
  board of that request continues.
- Tiles at y 584 (132 tall, radius 24): **Daily Puzzle** (flame streak badge
  when streak > 0; the locked state §8.3), **Museum** (the next figurine's
  locked PNG and a bar "done/20" of the current chapter; in Bonus Endless
  the collection count, `TODO(design)`), **Remove Ads** (hidden when
  `adsRemoved`; the other two widen; M3 opens the Shop's No Ads tab).
- Coin pill with "+" (Shop, Coins tab), the gear (Settings), the bottom nav
  (the shell's).
- `HomeCubit` adds the request, the Daily status (`refresh()`), the museum
  progress; it follows `SaveService.changes` and `DailyService.changes`.

### 10.4 Tutorial and intro cards (spec §7.6)

**The script** (bloc, `features/gameplay/bloc/tutorial_script.dart`):
active when `play.level.id` is `L0001` or `L0002`, `tutorialDone` is false,
and each scripted move is legal (`Rules.tryMove` on the current board);
otherwise it ends (rule 3). The step is derived from
`session.state.moveCount` (so a restored board resumes it):

| Level | moveCount | step | cue | move | frame / copy |
|---|---|---|---|---|---|
| L1 | 0 | 1 | tapSource r0c2 | r0c2 → r0c0 | 1.3 "STEP 1 OF 2 · Tap the small doll · Dolls nest into the same color, one size bigger." |
| L1 | 0, r0c2 lifted | 2 | tapTarget r0c0 | (same move) | 1.4 "STEP 2 OF 2 · Now tap the big one · The small doll drops inside with a clack." |
| L1 | 1 | 3 | tapSource r1c1, then tapTarget r0c0 | r1c1 → r0c0 (completes) | no frame, `TODO(design)`: no chip, "Finish the family · Tap the smallest doll, then the family." |
| L2 | 0 | 4 | drag r0c0 → r1c0 | r0c0 → r1c0 (the swallow) | 1.6 "NEW MOVE · Big can swallow small · Drop a big doll onto the next size down and it closes right over it." |

- Gating: while a cue is up only its move is accepted — a tap on `from`
  (select), then on `to`; a drag from `from` dropped on `to`; everything
  else, the boosters and Restart are ignored (Pause works). A drag dropped
  elsewhere cancels back to the step's first cue. The move itself goes
  through core as usual.
- `tutorial_step{step}` when each step completes (1 on the pick, 2 and 3
  when their moves apply, 4 on the swallow); L2's swallow also calls
  `markTutorialDone()`. L1's win shows 1.5 (the normal win, "+10",
  "Chapter 1 · 1 / 20 · Next up: The Classic Family").
- Page (gameplay-screens): the scrim with holes around both slots (the
  hole ellipse of NestyBoard: `rx = h·.42 + 16`, `ry = h·.6 + 14`, centred
  `surf − h·.42`), the dotted arc, the tooltip card (step chip, title 22,
  text 15), and the hand: `ui_tap_hand` (fingertip (48, 32) on the target)
  for taps, `ui_drag_hand` inside a BoardFit `Transform` for the drag; all
  above the board and under the HUD.

**Intro cards** (4.1 towers at L16, 4.2 glass at L31, 4.3 ice at L51, or the
first board of any kind with the mechanic): at start (and restore), `intro =`
the first `IntroMechanic.presentIn(level)` not in `seenIntros`; input is
locked; "Got it" → `IntroDismissed` → `markIntroSeen`, then the next unseen
one, then play. Card: NEW chip, title 34 ("Towers!", "Glass Cases", "Ice"),
a 302 × 230 illustration on a plank, text 16 (the §README copy), "Got it".
The looping mini animations reuse `doll_reveal`, `fx_glass_unlock` and
`fx_ice` on the design's illustration layout (`TODO(design)`: no loop
designed).

### 10.5 Daily (frames 5.1–5.6)

`DailyPage` (header "Daily" with a back arrow and the coin pill, no bottom
nav), `DailyCubit extends BaseAsyncCubit<DailyState>` over `DailyService`,
`LevelResolver` (prefetch today), `SaveService`; §8.4 for every state;
Play → `GameplayRoute(request: daily.todayRequest)`; on return it
refreshes; the chest modal and the saved banner as §8.2/§8.4.

### 10.6 Museum (frames 6.1–6.3)

The shell's third tab: header "Museum" + coin pill; the collection card
("Collection 2 / 10", "Chapter 3: 15 of 20 levels to The Baker Family");
the walnut cabinet, 4 shelves × 3 (the 10th alone), 76 px art: earned in
color with "Classic Family"; the next with a "15/20" chip and "Baker ·
soon"; the rest locked silhouettes at 55 % with "Chapter N". Tap earned →
6.2 modal (spotlight, 272 px art, "Chapter 2 · Rainy Café Corner", "The
Sailor Family", italic flavor text when it exists, "Collected · Sep 12" or
"Collected"). Tap the next or a locked one → 6.3 ("Finish Chapter 3 to bring
this family home.", the chapter bar, "▶ Play Level 56" → Home's request).
All ten collected → the card reads "Every family is home." (`TODO(design)`).

### 10.7 Shop (frames 7.3–7.7)

The shell's first tab: header "Shop" + coin pill, `NestySegmentedTabs`
Coins · Skins · Themes · No Ads (all four shown, D75): **Coins and No Ads
show a store-unavailable card in M3** ("The store is closed for now" /
"Coin packs and Remove Ads come in a later update."; `TODO(M6)`, Q75).
Skins: 2-column cards (84 px preview of the skin's three dolls on a plank
via `prepareShowcase`; Equipped with a green ring / Equip / the coin price);
the 7.5 downloading card state (purple ring, spinner, "Downloading N%") is
built for M4 and unreachable with bundled skins. Tap → SkinDetailRoute(id):
all 11 colors on 2 shelves (gold included, "All 11 colors · symbols kept"),
the size lineup ("Every size nests the same way. Only the paint changes."),
the name and description, Buy · price / Equip / Equipped, "You have N
coins". Themes: the "Match each chapter" toggle ("Uses the theme of the
chapter you're in"), 2-column 74 px thumbnails: In use (green ring) / Use /
locked "Ch N" + price. Use turns the toggle off; the toggle on sets
`selectedTheme` null; off with none chosen selects the current chapter's.
`fx_twinkle` on a purchase (lottie §15). `ShopCubit`/`SkinDetailCubit`
over `CatalogRepository`, `SaveService`, `SkinService`, `LevelRepository`
(reached chapter), `AnalyticsService`, `JingleCues`.

### 10.8 Gameplay screens (gameplay-screens lane)

Buy popup 3.2/3.3 and +1 Slot's (`BuyPopupBody`: ribbon title, 112 px icon
disc + 8 px halo, benefit line, the coin price button, "You have N coins";
copy §13); out-of-moves coin rows (Undo after the free ones shows its price,
`TODO(design)` per BACKLOG; +1 Slot's price when none held); booster badges
(count, or the coin price); the tutorial overlay and intro cards (§10.4);
All Levels Done → "Play Bonus Level N" sends `GameplayStarted(nextRequest)`;
the bonus pill 4.10 and the daily pill 5.3; the win card's chapter progress
with the locked figurine art, and its daily variant (5.4); Chapter complete
4.6 (§9.3); the next level's art prefetch for `nextRequest` (resolve it,
then `layoutFor`); the theme `selectedTheme ?? play.themeId`; a generating
board (`AsyncValueLoading` with data) shows `ui_spinner` over the old board.

### 10.9 UI kit (ui-kit-arb lane, `core/ui/**`)

`NestySegmentedTabs` (track 44–46, radius 23, `#EAD3B0` sunk, active
surface + 3 px edge, `motion.ui.tabLift`); `NestyBottomNav` on `WoodBar`
(items 80 wide; inactive 48 square, 18 % cream; active 58 × 52 surface
lifted −6, glyph `#C4631E`; tokens `layout.bottomNav`); `HomeTile` +
`StreakBadge`; `BuyPopupBody`; `IntroCard` (NEW/v1.1 chip, title,
illustration slot, text, Got it); `NestyToast` (+ a show helper, banners'
style, auto-dismiss); `ScreenHeader` (back/close, heading, optional coin
pill); `SettingsSection`/`SettingsRow`/`SettingsToggleRow`; a disabled
`CoinPriceButton` exists. Exported from `nesty_ui.dart`; widget tests at
360/390/430 and 1.3× text.

## 11. Services and DI (target state after stage 2)

| Interface | Real (env real) | Fake (env fake) | Lane |
|---|---|---|---|
| `SaveService` | `HiveSaveService` | `FakeSaveService` | services |
| `AppClock` | `SystemClock` | `FakeClock` | done |
| `CatalogRepository` | `BundledCatalogRepository` | `FakeCatalogRepository` | done |
| `LevelGeneratorService` | `IsolateLevelGeneratorService` | `FakeLevelGeneratorService` | services |
| `LevelResolver` | `DefaultLevelResolver` (both envs) | — (`FakeLevelResolver` unit tests only) | services |
| `DailyService` | `StreakDailyService` (both envs) | — (`FakeDailyService` unit tests only) | services |
| `AppInfoService` | `PackageAppInfoService` | `FakeAppInfoService` | services |
| `LinkLauncher` | `UrlLinkLauncher` | `FakeLinkLauncher` | services |
| `SkinService` | `AssetSkinService` (grows §9.2) | `FakeSkinService` | services |
| `SaveLifecycleFlusher` | one class, both envs | | services |

Every new annotation needs build_runner (the stage's codegen owner). `di_test`
asserts each row in both environments.

## 12. Analytics (spec §14.4; exactly these names and parameters)

| Event | Params | Fired by |
|---|---|---|
| `tutorial_step` | `step` 1–4 | bloc, when a scripted step completes (§10.4) |
| `level_start` | `level`, `tier`, `attempt` | bloc, at start and restart. `level` = campaign order, `levelCount + n` for Bonus n, the date `yyyymmdd` for the daily (D77) |
| `level_win` | `level, tier, moves, seconds, undos, hints, slots` | bloc, every win |
| `level_out_of_moves`, `level_soft_stuck`, `level_restart` | `level` | bloc (as M2) |
| `booster_use` | `type` undo/hint/slot, `source` free/coins | bloc (§7.2) |
| `daily_complete` | `streak` (after the solve) | bloc, daily win |
| `chapter_complete` | `chapter` (number) | bloc, the chapter's completing win |
| `skin_equip` | `skin` (id) | Shop / skin detail, on Equip or a purchase |
| `bonus_level_start` | `n` | bloc, at a bonus level's start (not restart) |

The rewarded, interstitial and IAP events are M6.

## 13. ARB keys (ui-kit-arb adds them all, each with a description)

Existing keys are reused where they fit (`levelTitle`, `bonusLevelTitle`,
`levelDaily`, `home`, `settings`, `settingSound/Music/Haptics`, `coinPrice`,
`coinsSemantics`, `winChapter`, `winCoins`, `winContinue`, `figurineName`,
`chapterName`, `tierName`, `allLevels*`, `oom*`, `boosterUndo/Hint`,
`closeSemantics`, `backSemantics`). New (English = the frames):

- **Shell/Home:** `navShop` "Shop", `navMuseum` "Museum", `homeDailyTile`
  "Daily Puzzle", `homeMuseumTile` "Museum", `homeRemoveAdsTile` "Remove
  Ads", `homeMuseumProgress` "{done}/{total}", `homeDailyLocked` "After
  Level 2" (a design gap), `streakBadgeSemantics` (plural "N-day streak").
- **Settings:** `settingColorSymbols` "Color symbols", `symbolsSubtle`
  "Subtle", `symbolsLarge` "Large", `settingLanguage` "Language",
  `settingRestorePurchases` "Restore Purchases", `settingPrivacyChoices`
  "Privacy choices", `settingPrivacyPolicy` "Privacy Policy",
  `settingSupport` "Support", `settingSupportValue` "Email us",
  `settingsFooter` "Nesty: Doll Sort · v{version} (build {build}) · Player
  ID {playerId}", `languageSheetTitle` "Language", `languageSheetDone`
  "Done", `languageName` (select es/pt_BR/id/hi/de/fr/tr/ja → "Spanish" …),
  `languageComingSoon` "Coming soon".
- **Daily:** `dailyStreakDays` (plural "{count} days"), `dailyStreakKeep`
  "Play today to keep your streak", `dailyStreakStart` "Play today to start a
  streak", `dailyStreakDone` "Done for today. See you tomorrow!",
  `dailyStreakWeek` "A full week!", `dailyFreezes` (plural: =0 "0 left", =1
  "1 freeze", other "{count} freezes"), `dailyDay` "Day", `dailyToday`
  "Today", `dailyTomorrow` "Tmrw", `dailyChestRow` "Day 7 chest · {coins}
  coins", `dailyChestToGoToday` / `dailyChestToGo` (plural "N day(s) to
  go[, counting today]"), `dailyChestOpenedToday` "Opened today",
  `dailyPuzzleTitle` "{weekday}’s puzzle", `dailyPuzzleInfo` "{colors,
  plural, …} · {tier}", `dailyPlay` "Play", `dailySolvedChip` "Solved ·
  +{coins}", `dailyNextPuzzle` "Next puzzle in {time}", `dailyCountdown`
  "{hours}h {minutes}m", `playLevel` "Play Level {level}",
  `dailySavedTitle` "Streak saved!", `dailySavedBody` "A freeze covered
  {weekday}. You'll earn a new one next week.", `dailyChestTitle` "7-day
  streak!", `dailyChestBody` "A full week of puzzles. Your chest is open.",
  `dailyChestDouble` "Double it" (M6), `dailyChestCollect` "Collect",
  `dailyWinTitle` "Daily solved!", `dailyWinStreak` "{count}-day streak",
  `dailyWinChestHint` (plural with =0 "Your Day 7 chest is ready!", =1 "One
  more day to the Day 7 chest", =2 "Two more days to the Day 7 chest" … =6,
  other "{count} more days…"), `dailyBackToDaily` "Back to Daily".
- **Museum:** `museumTitle` "Museum", `museumCollection` "Collection",
  `museumCount` "{done} / {total}", `museumNextLine` "Chapter {number}:
  {done} of {total} levels to {name}", `museumAllHome` "Every family is
  home." (a design gap), `museumFamilyLabel` "{name} Family",
  `museumSoonLabel` "{name} · soon", `figurineShortName` (select
  classic…explorer → "Classic" …), `figurineName` gains astronaut…explorer
  ("The Astronaut Family" …; Q73), `figurineFlavor` (select: sailor
  "“They keep a seashell in the smallest doll, just in case.”", other ''),
  `museumChapterChip` "Chapter {number} · {name}", `museumCollectedOn`
  "Collected · {date}", `museumCollected` "Collected", `museumLockedText`
  "Finish Chapter {number} to bring this family home."
- **Shop:** `shopTitle` "Shop", `shopTabCoins` "Coins", `shopTabSkins`
  "Skins", `shopTabThemes` "Themes", `shopTabNoAds` "No Ads",
  `shopEquipped` "Equipped", `shopEquip` "Equip", `skinName` (select
  classic "Classic", space "Space", ocean "Ocean", sweets "Sweets", forest
  "Forest Friends", winter "Winter", other ''), `skinDescription` (select
  ocean "Sailor collars, tiny anchors and wave trims.", other ''),
  `skinDetailTitle` "Skin", `skinDetailColors` "All 11 colors · symbols
  kept", `skinDetailSizes` "Every size nests the same way. Only the paint
  changes.", `shopBuy` "Buy", `balanceLine` (plural "You have {count}
  coins"), `shopDownloading` "Downloading {percent}%", `themesMatchTitle`
  "Match each chapter", `themesMatchSubtitle` "Uses the theme of the
  chapter you're in", `themeInUse` "In use", `themeUse` "Use",
  `themeChapterLock` "Ch {number}", `shopClosedTitle` "The store is closed
  for now", `shopClosedBody` "Coin packs and Remove Ads come in a later
  update."
- **Gameplay:** `buyUndoText` (plural "Your {count} free undos are used.
  Take back one more move."), `buyHintText` "Shows your next best move.",
  `buySlotText` "Adds one empty stand for this level.", `tutorialStep1Chip`
  "STEP 1 OF 2", `tutorialStep1Title` "Tap the small doll",
  `tutorialStep1Text` "Dolls nest into the same color, one size bigger.",
  `tutorialStep2Chip` "STEP 2 OF 2", `tutorialStep2Title` "Now tap the big
  one", `tutorialStep2Text` "The small doll drops inside with a clack.",
  `tutorialStep3Title` "Finish the family", `tutorialStep3Text` "Tap the
  smallest doll, then the family." (a design gap), `tutorialSwallowChip`
  "NEW MOVE", `tutorialSwallowTitle` "Big can swallow small",
  `tutorialSwallowText` "Drop a big doll onto the next size down and it
  closes right over it.", `introNew` "NEW", `introTowersTitle` "Towers!",
  `introTowersText` "Only the top nest can move. Clear it to reveal the doll
  hiding underneath.", `introGlassTitle` "Glass Cases", `introGlassText` "A
  locked doll is freed when the family on its padlock is complete.",
  `introIceTitle` "Ice", `introIceText` "Every family you finish cracks the
  ice. At zero, the doll is free.", `introGotIt` "Got it",
  `chapterCompleteTitle` "CHAPTER {number} COMPLETE", `chapterCompleteAdded`
  "Added to your Museum!", `chapterCompleteCoins` "+{count} coins",
  `chapterCompleteNext` "Next: Chapter {number} · {name}",
  `gameplayGenerating` "Setting up the shelves…" (a design gap).

## 14. Lane ownership and test plans

A lane touches only its paths; everything else goes in its report for the
integrator. `*.gen.dart`, `*.freezed.dart`, `*.gr.dart`, `di.config.dart` and
`app_localizations*.dart` are written only by codegen.

| Lane | Owns | Tests (in its paths) |
|---|---|---|
| **core-codec** | `packages/nesty_core/**` | §4 codec (VM + chrome), §5 goldens and parity, issue-code list, architecture guard, `public_api_test` |
| **services** | `apps/game/lib/core/{services,repository}/**` (not the frozen signatures), `core/dependency_injection/**` (annotations and modules; never `di.config.dart`), `lib/bootstrap.dart` (the lifecycle flush), `test/core/{services,repository,dependency_injection}/**`, `test/features/support/controlled_skin_service.dart` | `HiveSaveService` on `HiveDatabaseService.open(directory:)` temp dirs: round trip, migration 0, a corrupt document (backup under `doc_backup_invalid`, defaults), a newer schema (backup, unknown keys kept), a torn write (truncate the box file's last frame → the previous doc survives), the queue coalescing N changes into ≤ 2 writes, flush on demand, the in-memory fallback; `StreakDailyService` §8.2 table verbatim + unlock + chest + notice + midnight countdown; `DefaultLevelResolver` (each kind, cache, prefetch join, embedded-level restore, `completesChapter`, `next`, `homeRequest`); `IsolateLevelGeneratorService` (same output as the fake; failure → null); `AssetSkinService` growth; `AppInfoService`/`LinkLauncher` fakes; `di_test` rows of §11 |
| **gameplay-bloc** | `features/gameplay/bloc/**` (plus a new `tutorial_script.dart`), `test/features/gameplay/bloc/**` | restore on a version match / restart on a mismatch or a bad session; a save after each applied move, undo, restart, +1 Slot and none after a rejected move; generated start (loading, then data); every §7.3 path incl. unaffordable and a dead-end coin hint; win per kind (the `LevelWinRecord`, chapter complete once, daily streak, `nextRequest`, bonus prefetch); tutorial gating per step and restore; intro sequence; §12 events |
| **ui-kit-arb** (stage-2 codegen owner) | `core/ui/**` except `*.gen.dart`, `lib/l10n/app_en.arb` (+ gen-l10n output), `test/core/ui/**` | §10.9 widgets (fit at 360/390/430 × 1.3×, tactile feedback, tokens), an ARB test that every §13 key exists with a description |
| **shell-home-settings** (stage-3 codegen owner) | `core/router/**`, `lib/app/**`, `features/{shell,home,settings,splash}/**`, `test/core/router/**`, `test/features/{home,splash,settings,shell}/**`, `test/app_flow_test.dart` | shell tabs and back behaviour, Home tiles (daily locked/unlocked/badge, museum progress, remove-ads hidden), PLAY request (campaign, bonus, continue), Settings rows (hidden links, disabled M6 rows, footer), the language sheet, Pause → Settings → back; `app_flow_test`: Splash → Home → PLAY → moves → **teardown of DI and app, rebuilt on the same Hive dir → the same board** (uses `HiveDatabaseService.open(directory:)` via a test module), and the flow through Daily, Museum, Shop |
| **daily-museum-tools** | `features/{daily,museum}/**`, `test/features/{daily,museum}/**`, `tools/**` museum sync (+ tests, README), `apps/game/assets/museum/**` (written by the tool), the pubspec `- assets/museum/` line, `test/core/assets/asset_manifest_test.dart` (museum part) | Daily 5.1–5.6 with `FakeClock` and a scripted `FakeDailyService` (strip, chips, countdown, chest collect + jingle, banner once, play/continue); Museum 6.1–6.3 (earned/next/locked, dates, hidden flavor text); the sync's validation and `--check` |
| **shop** | `features/shop/**`, `test/features/shop/**` | tabs (coins/no-ads closed card), skin states, purchase (coins, jingle, equip, analytics), unaffordable, skin detail, themes (toggle, use, buy, locked, owned by chapter) |
| **gameplay-screens** | `features/gameplay/{pages,widgets,overlays}/**`, a new `features/tutorial/**` if used, their tests, `integration_test/**` (resume and daily phases) | §10.8 widgets and flows on the recording board; the integration phases A/B (plan "Verification") |

## 15. Decisions and questions

PROGRESS D66–D80 record this design; Q67–Q75 ask the owner (each also a
BACKLOG "Owner inputs needed → Decisions" item). Defaults ship unless the
owner answers otherwise.

## 16. Verification

- Contracts stage: `flutter analyze --fatal-infos --fatal-warnings` clean;
  `cd packages/nesty_core && dart test -x slow` and `dart test -p chrome
  test/generator/generator_retry_test.dart`; `cd apps/game && flutter test`.
- M3 close: the `/milestone` gate (codegen drift, format, analyze, every
  suite, token/icon/asset/TODO-index checks, `bundle check`, APK dev/prod,
  iOS dev, admin web; `pod install` picks up url_launcher_ios and
  package_info_plus), the resume integration phases on the iPhone 16
  simulator and the API 35 emulator (`xcrun simctl terminate` / `adb shell
  am force-stop`), the `NESTY_FAKE_DATE=20260926` daily fingerprint equal
  on both, then the owner's device checks.
