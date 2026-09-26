import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_id.dart';

void main() {
  test('a cue at a frame is at that frame in ms, and shifts onto a batch', () {
    final bonk = FxCue.atFrame(
      10.8,
      sound: SoundEffect.bonk,
      haptic: HapticPattern.invalid,
    );
    expect(bonk.atMs, closeTo(180, 1e-9));

    // The clack of a nest batch: the lid shuts 270 ms into doll_nest, which
    // starts when doll_move (16 f) ends.
    final clack = FxCue.atFrame(
      FxTiming.nestClackFrame,
      sound: SoundEffect.clack,
      haptic: HapticPattern.nest,
      dollSize: 4,
    ).shifted(1000 * 16 / 60);
    expect(clack.atMs, closeTo(536.67, 0.01));
    expect(clack.dollSize, 4);
    expect(clack.sound, SoundEffect.clack);
  });

  test('cues compare by value', () {
    const a = FxCue(atMs: 0, sound: SoundEffect.complete, comboStep: 2);
    const b = FxCue(atMs: 0, sound: SoundEffect.complete, comboStep: 2);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(const FxCue(atMs: 0, sound: SoundEffect.complete)));
  });

  test('the fake library loads nothing and reports done', () async {
    final library = FakeFxLibrary();
    final progress = <double>[];
    expect(library.isLoaded, isFalse);
    await library.load(onProgress: progress.add);
    expect(library.isLoaded, isTrue);
    expect(progress, [1]);
    for (final id in FxId.values) {
      expect(library[id], isNull);
    }
    expect(library.failed, isEmpty);
    expect(library.blank, isNull);
  });
}
