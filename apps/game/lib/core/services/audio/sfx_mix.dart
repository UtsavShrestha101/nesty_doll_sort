import 'dart:math' as math;

import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// Which file a [SoundEffect] plays, how loud and how fast (spec §11.3,
/// tokens.json `sound`, PROGRESS D19). Pure, so the rules are unit-tested
/// without an audio engine.
abstract final class SfxMix {
  /// Where `sync_design_assets` puts the SFX (`apps/game/assets/audio/`).
  static const assetDirectory = 'assets/audio';

  /// The placeholder WAVs' extension. Final files may be OGG with the same
  /// base names (tokens.json `sound.format`).
  // TODO(M7): switch when the final audio arrives (BACKLOG "Final audio").
  static const fileExtension = 'wav';

  /// Semitones already baked into the placeholder clacks (D19): they are
  /// +1 semitone, so the design's `2^(−2(size − 3.5)/12)` becomes
  /// `2^(−2(size − 3)/12)` here.
  // TODO(M7): 0 once the final clacks arrive (BACKLOG "Final audio").
  static const clackBakedSemitones = 1;

  /// The clack size [AudioService.play] assumes when none is given.
  static const defaultClackSize = 3;

  /// The combo step [AudioService.play] assumes when none is given.
  static const defaultComboStep = 1;

  /// Per-file gain on top of [SoundTokens.sfxVolumeDefault]. The
  /// placeholders are peak-normalized to the same level by
  /// `design/generator/nesty-sfx.js`, so every gain is 1 for now.
  // TODO(M7): balance the final files by ear (BACKLOG "Final audio").
  /// A file missing here plays at gain 1; `sfx_mix_test` checks that it
  /// covers every file of `SoundTokens.allFiles`.
  static const Map<String, double> gains = {
    'bonk': 1,
    'button': 1,
    'clack_1': 1,
    'clack_2': 1,
    'clack_3': 1,
    'coins': 1,
    'complete_1': 1,
    'complete_2': 1,
    'complete_3': 1,
    'complete_4': 1,
    'complete_5': 1,
    'ice_crack': 1,
    'ice_shatter': 1,
    'pick': 1,
    'unlock_glass': 1,
    'whoosh': 1,
    'win': 1,
  };

  /// `assets/audio/<file>.wav`.
  static String assetPath(String file) =>
      '$assetDirectory/$file.$fileExtension';

  /// The token cue behind [effect] (tokens.json `sound.events`).
  static SoundCue cueOf(SoundEffect effect) => switch (effect) {
    SoundEffect.pick => SoundTokens.pick,
    SoundEffect.clack => SoundTokens.nest,
    SoundEffect.whoosh => SoundTokens.move,
    SoundEffect.bonk => SoundTokens.invalid,
    SoundEffect.complete => SoundTokens.complete,
    SoundEffect.win => SoundTokens.win,
    SoundEffect.coins => SoundTokens.coinsCountUp,
    SoundEffect.unlockGlass => SoundTokens.unlock,
    SoundEffect.iceCrack => SoundTokens.iceCrack,
    SoundEffect.iceShatter => SoundTokens.iceShatter,
    SoundEffect.button => SoundTokens.button,
  };

  /// The file [effect] plays. [randomIndex] picks a variant for a random
  /// cue (the clacks): it gets the variant count and returns 0 to count − 1.
  /// [comboStep] picks `complete_{step}` (clamped to 1–5).
  static String fileFor(
    SoundEffect effect, {
    required int Function(int count) randomIndex,
    int? comboStep,
  }) {
    final cue = cueOf(effect);
    final files = cue.files;
    return switch (cue.pick) {
      SoundPick.single => files.first,
      SoundPick.random =>
        files[randomIndex(files.length).clamp(0, files.length - 1)],
      SoundPick.comboStep =>
        files[(comboStep ?? defaultComboStep).clamp(1, files.length) - 1],
    };
  }

  /// The playback rate of [effect]: the clack's per-size pitch
  /// (`2^((semitones − clackBakedSemitones)/12)` with the tokens'
  /// `clackSemitonesBySize`; bigger dolls are lower), 1 for everything
  /// else. A missing or out-of-range [dollSize] is clamped to 1–6.
  static double speedFor(SoundEffect effect, {int? dollSize}) {
    if (effect != SoundEffect.clack) return 1;
    return _clackRates[(dollSize ?? defaultClackSize).clamp(1, 6) - 1];
  }

  /// The play volume of [file]: the SFX mix default (0.8) × its gain.
  static double volumeOf(String file) =>
      SoundTokens.sfxVolumeDefault * (gains[file] ?? 1);

  // Built once: play() runs on every move, so no pow() per call.
  static final List<double> _clackRates = List.unmodifiable([
    for (var size = 1; size <= 6; size++)
      math
          .pow(
            2,
            (SoundTokens.clackSemitonesBySize[size]! - clackBakedSemitones) /
                12,
          )
          .toDouble(),
  ]);
}
