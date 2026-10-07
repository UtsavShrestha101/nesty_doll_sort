import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_render/nesty_render.dart';

/// The board's localized "+N" tower tag and ice badge text (ARB
/// `boardTowerHidden`/`boardIceCount`, spec §16), and the direction their
/// digits read in. [SlotDecor] never reads `AppLocalizations` or
/// `Directionality` itself (nesty_render's components stay Flutter-locale
/// free, CLAUDE.md rule 2): the page hands this down through
/// `GameplayBoard.boardLabels` when it builds the board and again whenever
/// the locale can have changed, the same way it hands over [levelSkin]s.
///
/// [fallback] reproduces the ARB's own English pattern ("+3", "2") for a
/// board built before the page's first hand-off lands, and for tests that
/// don't exercise localization (BACKLOG "the Flame board's '+N' tower tag
/// and the ice badge's digits through ARB").
final class BoardLabels {
  const BoardLabels({
    required this.towerTag,
    required this.iceBadge,
    this.textDirection = TextDirection.ltr,
  });

  /// `AppLocalizations.boardTowerHidden(count)`.
  final String Function(int count) towerTag;

  /// `AppLocalizations.boardIceCount(count)`.
  final String Function(int count) iceBadge;

  /// `Directionality.of(context)`. No launch language is RTL yet (l10n.md),
  /// so every real hand-off is `ltr` today too; the field exists so a
  /// future RTL locale doesn't need another round of plumbing.
  final TextDirection textDirection;

  static String _fallbackTag(int count) => '+$count';
  static String _fallbackIce(int count) => '$count';

  static const BoardLabels fallback = BoardLabels(
    towerTag: _fallbackTag,
    iceBadge: _fallbackIce,
  );
}

/// The walnut "+N" tower tag and the blue ice badge of one slot
/// (NestyBoard:16–17, :168, :180; docs/plans/m2-lottie-design.md §8, §9.6):
/// laid out once per label and layout (a cached `TextPainter` per value),
/// then drawn every frame without allocating (CLAUDE.md rule 8). The text
/// itself and its direction come from outside ([BoardLabels]): this class
/// only measures and paints them.
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

  String? _tagText;
  double _tagScale = 0;
  TextDirection _tagDirection = TextDirection.ltr;
  TextPainter? _tag;
  RRect? _tagPill;
  RRect? _tagRingRect;
  Offset _tagTextAt = Offset.zero;

  String? _badgeText;
  double _badgeScale = 0;
  TextDirection _badgeDirection = TextDirection.ltr;
  TextPainter? _badge;
  double _badgeRadius = 0;
  double _badgeRingRadius = 0;
  Offset _badgeEdgeCenter = Offset.zero;
  Offset _badgeTextAt = Offset.zero;
  final Paint _badgeFill = Paint();

  /// The tag's text, for tests: `+N` (through [BoardLabels.towerTag]), or
  /// null when none is laid out.
  String? get tagLabel => _tag?.text?.toPlainText();

  /// The badge's text, for tests.
  String? get badgeLabel => _badge?.text?.toPlainText();

  /// The tag's text direction, for tests: `BoardLabels.textDirection` as
  /// laid out, or null when none is laid out.
  TextDirection? get tagDirection => _tag?.textDirection;

  /// The badge's text direction, for tests.
  TextDirection? get badgeDirection => _badge?.textDirection;

  /// Lays the tag out for [label] (`BoardLabels.towerTag(count)`, already
  /// localized) at furniture scale [scale] reading [direction] (per event).
  /// A null [label] (no buried nests) drops it.
  void setTag(String? label, double scale, TextDirection direction) {
    if (label == _tagText && scale == _tagScale && direction == _tagDirection) {
      return;
    }
    _tagText = label;
    _tagScale = scale;
    _tagDirection = direction;
    _tag?.dispose();
    _tag = null;
    if (label == null) return;
    final text = _label(label, 12 * scale, 14 / 12, tagText, direction);
    final pill = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, text.width + 12 * scale, text.height + 4 * scale),
      Radius.circular(8 * scale),
    );
    _tag = text;
    _tagPill = pill;
    _tagRingRect = pill.inflate(1.5 * scale);
    _tagTextAt = Offset(6 * scale, 2 * scale);
  }

  /// Lays the badge out for [label] (`BoardLabels.iceBadge(count)`, already
  /// localized) at furniture scale [scale] reading [direction], [diameter]
  /// logical px wide (`SlotGeometry.iceBadgeRect`). A null [label] (no ice
  /// left) drops it.
  void setBadge(
    String? label,
    double scale,
    double diameter,
    TextDirection direction,
  ) {
    if (label == _badgeText &&
        scale == _badgeScale &&
        direction == _badgeDirection) {
      return;
    }
    _badgeText = label;
    _badgeScale = scale;
    _badgeDirection = direction;
    _badge?.dispose();
    _badge = null;
    if (label == null) return;
    final radius = diameter / 2;
    final text = _label(label, 16 * scale, 1, badgeRing, direction);
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

  /// Draws the tag with its top-left at ([x], [y]), [scale] times its size
  /// about its centre (the pop-in of a tower whose ice shattered, 0.6 → 1).
  void paintTag(Canvas canvas, double x, double y, [double scale = 1]) {
    final text = _tag;
    if (text == null) return;
    canvas
      ..save()
      ..translate(x, y);
    if (scale != 1) {
      final pill = _tagPill!;
      canvas
        ..translate(pill.width / 2, pill.height / 2)
        ..scale(scale)
        ..translate(-pill.width / 2, -pill.height / 2);
    }
    canvas
      ..drawRRect(_tagRingRect!, _tagRingPaint)
      ..drawRRect(_tagPill!, _tagFillPaint);
    text.paint(canvas, _tagTextAt);
    canvas.restore();
  }

  /// Draws the badge centred on ([x], [y]), [scale] times its size (the
  /// ice counter's bump when its slot is tapped, E.13).
  void paintBadge(Canvas canvas, double x, double y, [double scale = 1]) {
    final text = _badge;
    if (text == null) return;
    canvas
      ..save()
      ..translate(x, y);
    if (scale != 1) canvas.scale(scale);
    canvas
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
    _tagText = null;
    _badgeText = null;
  }

  static TextPainter _label(
    String text,
    double fontSize,
    double height,
    Color color,
    TextDirection direction,
  ) => TextPainter(
    text: TextSpan(
      text: text,
      style: DisplayFace.apply(
        TextStyle(
          // Bundled by the game (pubspec fonts).
          fontFamily: 'Fredoka',
          fontFamilyFallback: AppFontTokens.displayFallback,
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
          height: height,
          color: color,
        ),
      ),
    ),
    textDirection: direction,
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
