## 0.1.0 — skeleton

- Pre-M1 architecture skeleton (M0, 2026-09-25). No game rules, codec,
  solver, simulator or generator yet; those are M1 (spec §18).
- `DollColor`: the 11 colors of spec §12.3 in table order, with a stable codec
  `id` (spec §5.1), an `isWild` flag for gold (spec §3.5) and a strict
  `fromId` that throws `FormatException` for unknown ids.
- Architecture guard test: fails if `lib/` imports Flutter, Flame, `dart:ui` or
  a platform-specific `dart:` library, references `dart:math` `Random`,
  constructs an unseeded `Random`, or reads the wall clock (CLAUDE.md rules 2
  and 7, spec §6.5).
- README documents the planned M1 module layout; `test/fixtures/README.md`
  documents the solver fixture convention.
