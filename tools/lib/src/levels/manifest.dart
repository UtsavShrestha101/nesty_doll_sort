import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_tools/src/levels/finding.dart';
import 'package:nesty_tools/src/levels/json_fields.dart';

/// One authored level in `tools/levels/manifest.json` (tools/levels/README.md).
final class ManifestEntry {
  const ManifestEntry({
    required this.order,
    required this.id,
    required this.chapterId,
    required this.tier,
    required this.version,
    this.tierOverride,
    this.notes,
  });

  /// Play order, 1-based; equal to the entry's position in the manifest.
  final int order;

  /// The level id; the level is `authored/<id>.json` next to the manifest.
  final String id;

  final String chapterId;

  /// The declared tier. `bundle check` requires it to follow the §6.6
  /// pattern and to equal the simulated tier (design A32).
  final Tier tier;

  /// The level's edit version (spec §5.2). Bump it whenever the level's
  /// board changes, so a saved game of the old board is not restored
  /// (spec §13.3); `bundle build` refuses a changed board at the same
  /// version.
  final int version;

  /// Why the declared [tier] stands although the simulator suggests another
  /// one. Only the tutorials may have one (design §4).
  final String? tierOverride;

  /// Free text for authors. Not copied into the bundle.
  final String? notes;
}

/// `tools/levels/manifest.json`: the authored levels, in play order, with
/// what the bundle needs besides the board (design §4).
final class LevelManifest {
  LevelManifest({
    required this.levelsVersion,
    required List<ManifestEntry> levels,
  }) : levels = List.unmodifiable(levels);

  /// The `format` marker, so the tools tell a manifest from a bundle or a
  /// level.
  static const String format = 'nesty.levels.manifest';

  /// The manifest version these tools read.
  static const int currentManifestVersion = 1;

  /// The bundle's `levelsVersion` (spec §13.4).
  final int levelsVersion;

  final List<ManifestEntry> levels;
}

/// What [parseManifest] produced: a manifest when there was no error.
typedef ManifestParse = ({LevelManifest? manifest, List<Finding> findings});

/// Level ids become file names (`authored/<id>.json`), so they are limited
/// to letters, digits, `_` and `-`, at most 64 characters (design A21).
final RegExp manifestIdPattern = RegExp(r'^[A-Za-z0-9_-]{1,64}$');

/// Reads a parsed manifest strictly (tools/levels/README.md has the schema).
/// [subject] names the file in findings.
ManifestParse parseManifest(Object? json, {required String subject}) {
  final fields = JsonFields(subject: subject, codePrefix: 'manifest');
  final root = fields.object(json, const [], 'manifest');
  if (root == null) return (manifest: null, findings: fields.findings);

  final format = fields.string(root, 'format', const []);
  if (format != null && format != LevelManifest.format) {
    fields.add(
      FindingCodes.manifestBadFormat,
      'format is "$format", expected "${LevelManifest.format}"',
      const ['format'],
    );
    return (manifest: null, findings: fields.findings);
  }
  final version = fields.integer(root, 'manifestVersion', const []);
  if (version != null && version != LevelManifest.currentManifestVersion) {
    fields.add(
      FindingCodes.manifestUnsupportedVersion,
      'manifestVersion $version is not supported (these tools read '
      '${LevelManifest.currentManifestVersion})',
      const ['manifestVersion'],
    );
    return (manifest: null, findings: fields.findings);
  }
  final levelsVersion = fields.integer(root, 'levelsVersion', const [], min: 0);
  final levels = _entries(fields, root);
  fields.rejectUnknown(root, const {
    'format',
    'manifestVersion',
    'levelsVersion',
    'levels',
  }, const []);

  if (fields.errorCount > 0 || levelsVersion == null || levels == null) {
    return (manifest: null, findings: fields.findings);
  }
  return (
    manifest: LevelManifest(levelsVersion: levelsVersion, levels: levels),
    findings: fields.findings,
  );
}

const Set<String> _entryKeys = {
  'order',
  'id',
  'chapterId',
  'tier',
  'version',
  'tierOverride',
  'notes',
};

List<ManifestEntry>? _entries(JsonFields fields, Map<Object?, Object?> root) {
  final field = fields.required(root, 'levels', const []);
  if (!field.present) return null;
  final list = fields.array(field.value, const ['levels'], 'levels');
  if (list == null) return null;

  final entries = <ManifestEntry>[];
  final idAt = <String, int>{};
  for (var i = 0; i < list.length; i++) {
    final path = <Object>['levels', i];
    final map = fields.object(list[i], path, 'entry');
    if (map == null) continue;
    final order = fields.integer(map, 'order', path, min: 1);
    final id = fields.string(map, 'id', path);
    final chapterId = fields.string(
      map,
      'chapterId',
      path,
      nonEmpty: true,
      emptyCode: FindingCodes.manifestEmptyText,
    );
    final tierId = fields.string(map, 'tier', path);
    final version = fields.integer(map, 'version', path, min: 1);
    final tierOverride = fields.string(
      map,
      'tierOverride',
      path,
      optional: true,
      nonEmpty: true,
      emptyCode: FindingCodes.manifestEmptyText,
    );
    final notes = fields.string(
      map,
      'notes',
      path,
      optional: true,
      nonEmpty: true,
      emptyCode: FindingCodes.manifestEmptyText,
    );
    fields.rejectUnknown(map, _entryKeys, path);

    // The manifest lists levels in play order, so the order is the position:
    // reordering is always a visible edit of both.
    if (order != null && order != i + 1) {
      fields.add(
        FindingCodes.manifestOrderSequence,
        'Entry ${i + 1} has order $order; list the levels in play order, '
        'numbered 1, 2, 3, …',
        [...path, 'order'],
      );
    }
    if (id != null) {
      if (!manifestIdPattern.hasMatch(id)) {
        fields.add(
          FindingCodes.manifestBadId,
          'Level id "$id" must be 1–64 letters, digits, "_" or "-" (it names '
          'the file authored/$id.json)',
          [...path, 'id'],
        );
      } else if (idAt.containsKey(id)) {
        fields.add(
          FindingCodes.manifestDuplicateId,
          'Level id "$id" is already used by entry ${idAt[id]! + 1}',
          [...path, 'id'],
        );
      } else {
        idAt[id] = i;
      }
    }
    Tier? tier;
    if (tierId != null) {
      tier = Tier.tryFromId(tierId);
      if (tier == null) {
        fields.add(
          FindingCodes.manifestUnknownTier,
          'Unknown tier "$tierId" (expected one of '
          '${Tier.values.map((t) => t.id).join(', ')})',
          [...path, 'tier'],
        );
      }
    }
    if (order != null &&
        id != null &&
        chapterId != null &&
        tier != null &&
        version != null) {
      entries.add(
        ManifestEntry(
          order: order,
          id: id,
          chapterId: chapterId,
          tier: tier,
          version: version,
          tierOverride: tierOverride,
          notes: notes,
        ),
      );
    }
  }
  return entries;
}
