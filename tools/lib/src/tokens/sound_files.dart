/// The audio files tokens.json's `sound` section names (spec §11.3,
/// `design/audio/AUDIO.md`). Shared by the token codegen, which emits them
/// as `SoundTokens`, and the asset sync, which checks that each one ships in
/// its format.
library;

/// The sample rate of every file (tokens.json `sound.format`, AUDIO.md
/// "Files"). Loop lengths are counted in frames at this rate.
const soundSampleRate = 44100;

/// Jingles are the OGG one-shots (AUDIO.md "Jingles"); every other
/// `sound.events` file is a WAV SFX.
const jingleFilePrefix = 'jingle_';

/// Whether the `sound.events` file [name] is a jingle.
bool isJingleFile(String name) => name.startsWith(jingleFilePrefix);

/// How a `sound.events` value picks its file; mirrors the game's
/// `SoundPick`.
enum SoundEventPick { single, random, comboStep }

/// The files behind one `sound.events` value.
final class SoundEvent {
  const SoundEvent(this.files, this.pick);

  /// Base names, without extension.
  final List<String> files;
  final SoundEventPick pick;
}

final _name = RegExp(r'^[a-z0-9_]+$');
final _random = RegExp(r'^([a-z0-9_]+(?:\|[a-z0-9_]+)+) \(random\)$');
final _combo = RegExp(r'^([a-z0-9_]+)_\{comboStep\}$');

/// Parses one `sound.events` value: a single file (`pick`), a random pick
/// (`clack_1|clack_2|clack_3 (random)`) or one file per combo step
/// (`complete_{comboStep}` → `complete_1` … `complete_<maxSteps>`). Returns
/// null for any other wording.
SoundEvent? parseSoundEvent(String value, {required int maxSteps}) {
  if (_name.hasMatch(value)) return SoundEvent([value], SoundEventPick.single);
  if (_random.firstMatch(value) case final m?) {
    return SoundEvent(m[1]!.split('|'), SoundEventPick.random);
  }
  if (_combo.firstMatch(value) case final m?) {
    return SoundEvent([
      for (var i = 1; i <= maxSteps; i++) '${m[1]}_$i',
    ], SoundEventPick.comboStep);
  }
  return null;
}

/// Every audio file tokens.json names, by format.
final class SoundFiles {
  const SoundFiles({
    required this.sfx,
    required this.jingles,
    required this.musicFrames,
  });

  /// The SFX of `sound.events` (WAV, 44.1 kHz mono 16-bit), sorted.
  final List<String> sfx;

  /// The jingles of `sound.events` (OGG, 44.1 kHz stereo), sorted.
  final List<String> jingles;

  /// Each `sound.music.<key>.file` (OGG loop, 44.1 kHz stereo) → its length
  /// in frames (`sound.music.<key>.frames`).
  final Map<String, int> musicFrames;
}

/// The files the `sound` section of the decoded tokens.json [tokens] names.
/// Null when there is no `sound` section. Throws a [FormatException] naming
/// the path for a value of an unexpected shape (the token codegen rejects it
/// too).
SoundFiles? soundFilesOf(Map<String, Object?> tokens) {
  Map<String, Object?> object(Object? node, String path) {
    if (node is Map<String, Object?>) return node;
    throw FormatException('tokens.json `$path`: expected an object');
  }

  if (tokens['sound'] == null) return null;
  final sound = object(tokens['sound'], 'sound');

  final motion = tokens['motion'];
  final combo = motion is Map<String, Object?> ? motion['combo'] : null;
  final maxSteps = combo is Map<String, Object?> ? combo['maxSteps'] : null;
  if (maxSteps is! int) {
    throw const FormatException(
      'tokens.json `motion.combo.maxSteps`: expected an integer',
    );
  }
  final sfx = <String>{};
  final jingles = <String>{};
  final events = object(sound['events'], 'sound.events');
  for (final MapEntry(:key, :value) in events.entries) {
    final event = value is String
        ? parseSoundEvent(value, maxSteps: maxSteps)
        : null;
    if (event == null) {
      throw FormatException('tokens.json `sound.events.$key`: "$value"');
    }
    for (final file in event.files) {
      (isJingleFile(file) ? jingles : sfx).add(file);
    }
  }
  final musicFrames = <String, int>{};
  final music = sound['music'];
  if (music != null) {
    for (final MapEntry(:key, :value) in object(music, 'sound.music').entries) {
      final track = object(value, 'sound.music.$key');
      final file = track['file'];
      final frames = track['frames'];
      if (file is! String || !_name.hasMatch(file) || frames is! int) {
        throw FormatException(
          'tokens.json `sound.music.$key`: needs a file name and frames',
        );
      }
      musicFrames[file] = frames;
    }
  }
  return SoundFiles(
    sfx: sfx.toList()..sort(),
    jingles: jingles.toList()..sort(),
    musicFrames: Map.fromEntries(
      musicFrames.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    ),
  );
}
