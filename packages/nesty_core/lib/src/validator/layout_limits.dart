import 'package:nesty_core/src/models/doll.dart';

/// Board and level limits from spec §5.3 and the owner's extra-slot override
/// (D22). The validator, the engine's board layout and the generator all read
/// them from here, so a limit is stated once.
abstract final class LayoutLimits {
  /// Smallest level `maxSize` (§5.3 rule 1).
  static const int minMaxSize = 3;

  /// Largest level `maxSize` (§5.3 rule 1): the largest doll (§2.1).
  static const int maxMaxSize = Doll.maxSize;

  /// Fewest shelves (§2.1, §5.3 rule 2).
  static const int minShelves = 1;

  /// Most shelves (§2.1, §5.3 rule 2).
  static const int maxShelves = 4;

  /// Fewest authored slots on a shelf (§2.1, §5.3 rule 2).
  static const int minSlotsPerShelf = 2;

  /// Most authored slots on a shelf (§2.1, §5.3 rule 2).
  static const int maxSlotsPerShelf = 5;

  /// Extra slots a level can get (spec §3.6).
  static const int maxExtraSlots = 2;

  /// Slots the board layout fits in one row, extras included (design §1:
  /// "up to 6 = 4 authored + 2 extras").
  static const int maxRowSlots = 6;

  /// Most authored slots on the bottom shelf, so both extra slots still fit
  /// in its row (owner override D22, code `layout.noRoomForExtraSlots`).
  static const int maxBottomShelfSlots = maxRowSlots - maxExtraSlots;

  /// Deepest tower at the start (§3.2, §5.3 rule 5).
  static const int maxTowerDepth = 4;

  /// Most slots on any board, extras included: 22, so a bit mask of slots
  /// fits in 32 bits on every platform (design §2).
  static const int maxSlots = maxShelves * maxSlotsPerShelf + maxExtraSlots;

  /// Longest level id (design A21).
  static const int maxLevelIdLength = 64;

  /// Largest ice counter a slot may start with: 2^31 − 1. Spec §3.4 sets
  /// no maximum, so this is a representation limit, not a game rule: the
  /// engine keeps counters in 32-bit lists (an `Int32Array` on the web), and
  /// a larger value would wrap and play as thawed. Any counter above the
  /// level's sets never thaws anyway, so no playable level needs more. The
  /// validator reports a larger one as `schema.valueOutOfRange`, and the
  /// engine's board layout refuses it.
  static const int maxIce = 0x7FFFFFFF;
}
