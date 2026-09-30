import 'dart:async';
import 'dart:ui' as ui show Image;

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/features/daily/widgets/daily_background_loader.dart';
import 'package:nesty_render/nesty_render.dart' show ChapterTheme;

/// The chapter background under the puzzle card's plank (NestyMenus
/// `isDaily`: `background: url(ch3-seaside-market.svg) center 42%/cover`;
/// docs/plans/m7-design.md §18 "the Daily puzzle card's preview", the
/// `TODO(M7)` `puzzle_card.dart` carried). Always Seaside Market: the frame
/// fixes it regardless of the player's own chapter.
///
/// Reads a [DailyBackgroundLoader] from the tree (`DailyPage.wrappedRoute`
/// provides the real one; tests provide a fake, the same wiring as
/// `SkinService`), and paints its raster once ready. Falls back to the
/// theme's flat colour while it loads or if the asset can't be rasterized
/// (rule 3).
class DailyThemeBackground extends StatefulWidget {
  const DailyThemeBackground({this.theme = ChapterTheme.ch03, super.key});

  final ChapterTheme theme;

  @override
  State<DailyThemeBackground> createState() => DailyThemeBackgroundState();
}

/// Public only so `puzzle_card_test.dart` can read [image] (the regression
/// test for the fix above).
@visibleForTesting
class DailyThemeBackgroundState extends State<DailyThemeBackground> {
  ui.Image? _image;
  Size? _preparedFor;
  Size? _scheduledFor;
  int _request = 0;

  /// The rasterized art, once the loader lands; null while loading or on
  /// failure.
  ui.Image? get image => _image;

  void _releaseImage() {
    _image?.dispose();
    _image = null;
  }

  @override
  void didUpdateWidget(DailyThemeBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.theme != widget.theme) {
      _preparedFor = null;
      _scheduledFor = null;
      _releaseImage();
    }
  }

  void _scheduleIfNeeded(Size box, double devicePixelRatio) {
    if (box.isEmpty || !box.width.isFinite || !box.height.isFinite) return;
    if (box == _preparedFor || box == _scheduledFor) return;
    _scheduledFor = box;
    final loader = context.read<DailyBackgroundLoader>();
    final request = ++_request;
    unawaited(
      loader
          .rasterize(widget.theme, box: box, devicePixelRatio: devicePixelRatio)
          .then((image) {
            if (!mounted || request != _request) {
              image?.dispose();
              return;
            }
            _preparedFor = box;
            if (image == null) return;
            setState(() {
              _releaseImage();
              _image = image;
            });
          }),
    );
  }

  @override
  void dispose() {
    _request++;
    _releaseImage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      _scheduleIfNeeded(
        constraints.biggest,
        MediaQuery.devicePixelRatioOf(context),
      );
      final image = _image;
      return DecoratedBox(
        decoration: BoxDecoration(color: widget.theme.fallbackColor),
        child: image == null
            ? const SizedBox.expand()
            : SizedBox.expand(
                child: CustomPaint(painter: _ThemeRasterPainter(image)),
              ),
      );
    },
  );
}

class _ThemeRasterPainter extends CustomPainter {
  const _ThemeRasterPainter(this.image);

  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = FilterQuality.low;
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ThemeRasterPainter oldDelegate) =>
      !identical(oldDelegate.image, image);
}
