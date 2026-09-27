import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/music/music_mix.dart';
import 'package:nesty_game/core/services/music/music_service.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// The music's numbers come from tokens.json `sound` (AUDIO.md "Music
/// rules").
void main() {
  test('every duck reason has its tokens.json factor, and every factor a '
      'reason', () {
    expect({
      for (final reason in DuckReason.values) reason.name: reason.factor,
    }, SoundTokens.musicDuckFactors);
    expect(DuckReason.win.factor, 0.3);
    expect(DuckReason.outOfMoves.factor, 0.4);
    expect(DuckReason.reward.factor, 0.4);
    expect(DuckReason.pause.factor, 0.5);
  });

  test("ducks don't stack: the lowest active factor wins", () {
    expect(MusicMix.duckFactor(const []), 1);
    expect(MusicMix.duckFactor(const [DuckReason.pause]), 0.5);
    expect(MusicMix.duckFactor(const [DuckReason.pause, DuckReason.win]), 0.3);
    expect(
      MusicMix.duckFactor(const [DuckReason.outOfMoves, DuckReason.pause]),
      0.4,
    );
  });

  test('target = music volume × duck factor, 0–1', () {
    expect(MusicMix.defaultVolume, SoundTokens.musicVolumeDefault);
    expect(MusicMix.target(volume: 0.5, duck: 0.3), closeTo(0.15, 1e-12));
    expect(MusicMix.target(volume: 0.5, duck: 1), 0.5);
    expect(MusicMix.target(volume: 3, duck: 1), 1);
    expect(MusicMix.target(volume: -1, duck: 1), 0);
  });

  test('the fades are tokens.json sound.musicFadeMs', () {
    int ms(Duration d) => d.inMilliseconds;
    expect(ms(MusicMix.start), 1200);
    expect(ms(MusicMix.crossfade), 800);
    expect(ms(MusicMix.resume), 600);
    expect(ms(MusicMix.toggleOff), 300);
    expect(ms(MusicMix.toggleOn), 600);
    expect(ms(MusicMix.duckIn), 200);
    expect(ms(MusicMix.duckOut), 800);
    expect(ms(MusicMix.chapterOut), 400);
    expect(ms(MusicMix.chapterIn), 2000);
  });

  test('each track is its tokens.json loop, bundled as OGG', () {
    expect({
      for (final track in MusicTrack.values) track.file,
    }, SoundTokens.musicFiles.toSet());
    expect(MusicTrack.home.file, 'music_home');
    expect(MusicMix.assetPath(MusicTrack.home), 'assets/audio/music_home.ogg');
    expect(MusicMix.assetPath(MusicTrack.game), 'assets/audio/music_game.ogg');
  });
}
