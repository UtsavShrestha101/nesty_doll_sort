import 'dart:typed_data';

/// The solver's node arena (docs/plans/m1-core-design.md §3): one row per
/// stored state, in fixed-size chunks added as the search stores more, up to
/// the node budget.
///
/// A row holds the state's canonical key words (`CanonicalBoard.writeKey`:
/// the header and every cell, packed), its depth g, its heuristic h and a
/// closed flag, so everything the search reads when a successor turns out
/// to be a known state sits in one run of memory: at hundreds of thousands
/// of nodes the arena is far bigger than the caches. The key is a complete
/// board (`CanonicalBoard.unpack` restores it for expansion), so the arena
/// needs nothing else, and it is the exact form the visited table confirms
/// hits with. The parent and the move from the parent's board are read only
/// to build the solution, so they live apart.
///
/// Chunks of [chunkRows] rows, never copied: growing by doubling one list
/// held the old and the new list at once, so the last doubling of a 500k
/// admin search peaked at about 1.5× the arena (86 MiB on a 72-cell board,
/// above design §5's 64 MB) and copied every row it had. With chunks the
/// store holds at most one partly filled chunk beyond its rows, and [bytes]
/// is also its peak. A chunk never outgrows the budget, so a small search
/// (a 50-node budget) allocates only what it may use.
///
/// `4 × keyWords + 14` bytes per node: about 58 B for a 27-cell board, which
/// with the visited table and the queue is the design's 90–120 B/node.
///
/// Internal to nesty_core.
final class NodeStore {
  /// A store for keys of [keyWords] words that holds at most [limit] nodes.
  NodeStore(this.keyWords, this.limit) : rowStride = keyWords + _header;

  /// Rows per chunk: 2^[chunkShift].
  static const int chunkRows = 1 << chunkShift;

  /// A node's chunk is `node >> chunkShift`.
  static const int chunkShift = 10;
  static const int _chunkMask = chunkRows - 1;

  // After the key: g, then h | closed << 16.
  static const int _g = 0;
  static const int _hClosed = 1;
  static const int _header = 2;
  static const int _closedBit = 0x10000;

  /// Words of every key.
  final int keyWords;

  /// Int32s per row: the key plus g and h.
  final int rowStride;

  /// The most nodes the store may hold: the search's budget.
  final int limit;

  /// Nodes stored.
  int get length => _length;
  int _length = 0;

  // Rows the chunks have room for.
  int _capacity = 0;
  final List<Int32List> _rows = [];
  final List<Int32List> _parent = [];
  // from << 5 | to: slot indexes are below 32 (BoardLayout.maxSlotCount).
  final List<Uint16List> _move = [];

  /// Bytes held by the store's lists; chunks are never copied, so this is
  /// also the store's peak.
  int get bytes => _capacity * (4 * rowStride + 6);

  /// The chunk that holds [node]'s row; its key starts at [offsetOf].
  Int32List chunkOf(int node) => _rows[node >> chunkShift];

  /// Where [node]'s row starts in [chunkOf].
  int offsetOf(int node) => (node & _chunkMask) * rowStride;

  /// Stores the state with [key] reached from [parent] (-1 for the root) by
  /// the move [from] → [to] after [g] moves, with heuristic [h] (below
  /// 2^16). Returns its index. The caller keeps [length] below [limit].
  int add(Int32List key, int parent, int from, int to, int g, int h) {
    final node = _length;
    if (node == _capacity) _addChunk();
    _length++;
    _write(node, key, parent, from, to, g);
    chunkOf(node)[offsetOf(node) + keyWords + _hClosed] = h;
    return node;
  }

  /// Replaces [node]'s parent, move and depth by a cheaper way to reach the
  /// same state (design §3), and its key by [key], the same canonical key.
  /// Only for a node that was never expanded.
  void reroute(int node, Int32List key, int parent, int from, int to, int g) =>
      _write(node, key, parent, from, to, g);

  /// True when [node]'s key is [key]: the same canonical state.
  bool holds(int node, Int32List key) {
    final rows = _rows[node >> chunkShift];
    final start = (node & _chunkMask) * rowStride;
    for (var i = 0; i < keyWords; i++) {
      if (rows[start + i] != key[i]) return false;
    }
    return true;
  }

  int parent(int node) => _parent[node >> chunkShift][node & _chunkMask];

  int moveFrom(int node) => _moveOf(node) >> 5;

  int moveTo(int node) => _moveOf(node) & 0x1F;

  /// Moves from the searched board to [node].
  int g(int node) => chunkOf(node)[offsetOf(node) + keyWords + _g];

  /// `nestsOnBoard − setsRemaining` of [node] (spec §6.3).
  int h(int node) =>
      chunkOf(node)[offsetOf(node) + keyWords + _hClosed] & 0xFFFF;

  bool isClosed(int node) =>
      (chunkOf(node)[offsetOf(node) + keyWords + _hClosed] & _closedBit) != 0;

  void close(int node) =>
      chunkOf(node)[offsetOf(node) + keyWords + _hClosed] |= _closedBit;

  int _moveOf(int node) => _move[node >> chunkShift][node & _chunkMask];

  void _write(int node, Int32List key, int parent, int from, int to, int g) {
    final chunk = node >> chunkShift;
    final row = node & _chunkMask;
    final start = row * rowStride;
    _rows[chunk]
      ..setRange(start, start + keyWords, key)
      ..[start + keyWords + _g] = g;
    _parent[chunk][row] = parent;
    _move[chunk][row] = (from << 5) | to;
  }

  void _addChunk() {
    final left = limit - _capacity;
    final rows = left < chunkRows ? (left < 1 ? 1 : left) : chunkRows;
    _rows.add(Int32List(rows * rowStride));
    _parent.add(Int32List(rows));
    _move.add(Uint16List(rows));
    _capacity += rows;
  }
}
