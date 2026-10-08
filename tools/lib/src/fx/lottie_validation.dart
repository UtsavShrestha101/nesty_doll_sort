import 'dart:math' as math;

import 'package:nesty_tools/src/fx/lottie_contract.dart';
import 'package:nesty_tools/src/fx/lottie_json.dart';

/// One problem with a Lottie export, as `sync_design_assets` and
/// `gen_fx_spec` report it (`<file>: <code>: <message>`).
final class LottieIssue {
  const LottieIssue(this.code, this.message);

  /// Stable identifier, e.g. `expression` (see [LottieIssueCodes]).
  final String code;

  /// Detail with the JSON location (English, for tools only).
  final String message;

  @override
  bool operator ==(Object other) =>
      other is LottieIssue && other.code == code && other.message == message;

  @override
  int get hashCode => Object.hash(code, message);

  @override
  String toString() => '$code: $message';
}

/// The [LottieIssue.code]s.
abstract final class LottieIssueCodes {
  // The file.
  static const notJson = 'notJson';
  static const notObject = 'notObject';
  static const version = 'version';
  static const frameRate = 'frameRate';
  static const inPoint = 'inPoint';
  static const length = 'length';
  static const canvas = 'canvas';
  static const markers = 'markers';

  // The contract's hooks.
  static const imageAssets = 'imageAssets';
  static const imageSize = 'imageSize';
  static const missingRef = 'missingRef';
  static const hooks = 'hooks';
  static const fills = 'fills';

  /// A `<part>_fill` or `<part>_rect` the game keys on (LOTTIE.md m7-4
  /// "Tint and width") is missing, extra or not a fill / rectangle; or a
  /// matte's gradient `<part>_fill` (m7-6) is missing, extra or off its
  /// alpha matte.
  static const namedShapes = 'namedShapes';
  static const text = 'text';
  static const travel = 'travel';
  static const drop = 'drop';

  /// A remapped null (`travel`, `drop`) holds still between two keyframes:
  /// lottie 3.6.1 skips the position callback there (LOTTIE.md v3).
  static const hold = 'hold';

  /// An image layer animates its anchor, position, scale or rotation, which
  /// the image-slot compensation can't follow (LOTTIE.md v3 "Format").
  static const imageTransform = 'imageTransform';

  // Features lottie 3.6.1 can't draw, or the game must not depend on
  // (LOTTIE.md "Format"; m2-lottie-design §16 tools lane). Blocked one by
  // one rather than allow-listed, so trim paths and polystars stay fine.
  static const expression = 'expression';
  static const effect = 'effect';
  static const layerStyle = 'layerStyle';
  static const mergePath = 'mergePath';
  static const lumaMatte = 'lumaMatte';
  static const matteParent = 'matteParent';
  static const threeD = 'threeD';
  static const timeRemap = 'timeRemap';
  static const embeddedImage = 'embeddedImage';
  static const unsupportedLayer = 'unsupportedLayer';
  static const unsupportedShape = 'unsupportedShape';
}

final _version = RegExp(r'^5\.7\.\d+$');

/// Shape item types lottie 3.6.1 parses (`content_model_parser.dart`); any
/// other is dropped with a warning, so it is an issue here. `mm` parses but
/// is blocked separately ([LottieIssueCodes.mergePath]).
const _knownShapeTypes = {
  'gr', 'st', 'gs', 'fl', 'gf', 'tr', 'sh', 'el', 'rc', 'tm', 'sr', 'mm', //
  'rp', 'rd',
};

const _precomp = LottieLayerType.precomp;
const _image = LottieLayerType.image;
const _null = LottieLayerType.nullLayer;
const _text = LottieLayerType.text;

/// Validates one parsed export against [contract]. An empty list means the
/// file ships as is.
List<LottieIssue> validateLottie(Object? json, LottieFileContract contract) {
  if (json is! Map<String, Object?>) {
    return const [
      LottieIssue(LottieIssueCodes.notObject, 'the root is not an object'),
    ];
  }
  final v = _Validator(json, contract)..run();
  return v.issues;
}

final class _Validator {
  _Validator(this.json, this.contract);

  final Map<String, Object?> json;
  final LottieFileContract contract;
  final issues = <LottieIssue>[];

  void add(String code, String message) =>
      issues.add(LottieIssue(code, message));

  late final List<Map<String, Object?>> rootLayers = lottieMaps(json['layers']);
  late final List<Map<String, Object?>> assets = lottieMaps(json['assets']);

  void run() {
    _checkHeader();
    _checkMarkers();
    _checkAssets();
    _walkExpressions(json, r'$');
    _checkLayers(rootLayers, 'layers');
    for (final (i, asset) in assets.indexed) {
      if (asset['layers'] != null) {
        _checkLayers(lottieMaps(asset['layers']), 'assets[$i].layers');
      }
    }
    _checkHooks();
    _checkFills();
    _checkNamedShapes();
    _checkText();
    if (contract.kind == LottieKind.boardSpace) _checkTravel();
    if (contract.dropFrom != null) _checkDrop();
    _checkImageLayers();
  }

  void _checkHeader() {
    final version = json['v'];
    if (version is! String || !_version.hasMatch(version)) {
      add(LottieIssueCodes.version, 'v is $version, expected 5.7.x');
    }
    if (json['fr'] != 60) {
      add(LottieIssueCodes.frameRate, 'fr is ${json['fr']}, expected 60');
    }
    if (json['ip'] != 0) {
      add(LottieIssueCodes.inPoint, 'ip is ${json['ip']}, expected 0');
    }
    final op = json['op'];
    if (op is! num || op != op.roundToDouble() || op != contract.frames) {
      add(
        LottieIssueCodes.length,
        'op is $op, expected ${contract.frames} (LOTTIE.md "Length")',
      );
    }
    if (json['w'] != contract.width || json['h'] != contract.height) {
      add(
        LottieIssueCodes.canvas,
        'canvas is ${json['w']}×${json['h']}, expected '
        '${_n(contract.width)}×${_n(contract.height)} (LOTTIE.md "Canvas")',
      );
    }
    if (json['ddd'] != null && json['ddd'] != 0) {
      add(
        LottieIssueCodes.threeD,
        'the composition is 3D (ddd ${json['ddd']})',
      );
    }
  }

  void _checkMarkers() {
    final markers = <LottieMarker>[];
    for (final m in lottieMaps(json['markers'])) {
      final name = m['cm'];
      final start = m['tm'];
      final duration = m['dr'];
      if (name is! String || start is! num || duration is! num) {
        add(LottieIssueCodes.markers, 'a marker is not {cm, tm, dr}: $m');
        return;
      }
      markers.add(LottieMarker(name, start.toDouble(), duration.toDouble()));
    }
    if (!_sameList(markers, contract.markers)) {
      add(
        LottieIssueCodes.markers,
        'markers are ${markers.isEmpty ? 'none' : markers.join(', ')}, '
        'expected ${contract.markers.isEmpty ? 'none' : contract.markers.join(', ')} '
        '(LOTTIE.md "Segments")',
      );
    }
  }

  void _checkAssets() {
    final ids = <String>{};
    for (final (i, asset) in assets.indexed) {
      final id = asset['id'];
      if (id is! String) {
        add(LottieIssueCodes.imageAssets, 'assets[$i] has no id');
        continue;
      }
      if (asset['layers'] != null) continue; // A precomp.
      final path = asset['p'];
      if (asset['e'] == 1 || (path is String && path.startsWith('data:'))) {
        add(
          LottieIssueCodes.embeddedImage,
          'image asset "$id" is embedded; the game supplies every image '
          '(LOTTIE.md "Image slots")',
        );
      }
      ids.add(id);
      final slot = lottieImageSlotOf(id);
      if (slot == null) {
        add(
          LottieIssueCodes.imageAssets,
          'image asset "$id" is not an image slot (LOTTIE.md "Image slots")',
        );
      } else if (asset['w'] != slot.width || asset['h'] != slot.height) {
        add(
          LottieIssueCodes.imageSize,
          'image asset "$id" is declared ${asset['w']}×${asset['h']}, '
          'expected ${_n(slot.width)}×${_n(slot.height)}',
        );
      }
    }
    if (!_sameSet(ids, contract.imageAssets)) {
      add(
        LottieIssueCodes.imageAssets,
        'image assets are ${_sorted(ids)}, expected '
        '${_sorted(contract.imageAssets)}',
      );
    }
  }

  // Lottie keeps an expression in a property's `x` as a string; easing
  // handles also use `x`, but as numbers.
  void _walkExpressions(Object? node, String path) {
    if (node is Map<String, Object?>) {
      for (final MapEntry(:key, :value) in node.entries) {
        if (key == 'x' && value is String) {
          add(LottieIssueCodes.expression, '$path has an expression');
        } else {
          _walkExpressions(value, '$path.$key');
        }
      }
    } else if (node is List<Object?>) {
      for (final (i, item) in node.indexed) {
        _walkExpressions(item, '$path[$i]');
      }
    }
  }

  void _checkLayers(List<Map<String, Object?>> layers, String where) {
    for (final (i, layer) in layers.indexed) {
      final at = '$where[$i] "${layer['nm']}"';
      final ty = layer['ty'];
      if (ty is! int || ty < _precomp || ty > LottieLayerType.last) {
        add(LottieIssueCodes.unsupportedLayer, '$at has layer type $ty');
      }
      if (layer.containsKey('ef')) {
        add(LottieIssueCodes.effect, '$at has effects (ef)');
      }
      if (layer.containsKey('sy')) {
        add(LottieIssueCodes.layerStyle, '$at has layer styles (sy)');
      }
      if (layer.containsKey('tp')) {
        add(LottieIssueCodes.matteParent, '$at has a matte parent (tp)');
      }
      if (layer.containsKey('tm')) {
        add(LottieIssueCodes.timeRemap, '$at is time-remapped (tm)');
      }
      if (layer['ddd'] != null && layer['ddd'] != 0) {
        add(LottieIssueCodes.threeD, '$at is a 3D layer');
      }
      final tt = layer['tt'];
      if (tt != null && tt != 1 && tt != 2) {
        add(
          LottieIssueCodes.lumaMatte,
          '$at has track matte type $tt; only alpha mattes (1, 2) draw',
        );
      }
      if (ty == _text && contract.textLayers.isEmpty) {
        add(
          LottieIssueCodes.text,
          '$at is a text layer; only ui_family_counter, ui_win_ribbon and '
          'ui_chapter_ribbon have text (LOTTIE.md "Text layers")',
        );
      }
      if (ty == _precomp || ty == _image) {
        final ref = layer['refId'];
        final target = _assetById(ref);
        final wantPrecomp = ty == _precomp;
        if (target == null || (target['layers'] != null) != wantPrecomp) {
          add(
            LottieIssueCodes.missingRef,
            '$at refers to ${wantPrecomp ? 'precomp' : 'image'} "$ref", '
            'which is not in assets',
          );
        }
      }
      _checkShapes(lottieMaps(layer['shapes']), at);
    }
  }

  void _checkShapes(List<Map<String, Object?>> shapes, String at) {
    for (final shape in shapes) {
      final ty = shape['ty'];
      if (ty == 'mm') {
        add(
          LottieIssueCodes.mergePath,
          '$at has a merge path "${shape['nm']}"',
        );
      } else if (!_knownShapeTypes.contains(ty)) {
        add(
          LottieIssueCodes.unsupportedShape,
          '$at has shape type $ty "${shape['nm']}", which lottie drops',
        );
      }
      if (ty == 'gr') _checkShapes(lottieMaps(shape['it']), at);
    }
  }

  void _checkHooks() {
    final names = [for (final l in rootLayers) l['nm']];
    int count(String name) => names.where((n) => n == name).length;

    final sizeNulls = {for (final r in LottieRole.values) r.sizeNull: r};
    final roles = <LottieRole>{};
    for (final layer in rootLayers) {
      final role = sizeNulls[layer['nm']];
      if (role == null) continue;
      roles.add(role);
      if (layer['ty'] != _null) {
        add(LottieIssueCodes.hooks, '"${role.sizeNull}" is not a null layer');
      }
      if (!contract.sizesAuthored &&
          lottieIsAnimated(lottieTransform(layer, 's'))) {
        add(
          LottieIssueCodes.hooks,
          '"${role.sizeNull}" has an animated scale; the game overrides it '
          '(LOTTIE.md "Doll size")',
        );
      }
    }
    if (!_sameSet(roles, contract.roles)) {
      add(
        LottieIssueCodes.hooks,
        'size nulls are ${_sorted(roles.map((r) => r.sizeNull))}, expected '
        '${_sorted(contract.roles.map((r) => r.sizeNull))}',
      );
    }

    // The other scale nulls the runtime drives (`case_size`): like a size
    // null, a null whose scale the game overrides.
    for (final name in contract.scaleNulls) {
      for (final layer in rootLayers.where((l) => l['nm'] == name)) {
        if (layer['ty'] != _null) {
          add(LottieIssueCodes.hooks, '"$name" is not a null layer');
        }
        if (lottieIsAnimated(lottieTransform(layer, 's'))) {
          add(
            LottieIssueCodes.hooks,
            '"$name" has an animated scale; the game overrides it '
            '(LOTTIE.md "Case size")',
          );
        }
      }
    }

    final hooks = {
      for (final n in names)
        if (lottieHookLayers.contains(n)) n! as String,
    };
    if (!_sameSet(hooks, contract.hookLayers)) {
      add(
        LottieIssueCodes.hooks,
        'hook layers are ${_sorted(hooks)}, expected '
        '${_sorted(contract.hookLayers)}',
      );
    }

    for (final name in {
      ...contract.hookLayers,
      ...contract.requiredLayers,
      ...contract.scaleNulls,
      for (final r in contract.roles) r.sizeNull,
    }) {
      final n = count(name);
      if (n == 0 &&
          (contract.requiredLayers.contains(name) ||
              contract.scaleNulls.contains(name))) {
        add(LottieIssueCodes.hooks, 'no root layer "$name"');
      } else if (n > 1) {
        add(
          LottieIssueCodes.hooks,
          '$n root layers are named "$name"; the game keys on it, so it '
          'must be unique',
        );
      }
    }
  }

  void _checkFills() {
    final found = <String>{};
    void visitShapes(List<Map<String, Object?>> shapes, String at) {
      for (final shape in shapes) {
        final name = shape['nm'];
        if (lottieHookFills.contains(name)) {
          if (shape['ty'] == 'fl') {
            found.add(name! as String);
          } else {
            add(
              LottieIssueCodes.fills,
              '$at: "$name" names a ${shape['ty']}, not a fill; the colour '
              'delegate would recolour it',
            );
          }
        }
        if (shape['ty'] == 'gr') visitShapes(lottieMaps(shape['it']), at);
      }
    }

    void visitLayers(List<Map<String, Object?>> layers, String where) {
      for (final (i, layer) in layers.indexed) {
        final at = '$where[$i] "${layer['nm']}"';
        if (lottieHookFills.contains(layer['nm'])) {
          add(
            LottieIssueCodes.fills,
            '$at: a layer is named "${layer['nm']}"; only fills may be',
          );
        }
        visitShapes(lottieMaps(layer['shapes']), at);
      }
    }

    visitLayers(rootLayers, 'layers');
    for (final (i, asset) in assets.indexed) {
      visitLayers(lottieMaps(asset['layers']), 'assets[$i].layers');
    }
    if (!_sameSet(found, contract.fills)) {
      add(
        LottieIssueCodes.fills,
        'hook fills are ${_sorted(found)}, expected ${_sorted(contract.fills)} '
        '(LOTTIE.md "Rim", "Tint")',
      );
    }
  }

  // LOTTIE.md m7-4 "Tint and width": the game reaches each `<part>_fill`
  // with a colour delegate and each `<part>_rect` with a size delegate on
  // `['**', name]`, so the names are exactly the contract's, each on the
  // right shape type (a name may repeat: `tail_fill` is on both tails).
  // LOTTIE.md m7-6: a `<part>_fill` may also be a gradient fill when the
  // contract lists it as a matte fill (`ui_chest`'s `falloff_fill`) and it
  // sits on an alpha matte layer, so it only shapes the layer under it and
  // no delegate ever reaches it.
  void _checkNamedShapes() {
    final fills = <String>{};
    final rects = <String>{};
    final matteFills = <String>{};
    void visitShapes(
      List<Map<String, Object?>> shapes,
      String at, {
      required bool onMatte,
    }) {
      for (final shape in shapes) {
        final name = shape['nm'];
        if (name is String) {
          for (final (suffix, type, found) in [
            ('_fill', 'fl', fills),
            ('_rect', 'rc', rects),
          ]) {
            if (!name.endsWith(suffix)) continue;
            if (shape['ty'] == type) {
              found.add(name);
            } else if (suffix == '_fill' &&
                shape['ty'] == 'gf' &&
                contract.matteFills.contains(name)) {
              matteFills.add(name);
              if (!onMatte) {
                add(
                  LottieIssueCodes.namedShapes,
                  '$at: the matte fill "$name" is not on an alpha matte '
                  '(td 1 over a layer with tt 1 or 2), so it would draw',
                );
              }
            } else {
              add(
                LottieIssueCodes.namedShapes,
                '$at: "$name" names a ${shape['ty']}, not a $type; the '
                'delegate on it would miss',
              );
            }
          }
        }
        if (shape['ty'] == 'gr') {
          visitShapes(lottieMaps(shape['it']), at, onMatte: onMatte);
        }
      }
    }

    void visitLayers(List<Map<String, Object?>> layers, String where) {
      for (final (i, layer) in layers.indexed) {
        // An alpha matte source: `td: 1`, and the next layer takes it as
        // its track matte (1 alpha, 2 inverted alpha; luma is refused
        // elsewhere).
        final next = i + 1 < layers.length ? layers[i + 1] : null;
        final onMatte =
            layer['td'] == 1 && (next?['tt'] == 1 || next?['tt'] == 2);
        visitShapes(
          lottieMaps(layer['shapes']),
          '$where[$i] "${layer['nm']}"',
          onMatte: onMatte,
        );
      }
    }

    visitLayers(rootLayers, 'layers');
    for (final (i, asset) in assets.indexed) {
      visitLayers(lottieMaps(asset['layers']), 'assets[$i].layers');
    }
    if (!_sameSet(fills, contract.tintFills)) {
      add(
        LottieIssueCodes.namedShapes,
        'named fills are ${_sorted(fills)}, expected '
        '${_sorted(contract.tintFills)} (LOTTIE.md "Tint and width")',
      );
    }
    if (!_sameSet(matteFills, contract.matteFills)) {
      add(
        LottieIssueCodes.namedShapes,
        'named matte fills are ${_sorted(matteFills)}, expected '
        '${_sorted(contract.matteFills)} (LOTTIE.md "### m7-6")',
      );
    }
    if (!_sameSet(rects, contract.sizedRects)) {
      add(
        LottieIssueCodes.namedShapes,
        'named rectangles are ${_sorted(rects)}, expected '
        '${_sorted(contract.sizedRects)} (LOTTIE.md "Tint and width")',
      );
    }
  }

  void _checkText() {
    final names = <String>[
      for (final layer in [
        ...rootLayers,
        for (final asset in assets) ...lottieMaps(asset['layers']),
      ])
        if (layer['ty'] == _text) '${layer['nm']}',
    ];
    if (contract.textLayers.isEmpty) return; // Reported per layer.
    if (!_sameSet(names.toSet(), contract.textLayers.toSet()) ||
        names.length != contract.textLayers.length) {
      add(
        LottieIssueCodes.text,
        'text layers are $names, expected ${contract.textLayers}',
      );
    }
  }

  void _checkTravel() {
    final travel = rootLayers.where((l) => l['nm'] == 'travel').firstOrNull;
    if (travel == null) return; // Reported by _checkHooks.
    _checkRemappedNull(
      travel,
      code: LottieIssueCodes.travel,
      from: contract.travelS!,
      to: contract.travelT!,
      fromName: 'S',
      doc: 'LOTTIE.md "Files"',
    );
  }

  // `doll_reveal`'s `drop` lowers the doll from `dropFrom` to (0, 0); the
  // runtime moves its start per tower depth.
  void _checkDrop() {
    final drop = rootLayers.where((l) => l['nm'] == 'drop').firstOrNull;
    if (drop == null) return; // Reported by _checkHooks.
    final keyframes = _checkRemappedNull(
      drop,
      code: LottieIssueCodes.drop,
      from: contract.dropFrom!,
      to: LottiePoint.zero,
      fromName: 'the drop start',
      doc: 'LOTTIE.md "Reveal drop"',
    );
    if (keyframes.isEmpty) return;
    final last = lottiePoint(keyframes.last['s']);
    if (last != null && last != LottiePoint.zero) {
      add(LottieIssueCodes.drop, '"drop" ends at $last, expected (0, 0)');
    }
  }

  /// Checks a null whose position the runtime remaps along [from] → [to]
  /// by projection (`travel`, `drop`), and returns its keyframes. The
  /// projection is exact only for an unparented null with a static zero
  /// anchor on a straight path, and lottie skips the position callback
  /// during a hold, so none is allowed.
  List<Map<String, Object?>> _checkRemappedNull(
    Map<String, Object?> layer, {
    required String code,
    required LottiePoint from,
    required LottiePoint to,
    required String fromName,
    required String doc,
  }) {
    final name = layer['nm'];
    void bad(String why) => add(code, '"$name" $why');

    if (layer['ty'] != _null) bad('is not a null layer');
    if (layer['parent'] != null) {
      bad('has a parent; the remap works in canvas units');
    }
    final anchor = lottieTransform(layer, 'a');
    if (lottieIsAnimated(anchor) || !_isZeroPoint(anchor)) {
      bad('anchor is not a static (0, 0)');
    }
    final position = lottieTransform(layer, 'p');
    if (position == null || position['s'] == true) {
      bad('position is missing or split into x/y');
      return const [];
    }
    if (!lottieIsAnimated(position)) {
      bad('position is not keyframed');
      return const [];
    }
    final keyframes = lottieMaps(position['k']);
    if (keyframes.isEmpty) {
      bad('has no keyframes');
      return const [];
    }
    final dx = to.x - from.x;
    final dy = to.y - from.y;
    final length = math.sqrt(dx * dx + dy * dy);
    for (final (i, kf) in keyframes.indexed) {
      for (final key in const ['ti', 'to']) {
        if (!_isZeroList(kf[key])) {
          bad(
            'keyframe $i has a spatial tangent ($key); the projection is '
            'only exact on a straight path',
          );
        }
      }
      final value = lottiePoint(kf['s']);
      if (value == null) {
        // Older exports end on a keyframe with only a time.
        final timeOnlyEnd = i == keyframes.length - 1 && !kf.containsKey('s');
        if (!timeOnlyEnd) bad('keyframe $i has no point value');
        continue;
      }
      if (i == 0 && value != from) {
        bad('starts at $value, expected $fromName $from ($doc)');
      }
      final cross = (value.x - from.x) * dy - (value.y - from.y) * dx;
      if ((cross / length).abs() > 1e-6) {
        bad('keyframe $i at $value is off the line $from→$to');
      }
    }
    for (final hold in lottieHolds(position)) {
      add(
        LottieIssueCodes.hold,
        '"$name" holds still at ${hold.value} from frame ${_n(hold.start)} '
        'to ${_n(hold.end)}; lottie skips the position callback there, so '
        'the remap would not apply. Start the keyframes where the motion '
        'starts (LOTTIE.md "Travel remap")',
      );
    }
    return keyframes;
  }

  // Image layers are compensated through a static scale and anchor (§3):
  // LOTTIE.md v3 "Format" says an image layer never animates its transform;
  // a lift, bob, pulse, burst or shake goes on a parent null. Opacity may
  // stay animated (it isn't inherited through parenting).
  void _checkImageLayers() {
    void visit(List<Map<String, Object?>> layers, String where) {
      for (final (i, layer) in layers.indexed) {
        if (layer['ty'] != _image) continue;
        for (final (key, what) in const [
          ('a', 'anchor'),
          ('p', 'position'),
          ('s', 'scale'),
          ('r', 'rotation'),
        ]) {
          final prop = lottieTransform(layer, key);
          final animated =
              lottieIsAnimated(prop) ||
              (prop?['s'] == true &&
                  (lottieIsAnimated(_map(prop?['x'])) ||
                      lottieIsAnimated(_map(prop?['y']))));
          if (animated) {
            add(
              LottieIssueCodes.imageTransform,
              '$where[$i] "${layer['nm']}" animates its $what; the image-slot '
              'compensation needs a static transform, so animate a parent '
              'null instead (LOTTIE.md "Format")',
            );
          }
        }
      }
    }

    visit(rootLayers, 'layers');
    for (final (i, asset) in assets.indexed) {
      visit(lottieMaps(asset['layers']), 'assets[$i].layers');
    }
  }

  Map<String, Object?>? _assetById(Object? id) {
    for (final asset in assets) {
      if (asset['id'] == id) return asset;
    }
    return null;
  }
}

Map<String, Object?>? _map(Object? value) =>
    value is Map<String, Object?> ? value : null;

bool _isZeroPoint(Map<String, Object?>? prop) =>
    prop == null || _isZeroList(prop['k']);

bool _isZeroList(Object? value) =>
    value == null ||
    (value is List<Object?> && value.every((v) => v is num && v == 0));

bool _sameList<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _sameSet<T>(Set<T> a, Set<T> b) =>
    a.length == b.length && a.containsAll(b);

List<String> _sorted(Iterable<Object?> values) =>
    [for (final v in values) '$v']..sort();

String _n(double v) => v == v.roundToDouble() ? '${v.toInt()}' : '$v';
