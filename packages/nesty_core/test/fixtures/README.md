# Level fixtures

Hand-checked levels that pin the solver's behaviour (CLAUDE.md "Testing") and
double as codec and validator inputs (spec §5.1, §5.3).

## Layout

```
test/fixtures/
  solvable/            # the solver must return "solved" (with a move list)
  unsolvable/          # the solver must return "unsolvable"
  fixture_loader.dart  # loadFixtures(FixtureFolder.solvable) etc. (VM only)
  fixtures_test.dart   # proves every fixture is what it claims (see below)
test/solver/
  fixture_expectations.dart  # optimal move counts and the reasoning behind them
```

The folder a file sits in *is* its expected verdict, so a fixture can never
carry a stale or contradicting flag.

## Expectations live next to the tests, not in the JSON

Level JSON has no room for expectations, and adding a key would break the
strict codec (design A21). So `test/solver/fixture_expectations.dart` holds
them, keyed by file name without `.json` (Q19):

- `solvableFixtureMoves`: the optimal move count of every solvable fixture
  (spec §5.2 `metrics.solverMoves`), with the hand-worked argument as a
  comment next to each number.
- `unsolvableFixtures`: every unsolvable fixture, with why it can't be won.
- `budgetLimitedFixture` and `budgetLimitedBudget`: a solvable fixture that a
  50-node search can't finish, for the "exhausted budget is `unknown`, never
  `unsolvable`" test (spec §6.3).

The file is pure Dart (no dart:io), so parity and web suites can import it.

## Rules for a fixture

- **One level per file**, in exactly the canonical level JSON of spec §5.1
  (`schemaVersion: 1`, keys in the order `LevelCodec.encode` writes them).
  Fixtures must pass validation rules 1–7 (spec §5.3); files in `solvable/`
  must also pass rule 8.
- **Name** files `<nnn>_<what_it_covers>.json`. The number keeps the order
  stable; the name says why the fixture exists. The level `id` is the file
  name in `solvable/` and `u` + the file name in `unsolvable/` (so ids stay
  unique across the folders), except `003_spec_5_1_example`, which is the
  §5.1 example byte for byte (`L0042`).
- **Unsolvable fixtures must be small enough to search exhaustively** within
  the admin budget of 500,000 nodes (spec §6.3). A search that runs out of
  budget returns `unknown`, never `unsolvable`, so a fixture that is too big
  would test nothing. Each current one has at most 28 reachable states.
- **Explain every fixture** next to its entry in `fixture_expectations.dart`:
  the trick, and how the expected number follows from spec §4.
- Fixtures are **hand-written or hand-verified**, never produced by the
  generator: the generator is itself tested against the solver, so using its
  output here would make the test circular.
- **Add a fixture** by adding its file and its entry in
  `fixture_expectations.dart`; `fixtures_test.dart` fails until both exist.

## What fixtures_test.dart proves

For every file: it decodes without issues, it is canonical (`encode` gives
back the same values in the same key order), and it passes rules 1–7. It
then confirms the expectations without the solver, by an exhaustive
breadth-first search through the public `Rules` API: the optimal move count
of each small solvable fixture, and that no reachable state of an unsolvable
fixture is won. The large fixture is too big for that, so the test instead
checks that merges alone win it in exactly the §6.3 lower bound,
`nests − sets` moves.

The numbers were also cross-checked with an independent search written from
spec §4 alone, outside this package. It agreed on every optimal count and on
the exact number of reachable states of each unsolvable fixture.
