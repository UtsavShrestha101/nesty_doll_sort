import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_pool.dart';

final class _Item {
  _Item(this.index);

  final int index;
  int resets = 0;
}

void main() {
  test('pool sizes follow m2-lottie-design §14', () {
    expect(
      {
        for (final id in FxId.values)
          if (id.host == FxHost.board) id: FxPoolSizes.of(id),
      },
      {
        FxId.dollPick: 2,
        FxId.dollMove: 2,
        FxId.dollNest: 2,
        FxId.dollSwallow: 2,
        FxId.dollComplete: 2,
        FxId.dollInvalid: 2,
        FxId.dollReveal: 2,
        FxId.fxSelectGlow: 3,
        FxId.fxGlassUnlock: 1,
        FxId.fxIce: 1,
        FxId.fxDustPuff: 4,
        FxId.fxSparkle: 9,
        FxId.uiHintArrow: 1,
        FxId.uiExtraSlot: 2,
      },
    );
  });

  group('FxPool', () {
    late int created;
    late FxPool<_Item> pool;

    setUp(() {
      created = 0;
      pool = FxPool<_Item>(
        capacity: FxPoolSizes.of(FxId.fxSparkle),
        create: (i) {
          created++;
          return _Item(i);
        },
        onRelease: (item) => item.resets++,
      );
    });

    test('makes every item up front and reuses them in steady state', () {
      expect(created, 9);
      final seen = <_Item>{};
      // A long completion burst: sparkles spawned every 60 ms, each living
      // 267 ms (≤ 5 alive), for many batches.
      final alive = <_Item>[];
      for (var tick = 0; tick < 2000; tick++) {
        final item = pool.acquire();
        expect(item, isNotNull);
        seen.add(item!);
        alive.add(item);
        if (alive.length > 5) pool.release(alive.removeAt(0));
      }
      expect(created, 9, reason: 'no item is made after warm-up');
      expect(seen.length, lessThanOrEqualTo(9));
      expect(pool.inUse, 5);
    });

    test('an exhausted pool hands out nothing (the clip is skipped)', () {
      final items = [for (var i = 0; i < 9; i++) pool.acquire()!];
      expect(pool.isExhausted, isTrue);
      expect(pool.acquire(), isNull);
      pool.release(items[4]);
      expect(pool.acquire(), same(items[4]));
    });

    test('release resets once; double and foreign releases are ignored', () {
      final item = pool.acquire()!;
      pool
        ..release(item)
        ..release(item)
        ..release(_Item(99));
      expect(item.resets, 1);
      expect(pool.inUse, 0);
      expect(pool.isBusy(item), isFalse);
    });

    test('releaseAll returns every busy item (a board reset)', () {
      for (var i = 0; i < 4; i++) {
        pool.acquire();
      }
      pool.releaseAll();
      expect(pool.inUse, 0);
      expect(
        [for (var i = 0; i < 9; i++) pool[i].resets].reduce((a, b) => a + b),
        4,
      );
    });
  });
}
