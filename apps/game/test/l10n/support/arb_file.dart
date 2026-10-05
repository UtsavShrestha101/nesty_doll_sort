import 'dart:convert';
import 'dart:io';

import 'icu.dart';

/// Where the l10n checkers read the ARBs: the app's `lib/l10n` (run from
/// `apps/game`), or another directory with
/// `--dart-define=NESTY_L10N_ARB_DIR=<dir>`, which is how the checkers are
/// shown failing on a bad synthetic catalog without touching `lib/l10n`
/// (every app build regenerates l10n from it).
const arbDirectory = String.fromEnvironment(
  'NESTY_L10N_ARB_DIR',
  defaultValue: 'lib/l10n',
);

/// 5B-5's switch (l10n.md §5.4, §8.2): false while the translations are
/// written, so the parity checks run only for the locales whose ARB exists;
/// the integrator sets it to true once all nine are in, and from then on a
/// missing locale, or a `supportedLocales` out of step with the files,
/// fails.
const requireAllLaunchLocales = true;

/// One `app_<code>.arb`.
final class ArbFile {
  ArbFile(this.code, this.json, {this.path});

  /// Reads [file]; its code comes from the name (`app_pt_BR.arb` → `pt_BR`).
  factory ArbFile.read(File file) {
    final name = file.uri.pathSegments.last;
    final match = _name.firstMatch(name);
    if (match == null) throw ArgumentError('not an app_<code>.arb: $name');
    return ArbFile(
      match.group(1)!,
      jsonDecode(file.readAsStringSync()) as Map<String, Object?>,
      path: file.path,
    );
  }

  static final _name = RegExp(r'^app_([A-Za-z_]+)\.arb$');

  final String code;
  final Map<String, Object?> json;
  final String? path;

  /// `@@locale`, if the file has one.
  String? get localeTag => json['@@locale'] as String?;

  /// The message keys (no `@` entries).
  Iterable<String> get keys => json.keys.where((key) => !key.startsWith('@'));

  /// Every `@key` entry except `@@locale` (a non-template file has none).
  Iterable<String> get metadataKeys =>
      json.keys.where((key) => key.startsWith('@') && key != '@@locale');

  String? operator [](String key) => switch (json[key]) {
    final String value => value,
    _ => null,
  };

  final Map<String, List<IcuNode>> _parsed = {};

  /// [key]'s parsed message. Throws [IcuFormatException].
  List<IcuNode> parse(String key) =>
      _parsed.putIfAbsent(key, () => parseIcu(this[key]!));

  /// The locale name gen-l10n gives this file (`pt_BR`, `fr`).
  String get localeName => code;
}

/// Every `app_*.arb` in [directory], English first, then by code.
List<ArbFile> readArbFiles([String directory = arbDirectory]) {
  final files = [
    for (final entity in Directory(directory).listSync())
      if (entity is File &&
          RegExp(r'app_[A-Za-z_]+\.arb$').hasMatch(entity.path))
        ArbFile.read(entity),
  ];
  files.sort((a, b) {
    if (a.code == 'en') return -1;
    if (b.code == 'en') return 1;
    return a.code.compareTo(b.code);
  });
  return files;
}

/// The template, `app_en.arb`.
ArbFile readEnglishArb([String directory = arbDirectory]) =>
    ArbFile.read(File('$directory/app_en.arb'));
