import 'dart:math' as math;
import 'dart:ui' as ui show Image;
import 'dart:ui' show Canvas, PictureRecorder, Size;

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:nesty_render/nesty_render.dart'
    show ChapterTheme, loadSvgPicture;

/// Rasterizes the Daily puzzle card's small preview background (docs/plans/
/// m7-design.md §18 "the Daily puzzle card's preview"; NestyMenus `isDaily`:
/// `background: url(ch3-seaside-market.svg) center 42%/cover`).
///
/// This is deliberately not `SkinService.background`, the app's one
/// full-screen `ThemeBackground`: that class holds a single raster at a
/// time, keyed by its own (theme, size, pixel ratio), so a second, small
/// consumer would keep evicting whatever Home or Gameplay is showing full
/// screen. [DailyThemeBackground] reads this instead, and a test can
/// substitute a fake so it never touches the real SVG decode (the same
/// reason the doll art goes through `SkinService`).
abstract interface class DailyBackgroundLoader {
  /// The art for a [box]-sized card at [devicePixelRatio], already cropped
  /// to it; null while it can't be produced (rule 3: the caller keeps its
  /// flat fallback colour). Never throws.
  Future<ui.Image?> rasterize(
    ChapterTheme theme, {
    required Size box,
    required double devicePixelRatio,
  });
}

/// The real loader: `theme.assetKey()`'s bundled SVG, cropped exactly like
/// the frame's CSS (horizontal centre, [verticalAnchor] down), rasterized
/// with `Picture.toImageSync` — not `rasterizePictures`' async `toImage`,
/// which is "genuine async work outside flutter_test's fake time"
/// (`museum_page_test.dart`) and would need `WidgetTester.runAsync` in
/// every screen that ever mounts a `PuzzleCard`.
class AssetDailyBackgroundLoader implements DailyBackgroundLoader {
  const AssetDailyBackgroundLoader({this.bundle});

  /// Overridden by tests; defaults to [rootBundle].
  final AssetBundle? bundle;

  /// The CSS crop's vertical anchor ("42%" in the frame); horizontal is
  /// always centred ("center").
  static const double verticalAnchor = 0.42;

  /// Capped like `ThemeBackground.maxPixelRatio`: this box is a fraction of
  /// a full screen, so the same cap is ample.
  static const double maxPixelRatio = 2;

  @override
  Future<ui.Image?> rasterize(
    ChapterTheme theme, {
    required Size box,
    required double devicePixelRatio,
  }) async {
    if (!box.width.isFinite ||
        !box.height.isFinite ||
        box.width <= 0 ||
        box.height <= 0) {
      return null;
    }
    try {
      final source = await (bundle ?? rootBundle).loadString(theme.assetKey());
      final info = await loadSvgPicture(source);
      try {
        final artWidth = info.size.width;
        final artHeight = info.size.height;
        final scale = math.max(box.width / artWidth, box.height / artHeight);
        final scaledWidth = artWidth * scale;
        final scaledHeight = artHeight * scale;
        final ratio = math.min(devicePixelRatio, maxPixelRatio);
        // CSS `background-position`: the scaled image's origin lands at
        // (box − scaled) × percent (≤ 0 once "cover" fits both axes), so
        // the raster crop offset is its negation, in raster px.
        final left = -((box.width - scaledWidth) / 2) * ratio;
        final top = -((box.height - scaledHeight) * verticalAnchor) * ratio;
        final recorder = PictureRecorder();
        Canvas(recorder)
          ..translate(-left, -top)
          ..scale(scale * ratio)
          ..drawPicture(info.picture);
        final picture = recorder.endRecording();
        try {
          return picture.toImageSync(
            math.max(1, (box.width * ratio).round()),
            math.max(1, (box.height * ratio).round()),
          );
        } finally {
          picture.dispose();
        }
      } finally {
        info.picture.dispose();
      }
    } on Object {
      // Rule 3: a failure keeps the flat fallback colour, never throws.
      return null;
    }
  }
}
