/// Input gating (docs/plans/m2-lottie-design.md §7): a reserved slot drops
/// taps and drags until its last clip ends.
///
/// Times are the board timeline's clock (ms). Reservations only ever
/// extend: a slot reserved by two batches is free when the later ends.
final class SlotReservations {
  final Map<String, double> _until = {};

  /// Reserves [slotId] until timeline time [untilMs] (or keeps a later
  /// reservation).
  void reserve(String slotId, double untilMs) {
    final current = _until[slotId];
    if (current == null || untilMs > current) _until[slotId] = untilMs;
  }

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  /// Whether [slotId] is reserved at timeline time [nowMs].
  bool isReserved(String slotId, double nowMs) {
    final until = _until[slotId];
    return until != null && until > nowMs;
  }

  /// When [slotId]'s reservation ends, or null if it has none.
  double? until(String slotId) => _until[slotId];

  // ── End of hot path. ──

  /// Every slot reserved at [nowMs], for logs and tests.
  Iterable<String> reservedAt(double nowMs) =>
      _until.keys.where((id) => _until[id]! > nowMs);

  /// A board reset frees every slot.
  void clear() => _until.clear();
}
