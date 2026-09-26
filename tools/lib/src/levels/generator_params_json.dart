import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_tools/src/levels/finding.dart';
import 'package:nesty_tools/src/levels/json_fields.dart';

/// Makes the params for one seed of a `generate` batch.
typedef ParamsForSeed = GeneratorParams Function(int seed);

/// `GeneratorParams`' defaults for the optional keys, read from the class
/// itself so they are never restated here.
const GeneratorParams _defaults = GeneratorParams(
  colors: 1,
  maxSize: 3,
  shelves: 1,
  slotsPerShelf: 2,
  emptySlots: 0,
  targetTier: Tier.easy,
  seed: 0,
);

/// Reads the `--params` JSON of `nesty_levels generate`: the spec §6.5
/// params by their `GeneratorParams` names, `targetTier` as a tier id.
/// `colors`, `maxSize`, `shelves`, `slotsPerShelf`, `emptySlots` and
/// `targetTier` are required; `setsPerColor`, `towers`, `towerDepth`,
/// `locked` and `iceSlots` default as in `GeneratorParams`. The seed comes
/// from `--seed`, and the generator names the level, so `seed` and `id` are
/// rejected. Only the types are checked here: which values can make a level
/// is `Generator.checkParams`' call (CLAUDE.md rule 2).
({ParamsForSeed? params, List<Finding> findings}) parseGeneratorParams(
  Object? json, {
  required String subject,
}) {
  final fields = JsonFields(subject: subject, codePrefix: 'params');
  final map = fields.object(json, const [], 'params');
  if (map == null) return (params: null, findings: fields.findings);

  int? required(String key) => fields.integer(map, key, const []);
  int optional(String key, int fallback) =>
      fields.integer(map, key, const [], optional: true) ?? fallback;

  final colors = required('colors');
  final setsPerColor = optional('setsPerColor', _defaults.setsPerColor);
  final maxSize = required('maxSize');
  final shelves = required('shelves');
  final slotsPerShelf = required('slotsPerShelf');
  final towers = optional('towers', _defaults.towers);
  final towerDepth = optional('towerDepth', _defaults.towerDepth);
  final emptySlots = required('emptySlots');
  final locked = optional('locked', _defaults.locked);
  final iceSlots = optional('iceSlots', _defaults.iceSlots);
  final tierId = fields.string(map, 'targetTier', const []);
  Tier? targetTier;
  if (tierId != null) {
    targetTier = Tier.tryFromId(tierId);
    if (targetTier == null) {
      fields.add(
        FindingCodes.paramsUnknownTier,
        'Unknown tier "$tierId" (expected one of '
        '${Tier.values.map((t) => t.id).join(', ')})',
        const ['targetTier'],
      );
    }
  }
  fields.rejectUnknown(map, const {
    'colors',
    'setsPerColor',
    'maxSize',
    'shelves',
    'slotsPerShelf',
    'towers',
    'towerDepth',
    'emptySlots',
    'locked',
    'iceSlots',
    'targetTier',
  }, const []);

  if (fields.errorCount > 0 ||
      colors == null ||
      maxSize == null ||
      shelves == null ||
      slotsPerShelf == null ||
      emptySlots == null ||
      targetTier == null) {
    return (params: null, findings: fields.findings);
  }
  final tier = targetTier;
  return (
    params: (seed) => GeneratorParams(
      colors: colors,
      setsPerColor: setsPerColor,
      maxSize: maxSize,
      shelves: shelves,
      slotsPerShelf: slotsPerShelf,
      towers: towers,
      towerDepth: towerDepth,
      emptySlots: emptySlots,
      locked: locked,
      iceSlots: iceSlots,
      targetTier: tier,
      seed: seed,
    ),
    findings: fields.findings,
  );
}

/// [Finding]s for a failed generation, about [subject] (the level id or
/// seed).
List<Finding> generatorFailureFindings(
  GeneratorFailure failure,
  String subject,
) => [
  for (final issue in failure.issues)
    Finding.fromIssue(issue, subject: subject),
  if (failure.issues.isEmpty)
    Finding(
      FindingCodes.generatorFailed,
      'No level after ${failure.attempts} attempts',
      subject: subject,
    ),
];
