import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:nesty_render/nesty_render.dart';

/// The walnut "+N" tower tag and the blue ice badge of one slot
/// (NestyBoard:16–17, :168, :180; docs/plans/m2-lottie-design.md §8, §9.6):
/// laid out once per count and layout (a cached `TextPainter` per value),
/// then drawn every frame without allocating (CLAUDE.md rule 8).
///
/// Both are built in local coordinates (the tag from its top-left, the badge
/// from its centre), so a shake or a re-pitch only translates the canvas.
final class SlotDecor {
  /// NestyBoard:16: `#7B4824` pill, 1.5 dp `#FFF4E0` ring, `#FFEFD6` Fredoka
  /// 700 12/14, padding 2 × 6, radius 8.
  static const tagFill = Color(0xFF7B4824);
  static const tagRing = Color(0xFFFFF4E0);
  static const tagText = Color(0xFFFFEFD6);

  /// NestyBoard:17: `#6FB4EA → #3E8EDE`, a 2.5 dp white ring and a
  /// `#2B6CB0` edge 3 dp below, white Fredoka 700 16.
  static const badgeTop = Color(0xFF6FB4EA);
  static const badgeBottom = Color(0xFF3E8EDE);
  static const badgeRing = Color(0xFFFFFFFF);
  static const badgeEdge = Color(0xFF2B6CB0);

  static final Paint _tagFillPaint = Paint()..color = tagFill;
  static final Paint _tagRingPaint = Paint()..color = tagRing;
  static final Paint _badgeEdgePaint = Paint()..color = badgeEdge;
  static final Paint _badgeRingPaint = Paint()..color = badgeRing;

  int _tagCount = 0;
  double _tagScale = 0;
  TextPainter? _tag;
  RRect? _tagPill;
  RRect? _tagRingRect;
  Offset _tagTextAt = Offset.zero;

  int _badgeCount = 0;
  double _badgeScale = 0;
  TextPainter? _badge;
  double _badgeRadius = 0;
  double _badgeRingRadius = 0;
  Offset _badgeEdgeCenter = Offset.zero;
  Offset _badgeTextAt = Offset.zero;
  final Paint _badgeFill = Paint();

  /// The tag's text, for tests: `+N`, or null when none is laid out.
  String? get tagLabel => _tag?.text?.toPlainText();

  /// The badge's text, for tests.
  String? get badgeLabel => _badge?.text?.toPlainText();

  /// Lays the tag out for [count] buried nests at furniture scale [scale]
  /// (per event). A count of 0 drops it.
  void setTag(int count, double scale) {
    if (count == _tagCount && scale == _tagScale) return;
    _tagCount = count;
    _tagScale = scale;
    _tag?.dispose();
    _tag = null;
    if (count <= 0) return;
    // TODO(M7): the "+N" tag and the badge's digits through ARB, with the
    // locale's text direction, when translations land (spec §16); every
    // launch language writes "+3" this way (review PERF-RULES-3).
    final text = _label('+$count', 12 * scale, 14 / 12, tagText);
    final pill = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, text.width + 12 * scale, text.height + 4 * scale),
      Radius.circular(8 * scale),
    );
    _tag = text;
    _tagPill = pill;
    _tagRingRect = pill.inflate(1.5 * scale);
    _tagTextAt = Offset(6 * scale, 2 * scale);
  }

  /// Lays the badge out for [count] remaining ice at furniture scale
  /// [scale], [diameter] logical px wide (`SlotGeometry.iceBadgeRect`). A
  /// count of 0 drops it.
  void setBadge(int count, double scale, double diameter) {
    if (count == _badgeCount && scale == _badgeScale) return;
    _badgeCount = count;
    _badgeScale = scale;
    _badge?.dispose();
    _badge = null;
    if (count <= 0) return;
    final radius = diameter / 2;
    final text = _label('$count', 16 * scale, 1, badgeRing);
    _badge = text;
    _badgeRadius = radius;
    _badgeRingRadius = radius + 2.5 * scale;
    _badgeEdgeCenter = Offset(0, 3 * scale);
    _badgeTextAt = Offset(-text.width / 2, -text.height / 2);
    _badgeFill.shader = ui.Gradient.linear(
      Offset(0, -radius),
      Offset(0, radius),
      const [badgeTop, badgeBottom],
    );
  }

  bool get hasTag => _tag != null;

  bool get hasBadge => _badge != null;

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  /// Draws the tag with its top-left at ([x], [y]).
  void paintTag(Canvas canvas, double x, double y) {
    final text = _tag;
    if (text == null) return;
    canvas
      ..save()
      ..translate(x, y)
      ..drawRRect(_tagRingRect!, _tagRingPaint)
      ..drawRRect(_tagPill!, _tagFillPaint);
    text.paint(canvas, _tagTextAt);
    canvas.restore();
  }

  /// Draws the badge centred on ([x], [y]).
  void paintBadge(Canvas canvas, double x, double y) {
    final text = _badge;
    if (text == null) return;
    canvas
      ..save()
      ..translate(x, y)
      ..drawCircle(_badgeEdgeCenter, _badgeRingRadius, _badgeEdgePaint)
      ..drawCircle(Offset.zero, _badgeRingRadius, _badgeRingPaint)
      ..drawCircle(Offset.zero, _badgeRadius, _badgeFill);
    text.paint(canvas, _badgeTextAt);
    canvas.restore();
  }

  // ── End of hot path. ──

  void dispose() {
    _tag?.dispose();
    _tag = null;
    _badge?.dispose();
    _badge = null;
    _tagCount = 0;
    _badgeCount = 0;
  }

  static TextPainter _label(
    String text,
    double fontSize,
    double height,
    Color color,
  ) => TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        // Bundled by the game (pubspec fonts).
        fontFamily: 'Fredoka',
        fontWeight: FontWeight.w700,
        fontSize: fontSize,
        height: height,
        color: color,
      ),
    ),
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.noScaling,
  )..layout();
}

/// Keeps `BoardSpriteImage` draws allocation-free when the destination
/// isn't a precomputed `Rect` (a re-pitch lerp): the sprite's full design
/// box goes into (left, top, width, height), exactly as
/// `BoardSpriteImage.draw` does.
abstract final class SpriteDraw {
  static final Paint _paint = Paint()..filterQuality = FilterQuality.low;

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  static void box(
    Canvas canvas,
    BoardSpriteImage sprite,
    double left,
    double top,
    double width,
    double height, [
    Paint? paint,
  ]) {
    canvas
      ..save()
      ..translate(left, top)
      ..scale(width / sprite.fullWidth, height / sprite.fullHeight)
      ..drawImage(sprite.image, sprite.offset, paint ?? _paint)
      ..restore();
  }

  // ── End of hot path. ──
}
