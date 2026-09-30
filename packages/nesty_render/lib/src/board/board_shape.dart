import 'package:flutter/foundation.dart' show immutable;
import 'package:nesty_render/src/board/board_layout_constants.dart';

/// How a slot looks to the layout. The game maps nesty_core's slot views
/// onto these (a broken lock and an emptied tower read back as open slots,
/// m1 design §2), so the layout never needs to know the rules
/// (CLAUDE.md rule 2). Ice is a modifier on any slot (spec §3.4), so every
/// slot gets ice geometry and the painter decides whether to draw it.
enum SlotShapeKind {
  /// Spec §3.1.
  open,

  /// Spec §3.2: the taller tower stand, the "+N" tag and buried silhouettes.
  tower,

  /// Spec §3.3: a glass case over the stand, the sealed doll on its floor.
  locked,

  /// Spec §3.6 and D22: the booster stand, always on the bottom shelf.
  extra,
}

/// One slot as the layout sees it: the nesty_core slot id and its look.
@immutable
final class SlotShape {
  const SlotShape(this.id, this.kind, {this.lockedSize});

  /// The nesty_core slot id (`"r0c1"`, `"x0"`), used to look geometry up.
  final String id;

  final SlotShapeKind kind;

  /// The size of the doll sealed in a [SlotShapeKind.locked] slot's case, or
  /// null (every other kind, or a caller that doesn't know it). The layout
  /// uses it to pick the tall glass case (m7-3 `layout.board.glassCaseTall`:
  /// a sealed doll taller than `GlassCaseTallTokens.minDollHeight`; phase 4
  /// architecture §2.3). Null keeps the normal case.
  final int? lockedSize;

  @override
  bool operator ==(Object other) =>
      other is SlotShape &&
      other.id == id &&
      other.kind == kind &&
      other.lockedSize == lockedSize;

  @override
  int get hashCode => Object.hash(id, kind, lockedSize);

  @override
  String toString() => lockedSize == null
      ? 'SlotShape($id, ${kind.name})'
      : 'SlotShape($id, ${kind.name}, lockedSize: $lockedSize)';
}

/// The board's shape: shelves top to bottom, slots left to right, plus the
/// level's `maxSize` (which sets the pip count and the doll heights, spec
/// §10.3). It is all the layout needs, so the admin can lay out a level it is
/// still editing.
@immutable
final class BoardShape {
  /// Throws [ArgumentError] for a board the layout can't place: 1–4 shelves
  /// (spec §2.1), 1–6 slots per shelf (5 authored at most, 6 with two extra
  /// slots on the bottom shelf, D22), `maxSize` 3–6 and unique, non-empty ids.
  factory BoardShape({
    required List<List<SlotShape>> rows,
    required int maxSize,
  }) {
    if (rows.length < BoardLayoutConstants.minShelves ||
        rows.length > BoardLayoutConstants.maxShelves) {
      throw ArgumentError.value(
        rows.length,
        'rows',
        'a board has ${BoardLayoutConstants.minShelves}–'
            '${BoardLayoutConstants.maxShelves} shelves (spec §2.1)',
      );
    }
    if (maxSize < 3 || maxSize > 6) {
      throw ArgumentError.value(maxSize, 'maxSize', 'must be 3–6 (spec §2.1)');
    }
    final ids = <String>{};
    for (var r = 0; r < rows.length; r++) {
      final row = rows[r];
      if (row.isEmpty || row.length > BoardLayoutConstants.maxSlotsPerRow) {
        throw ArgumentError.value(
          row.length,
          'rows[$r]',
          'a shelf holds 1–${BoardLayoutConstants.maxSlotsPerRow} slots',
        );
      }
      for (final slot in row) {
        if (slot.id.isEmpty) {
          throw ArgumentError.value(slot.id, 'rows[$r]', 'empty slot id');
        }
        if (!ids.add(slot.id)) {
          throw ArgumentError.value(slot.id, 'rows[$r]', 'duplicate slot id');
        }
      }
    }
    return BoardShape._(
      List.unmodifiable([
        for (final row in rows) List<SlotShape>.unmodifiable(row),
      ]),
      maxSize,
    );
  }

  const BoardShape._(this.rows, this.maxSize);

  /// Shelves top to bottom, each left to right. Unmodifiable.
  final List<List<SlotShape>> rows;

  /// The level's biggest doll size (spec §2.1).
  final int maxSize;

  int get shelfCount => rows.length;

  int get slotCount {
    var count = 0;
    for (final row in rows) {
      count += row.length;
    }
    return count;
  }

  /// This board with an extra slot appended to the bottom shelf, which then
  /// re-pitches (D22: "always appended to the bottom shelf"). Throws
  /// [ArgumentError] when the shelf is already at
  /// [BoardLayoutConstants.maxSlotsPerRow] or the id is taken.
  BoardShape withExtraSlot(String id) => BoardShape(
    rows: [
      ...rows.take(rows.length - 1),
      [...rows.last, SlotShape(id, SlotShapeKind.extra)],
    ],
    maxSize: maxSize,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BoardShape ||
        other.maxSize != maxSize ||
        other.rows.length != rows.length) {
      return false;
    }
    for (var r = 0; r < rows.length; r++) {
      final a = rows[r];
      final b = other.rows[r];
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    maxSize,
    Object.hashAll([for (final row in rows) Object.hashAll(row)]),
  );

  @override
  String toString() => 'BoardShape(maxSize: $maxSize, rows: $rows)';
}
