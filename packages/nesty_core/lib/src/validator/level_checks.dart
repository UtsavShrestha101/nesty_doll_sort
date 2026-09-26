/// The checks of spec §5.3 rules 1–6 that need only the [Level] model, plus
/// the value checks the level JSON implies (id length, seed range, ice
/// counters the engine can store, doll size against `maxSize`, gold). Rules
/// 7 and 8 need the rules engine and the
/// solver, so the `Validator` runs them afterwards.
///
/// Internal to nesty_core (not exported by the barrel).
library;

import 'package:nesty_core/src/codec/level_issue.dart';
import 'package:nesty_core/src/models/doll.dart';
import 'package:nesty_core/src/models/doll_color.dart';
import 'package:nesty_core/src/models/level.dart';
import 'package:nesty_core/src/models/nest.dart';
import 'package:nesty_core/src/models/slot.dart';
import 'package:nesty_core/src/models/slot_id.dart';
import 'package:nesty_core/src/prng/prng.dart';
import 'package:nesty_core/src/validator/layout_limits.dart';

/// Runs every check on [level] and returns the issues in rule order.
///
/// Paths are JSON pointers into `LevelCodec.encode(level)`, so an issue on a
/// level read from JSON points at the value the author wrote.
List<LevelIssue> checkLevel(Level level) => (_Checks(level)..run()).issues;

// 2^53 − 1: the largest integer every platform reads exactly from JSON.
const int _maxJsonInteger = 0x1FFFFFFFFFFFFF;

/// A nest of the level with its JSON pointer segments and slot id.
typedef _PlacedNest = ({Nest nest, List<Object> path, String slotId});

final class _Checks {
  _Checks(this.level);

  final Level level;
  final List<LevelIssue> issues = [];

  /// Whether `maxSize` passed rule 1. The size checks of rule 3 and the
  /// counts of rule 4 are measured against it, so they only run when it is
  /// meaningful; otherwise every doll would be reported as well.
  bool get _maxSizeValid =>
      level.maxSize >= LayoutLimits.minMaxSize &&
      level.maxSize <= LayoutLimits.maxMaxSize;

  void run() {
    _levelFields();
    _iceCounters();
    _rule1MaxSize();
    _rule2Layout();
    _rule3Nests();
    _rule4Counts();
    _rule5Towers();
    _rule6Locks();
  }

  // --- Level fields: rule 1 schema version, id and generator fields ---

  void _levelFields() {
    // §5.3 rule 1. The codec stops at an unsupported version, so this only
    // fires for a level built in code.
    if (level.schemaVersion != Level.currentSchemaVersion) {
      _add(
        IssueCodes.unsupportedVersion,
        'schemaVersion ${level.schemaVersion} is not supported (this build '
        'reads ${Level.currentSchemaVersion})',
        const ['schemaVersion'],
        args: {
          'version': level.schemaVersion,
          'supported': Level.currentSchemaVersion,
        },
      );
    }
    // Design A21.
    final id = level.id;
    if (id.isEmpty || id.length > LayoutLimits.maxLevelIdLength) {
      _add(
        IssueCodes.badId,
        'The level id must be 1–${LayoutLimits.maxLevelIdLength} characters '
        '(got ${id.length})',
        const ['id'],
        args: {'id': id, 'maxLength': LayoutLimits.maxLevelIdLength},
      );
    }
    // Design A20: versions start at 1 (Generator.version), and a seed is an
    // input to Prng, which takes [0, Prng.maxSeed].
    _range('generatorVersion', level.generatorVersion, 1, _maxJsonInteger);
    _range('seed', level.seed, 0, Prng.maxSeed);
  }

  void _range(String field, int? value, int min, int max) {
    if (value == null || (value >= min && value <= max)) return;
    _add(
      IssueCodes.valueOutOfRange,
      '$field $value is outside $min–$max',
      [field],
      args: {'field': field, 'value': value, 'min': min, 'max': max},
    );
  }

  /// Ice counters above [LayoutLimits.maxIce] can't be stored exactly by the
  /// engine (they would wrap and play as thawed, spec §3.4), so they are
  /// out of range. Negative ice can't be represented at all (the codec's
  /// `ice.negative`).
  void _iceCounters() {
    for (final (:slot, :path, :slotId) in _slots()) {
      if (slot.ice <= LayoutLimits.maxIce) continue;
      _add(
        IssueCodes.valueOutOfRange,
        'ice ${slot.ice} is outside 0–${LayoutLimits.maxIce}',
        [...path, 'ice'],
        slotId: slotId,
        args: {
          'field': 'ice',
          'value': slot.ice,
          'min': 0,
          'max': LayoutLimits.maxIce,
        },
      );
    }
  }

  void _rule1MaxSize() {
    if (_maxSizeValid) return;
    _add(
      IssueCodes.maxSizeOutOfRange,
      'maxSize ${level.maxSize} is outside '
      '${LayoutLimits.minMaxSize}–${LayoutLimits.maxMaxSize}',
      const ['maxSize'],
      args: {
        'maxSize': level.maxSize,
        'min': LayoutLimits.minMaxSize,
        'max': LayoutLimits.maxMaxSize,
      },
    );
  }

  // --- Rule 2: 1–4 shelves, 2–5 slots each, room for the extra slots ---

  void _rule2Layout() {
    final shelves = level.shelves;
    if (shelves.length < LayoutLimits.minShelves ||
        shelves.length > LayoutLimits.maxShelves) {
      _add(
        IssueCodes.shelfCount,
        'A level needs ${LayoutLimits.minShelves}–${LayoutLimits.maxShelves} '
        'shelves (got ${shelves.length})',
        const ['shelves'],
        args: {
          'count': shelves.length,
          'min': LayoutLimits.minShelves,
          'max': LayoutLimits.maxShelves,
        },
      );
    }
    for (var row = 0; row < shelves.length; row++) {
      final count = shelves[row].length;
      if (count >= LayoutLimits.minSlotsPerShelf &&
          count <= LayoutLimits.maxSlotsPerShelf) {
        continue;
      }
      _add(
        IssueCodes.slotsPerShelf,
        'Shelf $row needs ${LayoutLimits.minSlotsPerShelf}–'
        '${LayoutLimits.maxSlotsPerShelf} slots (got $count)',
        ['shelves', row],
        args: {
          'row': row,
          'count': count,
          'min': LayoutLimits.minSlotsPerShelf,
          'max': LayoutLimits.maxSlotsPerShelf,
        },
      );
    }
    // Owner override D22: both extra slots join the bottom shelf, and a row
    // fits at most 6 slots (§10.3 "fits the layout").
    if (shelves.isNotEmpty &&
        shelves.last.length > LayoutLimits.maxBottomShelfSlots) {
      final row = shelves.length - 1;
      _add(
        IssueCodes.noRoomForExtraSlots,
        'The bottom shelf may hold at most '
        '${LayoutLimits.maxBottomShelfSlots} slots, so both extra slots fit '
        '(got ${shelves.last.length})',
        ['shelves', row],
        args: {
          'count': shelves.last.length,
          'max': LayoutLimits.maxBottomShelfSlots,
        },
      );
    }
  }

  // --- Rule 3: every nest valid (sizes within maxSize), none already full ---

  void _rule3Nests() {
    for (final (:nest, :path, :slotId) in _nests()) {
      // Spec §3.5: gold is v1.1. The codec parses it and the engine has the
      // hook, but no level may use it yet (owner override D22).
      // TODO(v1.1): accept gold once the §3.5 rules ship (spec §3.5, D22).
      if (nest.color == DollColor.gold) {
        _add(
          IssueCodes.goldNotSupported,
          'Gold dolls are not supported yet (${nest.outer.token})',
          path,
          slotId: slotId,
          args: {'token': nest.outer.token},
        );
      }
      if (!_maxSizeValid) continue;
      // Spec §2.1: sizes go from 1 to the level's maxSize. The largest dolls
      // of a nest come first, so only a prefix can be too large.
      for (var i = 0; nest.outerSize - i > level.maxSize; i++) {
        final doll = Doll(nest.color, nest.outerSize - i);
        _add(
          IssueCodes.dollSizeOutOfRange,
          '${doll.token} is larger than maxSize ${level.maxSize}',
          [...path, i],
          slotId: slotId,
          args: {
            'token': doll.token,
            'size': doll.size,
            'maxSize': level.maxSize,
          },
        );
      }
      if (nest.isFullSet(level.maxSize)) {
        _add(
          IssueCodes.alreadyFull,
          'A nest must not start as a full set ($nest)',
          path,
          slotId: slotId,
          args: {'color': nest.color.id},
        );
      }
    }
  }

  // --- Rule 4: each color's dolls form k ≥ 1 full sets; gold is exempt ---

  void _rule4Counts() {
    if (!_maxSizeValid) return;
    final maxSize = level.maxSize;
    // counts[color][size], sizes 1..maxSize; larger dolls were rule 3's.
    final counts = [
      for (final _ in DollColor.values) List.filled(maxSize + 1, 0),
    ];
    for (final (:nest, path: _, slotId: _) in _nests()) {
      for (var size = nest.innerSize; size <= nest.outerSize; size++) {
        if (size <= maxSize) counts[nest.color.index][size]++;
      }
    }
    for (final color in DollColor.values) {
      if (color.isWild) continue;
      final bySize = counts[color.index];
      // k is the most common size count: the sets the color would need for
      // its most repeated doll. Any other count is short of it.
      var sets = 0;
      for (var size = 1; size <= maxSize; size++) {
        if (bySize[size] > sets) sets = bySize[size];
      }
      if (sets == 0) continue; // The color isn't in the level.
      for (var size = 1; size <= maxSize; size++) {
        if (bySize[size] == sets) continue;
        _add(
          IssueCodes.notFullSets,
          '${color.id} dolls must form whole sets: $sets of each size 1–'
          '$maxSize, but size $size has ${bySize[size]}',
          const [],
          args: {
            'color': color.id,
            'size': size,
            'count': bySize[size],
            'expected': sets,
          },
        );
        break; // One issue per color: the first size that is off.
      }
    }
  }

  // --- Rule 5: towers at most 4 deep (empty stacks are the codec's) ---

  void _rule5Towers() {
    for (final (:slot, :path, :slotId) in _slots()) {
      if (slot is! TowerSlot ||
          slot.stack.length <= LayoutLimits.maxTowerDepth) {
        continue;
      }
      _add(
        IssueCodes.towerTooDeep,
        'A tower holds at most ${LayoutLimits.maxTowerDepth} nests '
        '(got ${slot.stack.length})',
        [...path, 'stack'],
        slotId: slotId,
        args: {'depth': slot.stack.length, 'max': LayoutLimits.maxTowerDepth},
      );
    }
  }

  // --- Rule 6: each lock's color is in the level and not all sealed in it --

  void _rule6Locks() {
    final dollsByColor = List.filled(DollColor.values.length, 0);
    for (final (:nest, path: _, slotId: _) in _nests()) {
      dollsByColor[nest.color.index] += nest.length;
    }
    for (final (:slot, :path, :slotId) in _slots()) {
      if (slot is! LockedSlot) continue;
      final color = slot.unlockColor;
      final colorPath = [...path, 'unlockColor'];
      if (color == DollColor.gold) {
        // A gold lock would open on a gold set, a v1.1 idea (§3.5, D22).
        _add(
          IssueCodes.goldNotSupported,
          'Gold dolls are not supported yet (unlockColor gold)',
          colorPath,
          slotId: slotId,
          args: {'token': color.id},
        );
        continue;
      }
      final total = dollsByColor[color.index];
      final sealed = slot.nest?.color == color ? slot.nest!.length : 0;
      if (total == 0) {
        _add(
          IssueCodes.lockColorAbsent,
          'The lock opens on ${color.id}, but the level has no ${color.id} '
          'dolls',
          colorPath,
          slotId: slotId,
          args: {'color': color.id},
        );
      } else if (sealed == total) {
        _add(
          IssueCodes.lockColorAllSealed,
          'Every ${color.id} doll is sealed in the lock that ${color.id} '
          'opens',
          colorPath,
          slotId: slotId,
          args: {'color': color.id},
        );
      }
    }
  }

  // --- Walking the level ---

  Iterable<({Slot slot, List<Object> path, String slotId})> _slots() sync* {
    final shelves = level.shelves;
    for (var row = 0; row < shelves.length; row++) {
      for (var col = 0; col < shelves[row].length; col++) {
        yield (
          slot: shelves[row][col],
          path: ['shelves', row, col],
          slotId: SlotId.grid(row, col),
        );
      }
    }
  }

  /// Every nest in board order; a tower's from bottom to top.
  Iterable<_PlacedNest> _nests() sync* {
    for (final (:slot, :path, :slotId) in _slots()) {
      switch (slot) {
        case OpenSlot(:final nest?) || LockedSlot(:final nest?):
          yield (nest: nest, path: [...path, 'nest'], slotId: slotId);
        case TowerSlot(:final stack):
          for (var i = 0; i < stack.length; i++) {
            yield (nest: stack[i], path: [...path, 'stack', i], slotId: slotId);
          }
        case OpenSlot() || LockedSlot():
          break;
      }
    }
  }

  void _add(
    String code,
    String message,
    List<Object> path, {
    String? slotId,
    Map<String, Object> args = const {},
  }) {
    issues.add(
      LevelIssue(
        code: code,
        message: message,
        path: LevelIssue.pointer(path),
        slotId: slotId,
        args: args,
      ),
    );
  }
}
