/// Pure-Dart game rules for Nesty: Doll Sort (spec §4, §13.1).
///
/// Everything the game, admin, solver, generator and simulator share lives
/// here, so a rule is written exactly once (CLAUDE.md rule 2). Apps import
/// only this library, never `src/`. The rules engine
/// (`src/rules/engine/`), the solver's search internals and `src/util/` are
/// deliberately not exported (docs/plans/m1-core-design.md §1).
library;

// Level codec, bundle codec, session codec and issues (spec §5.1, §5.3,
// §13.3, §13.4).
export 'package:nesty_core/src/codec/game_session_codec.dart';
export 'package:nesty_core/src/codec/level_bundle.dart';
export 'package:nesty_core/src/codec/level_codec.dart';
export 'package:nesty_core/src/codec/level_issue.dart';
// Generator and difficulty curve (spec §6.5, §6.6, §7.1, §7.5).
export 'package:nesty_core/src/generator/curve.dart';
export 'package:nesty_core/src/generator/generator.dart';
export 'package:nesty_core/src/generator/generator_params.dart';
// Models (spec §2.1, §3, §4).
export 'package:nesty_core/src/models/doll.dart';
export 'package:nesty_core/src/models/doll_color.dart';
export 'package:nesty_core/src/models/game_state.dart' show GameState;
export 'package:nesty_core/src/models/level.dart';
export 'package:nesty_core/src/models/move.dart';
export 'package:nesty_core/src/models/move_event.dart';
export 'package:nesty_core/src/models/move_result.dart';
export 'package:nesty_core/src/models/nest.dart';
export 'package:nesty_core/src/models/session_types.dart';
export 'package:nesty_core/src/models/slot.dart';
export 'package:nesty_core/src/models/slot_id.dart';
// Seeded PRNG (spec §6.5).
export 'package:nesty_core/src/prng/prng.dart';
// Rules and the play session (spec §2.4, §3.6, §4); the star rating
// (spec-prop §7.10).
export 'package:nesty_core/src/rules/rules.dart';
export 'package:nesty_core/src/rules/star_rating.dart';
export 'package:nesty_core/src/session/game_session.dart';
// Simulator and tiers (spec §6.4); the bot policies and the race's rival
// (spec-prop §7.7). The bots' players stay internal: only the policy enum
// is exported.
export 'package:nesty_core/src/simulator/bots.dart' show SimBot;
export 'package:nesty_core/src/simulator/rival_bot.dart';
export 'package:nesty_core/src/simulator/simulator.dart';
export 'package:nesty_core/src/simulator/tier.dart';
// Solver, hints and the isolate snapshot (spec §6.2, §6.3).
export 'package:nesty_core/src/solver/hint.dart';
export 'package:nesty_core/src/solver/snapshot.dart';
export 'package:nesty_core/src/solver/solver.dart';
export 'package:nesty_core/src/solver/solver_run.dart';
// Validator and layout limits (spec §5.3).
export 'package:nesty_core/src/validator/layout_limits.dart';
export 'package:nesty_core/src/validator/validator.dart';
