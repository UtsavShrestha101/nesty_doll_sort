import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nesty_core/nesty_core.dart';

part 'level_generator_service.freezed.dart';

/// A level generated on the device (spec §6.5, §7.1, §7.5): what
/// `LevelResolver` needs from a `GeneratorSuccess`.
@freezed
abstract class GeneratedLevel with _$GeneratedLevel {
  const factory GeneratedLevel({
    /// The board; its `seed` is the one that produced it (a retry seed
    /// after a `GeneratorFailure`, m3-design §5).
    required Level level,

    /// The simulated tier (`simulation.tier`): a bonus level plays as it
    /// (Q31).
    required Tier tier,

    /// False when no attempt hit the target tier (design A15).
    required bool tierMatched,

    /// Spec §6.4's "expert only" flag; nothing is shown for it (Q31).
    required bool expertOnly,
  }) = _GeneratedLevel;
}

/// Runs nesty_core's `Generator.generateWithRetries` off the UI isolate
/// (CLAUDE.md rule 8; docs/plans/m3-design.md §6.3).
///
/// The real implementation, `IsolateLevelGeneratorService`, runs each
/// request in `Isolate.run` (the params are plain data, so they copy with no
/// encoding) and brings the level back as `LevelCodec` JSON. The fake runs
/// it synchronously on the calling isolate.
abstract interface class LevelGeneratorService {
  /// The level [params] make, with the deterministic retries, or null when
  /// every seed failed or the isolate died. Never throws (rule 3).
  Future<GeneratedLevel?> generate(GeneratorParams params);

  /// Drops work in flight (DI reset).
  void dispose();
}
