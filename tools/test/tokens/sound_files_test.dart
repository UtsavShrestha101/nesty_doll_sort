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

    test('no sound: none, with or without a note (tokens v4)', () {
      for (final value in ['none', 'none (no sound, no haptic)']) {
        final event = parseSoundEvent(value, maxSteps: 5)!;
        expect(event.files, isEmpty, reason: value);
        expect(event.pick, SoundEventPick.single, reason: value);
      }
      // A file whose name starts with "none" is still a file.
      expect(parseSoundEvent('nonesuch', maxSteps: 5)!.files, ['nonesuch']);
      expect(parseSoundEvent('none (unclosed', maxSteps: 5), isNull);
      expect(parseSoundEvent('none, quiet', maxSteps: 5), isNull);
    });

    test('a single file with a note on where it plays (tokens v6)', () {
      for (final (value, file, note) in [
        (
          'button (the welcome card, its close, a month day, Play again)',
          'button',
          'the welcome card, its close, a month day, Play again',
        ),
        (
          'win @0, no coins (the past-day win, 14.3d)',
          'win',
          'no coins; the past-day win, 14.3d',
        ),
        ('win @0', 'win', null),
      ]) {
        final event = parseSoundEvent(value, maxSteps: 5)!;
        expect(event.files, [file], reason: value);
        expect(event.pick, SoundEventPick.single, reason: value);
        expect(event.note, note, reason: value);
      }
      expect(parseSoundEvent('pick', maxSteps: 5)!.note, isNull);
    });

    test('anything else is null', () {
      for (final value in [
        'Pick',
        'pick.wav',
        'clack_1|clack_2',
        'clack_1 | clack_2 (random)',
        'complete_{step}',
        '',
        // Tokens v6's notes: only `@0`, one note, and never `(random)` on a
        // single file.
        'win @200',
        'button (random)',
        'button (one) (two)',
        'button, (x)',
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
    test('design/tokens.json: 24 SFX, 5 jingles, 2 loops with frames', () {
      final json =
          jsonDecode(
                File(
                  p.join(findRepoRoot().path, tokensJsonPath),
                ).readAsStringSync(),
              )
              as Map<String, Object?>;
      final files = soundFilesOf(json)!;
      expect(files.sfx, hasLength(24));
      expect(
        files.sfx,
        containsAll([
          'pick',
          'clack_3',
          'complete_5',
          // m7-3: the stars, the chest and the race's rival.
          'star_1',
          'star_2',
          'star_3',
          'chest_wiggle',
          'chest_open',
          'rival_complete',
          // m7-5: the daily gift's claim (AUDIO.md "SFX m7-5").
          'gift_claim',
        ]),
      );
      expect(files.sfx.where(isJingleFile), isEmpty);
      expect(files.jingles, [
        'jingle_chapter',
        'jingle_oom',
        'jingle_reward',
        'jingle_versus_lose',
        'jingle_versus_win',
      ]);
      expect(files.musicFrames, {'music_game': 3024000, 'music_home': 2940000});
    });

    test('a none event names no file (tokens v4 reminderSet)', () {
      final files = soundFilesOf({
        'motion': {
          'combo': {'maxSteps': 2},
        },
        'sound': {
          'events': {
            'pick': 'pick',
            'reminderSet': 'none (no sound, no haptic)',
          },
        },
      })!;
      expect(files.sfx, ['pick']);
      expect(files.jingles, isEmpty);
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

    test('every SFX row of AUDIO.md\'s m7 sections is a tokens SFX', () {
      final root = findRepoRoot().path;
      final json =
          jsonDecode(File(p.join(root, tokensJsonPath)).readAsStringSync())
              as Map<String, Object?>;
      final sfx = soundFilesOf(json)!.sfx;
      final audio = File(
        p.join(root, 'design/audio/AUDIO.md'),
      ).readAsStringSync();
      final rows = <String>[];
      for (final section in audio.split('\n## ').skip(1)) {
        if (!section.startsWith('SFX m7')) continue;
        for (final m in RegExp(
          r'^\| `([a-z0-9_]+)` \|',
          multiLine: true,
        ).allMatches(section)) {
          rows.add(m[1]!);
        }
      }
      // m7-2's stars, chest and rival; m7-5's gift claim.
      expect(rows, contains('gift_claim'));
      expect(rows, hasLength(7));
      expect(sfx, containsAll(rows));
      expect(
        (json['sound']! as Map<String, Object?>)['events'],
        containsPair('giftClaim', 'gift_claim'),
      );
    });

    test('the local habits play AUDIO.md\'s sounds, and no new one (m7-6)', () {
      final root = findRepoRoot().path;
      final json =
          jsonDecode(File(p.join(root, tokensJsonPath)).readAsStringSync())
              as Map<String, Object?>;
      final events =
          (json['sound']! as Map<String, Object?>)['events']!
              as Map<String, Object?>;
      String fileOf(String key) =>
          parseSoundEvent(events[key]! as String, maxSteps: 5)!.files.single;
      final audio = File(
        p.join(root, 'design/audio/AUDIO.md'),
      ).readAsStringSync();
      final section = audio
          .split('\n## ')
          .firstWhere((s) => s.startsWith('Local habits'));
      expect(section, contains('No new sound'));
      final named = {
        for (final m in RegExp(
          r'^\|[^|]+\| `([a-z0-9_]+)`',
          multiLine: true,
        ).allMatches(section))
          m[1]!,
      };
      expect(named, {'button', 'win'});
      expect({fileOf('habitsTap'), fileOf('habitsPastWin')}, named);
      // Each is an existing event's file: the set covers every habit.
      expect(events['button'], 'button');
      expect(events['win'], 'win');
    });
  });
}
