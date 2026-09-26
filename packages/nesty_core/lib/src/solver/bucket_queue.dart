import 'dart:typed_data';

/// The A* open list (docs/plans/m1-core-design.md §3): one LIFO stack of
/// nodes per f value, kept as linked entries in typed lists.
///
/// Every move costs 1 and h is an integer, so f is a small integer and a
/// bucket per value replaces a heap. The heuristic is consistent (spec §6.3:
/// a merge lowers h by exactly 1, a placement leaves it), so a child's f is
/// never below its parent's and the lowest bucket only moves up. Within a
/// bucket the last node pushed pops first: the search dives along the
/// newest line, deterministically.
///
/// A node may sit in the queue more than once after a cheaper path to it
/// was found; the search skips the stale entry when it pops (design §3).
/// Popped entries are recycled.
///
/// Internal to nesty_core.
final class BucketQueue {
  BucketQueue() {
    _heads.fillRange(0, _heads.length, -1);
  }

  Int32List _heads = Int32List(64);
  Int32List _entryNode = Int32List(1024);
  Int32List _entryNext = Int32List(1024);
  int _entries = 0;
  int _free = -1;
  int _size = 0;
  int _minF = 0;
  int _maxF = -1;

  /// The f value of the bucket the last [pop] took its node from.
  int get poppedF => _poppedF;
  int _poppedF = -1;

  /// Entries waiting, stale ones included.
  int get length => _size;

  bool get isEmpty => _size == 0;

  /// Bytes held by the queue's lists.
  int get bytes => (_heads.length + 2 * _entryNode.length) * 4;

  /// The most bytes the queue ever held at once: growing its entry lists
  /// briefly holds the old and the doubled ones.
  int get peakBytes => _peakBytes > bytes ? _peakBytes : bytes;
  int _peakBytes = 0;

  /// Pushes [node] onto the bucket of [f] (at least 0).
  void push(int f, int node) {
    if (f >= _heads.length) _growHeads(f);
    final int entry;
    if (_free >= 0) {
      entry = _free;
      _free = _entryNext[entry];
    } else {
      if (_entries == _entryNode.length) _growEntries();
      entry = _entries++;
    }
    _entryNode[entry] = node;
    _entryNext[entry] = _heads[f];
    _heads[f] = entry;
    if (_size == 0 || f < _minF) _minF = f;
    if (f > _maxF) _maxF = f;
    _size++;
  }

  /// Removes and returns the newest node of the lowest non-empty bucket,
  /// or -1 when the queue is empty. [poppedF] then tells its bucket.
  int pop() {
    if (_size == 0) return -1;
    var f = _minF;
    while (_heads[f] < 0) {
      f++;
    }
    _minF = f;
    final entry = _heads[f];
    _heads[f] = _entryNext[entry];
    final node = _entryNode[entry];
    _entryNext[entry] = _free;
    _free = entry;
    _size--;
    _poppedF = f;
    return node;
  }

  void _growHeads(int f) {
    var length = _heads.length * 2;
    while (length <= f) {
      length *= 2;
    }
    final heads = Int32List(length)..fillRange(0, length, -1);
    heads.setRange(0, _heads.length, _heads);
    _heads = heads;
  }

  void _growEntries() {
    final length = _entryNode.length * 2;
    final both = bytes + 2 * length * 4;
    if (both > _peakBytes) _peakBytes = both;
    _entryNode = Int32List(length)..setRange(0, _entries, _entryNode);
    _entryNext = Int32List(length)..setRange(0, _entries, _entryNext);
  }
}
