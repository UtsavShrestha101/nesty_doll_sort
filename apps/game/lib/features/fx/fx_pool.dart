import 'package:flutter/foundation.dart';
import 'package:nesty_game/features/fx/fx_id.dart';

/// How many clips of a file can be alive at once on the board
/// (m2-lottie-design §14): built when the board is, never per event.
abstract final class FxPoolSizes {
  /// Two batches can overlap (a move while a completion flies), hence two
  /// per doll file; the glow needs the selection, the hint target and one
  /// fading out; sparkles spawn every 60 ms and live 267 ms (≤ 5 at once,
  /// plus margin). The locked and iced slots own one composition each
  /// ([perSlot]).
  static int of(FxId id) => switch (id) {
    FxId.dollPick ||
    FxId.dollMove ||
    FxId.dollNest ||
    FxId.dollSwallow ||
    FxId.dollComplete ||
    FxId.dollInvalid ||
    FxId.dollReveal ||
    FxId.uiExtraSlot => 2,
    FxId.fxSelectGlow => 4,
    FxId.fxDustPuff => 4,
    FxId.fxSparkle => 9,
    FxId.uiHintArrow => 1,
    FxId.fxGlassUnlock || FxId.fxGlassUnlockTall || FxId.fxIce => perSlot,
    // Widget files: one view each where they're shown.
    _ => 1,
  };

  /// `fx_glass_unlock` / `fx_ice`: one paused composition per locked or
  /// iced slot, owned by the slot (§8).
  static const perSlot = 1;
}

/// A fixed set of reusable objects (pooled clips), all made up front by
/// [create]. [acquire] hands out a free one or null when every one is busy
/// (the extra clip is skipped and the rest pose shows, §14); [release]
/// gives it back. Neither allocates (CLAUDE.md rule 8).
final class FxPool<T extends Object> {
  FxPool({
    required int capacity,
    required T Function(int index) create,
    this.onAcquire,
    this.onRelease,
    this.debugLabel = 'fx',
  }) : assert(capacity > 0),
       _items = List.generate(capacity, create, growable: false),
       _busy = List.filled(capacity, false, growable: false);

  final List<T> _items;
  final List<bool> _busy;
  int _inUse = 0;

  /// Called on an item as it is handed out (before the caller configures
  /// it), and as it comes back (reset it here).
  final void Function(T item)? onAcquire;
  final void Function(T item)? onRelease;

  /// Names the pool in the debug log when it runs out.
  final String debugLabel;

  int get capacity => _items.length;
  int get inUse => _inUse;
  bool get isExhausted => _inUse == _items.length;

  /// The pooled item at [index] (for setup that touches every item, such as
  /// a new level's image source).
  T operator [](int index) => _items[index];

  bool isBusy(T item) {
    final i = _indexOf(item);
    return i >= 0 && _busy[i];
  }

  // ── Hot path: acquired and released per event, several per batch. ──

  /// A free item, or null when all [capacity] are busy.
  T? acquire() {
    for (var i = 0; i < _items.length; i++) {
      if (_busy[i]) continue;
      _busy[i] = true;
      _inUse++;
      final item = _items[i];
      onAcquire?.call(item);
      return item;
    }
    _logExhausted();
    return null;
  }

  /// Returns [item]; ignored when it isn't busy (released twice).
  void release(T item) {
    final i = _indexOf(item);
    if (i < 0 || !_busy[i]) return;
    _busy[i] = false;
    _inUse--;
    onRelease?.call(item);
  }

  /// Releases every busy item (a board reset).
  void releaseAll() {
    for (var i = 0; i < _items.length; i++) {
      if (_busy[i]) release(_items[i]);
    }
  }

  int _indexOf(T item) {
    for (var i = 0; i < _items.length; i++) {
      if (identical(_items[i], item)) return i;
    }
    return -1;
  }

  // ── End of hot path. ──

  void _logExhausted() {
    if (kDebugMode) debugPrint('[nesty.fx] pool $debugLabel exhausted');
  }
}
