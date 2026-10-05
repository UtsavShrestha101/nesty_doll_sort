import 'dart:convert';
import 'dart:io';

import 'package:nesty_tools/src/fx/lottie_contract.dart';
import 'package:nesty_tools/src/fx/lottie_validation.dart';
import 'package:path/path.dart' as p;

final _jsonName = RegExp(r'^[a-z0-9_]+\.json$');

/// One export of [designLottieDir], read and parsed.
final class LottieSource {
  LottieSource({
    required this.contract,
    required this.path,
    required this.bytes,
    required this.json,
  });

  final LottieFileContract contract;

  /// Repo-relative, e.g. `design/lottie/doll_pick.json`.
  final String path;

  /// The file exactly as exported: it ships byte for byte.
  final List<int> bytes;

  /// The parsed root; null when the file is not a JSON object.
  final Map<String, Object?>? json;

  String get name => contract.name;
}

/// Every export in [contract] order, plus what is wrong with them.
final class LottieSourceSet {
  LottieSourceSet(this.sources, this.issues);

  /// One per contract entry that has a file.
  final List<LottieSource> sources;

  /// `<path>: <issue>`. Non-empty → neither the sync nor the codegen writes.
  final List<String> issues;
}

/// Reads `design/lottie/*.json` under [repoRoot] and validates each against
/// [contracts] (default: [lottieContracts]).
///
/// [lottieContractDoc] and the [lottiePlaceholderDir] folder are expected
/// and skipped; any other file, a JSON with no contract entry and a
/// contract entry with no JSON are issues.
LottieSourceSet readDesignLottie(
  Directory repoRoot, {
  List<LottieFileContract> contracts = lottieContracts,
}) {
  final dir = Directory(p.join(repoRoot.path, designLottieDir));
  final issues = <String>[];
  if (!dir.existsSync()) {
    return LottieSourceSet(const [], ['$designLottieDir: missing']);
  }
  final files = <String, File>{};
  final entries = dir.listSync().toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final entry in entries) {
    final name = p.basename(entry.path);
    if (name.startsWith('.')) continue;
    if (entry is Directory) {
      if (name != lottiePlaceholderDir) {
        issues.add('$designLottieDir/$name: unexpected folder');
      } else {
        issues.addAll(_checkPlaceholders(entry));
      }
      continue;
    }
    if (entry is! File || name == lottieContractDoc) continue;
    if (!_jsonName.hasMatch(name)) {
      issues.add('$designLottieDir/$name: unexpected file in $designLottieDir');
      continue;
    }
    final id = p.basenameWithoutExtension(name);
    if (lottieContractOf(id, contracts) == null) {
      issues.add(
        '$designLottieDir/$name: no contract entry; add it to '
        'tools/lib/src/fx/lottie_contract.dart (and FxId) first',
      );
      continue;
    }
    files[id] = entry;
  }

  final sources = <LottieSource>[];
  for (final contract in contracts) {
    final path = '$designLottieDir/${contract.name}.json';
    final file = files[contract.name];
    if (file == null) {
      issues.add('$path: missing (LOTTIE.md "Files")');
      continue;
    }
    final bytes = file.readAsBytesSync();
    Map<String, Object?>? json;
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is Map<String, Object?>) json = decoded;
    } on FormatException catch (e) {
      issues.add('$path: ${LottieIssueCodes.notJson}: ${e.message}');
      sources.add(
        LottieSource(contract: contract, path: path, bytes: bytes, json: null),
      );
      continue;
    }
    for (final issue in validateLottie(json, contract)) {
      issues.add('$path: $issue');
    }
    sources.add(
      LottieSource(contract: contract, path: path, bytes: bytes, json: json),
    );
  }
  return LottieSourceSet(sources, issues);
}

/// The placeholder PNGs never ship (PROGRESS D50), but each is named after
/// the image slot it stands in for (`<slot id>.png`), so a new placeholder
/// with no slot (m7-4's `figurine`, `rival_portrait` before their slots)
/// is noticed.
List<String> _checkPlaceholders(Directory images) {
  final issues = <String>[];
  final files = images.listSync().whereType<File>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    final name = p.basename(file.path);
    if (name.startsWith('.')) continue;
    final at = '$designLottieDir/$lottiePlaceholderDir/$name';
    if (p.extension(name) != '.png') {
      issues.add('$at: unexpected file (placeholders are PNGs)');
    } else if (lottieImageSlotOf(p.basenameWithoutExtension(name)) == null) {
      issues.add(
        '$at: no image slot "${p.basenameWithoutExtension(name)}" (LOTTIE.md '
        '"Image slots"); add it to tools/lib/src/fx/lottie_contract.dart',
      );
    }
  }
  return issues;
}
