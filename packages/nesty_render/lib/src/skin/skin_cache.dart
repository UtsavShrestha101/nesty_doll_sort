import 'package:nesty_render/src/skin/skin_image_set.dart';
import 'package:nesty_render/src/skin/skin_rasterizer.dart';

/// Rasterized skin layers per (skin, version, artboard pixel height), least
/// recently used first out (spec §12.2 "rasterizes each layer once per
/// needed size", §13.5).
///
/// The cache keeps one handle per set and hands out clones, so a renderer's
/// images stay valid if the cache evicts or is cleared mid-level. Memory is
/// freed once the cache and every renderer have let go of a set.
///
/// A disk PNG cache is M4 (BACKLOG "Disk raster cache").
final class SkinCache {
  SkinCache({this.maxBytes = 16 * 1024 * 1024}) : assert(maxBytes >= 0);

  /// Evicts least recently used sets while the cache holds more than this.
  /// The newest set is always kept, whatever its size.
  final int maxBytes;

  // Insertion-ordered (a LinkedHashMap): the first key is the least
  // recently used.
  final _sets = <(String, int), SkinImageSet>{};
  final _pending = <(String, int), Future<SkinImageSet>>{};
  int _bytes = 0;

  /// Bytes held by the cache's own handles.
  int get byteSize => _bytes;

  /// Number of cached sets.
  int get length => _sets.length;

  /// Whether a set for [skinKey] at [artHeightPx] is cached.
  bool contains(String skinKey, int artHeightPx) =>
      _sets.containsKey((skinKey, artHeightPx));

  /// A clone of the set for [rasterizer]'s skin at [artHeightPx], rasterized
  /// on a miss. The caller owns the clone and must dispose it. Concurrent
  /// requests for the same set share one rasterization.
  Future<SkinImageSet> obtain(
    SkinRasterizer rasterizer,
    int artHeightPx,
  ) async {
    final key = (rasterizer.cacheKey, artHeightPx);
    final hit = _sets.remove(key);
    if (hit != null) {
      _sets[key] = hit; // most recently used
      return hit.clone();
    }
    var pending = _pending[key];
    if (pending == null) {
      pending = _rasterizeAndInsert(rasterizer, key);
      _pending[key] = pending;
    }
    await pending;
    // Clone whatever is cached now: a tiny maxBytes can evict (and a later
    // request re-insert) the set before this waiter resumes.
    final current = _sets[key];
    return current != null ? current.clone() : obtain(rasterizer, artHeightPx);
  }

  // Inserts before any waiter resumes, so every waiter clones the one
  // cached handle and none of them owns it.
  Future<SkinImageSet> _rasterizeAndInsert(
    SkinRasterizer rasterizer,
    (String, int) key,
  ) async {
    try {
      final set = await rasterizer.rasterize(key.$2);
      _sets[key] = set;
      _bytes += set.byteSize;
      _evict(keep: key);
      return set;
    } finally {
      final removed = _pending.remove(key);
      assert(removed != null, 'pending entry for $key');
    }
  }

  /// Disposes every cached handle. Clones held by renderers stay valid.
  void clear() {
    for (final set in _sets.values) {
      set.dispose();
    }
    _sets.clear();
    _bytes = 0;
  }

  void _evict({required (String, int) keep}) {
    while (_bytes > maxBytes && _sets.length > 1) {
      var oldest = _sets.keys.first;
      if (oldest == keep) oldest = _sets.keys.elementAt(1);
      final set = _sets.remove(oldest)!;
      _bytes -= set.byteSize;
      set.dispose();
    }
  }
}
