import 'dart:ui' show Size;

import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:nesty_render/nesty_render.dart';

/// Builds a board from one string per shelf, one letter per slot:
/// `o` open, `t` tower, `l` locked, `x` extra. Ids follow nesty_core
/// (`r0c1`, extras `x0`, `x1`).
/// [lockedSize] is the sealed doll's size in every `l` case (null: unknown,
/// which keeps the normal case).
BoardShape board(List<String> rows, {required int maxSize, int? lockedSize}) {
  var extras = 0;
  return BoardShape(
    rows: [
      for (var r = 0; r < rows.length; r++)
        [
          for (var c = 0; c < rows[r].length; c++)
            switch (rows[r][c]) {
              'o' => SlotShape('r${r}c$c', SlotShapeKind.open),
              't' => SlotShape('r${r}c$c', SlotShapeKind.tower),
              'l' => SlotShape(
                'r${r}c$c',
                SlotShapeKind.locked,
                lockedSize: lockedSize,
              ),
              'x' => SlotShape('x${extras++}', SlotShapeKind.extra),
              final other => throw ArgumentError.value(other, 'rows'),
            },
        ],
    ],
    maxSize: maxSize,
  );
}

/// NestyBoard:80–84 `MAIN()` (frame 2.2, Level 56): a tower at r1c0, a
/// glass case at r1c3, ice on r2c1.
final mainBoard = board(['oooo', 'tool', 'ooo'], maxSize: 4);

/// NestyBoard:92–96 `FULL()` (frame 3.5), the board the extra slot joins.
final fullBoard = board(['oooo', 'tol', 'ooo'], maxSize: 4);

/// NestyBoard:90 `TUT1()` (frames 1.3/1.4) on the 2-shelf preset.
final tutorialBoard = board(['ooo', 'ooo'], maxSize: 3);

/// NestyBoard:118–122 `BONUS()` on `L5` (maxSize 5, 3 shelves).
final bonusBoard = board(['oooo', 'oooo', 'ooo'], maxSize: 5);

/// The five screens the hit-rect acceptance covers, with typical safe areas.
const screens = <String, BoardViewport>{
  '360×640': BoardViewport(
    size: Size(360, 640),
    padding: EdgeInsets.only(top: 24),
  ),
  '375×667': BoardViewport(
    size: Size(375, 667),
    padding: EdgeInsets.only(top: 20),
  ),
  '390×844': BoardViewport.reference,
  '430×932': BoardViewport(
    size: Size(430, 932),
    padding: EdgeInsets.only(top: 59, bottom: 34),
  ),
  '768×1024': BoardViewport(
    size: Size(768, 1024),
    padding: EdgeInsets.only(top: 24, bottom: 20),
  ),
};

/// The ±0.5 dp tolerance of the render design §3.
const designTolerance = 0.5;

/// For values that are exact up to floating-point noise.
const exact = 1e-9;
