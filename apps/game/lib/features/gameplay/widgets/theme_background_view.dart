import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:nesty_render/nesty_render.dart';

/// A chapter theme's background art behind a whole screen (spec §12.4:
/// splash, Home and gameplay; NestyBoard `center top/390px auto` over the
/// theme's colour).
///
/// [background] is the app's one `SkinService.background`: it is
/// rasterized at the screen's size the first time a theme shows and kept
/// until another replaces it. Without it (the fake env) or until the art is
/// ready, or if it fails (rule 3), the theme's fallback colour fills the
/// screen.
///
/// The one [ThemeBackground] is shared by every screen, so this re-asks for
/// its [theme] whenever its route becomes current again (Home after a level
/// of another chapter).
class ThemeBackgroundView extends StatefulWidget {
  const ThemeBackgroundView({required this.theme, this.background, super.key});

  final ChapterTheme theme;
  final ThemeBackground? background;

  @override
  State<ThemeBackgroundView> createState() => _ThemeBackgroundViewState();
}

class _ThemeBackgroundViewState extends State<ThemeBackgroundView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A dependency on the route, so a route that becomes current again
    // re-shows its own theme.
    ModalRoute.of(context);
    _show();
  }

  @override
  void didUpdateWidget(ThemeBackgroundView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.theme != widget.theme ||
        !identical(oldWidget.background, widget.background)) {
      _show();
    }
  }

  void _show() {
    final background = widget.background;
    if (background == null) return;
    final size = MediaQuery.sizeOf(context);
    if (size.isEmpty) return;
    // Rule 3: on any failure the fallback colour stays.
    try {
      unawaited(
        background
            .show(
              widget.theme,
              size: size,
              devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
            )
            .catchError(_log),
      );
    } on Object catch (error, stack) {
      _log(error, stack);
    }
  }

  static void _log(Object error, StackTrace stack) {
    developer.log(
      'the theme background failed',
      name: 'nesty.theme',
      error: error,
      stackTrace: stack,
    );
    // developer.log never reaches the `flutter run` terminal.
    if (kDebugMode) debugPrint('[nesty.theme] background failed: $error');
  }

  @override
  Widget build(BuildContext context) {
    final background = widget.background;
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: background == null
            ? ColoredBox(
                color: widget.theme.fallbackColor,
                child: const SizedBox.expand(),
              )
            : CustomPaint(
                painter: _ThemePainter(background, widget.theme),
                child: const SizedBox.expand(),
              ),
      ),
    );
  }
}

/// The shared background, but only while it shows [theme]: until the art
/// of a newly asked theme is ready its colour fills the screen, never the
/// previous chapter's art.
final class _ThemePainter extends CustomPainter {
  _ThemePainter(this.background, this.theme) : super(repaint: background);

  final ThemeBackground background;
  final ChapterTheme theme;

  final Paint _fill = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    if (background.shownTheme == theme) {
      background.paint(canvas, size);
      return;
    }
    _fill.color = theme.fallbackColor;
    canvas.drawRect(Offset.zero & size, _fill);
  }

  @override
  bool shouldRepaint(_ThemePainter oldDelegate) =>
      !identical(oldDelegate.background, background) ||
      oldDelegate.theme != theme;
}
