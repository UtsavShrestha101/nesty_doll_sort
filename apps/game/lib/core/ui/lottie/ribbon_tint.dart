import 'dart:ui' show Color;

import 'package:flutter/painting.dart' show ColorFilter;
import 'package:nesty_render/nesty_render.dart' show ChapterPalette;

/// Tints `ui_chapter_ribbon`'s blue by a chapter's palette (lead note 7;
/// ui-spec-game C4): the file carries no named fill to recolour, so the
/// whole clip goes through one colour matrix.
///
/// The matrix is the linear map that keeps white (the highlight and the
/// label) and sends the file's band `#3D8FDE` to the palette's `accent` and
/// its edge `#2B6BB0` to `accentEdge`; the tails and the fold, which lie
/// between those blues, follow by linearity. Built once per chapter.
// TODO(design): ask whether the two-line plate of frame 4.7 replaces this
// tinted Lottie; the tokens and LOTTIE.md give the one-line ribbon.
abstract final class RibbonTint {
  /// The file's band (`#3D8FDE`) and edge (`#2B6BB0`), as 0–1 triples.
  static const List<double> _band = [61 / 255, 143 / 255, 222 / 255];
  static const List<double> _edge = [43 / 255, 107 / 255, 176 / 255];

  /// The 4×5 colour matrix (row-major, alpha kept) of [palette].
  static List<double> matrixOf(ChapterPalette palette) {
    final a = _triple(palette.accent);
    final e = _triple(palette.accentEdge);
    // Columns of S are white, band, edge; of T white, accent, accentEdge.
    final s = [
      [1.0, _band[0], _edge[0]],
      [1.0, _band[1], _edge[1]],
      [1.0, _band[2], _edge[2]],
    ];
    final t = [
      [1.0, a[0], e[0]],
      [1.0, a[1], e[1]],
      [1.0, a[2], e[2]],
    ];
    final m = _multiply(t, _invert(s));
    return [
      m[0][0], m[0][1], m[0][2], 0, 0, //
      m[1][0], m[1][1], m[1][2], 0, 0,
      m[2][0], m[2][1], m[2][2], 0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  /// The filter for [palette].
  static ColorFilter filterOf(ChapterPalette palette) =>
      ColorFilter.matrix(matrixOf(palette));

  static List<double> _triple(Color c) => [c.r, c.g, c.b];

  static List<List<double>> _multiply(
    List<List<double>> a,
    List<List<double>> b,
  ) => [
    for (var i = 0; i < 3; i++)
      [
        for (var j = 0; j < 3; j++)
          a[i][0] * b[0][j] + a[i][1] * b[1][j] + a[i][2] * b[2][j],
      ],
  ];

  static List<List<double>> _invert(List<List<double>> m) {
    final a = m[0][0], b = m[0][1], c = m[0][2];
    final d = m[1][0], e = m[1][1], f = m[1][2];
    final g = m[2][0], h = m[2][1], i = m[2][2];
    final det = a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g);
    return [
      [(e * i - f * h) / det, (c * h - b * i) / det, (b * f - c * e) / det],
      [(f * g - d * i) / det, (a * i - c * g) / det, (c * d - a * f) / det],
      [(d * h - e * g) / det, (b * g - a * h) / det, (a * e - b * d) / det],
    ];
  }
}
