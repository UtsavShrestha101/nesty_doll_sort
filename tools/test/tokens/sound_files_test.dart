import 'dart:convert';
import 'dart:io';

import 'package:nesty_tools/src/repo_root.dart';
import 'package:nesty_tools/src/tokens/design_tokens_codegen.dart';
import 'package:nesty_tools/src/tokens/sound_files.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('parseSoundEvent (tokens.json `sound.events`)', () {
    test('a single file, a random pick and a combo step', () {
      final single = parseSoundEvent('jingle_oom', maxSteps: 5)!;
      expect(single.files, ['jingle_oom']);
      expect(single.pick, SoundEventPick.single);

      final random = parseSoundEvent(
        'clack_1|clack_2|clack_3 (random)',
        maxSteps: 5,
      )!;
      expect(random.files, ['clack_1', 'clack_2', 'clack_3']);
      expect(random.pick, SoundEventPick.random);

      final combo = parseSoundEvent('complete_{comboStep}', maxSteps: 3)!;
      expect(combo.files, ['complete_1', 'complete_2', 'complete_3']);
      expect(combo.pick, SoundEventPick.comboStep);
    });

    test('anything else is null', () {
      for (final value in [
        'Pick',
        'pick.wav',
        'clack_1|clack_2',
        'clack_1 | clack_2 (random)',
        'complete_{step}',
        '',
      ]) {
        expect(parseSoundEvent(value, maxSteps: 5), isNull, reason: value);
      }
    });

    test('jingles are the jingle_* files', () {
      expect(isJingleFile('jingle_chapter'), isTrue);
      expect(isJingleFile('complete_1'), isFalse);
      expect(isJingleFile('music_home'), isFalse);
    });
  });

  group('soundFilesOf', () {
    test('design/tokens.json: 17 SFX, 3 jingles, 2 loops with frames', () {
      final json =
          jsonDecode(
                File(
                  p.join(findRepoRoot().path, tokensJsonPath),
                ).readAsStringSync(),
              )
              as Map<String, Object?>;
      final files = soundFilesOf(json)!;
      expect(files.sfx, hasLength(17));
      expect(files.sfx, containsAll(['pick', 'clack_3', 'complete_5']));
      expect(files.sfx.where(isJingleFile), isEmpty);
      expect(files.jingles, ['jingle_chapter', 'jingle_oom', 'jingle_reward']);
      expect(files.musicFrames, {'music_game': 3024000, 'music_home': 2940000});
    });

    test('null without a sound section; loud on a bad shape', () {
      expect(soundFilesOf(const {'dollColor': <String, Object?>{}}), isNull);
      final combo = {
        'motion': {
          'combo': {'maxSteps': 2},
        },
      };
      expect(
        () => soundFilesOf({
          ...combo,
          'sound': {
            'events': {'pick': 'Pick!'},
          },
        }),
        throwsFormatException,
      );
      expect(
        () => soundFilesOf({
          ...combo,
          'sound': {
            'events': <String, Object?>{},
            'music': {
              'home': {'file': 'music_home'},
            },
          },
        }),
        throwsFormatException,
      );
      expect(
        () => soundFilesOf(const {
          'sound': {'events': <String, Object?>{}},
        }),
        throwsFormatException,
        reason: 'motion.combo.maxSteps is needed for combo cues',
      );
    });
  });
}
