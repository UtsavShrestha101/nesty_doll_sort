import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/art/ui_art.dart';
import 'package:nesty_game/core/ui/art/ui_art_library.dart';

/// One [UiArt] in a [size] box (phase 4 architecture §3.4): the
/// [UiArtLibrary]'s raster for that box at the screen's pixel ratio, the art
/// fitted inside and centred.
///
/// Until the raster lands, and for good when the art can't load (or in a
/// test without art), it is an empty box of the same size, so the layout
/// never jumps (rule 3). The game ships no SVG widget: flutter_svg stays
/// behind `nesty_render`'s rasterizer (no new package, rule 9).
///
/// With a [semanticLabel] it is an image to screen readers; without one it
/// is excluded (decorative, or labelled by its parent).
class UiArtImage extends StatefulWidget {
  const UiArtImage(
    this.art, {
    required this.size,
    this.semanticLabel,
    this.library,
    super.key,
  });

  /// A square [extent] box.
  UiArtImage.square(
    this.art, {
    required double extent,
    this.semanticLabel,
    this.library,
    super.key,
  }) : size = Size(extent, extent);

  final UiArt art;

  /// The logical box, in dp.
  final Size size;

  /// What a screen reader says; null excludes the image from semantics.
  final String? semanticLabel;

  /// Overrides `UiArtLibrary.of(context)` (tests).
  final UiArtLibrary? library;

  @override
  State<UiArtImage> createState() => _UiArtImageState();
}

class _UiArtImageState extends State<UiArtImage> {
  UiArtLibrary? _library;
  double? _pixelRatio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attach();
  }

  @override
  void didUpdateWidget(UiArtImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.art != widget.art ||
        oldWidget.size != widget.size ||
        oldWidget.library != widget.library) {
      _pixelRatio = null;
      _attach();
    }
  }

  void _attach() {
    final library = widget.library ?? UiArtLibrary.of(context);
    if (!identical(library, _library)) {
      _library?.changes.removeListener(_onChanged);
      _library = library;
      library?.changes.addListener(_onChanged);
      _pixelRatio = null;
    }
    final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    if (library == null || ratio == _pixelRatio) return;
    _pixelRatio = ratio;
    if (library.imageOf(widget.art, widget.size) == null) {
      unawaited(
        library.prepare(
          [widget.art],
          sizes: [widget.size],
          devicePixelRatio: ratio,
        ),
      );
    }
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _library?.changes.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _library?.imageOf(widget.art, widget.size);
    final box = SizedBox.fromSize(
      size: widget.size,
      child: image == null
          ? null
          : RawImage(
              image: image,
              width: widget.size.width,
              height: widget.size.height,
              filterQuality: FilterQuality.medium,
            ),
    );
    final label = widget.semanticLabel;
    return label == null
        ? ExcludeSemantics(child: box)
        : Semantics(
            image: true,
            label: label,
            child: ExcludeSemantics(child: box),
          );
  }
}
