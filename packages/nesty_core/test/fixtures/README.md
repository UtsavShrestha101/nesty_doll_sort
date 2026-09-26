# Solver fixtures

Hand-checked levels that pin the solver's behaviour (CLAUDE.md "Testing"). The
first fixtures arrive with the solver in **M1** (spec §18); this folder only
documents the convention until then.

## Layout

```
test/fixtures/
  solvable/     # the solver must return "solved" (with a move list)
  unsolvable/   # the solver must return "unsolvable"
```

The folder a file sits in *is* its expected verdict, so a fixture can never
carry a stale or contradicting flag.

## Rules for a fixture

- **One level per file**, in exactly the level JSON of spec §5.1
  (`schemaVersion: 1`). Fixtures are therefore also inputs for the level
  codec round-trip tests and must pass the validator (spec §5.3), apart from
  rule 8 ("the solver proves the level is solvable") for files in
  `unsolvable/`.
- **Name** files `<nnn>_<what_it_covers>.json`, for example
  `003_swallow_required.json` or `001_no_empty_slot_dead_end.json`. The number
  keeps the order stable; the name says why the fixture exists.
- **Unsolvable fixtures must be small enough to search exhaustively** within
  the admin budget of 500,000 nodes (spec §6.3). A search that runs out of
  budget returns `unknown`, never `unsolvable`, so a fixture that is too big
  would test nothing.
- **Explain non-obvious fixtures.** JSON has no comments, so describe the
  trick (e.g. "only solvable by filling the last empty slot first") in the
  test that loads it.
- Fixtures are **hand-written or hand-verified**, never produced by the
  generator: the generator is itself tested against the solver, so using its
  output here would make the test circular.

<!-- TODO(M1): decide how a solvable fixture records its expected optimal move
count (spec §5.2 metrics.solverMoves), e.g. a map in the test that loads it,
without changing the level JSON. -->
