# nesty_core

Pure-Dart game rules for **Nesty: Doll Sort**: models, level codec, validator,
rules, game session, solver, simulator, generator and PRNG
([spec §13.1](../../docs/GAME_SPEC.md#131-packages)).

The mobile game, the Flutter Web admin, the solver, the generator and the
simulator all call the functions in this package, so every rule is written
exactly once (CLAUDE.md rule 2).

## Status

Pre-M1 skeleton. Only `DollColor` exists (the 11 colors of
[spec §12.3](../../docs/GAME_SPEC.md#123-doll-colors-each-has-a-symbol-for-color-blind-accessibility),
with the codec id and the wild flag of §3.5). Everything below is the plan for
**M1** ([spec §18](../../docs/GAME_SPEC.md#18-milestones-and-acceptance-criteria)).

## Hard rules for this package

| Rule | Why | Enforced by |
|---|---|---|
| No Flutter, Flame or `dart:ui` imports | Game, web admin and VM tools share one rule set (CLAUDE.md rule 2) | `test/architecture_guard_test.dart` |
| Only platform-neutral `dart:` libraries (no `dart:io`, `dart:isolate`, `dart:html`, ...) | Core runs in the web admin (Solve / Simulate / Playtest, §15) and on mobile | `test/architecture_guard_test.dart` |
| No `dart:math` `Random`, never an unseeded generator | Its sequence may change between SDK versions, which would change generated and daily levels (§6.5, CLAUDE.md rule 7) | `test/architecture_guard_test.dart` |
| No clock: `DateTime.now()`, `DateTime.timestamp()` or `Stopwatch` | Determinism: dates and seeds are passed in by the caller (§7.5, CLAUDE.md rule 7). Solver budgets are node counts (§6.3), so a time-based cutoff would make results depend on device speed | `test/architecture_guard_test.dart` |
| Immutable models with `==` / `hashCode` | Undo history and solver states compare by value (CLAUDE.md "Code style") | review |
| No code generation | Keeps core a plain Dart package with no build step | review |

The guard scans `lib/**.dart` with a small lexer (`test/support/`) that ignores
comments and string contents, and `test/support/core_guards_test.dart` proves
each guard fires on offending code.

## Planned module layout (M1)

```
lib/
  nesty_core.dart            # barrel: exports everything below
  src/
    models/                  # Doll, Nest, Slot variants, Level, GameState, Move, MoveEvent
    codec/                   # LevelCodec: JSON <-> models
    validator/               # Validator: level checks
    rules/                   # tryMove, legalMoves, isWon, isOutOfMoves
    game_session/            # GameSession: state + undo + extra slots + events
    solver/                  # Solver: compact state encoding, canonical form, A*/IDA*
    simulator/               # Simulator: casual and smart bots, tier suggestion
    generator/               # Generator: seeded level generation
    prng/                    # Prng: seeded generator, stable across SDK versions
```

| Module | Responsibility | Spec |
|---|---|---|
| `models` | `DollColor` (done), `Doll`, `Nest` (outer to inner, same color, consecutive sizes), `OpenSlot` / `TowerSlot` / `LockedSlot` + ice modifier, `Level`, `GameState` with stable slot ids (`r{row}c{col}`, `x{n}`), `MoveEvent` | §2.1, §3, §4 |
| `codec` | `LevelCodec`: schema v1 JSON, compact dolls such as `"red4"`, nests outer to inner, tower stacks bottom to top. Round-trip tested | §5.1 |
| `validator` | `Validator`: the eight checks of §5.3, shared by the admin and the game loader (invalid levels are rejected or skipped with a log entry) | §5.3 |
| `rules` | `tryMove(src, dst)` returning `MoveResult(events, newState)`, plus `legalMoves`, `isWon`, `isOutOfMoves`. Nest inside, swallow, tower pop and reveal, completion, unlock, ice countdown | §2.2, §2.3, §3, §4 |
| `game_session` | `GameSession`: current state, `undo()` (history cleared when a set completes), `addExtraSlot()` (max 2), restart, event stream for the game to animate | §2.4, §3.6, §4 |
| `solver` | Nests packed into ints `(color, outerSize, len)`, canonical key that sorts open-slot contents, 64-bit visited-set hash, A* / IDA* with `h = nestsOnBoard - setsRemaining`, pruning of pointless moves, node budgets (admin 500k, hint 30k, soft-stuck 20k), `unknown` when out of budget, fallback hint. Runs in an isolate that the *game* spawns | §6.2, §6.3 |
| `simulator` | Casual and smart bots, 300 seeded playthroughs each with a 250-move cap, tier from casual win rate, "expert only" flag | §6.4 |
| `generator` | Seeded generation from the §6.5 params, retries with sub-seeds, records `generatorVersion`. Used for Bonus Endless (`seed = 1_000_000 + levelNumber`) and the daily puzzle (`seed = yyyymmdd`) | §6.5, §6.6, §7.1, §7.5 |
| `prng` | `Prng`: small seeded generator implemented here (e.g. xoshiro128** or PCG32) | §6.5 |

## Testing

```
cd packages/nesty_core && dart test     # must always pass
dart analyze                            # zero issues
```

- Every §4 rule gets a unit test, including invalid moves (M1).
- Solver fixtures follow the convention in `test/fixtures/README.md` (M1).
- Codec: round-trip and §5.3 schema validation tests (M1).
- Generator: same seed and params give identical output, and every generated
  level validates and solves (M1).
