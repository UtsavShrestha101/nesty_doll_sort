import 'dart:math' as math;

import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// Which file a [SoundEffect] or [Jingle] plays, how loud and how fast (spec
/// §11.3, tokens.json `sound`, `design/audio/AUDIO.md`). Pure, so the rules
/// are unit-tested without an audio engine.
abstract final class SfxMix {
  /// Where `sync_design_assets` puts the audio (`apps/game/assets/audio/`).
  static const assetDirectory = 'assets/audio';

  /// The SFX are WAV (44.1 kHz mono 16-bit, AUDIO.md "Files").
  static const fileExtension = 'wav';

  /// The jingles are OGG Vorbis, like the music loops.
  static const jingleExtension = 'ogg';

  /// The clack size [AudioService.play] assumes when none is given.
  static const defaultClackSize = 3;

  /// The combo step [AudioService.play] assumes when none is given.
  static const defaultComboStep = 1;

  /// Per-file gain on top of the bus volume. Every gain is 1: AUDIO.md says
  /// the SFX's relative levels are intentional (don't normalize them), and
  /// the jingles are mastered to −17 dBFS RMS. A file missing here plays at
  /// gain 1; `sfx_mix_test` checks that it covers every file of
  /// `SoundTokens.allFiles` and `SoundTokens.jingleFiles`.
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
    'jingle_chapter': 1,
    'jingle_oom': 1,
    'jingle_reward': 1,
    'pick': 1,
    'unlock_glass': 1,
    'whoosh': 1,
    'win': 1,
  };

  /// The jingles' bus (tokens.json `sound.mix.jingleBus`): `sfx`, so they
  /// play at the SFX volume and follow the Sound toggle (AUDIO.md
  /// "Jingles"). `sfx_mix_test` pins it: a `music` bus would have the
  /// music service own them.
  static const jingleBus = SoundTokens.jingleBus;

  /// `assets/audio/<file>.wav`.
  static String assetPath(String file) =>
      '$assetDirectory/$file.$fileExtension';

  /// `assets/audio/<file>.ogg`.
  static String jingleAssetPath(String file) =>
      '$assetDirectory/$file.$jingleExtension';

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

  /// The token cue behind [jingle] (tokens.json `sound.events`).
  static SoundCue jingleCueOf(Jingle jingle) => switch (jingle) {
    Jingle.chapter => SoundTokens.chapterComplete,
    Jingle.reward => SoundTokens.reward,
    Jingle.outOfMoves => SoundTokens.outOfMoves,
  };

  /// The file [jingle] plays (`jingle_chapter`, `jingle_reward`,
  /// `jingle_oom`).
  static String jingleFileOf(Jingle jingle) => jingleCueOf(jingle).files.first;

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

  /// The playback rate of [effect]: the clack's per-size pitch, 1 for
  /// everything else. The clack files are recorded at
  /// `SoundTokens.clackBakedSemitones` (0: the v2 files are baked at size
  /// 3.5), so the rate is `2^((clackSemitonesBySize[size] − baked)/12)`,
  /// which is `2^(−2(size − 3.5)/12)`: size 1 is +5 semitones, size 6 −5;
  /// bigger dolls are lower. A missing or out-of-range [dollSize] is
  /// clamped to 1–6.
  static double speedFor(SoundEffect effect, {int? dollSize}) {
    if (effect != SoundEffect.clack) return 1;
    return _clackRates[(dollSize ?? defaultClackSize).clamp(1, 6) - 1];
  }

  /// The play volume of the SFX [file]: the SFX bus default (0.8) × its
  /// gain.
  static double volumeOf(String file) =>
      SoundTokens.sfxVolumeDefault * (gains[file] ?? 1);

  /// The play volume of the jingle [file]: on the SFX bus, like the SFX
  /// ([jingleBus]).
  static double jingleVolumeOf(String file) => volumeOf(file);

  // Built once: play() runs on every move, so no pow() per call.
  static final List<double> _clackRates = List.unmodifiable([
    for (var size = 1; size <= 6; size++)
      math
          .pow(
            2,
            (SoundTokens.clackSemitonesBySize[size]! -
                    SoundTokens.clackBakedSemitones) /
                12,
          )
          .toDouble(),
  ]);
}
