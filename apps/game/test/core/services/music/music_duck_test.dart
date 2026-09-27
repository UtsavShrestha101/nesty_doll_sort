import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/music/fake_music_service.dart';
import 'package:nesty_game/core/services/music/music_duck.dart';
import 'package:nesty_game/core/services/music/music_service.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// `MusicDuck`: an overlay ducks the music exactly while it is in the tree.
void main() {
  late FakeMusicService music;
  late FakeAudioService jingles;

  setUp(() {
    music = FakeMusicService();
    jingles = FakeAudioService();
  });

  Widget duck(DuckReason reason, {Jingle? jingle, Key? key}) => MusicDuck(
    key: key,
    music: music,
    reason: reason,
    jingles: jingles,
    jingle: jingle,
    child: const SizedBox(),
  );

  testWidgets('ducks when it mounts and unducks when it goes', (tester) async {
    await tester.pumpWidget(duck(DuckReason.win));
    expect(music.calls, [const MusicCall.duck(DuckReason.win)]);
    expect(music.ducking, {DuckReason.win});

    await tester.pumpWidget(const SizedBox());
    expect(music.calls.last, const MusicCall.unduck(DuckReason.win));
    expect(music.ducking, isEmpty);
    expect(jingles.jingles, isEmpty);
  });

  testWidgets('plays its jingle once the duck is in', (tester) async {
    await tester.pumpWidget(
      duck(DuckReason.outOfMoves, jingle: Jingle.outOfMoves),
    );
    await tester.pump(
      const Duration(milliseconds: SoundTokens.musicFadeDuckInMs - 1),
    );
    expect(jingles.jingles, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(jingles.jingles, [Jingle.outOfMoves]);
    await tester.pump(const Duration(seconds: 5));
    expect(jingles.jingles, [Jingle.outOfMoves], reason: 'once');
  });

  testWidgets('gone before the duck is in, it plays no jingle', (tester) async {
    await tester.pumpWidget(
      duck(DuckReason.outOfMoves, jingle: Jingle.outOfMoves),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    expect(jingles.jingles, isEmpty);
    expect(music.ducking, isEmpty);
  });

  testWidgets('a new reason ducks before the old one lifts', (tester) async {
    await tester.pumpWidget(duck(DuckReason.pause));
    await tester.pumpWidget(duck(DuckReason.win));
    expect(music.calls, [
      const MusicCall.duck(DuckReason.pause),
      const MusicCall.duck(DuckReason.win),
      const MusicCall.unduck(DuckReason.pause),
    ]);
    expect(music.ducking, {DuckReason.win});
  });

  testWidgets('an overlay rebuilt in a new place stays ducked through the '
      'swap', (tester) async {
    await tester.pumpWidget(
      Column(children: [duck(DuckReason.win, key: const ValueKey(1))]),
    );
    await tester.pumpWidget(
      Column(
        children: [
          const SizedBox(),
          duck(DuckReason.win, key: const ValueKey(2)),
        ],
      ),
    );
    // The new one ducked before the old one went: still ducked.
    expect(music.ducking, {DuckReason.win});
    expect(music.calls, [
      const MusicCall.duck(DuckReason.win),
      const MusicCall.duck(DuckReason.win),
      const MusicCall.unduck(DuckReason.win),
    ]);
  });
}
