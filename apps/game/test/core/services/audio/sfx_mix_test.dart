import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/audio/sfx_mix.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

void main() {
  int first(int count) => 0;

  test('every effect maps to its tokens.json sound.events file', () {
    final files = {
      for (final effect in SoundEffect.values)
        effect: SfxMix.fileFor(effect, randomIndex: first),
    };
    expect(files, {
      SoundEffect.pick: 'pick',
      SoundEffect.clack: 'clack_1',
      SoundEffect.whoosh: 'whoosh',
      SoundEffect.bonk: 'bonk',
      SoundEffect.complete: 'complete_1',
      SoundEffect.win: 'win',
      SoundEffect.coins: 'coins',
      SoundEffect.unlockGlass: 'unlock_glass',
      SoundEffect.iceCrack: 'ice_crack',
      SoundEffect.iceShatter: 'ice_shatter',
      SoundEffect.button: 'button',
      // m7-3 (phase 4 architecture §3.11).
      SoundEffect.star1: 'star_1',
      SoundEffect.star2: 'star_2',
      SoundEffect.star3: 'star_3',
      SoundEffect.chestWiggle: 'chest_wiggle',
      SoundEffect.chestOpen: 'chest_open',
      SoundEffect.rivalComplete: 'rival_complete',
      // m7-5: the daily gift's Claim (AUDIO.md "SFX m7-5").
      SoundEffect.giftClaim: 'gift_claim',
    });
  });

  test('the clack is a random one of clack_1..3', () {
    final seen = {
      for (var i = 0; i < 3; i++)
        SfxMix.fileFor(SoundEffect.clack, randomIndex: (count) => i),
    };
    expect(seen, {'clack_1', 'clack_2', 'clack_3'});
    // An out-of-range pick can't index past the list.
    expect(
      SfxMix.fileFor(SoundEffect.clack, randomIndex: (count) => 99),
      'clack_3',
    );
  });

  test('complete plays complete_{comboStep}, clamped to 1–5', () {
    for (var step = 1; step <= 5; step++) {
      expect(
        SfxMix.fileFor(
          SoundEffect.complete,
          randomIndex: first,
          comboStep: step,
        ),
        'complete_$step',
      );
    }
    expect(
      SfxMix.fileFor(SoundEffect.complete, randomIndex: first, comboStep: 9),
      'complete_5',
    );
    expect(
      SfxMix.fileFor(SoundEffect.complete, randomIndex: first, comboStep: 0),
      'complete_1',
    );
  });

  test('the clack rate is 2^(−2(size − 3.5)/12): the v2 clacks are baked at '
      'size 3.5, 0 semitones (AUDIO.md "SFX v2")', () {
    expect(SoundTokens.clackBakedSemitones, 0);
    for (var size = 1; size <= 6; size++) {
      expect(
        SfxMix.speedFor(SoundEffect.clack, dollSize: size),
        closeTo(math.pow(2, -2 * (size - 3.5) / 12), 1e-12),
        reason: 'size $size',
      );
      // Same thing through the tokens' semitone table.
      expect(
        SfxMix.speedFor(SoundEffect.clack, dollSize: size),
        closeTo(
          math.pow(
            2,
            (SoundTokens.clackSemitonesBySize[size]! -
                    SoundTokens.clackBakedSemitones) /
                12,
          ),
          1e-12,
        ),
      );
    }
    // Size 1 is +5 semitones, size 6 −5.
    expect(
      SfxMix.speedFor(SoundEffect.clack, dollSize: 1),
      closeTo(math.pow(2, 5 / 12), 1e-12),
    );
    expect(
      SfxMix.speedFor(SoundEffect.clack, dollSize: 6),
      closeTo(math.pow(2, -5 / 12), 1e-12),
    );
    // Bigger dolls are lower.
    expect(
      SfxMix.speedFor(SoundEffect.clack, dollSize: 6),
      lessThan(SfxMix.speedFor(SoundEffect.clack, dollSize: 1)),
    );
    // Missing: size 3, one semitone up; out of range: clamped.
    expect(
      SfxMix.speedFor(SoundEffect.clack),
      closeTo(math.pow(2, 1 / 12), 1e-12),
    );
    expect(
      SfxMix.speedFor(SoundEffect.clack, dollSize: 9),
      SfxMix.speedFor(SoundEffect.clack, dollSize: 6),
    );
    // Only the clack is pitched.
    expect(SfxMix.speedFor(SoundEffect.whoosh, dollSize: 1), 1);
  });

  test('the mix plays every file at sfxDefault 0.8 × its gain', () {
    expect(SfxMix.gains.keys.toSet(), {
      ...SoundTokens.allFiles,
      ...SoundTokens.jingleFiles,
    });
    for (final file in SoundTokens.allFiles) {
      expect(
        SfxMix.volumeOf(file),
        SoundTokens.sfxVolumeDefault * SfxMix.gains[file]!,
      );
    }
    expect(SfxMix.volumeOf('unknown'), SoundTokens.sfxVolumeDefault);
    expect(SfxMix.assetPath('pick'), 'assets/audio/pick.wav');
  });

  test('each jingle plays its tokens.json sound.events file, an OGG', () {
    expect(
      {for (final j in Jingle.values) j: SfxMix.jingleFileOf(j)},
      {
        Jingle.chapter: 'jingle_chapter',
        Jingle.reward: 'jingle_reward',
        Jingle.outOfMoves: 'jingle_oom',
        Jingle.versusWin: 'jingle_versus_win',
        Jingle.versusLose: 'jingle_versus_lose',
      },
    );
    expect({
      for (final j in Jingle.values) SfxMix.jingleFileOf(j),
    }, SoundTokens.jingleFiles.toSet());
    expect(SfxMix.jingleAssetPath('jingle_oom'), 'assets/audio/jingle_oom.ogg');
  });

  test('the jingles are on the SFX bus (tokens.json sound.mix.jingleBus)', () {
    // A `music` bus would need the music service to play them, under the
    // Music toggle and volume: pinned so a token change can't go unheard.
    expect(SfxMix.jingleBus, 'sfx');
    for (final file in SoundTokens.jingleFiles) {
      expect(
        SfxMix.jingleVolumeOf(file),
        SoundTokens.sfxVolumeDefault * SfxMix.gains[file]!,
      );
    }
  });
}
