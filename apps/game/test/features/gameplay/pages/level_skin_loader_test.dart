import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/gameplay/pages/level_skin_loader.dart';
import 'package:nesty_render/nesty_render.dart';

import '../../../helpers/level_fixtures.dart';
import '../../support/controlled_skin_service.dart';

final Level _level = levelFrom(tutorialLevelJson);

final Level _next = levelFrom('''
{
  "schemaVersion": 1,
  "id": "T0102",
  "maxSize": 3,
  "shelves": [
    [ {"type": "open", "nest": ["red3"]},
      {"type": "open", "nest": ["blue3"]},
      {"type": "open", "nest": ["red2", "red1"]} ],
    [ {"type": "open", "nest": ["blue2", "blue1"]},
      {"type": "open", "nest": null},
      {"type": "open", "nest": null} ]
  ]
}
''');

BoardGeometry _geometry({BoardViewport viewport = BoardViewport.reference}) =>
    BoardLayout.compute(
      BoardShape(
        rows: const [
          [
            SlotShape('r0c0', SlotShapeKind.open),
            SlotShape('r0c1', SlotShapeKind.open),
            SlotShape('r0c2', SlotShapeKind.open),
          ],
          [
            SlotShape('r1c0', SlotShapeKind.open),
            SlotShape('r1c1', SlotShapeKind.open),
            SlotShape('r1c2', SlotShapeKind.open),
          ],
        ],
        maxSize: 3,
      ),
      viewport,
    );

/// The level's art behind the page (m2-lottie-design §4 "SkinService"):
/// every layout gets its own, the latest request wins, and nothing leaks.
void main() {
  late ControlledSkinService skins;
  late List<LevelSkin> ready;
  late LevelSkinLoader loader;

  setUp(() {
    skins = ControlledSkinService();
    ready = [];
    loader = LevelSkinLoader(skins, onReady: ready.add);
  });

  Future<void> prepare() => loader.prepare(
    _level,
    geometry: _geometry(),
    devicePixelRatio: 3,
    symbols: DollSymbols.large,
  );

  test('asks the skin service for the level, the DPR and the symbols', () {
    prepare().ignore();
    final request = skins.requests.single;
    expect(request.level, _level);
    expect(request.devicePixelRatio, 3);
    expect(request.symbols, DollSymbols.large);
  });

  test('passes the board theme on, and a prefetch of another theme is not '
      'adopted (m7-4 A.5 board wood)', () async {
    loader
        .prefetch(
          _next,
          geometry: _geometry(),
          devicePixelRatio: 3,
          symbols: DollSymbols.large,
          themeId: 'ch07',
        )
        .ignore();
    expect(skins.requests.single.themeId, 'ch07');
    skins.complete(0);
    final other = loader.prepare(
      _next,
      geometry: _geometry(),
      devicePixelRatio: 3,
      symbols: DollSymbols.large,
      themeId: 'ch08',
    );
    expect(skins.requests, hasLength(2));
    expect(skins.requests.last.themeId, 'ch08');
    skins.complete(1);
    await other;
    expect(ready, hasLength(1));
  });

  test('hands each new skin over, then disposes the one it replaces', () async {
    final first = prepare();
    final a = skins.complete(0);
    await first;
    expect(ready, [a]);
    expect(loader.current, a);

    final second = prepare();
    final b = skins.complete(1);
    await second;
    expect(ready, [a, b]);
    expect(loader.current, b);
    expect(a.disposed, isTrue);
    expect(b.disposed, isFalse);
  });

  test('the latest request wins: an older result is disposed unseen', () async {
    final older = prepare();
    final newer = prepare();
    final b = skins.complete(1);
    await newer;
    final a = skins.complete(0);
    await older;
    expect(ready, [b]);
    expect(loader.current, b);
    expect(a.disposed, isTrue);
    expect(b.disposed, isFalse);
  });

  test('a failure keeps the current skin (rule 3)', () async {
    final first = prepare();
    final a = skins.complete(0);
    await first;
    final second = prepare();
    skins.fail(1);
    await second;
    expect(loader.current, a);
    expect(a.disposed, isFalse);
    expect(ready, [a]);
  });

  test('dispose frees the current skin and any that lands later', () async {
    final first = prepare();
    final a = skins.complete(0);
    await first;
    final late = prepare();
    loader.dispose();
    expect(a.disposeCount, 1);
    expect(loader.current, isNull);
    final b = skins.complete(1);
    await late;
    expect(b.disposed, isTrue);
    expect(ready, [a]);

    loader.dispose();
    expect(a.disposeCount, 1, reason: 'idempotent');
    await prepare();
    expect(skins.requests, hasLength(2), reason: 'no request once disposed');
  });

  group('prefetch (review CORRECTNESS-1)', () {
    Future<void> prefetch({BoardGeometry? geometry, Level? level}) =>
        loader.prefetch(
          level ?? _next,
          geometry: geometry ?? _geometry(),
          devicePixelRatio: 3,
          symbols: DollSymbols.large,
        );

    Future<void> prepareNext({BoardGeometry? geometry}) => loader.prepare(
      _next,
      geometry: geometry ?? _geometry(),
      devicePixelRatio: 3,
      symbols: DollSymbols.large,
    );

    test('prepares ahead without handing it over; the prepare of that '
        'level and layout adopts it at once, asking nothing again', () async {
      final first = prepare();
      final a = skins.complete(0);
      await first;
      final ahead = prefetch();
      expect(skins.requests[1].level, _next);
      final b = skins.complete(1);
      await ahead;
      expect(loader.current, a, reason: 'not handed over yet');
      expect(ready, [a]);

      // An equal layout, computed again (the board's own).
      prepareNext().ignore();
      expect(loader.current, b, reason: 'synchronously');
      expect(ready, [a, b]);
      expect(a.disposed, isTrue);
      expect(b.disposed, isFalse);
      expect(skins.requests, hasLength(2));
    });

    test('one still on its way is waited for, not asked again', () async {
      final ahead = prefetch();
      final prepared = prepareNext();
      expect(loader.current, isNull);
      final b = skins.complete(0);
      await ahead;
      await prepared;
      expect(loader.current, b);
      expect(skins.requests, hasLength(1));
    });

    test('a newer prefetch drops the older: disposed when it lands', () async {
      final older = prefetch();
      final newer = prefetch(level: _level);
      final a = skins.complete(0);
      final b = skins.complete(1);
      await older;
      await newer;
      expect(a.disposed, isTrue);
      expect(b.disposed, isFalse);
      expect(ready, isEmpty);
    });

    test('the same level on another layout (a resize) drops it and asks '
        'again; another level leaves it for its turn', () async {
      final ahead = prefetch();
      final b = skins.complete(0);
      await ahead;
      // The level in play re-laid out: the prefetch stays.
      final current = prepare();
      final a = skins.complete(1);
      await current;
      expect(loader.current, a);
      expect(b.disposed, isFalse);

      final resized = prepareNext(
        geometry: _geometry(
          viewport: const BoardViewport(size: Size(360, 640)),
        ),
      );
      expect(b.disposed, isTrue, reason: 'stale');
      expect(skins.requests, hasLength(3));
      final c = skins.complete(2);
      await resized;
      expect(loader.current, c);
    });

    test('a failed prefetch falls back to a fresh request', () async {
      final ahead = prefetch();
      skins.fail(0);
      await ahead;
      final prepared = prepareNext();
      final b = skins.complete(1);
      await prepared;
      expect(loader.current, b);
    });

    test('dispose drops it', () async {
      final ahead = prefetch();
      final b = skins.complete(0);
      await ahead;
      loader.dispose();
      expect(b.disposed, isTrue);
      await prefetch();
      expect(skins.requests, hasLength(1), reason: 'nothing once disposed');
    });
  });
}
