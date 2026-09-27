import 'dart:math' as math;

import 'package:nesty_game/core/services/audio/sfx_mix.dart';
import 'package:nesty_game/core/services/music/music_service.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// The music's numbers (AUDIO.md "Music rules"; tokens.json
/// `sound.musicFadeMs`, `sound.musicDuck`, `sound.mix.musicDefault`). Pure,
/// so the rules are unit-tested without an audio engine.
abstract final class MusicMix {
  /// `assets/audio/<file>.ogg`: the loops ship as OGG Vorbis, streamed.
  static String assetPath(MusicTrack track) =>
      '${SfxMix.assetDirectory}/${track.file}.ogg';

  /// The volume the music plays at by default, before any duck.
  static const double defaultVolume = SoundTokens.musicVolumeDefault;

  /// The lowest factor of the [active] ducks, or 1 with none: ducks don't
  /// stack.
  static double duckFactor(Iterable<DuckReason> active) {
    var factor = 1.0;
    for (final reason in active) {
      factor = math.min(factor, reason.factor);
    }
    return factor;
  }

  /// The loop's volume: the music [volume] × the [duck] factor, 0–1.
  static double target({required double volume, required double duck}) =>
      (volume * duck).clamp(0.0, 1.0);

  /// Splash ready: the first loop fades in from silence.
  static const start = Duration(milliseconds: SoundTokens.musicFadeStartMs);

  /// Home ↔ a level: the incoming loop fades in while the outgoing one
  /// fades out and pauses.
  static const crossfade = Duration(
    milliseconds: SoundTokens.musicFadeCrossfadeMs,
  );

  /// Back from the background or an ad.
  static const resume = Duration(milliseconds: SoundTokens.musicFadeResumeMs);

  /// The Music toggle turned off: silent within this.
  static const toggleOff = Duration(
    milliseconds: SoundTokens.musicFadeToggleOffMs,
  );

  /// The Music toggle turned on.
  static const toggleOn = Duration(
    milliseconds: SoundTokens.musicFadeToggleOnMs,
  );

  /// A duck coming in.
  static const duckIn = Duration(milliseconds: SoundTokens.musicFadeDuckInMs);

  /// A duck ending.
  static const duckOut = Duration(milliseconds: SoundTokens.musicFadeDuckOutMs);

  /// Chapter complete: out, then `jingle_chapter`.
  static const chapterOut = Duration(
    milliseconds: SoundTokens.musicFadeChapterOutMs,
  );

  /// The next level after chapter complete.
  static const chapterIn = Duration(
    milliseconds: SoundTokens.musicFadeChapterInMs,
  );
}
