import 'package:nesty_core/src/models/equality.dart';

/// How bad a [LevelIssue] is.
enum IssueSeverity {
  /// The level is invalid: the admin rejects it and the game skips it with a
  /// log entry (spec §5.3).
  error,

  /// Worth showing, but the level is still valid.
  warning,
}

/// One problem found in a level (or in generator params, a bundle or a saved
/// session) by the codec, the validator, the bundle codec, the generator or
/// the session codec (spec §5.3, §13.3).
///
/// Issues are collected, not thrown, so the admin can show every problem at
/// once. [code] and [args] are stable and meant for localized messages in
/// the admin's ARB files (M5); [message] is an English fallback for logs and
/// the CLI.
final class LevelIssue {
  /// [args] is copied into an unmodifiable map.
  LevelIssue({
    required this.code,
    required this.message,
    this.severity = IssueSeverity.error,
    this.path = '',
    this.slotId,
    Map<String, Object> args = const {},
  }) : args = Map.unmodifiable(args);

  /// One of [IssueCodes], such as `nest.notConsecutive`.
  final String code;

  final IssueSeverity severity;

  /// A JSON pointer (RFC 6901) into the input, such as
  /// `/shelves/0/2/stack/1`, or `''` for the whole document. See [pointer].
  final String path;

  /// The slot the issue is about (`r0c2`), when there is one.
  final String? slotId;

  /// Values for the message placeholders, such as `{'color': 'red'}`. Values
  /// are `String`, `int` or `bool`, so they map onto ARB placeholders; the
  /// arguments each code carries are listed on [IssueCodes].
  final Map<String, Object> args;

  /// English description for logs and the CLI.
  final String message;

  /// True for an [IssueSeverity.error].
  bool get isError => severity == IssueSeverity.error;

  /// Builds a JSON pointer (RFC 6901) from path [segments]: `pointer(
  /// ['shelves', 0, 2])` is `/shelves/0/2`. `~` and `/` inside a segment are
  /// escaped as `~0` and `~1`.
  static String pointer(Iterable<Object> segments) => segments
      .map(
        (s) => '/${s.toString().replaceAll('~', '~0').replaceAll('/', '~1')}',
      )
      .join();

  @override
  bool operator ==(Object other) =>
      other is LevelIssue &&
      other.code == code &&
      other.severity == severity &&
      other.path == path &&
      other.slotId == slotId &&
      other.message == message &&
      mapEquals(other.args, args);

  @override
  int get hashCode =>
      Object.hash(code, severity, path, slotId, message, mapHash(args));

  @override
  String toString() {
    final where = [if (path.isNotEmpty) path, ?slotId].join(' ');
    return '${severity.name} $code${where.isEmpty ? '' : ' at $where'}: '
        '$message';
  }
}

/// Every [LevelIssue.code], grouped as in docs/plans/m1-core-design.md §3,
/// then the session codes of docs/plans/m3-design.md §4.
///
/// Codes are stable identifiers: never rename one, because the admin's ARB
/// keys and stored reports refer to them. The list is append-only; a step
/// that needs a new code adds it here, to its group and to [all]. The
/// expected `args` of each code are in its doc comment.
abstract final class IssueCodes {
  // --- Schema and tokens (codec, spec §5.1) ---

  /// The input is not valid JSON. No args: the parser's own text is only in
  /// the message, because it differs between the VM and the web.
  static const invalidJson = 'schema.invalidJson';

  /// `schemaVersion` is not one this package reads (§5.3 rule 1).
  /// Args: `version`, `supported`.
  static const unsupportedVersion = 'schema.unsupportedVersion';

  /// A required key is absent. Args: `field`.
  static const missingField = 'schema.missingField';

  /// A key the schema doesn't define (the codec is strict, design A21).
  /// Args: `field`.
  static const unknownField = 'schema.unknownField';

  /// A value has the wrong JSON type. Args: `field`, `expected`.
  static const wrongType = 'schema.wrongType';

  /// A number outside its allowed range, such as a negative `seed` or one of
  /// 2^53 or more (design A20), or an `ice` counter above
  /// `LayoutLimits.maxIce` (then with the slot's `slotId`). Args: `field`,
  /// `value`, `min`, `max`.
  static const valueOutOfRange = 'schema.valueOutOfRange';

  /// `id` is empty or longer than 64 characters (design A21).
  /// Args: `id`, `maxLength`.
  static const badId = 'level.badId';

  /// `type` is not `open`, `tower` or `locked`. Args: `type`.
  static const unknownSlotType = 'slot.unknownType';

  /// A doll token doesn't match `<color><size>`, e.g. `Red4`, `red`, `red10`.
  /// Args: `token`.
  static const badDollToken = 'doll.badToken';

  /// The token's color is not a `DollColor` id. Args: `token`, `color`.
  static const unknownDollColor = 'doll.unknownColor';

  /// The token's size is outside 1..maxSize. Args: `token`, `size`,
  /// `maxSize`.
  static const dollSizeOutOfRange = 'doll.sizeOutOfRange';

  /// `ice` is below 0 (spec §3.4). Args: `ice`.
  static const negativeIce = 'ice.negative';

  /// The level uses a gold doll, which is v1.1 (spec §3.5, D22).
  /// Args: `token`.
  static const goldNotSupported = 'gold.notSupported';

  // --- Rule 1 (spec §5.3) ---

  /// `maxSize` is outside 3–6. Args: `maxSize`, `min`, `max`.
  static const maxSizeOutOfRange = 'level.maxSizeOutOfRange';

  // --- Rule 2 ---

  /// Not 1–4 shelves. Args: `count`, `min`, `max`.
  static const shelfCount = 'layout.shelfCount';

  /// A shelf without 2–5 slots. Args: `row`, `count`, `min`, `max`.
  static const slotsPerShelf = 'layout.slotsPerShelf';

  /// The bottom shelf has more than 4 slots, so the 2 extra slots wouldn't
  /// fit in a row of 6 (owner override D22). Args: `count`, `max`.
  static const noRoomForExtraSlots = 'layout.noRoomForExtraSlots';

  // --- Rule 3 ---

  /// A nest with no dolls (`[]`). Args: none.
  static const emptyNest = 'nest.empty';

  /// A nest mixing colors (spec §2.1). Args: `tokens`.
  static const mixedColors = 'nest.mixedColors';

  /// Sizes that are not consecutive and decreasing (spec §2.1).
  /// Args: `tokens`.
  static const notConsecutive = 'nest.notConsecutive';

  /// A nest that is already a full set. Args: `color`.
  static const alreadyFull = 'nest.alreadyFull';

  // --- Rule 4 ---

  /// A color's dolls don't form whole full sets. Args: `color`, `size`,
  /// `count`, `expected` (the first size whose count is off).
  static const notFullSets = 'counts.notFullSets';

  // --- Rule 5 ---

  /// A tower deeper than 4. Args: `depth`, `max`.
  static const towerTooDeep = 'tower.tooDeep';

  /// A tower with an empty stack. Args: none.
  static const towerEmptyAtStart = 'tower.emptyAtStart';

  // --- Rule 6 ---

  /// No doll of the lock's `unlockColor` is in the level. Args: `color`.
  static const lockColorAbsent = 'locked.colorAbsent';

  /// Every doll of the `unlockColor` is sealed in the lock itself.
  /// Args: `color`.
  static const lockColorAllSealed = 'locked.colorAllSealed';

  // --- Rule 7 ---

  /// The starting board has no legal move. Args: none.
  static const noLegalFirstMove = 'moves.noLegalFirstMove';

  // --- Rule 8 ---

  /// The solver proved the level can't be won. Args: `nodes`.
  static const unsolvable = 'solver.unsolvable';

  /// The solver ran out of budget before proving the level solvable (the
  /// verdict is `unknown`, never `unsolvable`, spec §6.3). Args: `nodes`,
  /// `budget`.
  static const unproven = 'solver.unproven';

  // --- Level bundle (spec §13.4, design §4) ---

  /// `format` is not `nesty.levels`. Args: `format`.
  static const bundleBadFormat = 'bundle.badFormat';

  /// `bundleVersion` is not one this package reads. Args: `version`,
  /// `supported`.
  static const bundleUnsupportedVersion = 'bundle.unsupportedVersion';

  /// Two entries share a level id. Args: `id`, `order`.
  static const bundleDuplicateId = 'bundle.duplicateId';

  /// Two entries share an `order`. Args: `order`.
  static const bundleDuplicateOrder = 'bundle.duplicateOrder';

  /// Orders are not continuous from 1. Args: `expected`, `found`.
  static const bundleOrderGap = 'bundle.orderGap';

  /// `tier` is not a `Tier` id. Args: `tier`.
  static const bundleUnknownTier = 'bundle.unknownTier';

  // --- Generator params and outcome (spec §6.5) ---

  /// A parameter outside its range. Args: `param`, `value`, `min`, `max`.
  static const genParamOutOfRange = 'gen.paramOutOfRange';

  /// Towers, empty and occupied slots don't fit the board. Args: `needed`,
  /// `available`.
  static const genSlotsInfeasible = 'gen.slotsInfeasible';

  /// The sets can't be cut into segments that fill the occupied slots
  /// (`2·sets ≤ capacity ≤ maxSize·sets`, design §3). Args: `capacity`,
  /// `min`, `max`.
  static const genSegmentsInfeasible = 'gen.segmentsInfeasible';

  /// No attempt produced a solvable level (design A14). Args: `attempts`.
  static const genNoSolvableLevel = 'gen.noSolvableLevel';

  // --- The in-progress session (spec §13.3, docs/plans/m3-design.md §4) ---
  //
  // `GameSessionCodec.decode` also reports `schema.missingField`,
  // `schema.unknownField`, `schema.wrongType`, `doll.badToken`,
  // `gold.notSupported` and, for a negative `undosUsed`,
  // `schema.valueOutOfRange`.

  /// The session's `format` is not one this package reads; nothing else is
  /// read. Args: `found`.
  static const sessionUnsupportedFormat = 'session.unsupportedFormat';

  /// The session was saved for another level. Args: `expected` (the level's
  /// id), `found` (the saved `levelId`).
  static const sessionLevelMismatch = 'session.levelMismatch';

  /// A saved board is not one the level can be in: wrong slot ids, invalid
  /// nests, counters out of range, or dolls and states play can't reach.
  /// Args: `board` (`state` or `history/<i>`); `slotId` when the problem is
  /// one slot.
  static const sessionBadBoard = 'session.badBoard';

  /// A history entry's move doesn't replay through the rules to the next
  /// saved board. Args: `index`.
  static const sessionBadHistory = 'session.badHistory';

  /// Every code above, for exhaustive tests and the admin's ARB coverage.
  static const List<String> all = [
    invalidJson,
    unsupportedVersion,
    missingField,
    unknownField,
    wrongType,
    valueOutOfRange,
    badId,
    unknownSlotType,
    badDollToken,
    unknownDollColor,
    dollSizeOutOfRange,
    negativeIce,
    goldNotSupported,
    maxSizeOutOfRange,
    shelfCount,
    slotsPerShelf,
    noRoomForExtraSlots,
    emptyNest,
    mixedColors,
    notConsecutive,
    alreadyFull,
    notFullSets,
    towerTooDeep,
    towerEmptyAtStart,
    lockColorAbsent,
    lockColorAllSealed,
    noLegalFirstMove,
    unsolvable,
    unproven,
    bundleBadFormat,
    bundleUnsupportedVersion,
    bundleDuplicateId,
    bundleDuplicateOrder,
    bundleOrderGap,
    bundleUnknownTier,
    genParamOutOfRange,
    genSlotsInfeasible,
    genSegmentsInfeasible,
    genNoSolvableLevel,
    sessionUnsupportedFormat,
    sessionLevelMismatch,
    sessionBadBoard,
    sessionBadHistory,
  ];
}
