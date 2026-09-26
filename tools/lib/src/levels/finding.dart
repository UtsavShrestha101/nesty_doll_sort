import 'package:nesty_core/nesty_core.dart';

/// How bad a [Finding] is. Only errors fail a command.
enum FindingSeverity { error, warning }

/// One problem the level tools found: in the manifest, an authored file, the
/// bundle, or a level's rules, tier or schedule.
///
/// Core issues ([LevelIssue]) keep their code (`doll.badToken`, …); the
/// tools' own checks use the codes in [FindingCodes].
final class Finding {
  const Finding(
    this.code,
    this.message, {
    this.subject = '',
    this.path = '',
    this.severity = FindingSeverity.error,
  });

  /// A core [LevelIssue] about [subject], with its JSON pointer moved under
  /// [pathPrefix] (the issue's path is relative to the level).
  factory Finding.fromIssue(
    LevelIssue issue, {
    required String subject,
    String pathPrefix = '',
  }) => Finding(
    issue.code,
    issue.message,
    subject: subject,
    path: '$pathPrefix${issue.path}',
    severity: issue.isError ? FindingSeverity.error : FindingSeverity.warning,
  );

  /// A [FindingCodes] value, or a core `IssueCodes` value.
  final String code;

  /// What it is about: a file (`tools/levels/manifest.json`) or a level
  /// (`L0003`).
  final String subject;

  /// A JSON pointer into [subject], or `''`.
  final String path;

  final String message;

  final FindingSeverity severity;

  bool get isError => severity == FindingSeverity.error;

  @override
  String toString() {
    final where = [
      if (subject.isNotEmpty) subject,
      if (path.isNotEmpty) path,
    ].join(' ');
    return '${severity.name} ${where.isEmpty ? '' : '$where: '}$code: $message';
  }
}

/// The level tools' own finding codes (core issues keep their `IssueCodes`).
abstract final class FindingCodes {
  // --- Input files ---
  static const unreadable = 'input.unreadable';
  static const invalidJson = 'input.invalidJson';

  // --- tools/levels/manifest.json ---
  static const manifestWrongType = 'manifest.wrongType';
  static const manifestMissingField = 'manifest.missingField';
  static const manifestUnknownField = 'manifest.unknownField';
  static const manifestBadFormat = 'manifest.badFormat';
  static const manifestUnsupportedVersion = 'manifest.unsupportedVersion';
  static const manifestValueOutOfRange = 'manifest.valueOutOfRange';
  static const manifestUnknownTier = 'manifest.unknownTier';
  static const manifestBadId = 'manifest.badId';
  static const manifestDuplicateId = 'manifest.duplicateId';
  static const manifestOrderSequence = 'manifest.orderSequence';
  static const manifestEmptyText = 'manifest.emptyText';

  // --- Building the bundle from the manifest ---
  static const missingLevelFile = 'build.missingLevelFile';
  static const strayLevelFile = 'build.strayLevelFile';
  static const idMismatch = 'build.idMismatch';
  static const versionNotBumped = 'build.versionNotBumped';

  // --- bundle check ---
  static const bundleMissing = 'bundle.missing';
  static const bundleDrift = 'bundle.drift';

  // --- Tier (spec §6.4, design A32) ---
  static const tierMismatch = 'tier.mismatch';
  static const tierOverrideNotTutorial = 'tier.overrideNotTutorial';
  static const tierOverrideUnneeded = 'tier.overrideUnneeded';
  static const expertOnly = 'tier.expertOnly';

  // --- Bundle policy (spec §3.7, §6.6, §7.1, M2 layout) ---
  static const pattern = 'policy.pattern';
  static const chapter = 'policy.chapter';
  static const scheduleMaxSize = 'policy.schedule.maxSize';
  static const scheduleColors = 'policy.schedule.colors';
  static const scheduleTowers = 'policy.schedule.towers';
  static const scheduleLocked = 'policy.schedule.locked';
  static const scheduleIce = 'policy.schedule.ice';
  static const layoutShelves = 'policy.layout.shelves';
  static const layoutRowSlots = 'policy.layout.rowSlots';

  // --- fixtures check ---
  static const fixtureNotCanonical = 'fixture.notCanonical';
  static const fixtureDuplicateId = 'fixture.duplicateId';
  static const fixtureVerdict = 'fixture.verdict';
  static const fixtureMoves = 'fixture.moves';
  static const fixtureNoExpectation = 'fixture.noExpectation';
  static const fixtureMissingFile = 'fixture.missingFile';
  static const fixtureExpectationsUnreadable = 'fixture.expectationsUnreadable';

  // --- generate: `--params` JSON (`params.wrongType`, `.missingField`,
  // `.unknownField`, `.valueOutOfRange` come from JsonFields) ---
  static const paramsUnknownTier = 'params.unknownTier';
  static const generatorFailed = 'gen.failed';
}
