import 'dart:typed_data';

/// Confirms that a stored node really has the key being looked up.
///
/// Internal to nesty_core.
abstract interface class NodeKeyMatcher {
  /// True when the canonical key of stored [node] equals the key being
  /// looked up.
  bool matches(int node);
}

/// The solver's visited set (docs/plans/m1-core-design.md §3): open
/// addressing with linear probing over the two 32-bit halves of each
/// state's `Hash64` (spec §6.2), mapping to the node that holds the state.
///
/// A hash match alone is never trusted: [lookup] asks a [NodeKeyMatcher] to
/// compare the full canonical keys, and a mismatch keeps probing. So a hash
/// collision can cost time but can never merge two different states, and an
/// `unsolvable` verdict stays a proof.
///
/// Each entry is three adjacent u32s (hi, lo, node + 1), so a probe touches
/// one cache line: at hundreds of thousands of states the table is far
/// bigger than the caches, and the solver probes it once per successor.
/// Grown by doubling at load 1/2 (CLAUDE.md rule 8). Its order depends on
/// hash values, but nothing iterates it, so the search's result doesn't
/// (design §3: no hash-order iteration).
///
/// Internal to nesty_core.
final class VisitedTable {
  /// An empty table with room for about [initialCapacity] / 2 states;
  /// [initialCapacity] is rounded up to a power of two.
  VisitedTable([int initialCapacity = 1024]) {
    var capacity = 16;
    while (capacity < initialCapacity) {
      capacity *= 2;
    }
    _allocate(capacity);
  }

  static const int _hi = 0;
  static const int _lo = 1;
  static const int _node = 2;
  static const int _width = 3;

  // Entry i at [i * 3]: hi, lo, node + 1 (0 = empty, so a new list is
  // empty).
  late Uint32List _entries;
  late int _mask;

  /// States stored.
  int get length => _length;
  int _length = 0;

  /// Entries the table has room for before it grows.
  int get capacity => _mask + 1;

  /// Bytes held by the table's list.
  int get bytes => _entries.length * 4;

  /// The most bytes the table ever held at once: while it grows it holds
  /// the old list and the doubled one (design §5 memory budget).
  int get peakBytes => _peakBytes > bytes ? _peakBytes : bytes;
  int _peakBytes = 0;

  /// The node stored under the hash ([hi], [lo]) whose key [matcher]
  /// confirms, or -1.
  int lookup(int hi, int lo, NodeKeyMatcher matcher) {
    final entries = _entries;
    final mask = _mask;
    for (var i = lo & mask; ; i = (i + 1) & mask) {
      final at = i * _width;
      final stored = entries[at + _node];
      if (stored == 0) return -1;
      if (entries[at + _lo] == lo &&
          entries[at + _hi] == hi &&
          matcher.matches(stored - 1)) {
        return stored - 1;
      }
    }
  }

  /// Stores [node] under the hash ([hi], [lo]). The caller has checked with
  /// [lookup] that its state is not stored yet.
  void add(int hi, int lo, int node) {
    if ((_length + 1) * 2 > capacity) _grow();
    _place(_entries, _mask, hi, lo, node + 1);
    _length++;
  }

  static void _place(
    Uint32List entries,
    int mask,
    int hi,
    int lo,
    int storedNode,
  ) {
    var at = (lo & mask) * _width;
    while (entries[at + _node] != 0) {
      at = ((at ~/ _width + 1) & mask) * _width;
    }
    entries[at + _hi] = hi;
    entries[at + _lo] = lo;
    entries[at + _node] = storedNode;
  }

  void _grow() {
    final old = _entries;
    _allocate(capacity * 2);
    final both = (old.length + _entries.length) * 4;
    if (both > _peakBytes) _peakBytes = both;
    for (var at = 0; at < old.length; at += _width) {
      final stored = old[at + _node];
      if (stored != 0) {
        _place(_entries, _mask, old[at + _hi], old[at + _lo], stored);
      }
    }
  }

  void _allocate(int capacity) {
    _entries = Uint32List(capacity * _width);
    _mask = capacity - 1;
  }
}
