import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/music/fake_music_service.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/services/music/music_service.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// `JingleCues`: the reward and chapter-complete jingles with their music
/// moves (AUDIO.md "Jingles", audio plan Q40), for M3's screens.
void main() {
  late FakeMusicService music;
  late FakeAudioService jingles;
  late JingleCues cues;

  setUp(() {
    music = FakeMusicService();
    jingles = FakeAudioService();
    cues = JingleCues(music, jingles);
  });

  tearDown(() => cues.dispose());

  testWidgets('a reward plays jingle_reward under a 0.4 duck that lifts when '
      'it ends', (tester) async {
    cues.reward();
    expect(jingles.jingles, [Jingle.reward]);
    expect(music.ducking, {DuckReason.reward});
    expect(DuckReason.reward.factor, SoundTokens.musicDuckReward);

    final length = FakeAudioService.shippedJingleLengths[Jingle.reward]!;
    await tester.pump(length - const Duration(milliseconds: 1));
    expect(music.ducking, {DuckReason.reward});
    await tester.pump(const Duration(milliseconds: 1));
    expect(music.ducking, isEmpty);
    expect(cues.pending, 0);
  });

  testWidgets('a reward whose jingle does not play (Sound off) leaves the '
      'music alone', (tester) async {
    jingles.jingleLengths = const {};
    cues.reward();
    expect(music.calls, isEmpty);
    expect(cues.pending, 0);
  });

  testWidgets('chapter complete fades the music out, then plays '
      'jingle_chapter only (audio plan Q40)', (tester) async {
    cues.chapterComplete();
    expect(music.calls, [const MusicCall.stopForChapter()]);
    await tester.pump(
      const Duration(milliseconds: SoundTokens.musicFadeChapterOutMs - 1),
    );
    expect(jingles.jingles, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(jingles.jingles, [Jingle.chapter]);
    expect(music.ducking, isEmpty);
  });

  testWidgets('dispose cancels what is still to come', (tester) async {
    cues
      ..chapterComplete()
      ..reward()
      ..dispose();
    expect(cues.pending, 0);
    await tester.pump(const Duration(seconds: 10));
    expect(jingles.jingles, [Jingle.reward]);
  });
}
