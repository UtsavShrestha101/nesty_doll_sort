/// Structural equality helpers for the hand-written immutable models.
///
/// Core has no dependencies (CLAUDE.md rule 9), so `package:collection`'s
/// `ListEquality` is not available. These cover the only shapes the models
/// hold: lists of values with their own `==`, and nested lists of those.
///
/// Internal to nesty_core (not exported by the barrel).
library;

/// Element-wise `==` of two lists, in order.
bool listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Element-wise [listEquals] of two lists of lists.
bool nestedListEquals<T>(List<List<T>> a, List<List<T>> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!listEquals(a[i], b[i])) return false;
  }
  return true;
}

/// Key-by-key `==` of two maps. Order is ignored, as for `Map` equality in
/// general; values are compared with their own `==`.
bool mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final MapEntry(:key, :value) in a.entries) {
    if (!b.containsKey(key) || b[key] != value) return false;
  }
  return true;
}

/// A hash consistent with [mapEquals]: independent of iteration order.
///
/// Like every `hashCode` in core it is for in-memory lookups only and is
/// never persisted or used for ordering (docs/plans/m1-core-design.md §2).
int mapHash<K, V>(Map<K, V> map) => Object.hashAllUnordered([
  for (final MapEntry(:key, :value) in map.entries) Object.hash(key, value),
]);
