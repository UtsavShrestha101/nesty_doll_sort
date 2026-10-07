import 'dart:math' as math;

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// The gift sheet's numbers on a screen (frames 13.3 and 13.3b; tokens
/// `gift.sheet`, `gift.tile` and `gift.short`): the 390×844 values on a
/// tall phone, the 16:9 (390×693) ones on a short one, and in between
/// every number blended on the screen's height, as Home blends 2.1 and
/// 2.1b (`HomeLayout`), so the sheet never jumps between two looks.
@immutable
class GiftSheetMetrics {
  const GiftSheetMetrics._(this.t);

  /// The metrics for a screen [height] tall.
  factory GiftSheetMetrics.forHeight(double height) =>
      GiftSheetMetrics._(((_tall - height) / (_tall - _short)).clamp(0.0, 1.0));

  factory GiftSheetMetrics.of(BuildContext context) =>
      GiftSheetMetrics.forHeight(MediaQuery.sizeOf(context).height);

  /// The two frames' screen heights.
  static const double _tall = 844;
  static const double _short = 693;

  /// 0 on the tall frame, 1 on the short one.
  final double t;

  double _lerp(double tall, double short) => tall + (short - tall) * t;

  double get paddingTop =>
      _lerp(GiftSheetTokens.padding.top, GiftShortTokens.padding.top);

  double get paddingSide => GiftSheetTokens.padding.left;

  /// The frames' bottom: 40 on 844 is the 34 dp home indicator plus 6; the
  /// 16:9 phone has no indicator and keeps 20.
  double paddingBottom(double safeBottom) =>
      math.max(GiftShortTokens.padding.bottom, safeBottom + 6);

  double get titleGap =>
      _lerp(GiftSheetTokens.titleGap, GiftShortTokens.titleGap);
  double get titleHeight =>
      _lerp(GiftSheetTokens.titleHeight, GiftShortTokens.titleHeight);
  double get titleSize =>
      _lerp(GiftTypeTokens.title.fontSize!, GiftTypeTokens.titleShortSize);

  double get subGap => _lerp(GiftSheetTokens.subGap, GiftShortTokens.subGap);
  double get subHeight =>
      _lerp(GiftSheetTokens.subHeight, GiftShortTokens.subHeight);
  double get subSize =>
      _lerp(GiftTypeTokens.sub.fontSize!, GiftTypeTokens.subShortSize);

  double get gridGap => _lerp(GiftSheetTokens.gridGap, GiftShortTokens.gridGap);
  double get tileGap =>
      _lerp(GiftSheetTokens.gridTileGap, GiftShortTokens.gridTileGap);
  double get tileHeight =>
      _lerp(GiftSheetTokens.gridTileHeight, GiftShortTokens.gridTileHeight);

  /// A tile's gift art.
  double get art => _lerp(GiftTileTokens.art, GiftShortTokens.art);

  /// A tile's amount.
  double get amountSize =>
      _lerp(GiftTypeTokens.amount.fontSize!, GiftTypeTokens.amountShortSize);

  /// Day 7's tile sits one tile gap under the grid (the frame's margin).
  double get day7GapAbove => tileGap;
  double get day7Height =>
      _lerp(GiftSheetTokens.day7Height, GiftShortTokens.day7Height);
  Size get day7Chest => Size(
    _lerp(GiftSheetTokens.day7Chest.width, GiftShortTokens.day7Chest.width),
    _lerp(GiftSheetTokens.day7Chest.height, GiftShortTokens.day7Chest.height),
  );

  double get footerGap =>
      _lerp(GiftSheetTokens.footerGap, GiftShortTokens.footerGap);
  double get footerHeight =>
      _lerp(GiftSheetTokens.footerHeight, GiftShortTokens.footerHeight);

  @override
  bool operator ==(Object other) => other is GiftSheetMetrics && other.t == t;

  @override
  int get hashCode => t.hashCode;
}
