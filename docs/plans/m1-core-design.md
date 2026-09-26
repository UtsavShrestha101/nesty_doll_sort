# M1 design — `packages/nesty_core`

Approved 2026-09-26 as part of the "Design foundation + M1 + M2" round (see docs/PROGRESS.md D18–D25).
Spec sections are docs/GAME_SPEC.md. Where this document and an **owner override** below disagree, the override wins.

## Owner overrides (2026-09-26)
- **Extra slot** (design wins): `addExtraSlot()` always appends to the **bottom shelf** (ids `x0`, `x1`), max 2 per level, and extra slots **survive Restart** ("Add a stand for this level"). Consequence for validation rule 2 (§5.3) and the generator: the bottom shelf may hold at most **4 authored slots** so both extras fit (BoardLayout supports up to 6 in a row). Validator code `layout.noRoomForExtraSlots` when bottom-row slots + 2 > 6.
- **Gold (§3.5)**: design marks it v1.1. Build the hook (nest-code bits, `colorsMatch`, codec parses `goldN`), but the validator rejects gold with `gold.notSupported` until v1.1.
- **Hint on a proven-unsolvable state**: no move, verdict returned; the app shows the soft-stuck banner and charges nothing.
- **Destination `Revealed` comes after `Completed`** (A2) — confirmed.
- The game loader validates rules 1–7 and trusts bundled levels for rule 8; CI (`nesty_levels bundle check`) proves every bundled level solvable (A6).
- All other ambiguities (A3–A32 below) use the recommended defaults and are recorded in PROGRESS.

## Amendments from the M1 build and review (2026-09-26)
Recorded as docs/PROGRESS.md D26–D39; where they differ from the sections below, they win.
- Solver nodes store packed canonical keys, not cells; solutions replay on the real board (D31). The node arena grows in chunks (no copy); `peakBytes` bounds memory.
- The default simulation seed hashes the board only (`schemaVersion`, `maxSize`, `shelves`), not the id (D32).
- Codec: unknown keys are reported sorted by code unit and `schema.invalidJson` has no args, so the VM and the web agree (D29). Ice above `LayoutLimits.maxIce` (2^31 − 1) is `schema.valueOutOfRange` and the engine refuses it.
- `SolverSnapshot.decode` rejects cells that contradict `completedSets` (D31).
- `bundle check` accepts `tierOverride` on open-slot-only boards, which always simulate easy (D26, amends A32).
- CI runs the parity suites on node, Chrome and dart2wasm; core guards ban `~`, 64-bit typed lists and `HashMap`/`HashSet` (D39).

## 0. Architecture — one rules engine, models as views
A small allocation-free engine over a compact mutable board (`src/rules/engine/`) is the **only** implementation of §4.
`Rules`, `GameSession` (UI + admin playtest), solver, simulator and generator all call it (CLAUDE.md rule 2).
Immutable hand-written models (`Level`, `Slot`, `Nest`) define levels; `GameState` is an immutable value wrapper around
packed ints and exposes model views. §4 unit tests go through the public API, exercising the same code the solver runs.

## 1. Layout and public API
```
lib/nesty_core.dart                   barrel (not engine internals / util)
src/util/u32.dart                     web-safe 32-bit ops (mul32 via 16-bit split, add32, rotl32, fmix32)
src/util/hash64.dart                  Hash64 = two independent 32-bit murmur3-style halves
src/prng/prng.dart                    Prng (xoshiro128**), splitmix32 seeding, derive(seed, a, b)
src/models/{doll,nest,slot,slot_id,level,game_state,move,move_event,move_result}.dart
src/codec/{level_codec,level_issue,level_bundle,game_state_codec(stretch, M3)}.dart
src/validator/{validator,layout_limits}.dart
src/rules/engine/{nest_code,board_layout,kernel,move_log}.dart
src/rules/{rules,event_builder}.dart
src/session/game_session.dart
src/solver/{canonical,visited_table,node_store,bucket_queue,solver,solver_run,hint,snapshot}.dart
src/simulator/{tier,bots,simulator}.dart
src/generator/{generator_params,generator,segments,curve,seeds}.dart
```
Key signatures:
```dart
final class Doll { const Doll(this.color, this.size); DollColor color; int size; String get token; }   // "red4"
final class Nest { factory Nest.run(DollColor c, {required int outer, required int length});
  static Nest? tryFromDolls(List<Doll> d); DollColor color; int outerSize, length;
  int get innerSize; Doll get outer; Doll get inner; List<Doll> get dolls; bool isFullSet(int maxSize); bool containsSize(int s); }
sealed class Slot { int ice; }
final class OpenSlot extends Slot { Nest? nest; }
final class TowerSlot extends Slot { List<Nest> stack; Nest get top; int get hiddenCount; }   // bottom→top
final class LockedSlot extends Slot { DollColor unlockColor; Nest? nest; }                    // broken lock → OpenSlot view
abstract final class SlotId { static String grid(int r, int c); static String extra(int n); } // "r0c1", "x0"
final class BoardPosition { int row, col; }
final class Level { id, schemaVersion, maxSize, List<List<Slot>> shelves, int? generatorVersion, int? seed;
  int get totalSets; Map<DollColor,int> get setsByColor; List<String> get slotIds; }
final class GameState { factory GameState.initial(Level l); Level get level; List<String> get slotIds; Slot slot(String id);
  BoardPosition positionOf(String id); int get completedSets, totalSets, moveCount, extraSlotCount; int completedOf(DollColor c); bool get isWon; }
final class Move { const Move(this.from, this.to); String from, to; }
sealed class MoveResult {}  final class MoveApplied { GameState state; List<MoveEvent> events; bool completedSet; }
final class MoveRejected { InvalidMoveReason reason; String targetId; }
enum InvalidMoveReason { unknownSlot, sameSlot, sourceEmpty, sourceFrozen, sourceLocked, targetFrozen, targetLocked, colorMismatch, sizeMismatch, targetOccupied }
abstract final class Rules { canPick, isInteractable, tryMove(GameState, Move), legalMoves(GameState), legalTargets(GameState, String from), isWon, isOutOfMoves }
final class GameSession { GameSession(Level); GameSession.restore(Level, GameState, List<UndoEntry>); static const maxExtraSlots = 2;
  GameState get state; MoveResult move(String from, String to); bool get canUndo; int get undoDepth; int get undosUsed; UndoResult? undo();
  bool get canAddExtraSlot; ExtraSlotAdded? addExtraSlot(); void restart(); bool get isWon, isOutOfMoves; int get setsCompleted, totalSets; List<Move> legalMoves(); }
enum SolveVerdict { solved, unsolvable, unknown }
abstract final class SolverBudgets { static const admin = 500000, hint = 30000, softStuck = 20000; }
final class SolveResult { SolveVerdict verdict; List<Move>? solution; int nodes; double branching; }
abstract final class Solver { static SolveResult solve(GameState s, {int budget}); static SolverRun start(GameState s, {int budget}); // advance(maxNodes)
  static HintResult hint(GameState s, {int budget}); static SolveVerdict softStuck(GameState s, {int budget}); static Move? fallbackHint(GameState s); }
final class HintResult { Move? move; HintSource source /*solver|fallback|none*/; SolveVerdict verdict; int nodes; }
abstract final class SolverSnapshot { static Int32List encode(GameState s); static Int32List run(Int32List snap, int task, int budget); }
enum Tier { easy, medium, hard, superhard }
abstract final class Simulator { static SimulationResult run(Level l, [SimulatorParams p]); } // BotStats casual, smart; Tier tier; bool expertOnly
abstract final class Generator { static const version = 1, maxAttempts = 50; static GeneratorOutcome generate(GeneratorParams p); static List<LevelIssue> checkParams(GeneratorParams p); }
abstract final class DifficultyCurve { static Tier tierForLevel(int n); static GeneratorParams bonusParams(int n); static GeneratorParams dailyParams(int yyyymmdd);
  static int bonusSeed(int n) => 1000000 + n; static int dailySeed(int y, int m, int d); }
abstract final class LevelCodec { decode(Object? json) -> LevelDecodeResult; decodeString; encode(Level) -> Map; encodeString; }
abstract final class Validator { static ValidationReport validate(Level l, {ValidationOptions o}); static ValidationReport validateJson(Object? j, {ValidationOptions o}); }
```

## 2. Data model
- Hand-written immutable classes with `==`/`hashCode` (`Object.hash`); no codegen/deps. `hashCode` never persisted/ordered.
- `Nest` stored as (color, outerSize, length) → invalid nests unrepresentable (codec checks §2.1).
- Nest code `color<<6 | outer<<3 | len` (≥ 9, 0 = empty, < 2^10); bits 10–12 reserved for gold position.
- `BoardLayout` (engine) compiled once per Level: row-major slots then `x0`,`x1` (≤ 22 slots → 32-bit masks); per slot kind, cell offset, capacity, unlockColor, initial ice. Two extra cells always reserved → adding an extra slot never re-lays out.
- Dynamic state = header (`completedSets`, `openedMask`, `extraCount`) + `Uint16List` cells. Current ice = max(0, initialIce − completedSets). Per-colour completions derived. A tower of depth 0 or anything in `openedMask` reads back as `OpenSlot`.

## 3. Algorithms
**tryMove (§4, kernel.dart)** line for line: interactable = active && ice == 0 && !(locked && !opened); empty tower / broken lock behave as open; inside = `M.outer == T.inner − 1`, swallow = `T.outer == M.inner − 1` (mutually exclusive). After merge: pop source (tower reveals next; empty tower → opened) → if merged full: remove, completedSets++ → destination tower reveals next → every still-locked slot with unlockColor c opens → ice drops everywhere. ≤ 1 completion per move.

**Events (order + payloads)**: 1 `Picked(slotId, nest, fromTower, leftEmptyTower)`; 2 `Placed(fromId, slotId, nest)` or `NestedInto(fromId, slotId, direction inside|swallow, moving, target, merged)` (clack pitch uses `merged.outerSize`); 3 `Revealed(slotId, nest, hiddenBelow)` for the source tower; 4 `Completed(slotId, color, setsCompleted, totalSets, leftEmptyTower)`; 5 destination `Revealed`; 6 `Unlocked(slotId, unlockColor)` in slot order; 7 `IceCracked(slotId, remaining)` or `IceShattered(slotId)` at 0 (A9), slot order; 8 `Won(moveCount)` / `OutOfMoves` (not won and legalMoves empty, A22). A rejected move changes nothing and returns a reason.

**Undo (§2.4)**: history of `UndoEntry(before, move, events)`, cleared on completion (the completing move can't be undone). `undo()` restores `before` but keeps current `extraCount`; returns `UndoResult(revertedMove, restoredState)`; `moveCount` reverts; `undosUsed` counts. `addExtraSlot()` is not a move, pushes no undo, returns `ExtraSlotAdded(slotId, BoardPosition, state)` — bottom shelf (override). `restart()` → initial board, history cleared, extras kept (override).

**Solver (§6.2/§6.3)**: A* with a bucket queue over f = g + h, h = nestsOnBoard − setsRemaining (consistent: merges −1, placements 0), LIFO within bucket (deterministic dive). Goal-at-generation is still optimal (last move is always a merge). Node = distinct canonical state stored (A5), ~90–120 B/node (hint ≈ 3.6 MB, soft-stuck ≈ 2.4 MB, admin ≈ 60 MB browser). Budget exhausted → `unknown`, never `unsolvable`. Canonical key: `freeMask` (interactable open-like slots) + free slots' nest codes sorted (insertion sort) + fixed slots (towers ≥1 nest, still-locked, iced) in index order; hashed to Hash64. Visited: open addressing over Uint32List hi/lo + node index, hit confirmed by recomputing the stored node's key (no false positives → `unsolvable` is a real proof). Arena stores actual cells so the parent chain replays real moves; cheaper re-reach overwrites and re-pushes, stale pops skipped. Pruning: ≤ 1 "place into an empty free slot" per source; skip moves of a lone nest from a free slot into an empty free slot. Hint: solved → first move; unknown → fallback (1 first legal merge; 2 else first non-pointless placement that still leaves an empty open slot; 3 else any placement) (A3); unsolvable → null + verdict (override). Soft-stuck banner only on `unsolvable`. Metrics: branching = successors/expansions; nodes = stored states. Every solution replays through `Rules` to `Won` in tests.

**Web-safe arithmetic (Q9)**: values in [0, 2^32), mask `& 0xFFFFFFFF` after `<<`, `+`, `*`; 32×32 multiply only via `mul32`; never `~` (use `^ 0xFFFFFFFF`); no Int64List/Uint64List; no HashMap/HashSet iteration; total-order sort comparators; no doubles in determinism-relevant outputs (win counts as ints). PRNG xoshiro128** (PCG32 needs 64-bit). Seeds in [0, 2^53), split with `%`/`~/`.

**Simulator (§6.4)**: 300 runs/bot, 250-move cap, loss on OutOfMoves/cap, no undo/extra slots; run seed `Prng.derive(simSeed, bot, i)`, default simSeed = low 32 bits of Hash64(canonical level JSON). Casual: merges exist && nextInt(100) < 70 → random merge, else uniform over legalMoves. Smart (A17): legal minus pointless → rank completes > merge > placement leaving an empty slot > rest → 1-ply lookahead drops moves leading to OutOfMoves, prefers most merges after → PRNG tie-break. Tiers on casual wins/300: easy ≥ 195, medium ≥ 105, hard ≥ 36, else superhard (A18 inclusive lower edges); expertOnly when smart wins < 150.

**Generator (§6.5)**: attempt i uses `Prng.derive(seed, i)`, ≤ 50. Segments: capacity N = occupied open slots + towers × towerDepth; 2·sets ≤ N ≤ maxSize·sets else `gen.segmentsInfeasible`; each set ≥ 2 segments (A10), remaining cuts dealt to sets with room. Placement: Fisher–Yates segments + slot positions; resample tower tops if > ⌊towers/2⌋ immediately mergeable with a visible top (A13). Locks on occupied open slots with unlockColor ≠ sealed colour when setsPerColor == 1 (rule 6); ice on occupied slots, n ∈ [1, min(3, totalSets − 1)] (A12). Each attempt: validator 1–7, solve with admin budget (must be solved), simulate; stop at first tier match; else closest solvable (tier distance → band centre → earliest) (A15); none solvable → `GeneratorFailure` (A14). Respect the bottom-shelf ≤ 4 rule. `generatorVersion` covers the pipeline (PRNG, solver, simulator, curve); output-changing edits bump it + new golden hashes; frozen v1 kept for dailies. Colours chosen by PRNG from the 10 non-gold (A11).

**Codec/Validator (§5.1/§5.3)**: strict token `^([a-z]+)([1-6])$`, unknown keys rejected (A21), `nest: null` empty, `ice` omitted at 0; canonical key order `type, unlockColor, nest|stack, ice`; top-level `schemaVersion, id, maxSize, shelves[, generatorVersion, seed]` (A20). Issues collected (not fail-fast); rules 7–8 only on well-formed levels. `LevelIssue{code, severity, path (JSON pointer), slotId, args, message}`. Codes: schema.unsupportedVersion/missingField/unknownField/wrongType, slot.unknownType, doll.badToken/unknownColor/sizeOutOfRange, ice.negative, gold.notSupported; R1 level.maxSizeOutOfRange; R2 layout.shelfCount/slotsPerShelf/noRoomForExtraSlots; R3 nest.empty/mixedColors/notConsecutive/alreadyFull; R4 counts.notFullSets; R5 tower.tooDeep/emptyAtStart; R6 locked.colorAbsent/colorAllSealed; R7 moves.noLegalFirstMove; R8 solver.unsolvable/unproven. `ValidationOptions(checkSolvable, solverBudget)`.

## 4. Bundle + 30 M2 levels
`apps/game/assets/levels/bundle.json` via `LevelBundleCodec` (2-space indent, fixed key order, sorted by order, no timestamps):
```json
{ "format": "nesty.levels", "bundleVersion": 1, "levelsVersion": 0,
  "levels": [ { "order": 1, "chapterId": "ch01", "tier": "easy", "version": 1, "rewardCoins": 10, "data": { "schemaVersion": 1, "id": "L0001", "maxSize": 3, "shelves": [] } } ] }
```
Decoder checks unique ids, continuous orders from 1, skips invalid entries with issues. `rewardCoins` from tier (§7.3; medium = easy, Q5).
Tutorial boards (design TUT1/TUT2): L1 r0 `[red3] null [red2]`, r1 `null [red1] null` (2 moves); L2 r0 `[red3] [blue2] null`, r1 `[red2,red1] [blue3] [blue1]` (3 moves, swallow red3 → [red2,red1]).
Plan (§6.6 pattern per 10: E E M E M H M E M S; §3.7 schedule; 2–3 shelves; ≤ 4 slots per row; bottom row ≤ 4; no locks/ice/gold; maxSize ≤ 4):
| Levels | Tiers | Colours / maxSize | Towers | Empty |
|---|---|---|---|---|
| 1–2 | E E | tutorials | 0 | 3 / 1 |
| 3–9 | M E M H M E M | 3–4 / 3 | 0 | 1–2 |
| 10 | S | 4 / 4 (maxSize intro) | 0 | 1 |
| 11–15 | E E M E M | 3–4 / 4 | 0 | 1–2 |
| 16 | H | 4 / 4, rows (4,3,3) (design TOWER16) | 2 (towers intro) | 1–2 |
| 17–20 | M E M S | 4–5 / 4 | 1–2 | 1–2 |
| 21–30 (ch02) | E E M E M H M E M S | 3–5 / 4 | 1–3, depth 2–3 | 1–2 |
Sources: `tools/levels/authored/L0001.json…L0030.json` (pure §5.1) + `tools/levels/manifest.json` (order, id, chapterId, declared tier, notes).
CLI `dart run nesty_tools:nesty_levels validate|solve|simulate|report <file|bundle>`, `bundle build`, `bundle check` (drift + rules 1–8 + simulated tier == declared (tutorial `tierOverride` only) + §6.6/§3.7/layout policy; prints order, id, tiers, casual%, smart%, solverMoves, nodes), `generate --params <json> --seed S --count N`, `fixtures check`. CI runs `bundle check`.

## 5. Tests
§4 rules one test each (place/inside/swallow; every InvalidMoveReason; tower pick/reveal/emptied→open, merge into tower top, completion in tower destination revealing next; unlock only on first completion incl. several same-colour locks; ice every completion, cracked vs shattered, iced slot unusable; Won, OutOfMoves, exact event order, legalMoves order/completeness, moveCount); expected values from the spec, not the code. The §5.1 example as a scenario (swallow into tower completes red → reveals green4, unlocks r1c0, ice → 1; optimal 4 moves). Session (undo, cleared on completion, extra slot kept on undo/restart, ≤ 2, rejected move pushes nothing). Fixtures stay pure §5.1 JSON; expectations in `test/solver/fixture_expectations.dart` (`001_l1_tutorial: 2`, `002_l2_swallow: 3`, `003_spec_5_1_example: 4`); unsolvable: lock deadlock, never-thawing ice, no-space dead end; unknown: large level with budget 50. Solver canonical equivalence, pruning, hint + each fallback branch, snapshot round-trip, all solutions replay to Won. Codec round-trips + one test per issue code + bundle order/id errors. PRNG reference vectors from an independent implementation; `mul32` vs BigInt oracle; Hash64 goldens. Simulator determinism, tier boundaries 195/194, 105/104, 36/35, expertOnly, bot policies. Generator: same params+seed → identical `jsonEncode(LevelCodec.encode(level))` pinned by golden hashes; param errors; **M1 acceptance**: n = 1..100 `bonusParams(n)` with seed 1,000,000+n → every result passes rules 1–8 on a fresh solve and replays to Won (tag `slow`, 10-level fast twin; Stop hook runs `-x slow`). VM/web parity (`test/parity/`, no dart:io, JSON consts): PRNG streams, mul32, hashes, canonical keys, solver verdict/moves/nodes, simulator counts, 3 generator hashes — `dart test test/parity`, `-p chrome`, `-p node` (mark file-reading tests `@TestOn('vm')`; `dart_test.yaml` tags `slow`, `parity`). Benchmarks in `benchmark/` (Stopwatch allowed there), recorded in PROGRESS: solver ≥ 300k nodes/s VM; hint 30k ≤ 100 ms VM / ≤ 400 ms dart2js; soft-stuck ≤ 70 ms; admin 500k ≤ 2 s VM / ≤ 8 s Chrome, heap ≤ 64 MB; simulator ≤ 250 ms/level; generator median ≤ 1.5 s, p95 ≤ 5 s; kernel apply ≤ 1 µs; tryMove facade ≤ 20 µs.

## 6. Isolate boundary
Core never imports dart:isolate. In: `SolverSnapshot.encode(state)` → versioned self-contained Int32List (~100 ints) + task (hint | softStuck | generate) + budget + requestId. Out: Int32List `[requestId, verdict, source, fromIndex, toIndex, nodes, solutionLength]`, mapped to slot ids via `state.slotIds`. Game: one long-lived worker isolate, latest-wins, steps `SolverRun.advance(2000)` so stale requests cancel. Admin (web): same stepping on the main thread with `await` between chunks.

## 7. Recorded ambiguity defaults (A-list)
A1 gold deferred · A2 destination Revealed after Completed · A3 hint fallback order · A4 unsolvable hint → no move/no charge · A5 node = distinct stored state · A6 loader rules 1–7, CI rule 8 · A7 extra slot on bottom shelf (override), ids 0-based · A8 extras survive Restart · A9 ice 1→0 emits only IceShattered · A10 ≥ 2 segments per set · A11 colours by PRNG from 10 non-gold · A12 ice n ∈ [1,3], locks on open slots · A13 tower-top mergeable limit ⌊towers/2⌋ · A14 generator failure → app policy (retry next seed) · A15 closest tier metric · A16 bonus/daily curve table (owner table later; M3) · A17 smart bot reading · A18 inclusive lower tier edges · A19 metrics definitions · A20 generatorVersion/seed optional level fields · A21 strict codec, id ≤ 64 chars · A22 OutOfMoves = legalMoves empty · A24 follow tier pattern at L10/L16 · A27 rewardCoins from tier · A30 pruning reading · A32 CLI tier mismatch fails CI.
