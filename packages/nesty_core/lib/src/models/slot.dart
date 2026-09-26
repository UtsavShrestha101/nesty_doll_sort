import 'package:nesty_core/src/models/doll_color.dart';
import 'package:nesty_core/src/models/equality.dart';
import 'package:nesty_core/src/models/nest.dart';

/// A spot on a shelf (spec §2.1, §3), as a level defines it or as a
/// `GameState` shows it.
///
/// The three kinds of spec §3 are subclasses, so a `switch` over a slot is
/// exhaustive. Ice (§3.4) is a modifier any kind can carry, so it lives here.
///
/// In a `GameState` view a tower whose last nest left, and a locked slot
/// whose case broke, both read back as an [OpenSlot] (spec §3.2, §3.3), so a
/// [TowerSlot] always has a nest and a [LockedSlot] is always still locked
/// (docs/plans/m1-core-design.md §2).
sealed class Slot {
  Slot({required this.ice}) {
    // Negative ice has no meaning (§3.4); the codec reports it as
    // `ice.negative` before it builds a slot (spec §5.3).
    RangeError.checkNotNegative(ice, 'ice');
  }

  /// The ice counter `n` (spec §3.4). 0 means no ice. While it is above 0 the
  /// slot can't be picked from or dropped onto.
  final int ice;

  /// True while the slot is iced (spec §3.4).
  bool get isFrozen => ice > 0;

  /// Every nest in the slot, bottom to top. An open or locked slot holds at
  /// most one.
  List<Nest> get nests;

  /// True when the slot holds no nest.
  bool get isEmpty => nests.isEmpty;
}

/// The basic slot: holds 0 or 1 nest (spec §3.1). Open slots are
/// interchangeable, which the solver exploits (spec §6.2).
final class OpenSlot extends Slot {
  OpenSlot({this.nest, super.ice = 0});

  /// The nest in the slot, or null when it is empty.
  final Nest? nest;

  @override
  List<Nest> get nests => [?nest];

  @override
  bool operator ==(Object other) =>
      other is OpenSlot && other.nest == nest && other.ice == ice;

  @override
  int get hashCode => Object.hash(OpenSlot, nest, ice);

  @override
  String toString() => 'open(${nest ?? 'empty'}${_iceSuffix(ice)})';
}

/// A stack of nests, bottom to top, of which only the top can be picked up or
/// merged into (spec §3.2). Nests below the top are hidden silhouettes.
///
/// A tower is never empty: rule 5 of spec §5.3 forbids an empty tower at the
/// start, and an emptied tower becomes an open slot (§3.2).
final class TowerSlot extends Slot {
  /// Throws an [ArgumentError] when [stack] is empty. Depth above 4 can be
  /// built so the validator can report it (spec §5.3 rule 5).
  TowerSlot(List<Nest> stack, {super.ice = 0})
    : stack = List.unmodifiable(stack) {
    if (stack.isEmpty) {
      throw ArgumentError.value(
        stack,
        'stack',
        'A tower is never empty (spec §3.2, §5.3 rule 5)',
      );
    }
  }

  /// The nests, bottom to top: `stack.last` is the top (spec §4).
  final List<Nest> stack;

  /// The only nest that can be picked up or merged into (spec §3.2).
  Nest get top => stack.last;

  /// How many nests are hidden under [top].
  int get hiddenCount => stack.length - 1;

  @override
  List<Nest> get nests => stack;

  @override
  bool operator ==(Object other) =>
      other is TowerSlot && other.ice == ice && listEquals(other.stack, stack);

  @override
  int get hashCode => Object.hash(TowerSlot, Object.hashAll(stack), ice);

  @override
  String toString() => 'tower(${stack.join(' ')}${_iceSuffix(ice)})';
}

/// A glass case (spec §3.3). Its nest, if any, is visible but can't be used.
/// The case breaks, and the slot becomes an [OpenSlot], the moment the first
/// full set of [unlockColor] completes.
final class LockedSlot extends Slot {
  LockedSlot({required this.unlockColor, this.nest, super.ice = 0});

  /// The color whose first completed set breaks the case (spec §3.3).
  final DollColor unlockColor;

  /// The nest sealed behind the glass, or null.
  final Nest? nest;

  @override
  List<Nest> get nests => [?nest];

  @override
  bool operator ==(Object other) =>
      other is LockedSlot &&
      other.unlockColor == unlockColor &&
      other.nest == nest &&
      other.ice == ice;

  @override
  int get hashCode => Object.hash(LockedSlot, unlockColor, nest, ice);

  @override
  String toString() =>
      'locked(${unlockColor.id}: ${nest ?? 'empty'}${_iceSuffix(ice)})';
}

String _iceSuffix(int ice) => ice > 0 ? ', ice $ice' : '';
