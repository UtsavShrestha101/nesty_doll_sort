import 'dart:convert';

import 'package:nesty_core/nesty_core.dart';

/// A comparable fingerprint of deterministic `nesty_core` output, for the
/// device-kill resume phases and the daily-puzzle parity check (plan-m3.md
/// "Verification"; m3-design §14).
///
/// The core's own goldens (`packages/nesty_core/test/generator/
/// daily_golden_test.dart`, via `test/parity/generated_levels.dart`)
/// fingerprint with `Hash64`, a 64-bit digest. `Hash64` lives at
/// `packages/nesty_core/lib/src/util/hash64.dart`, whose own doc comment
/// says "Internal to nesty_core (not exported by the barrel)", and
/// `lib/nesty_core.dart` says outright "Apps import only this library,
/// never `src/`" — a rule `.claude/rules/nesty-core.md` repeats. So this
/// app-side test does not reach into it (an earlier draft of
/// `resume_scenario.dart` did; fixed here).
///
/// Instead, the canonical JSON encoding itself — `LevelCodec.encode` or
/// `GameSessionCodec.encode`, both public — is compared verbatim. For the
/// actual acceptance goal (phase A equals phase B; the same date's daily
/// equals itself on a second device) full-string equality is at least as
/// strong as comparing a hash of that same string. It reads longer in a log
/// line or `reportData`, which is the one thing a short digest would have
/// bought; see this lane's report for a suggestion to core-codec (a small
/// public digest helper) if a shorter value is wanted later.
abstract final class Fingerprint {
  /// A generated level's canonical encoding — comparable with what
  /// `daily_golden_test.dart` fingerprints, minus the `Hash64` step.
  static String ofLevel(Level level) => jsonEncode(LevelCodec.encode(level));

  /// An in-progress session's canonical encoding (m3-design §4).
  static String ofSession(GameSession session) =>
      jsonEncode(GameSessionCodec.encode(session));
}
