import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/fx/asset_fx_library.dart';
import 'package:nesty_game/features/fx/fx_id.dart';

/// The shipped files from disk, with some replaced or missing.
final class _Bundle extends CachingAssetBundle {
  _Bundle({this.missing = const {}, this.replaced = const {}});

  final Set<FxId> missing;
  final Map<FxId, List<int>> replaced;
  final List<String> loads = [];

  @override
  Future<ByteData> load(String key) async {
    loads.add(key);
    for (final id in missing) {
      if (id.assetPath == key) throw FlutterError('Unable to load asset: $key');
    }
    for (final MapEntry(key: id, value: bytes) in replaced.entries) {
      if (id.assetPath == key) {
        return ByteData.sublistView(Uint8List.fromList(bytes));
      }
    }
    // A view into a larger buffer, as a real bundle may hand out.
    final bytes = File(key).readAsBytesSync();
    final padded = Uint8List(bytes.length + 16)
      ..setRange(8, 8 + bytes.length, bytes);
    return ByteData.sublistView(padded, 8, 8 + bytes.length);
  }
}

List<int> _withCanvas(FxId id, int width) {
  final json =
      jsonDecode(File(id.assetPath).readAsStringSync()) as Map<String, Object?>;
  json['w'] = width;
  return utf8.encode(jsonEncode(json));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the splash loader first, then every other file once', () async {
    final bundle = _Bundle();
    final library = AssetFxLibrary(bundle: bundle, yieldToFrames: () async {});
    await library.load();
    expect(bundle.loads.first, FxId.uiSplashLoader.assetPath);
    expect(bundle.loads.toSet().length, FxId.values.length);
    expect(bundle.loads.length, FxId.values.length);
    expect(AssetFxLibrary.loadOrder.toSet(), FxId.values.toSet());
  });

  test('a missing, broken or mismatched file is null and listed; the rest '
      'load; nothing throws (rule 3)', () async {
    final library = AssetFxLibrary(
      bundle: _Bundle(
        missing: {FxId.dollMove},
        replaced: {
          FxId.fxSparkle: utf8.encode('{"v": "5.7.4", "fr": 60, "layers": ['),
          FxId.dollPick: _withCanvas(FxId.dollPick, 161),
        },
      ),
      yieldToFrames: () async {},
    );
    await library.load();
    expect(library.isLoaded, isTrue);
    expect(library.failed, {FxId.dollMove, FxId.fxSparkle, FxId.dollPick});
    for (final id in library.failed) {
      expect(library[id], isNull, reason: id.fileName);
    }
    expect(library[FxId.dollNest], isNotNull);
    expect(library[FxId.uiSplashLoader], isNotNull);
  });

  test('blank is a 1×1 transparent image, null before load', () async {
    final library = AssetFxLibrary(
      bundle: _Bundle(),
      yieldToFrames: () async {},
    );
    expect(library.blank, isNull);
    await library.load();
    final blank = library.blank!;
    expect((blank.width, blank.height), (1, 1));
    final data = await blank.toByteData();
    expect(data!.getUint8(3), 0);
  });

  test('one load; progress climbs to 1 for every listener', () async {
    var yields = 0;
    final library = AssetFxLibrary(
      bundle: _Bundle(),
      yieldToFrames: () async => yields++,
    );
    final first = <double>[];
    final second = <double>[];
    final a = library.load(onProgress: first.add);
    final b = library.load(onProgress: second.add);
    expect(identical(a, b), isTrue);
    await a;
    expect(first.length, FxId.values.length);
    expect(first.last, 1);
    for (var i = 1; i < first.length; i++) {
      expect(first[i], greaterThan(first[i - 1]));
    }
    expect(second, first);
    // Spread over the event loop: a turn between files.
    expect(yields, FxId.values.length - 1);

    final late = <double>[];
    await library.load(onProgress: late.add);
    expect(late, [1]);
  });

  test('a listener that throws does not stop the load', () async {
    final library = AssetFxLibrary(
      bundle: _Bundle(),
      yieldToFrames: () async {},
    );
    await library.load(onProgress: (_) => throw StateError('splash bug'));
    expect(library.isLoaded, isTrue);
    expect(library.failed, isEmpty);
  });
}
