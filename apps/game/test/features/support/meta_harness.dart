import 'package:flutter/material.dart';
import 'package:nesty_game/core/ui/art/theme_thumbnail_loader.dart';

/// Wraps a meta screen (Home, Chapters, Museum, Records, Shop) in phase 4's
/// fake art: a [FakeThemeThumbnailLoader], so every theme crop stays its
/// `palette.band` and no test decodes a real SVG. (The stars, badges and
/// portraits already draw their empty boxes without a `UiArtLibrary`: rule
/// 3's path.)
///
/// Keep [loader] to read what was asked for.
Widget withFakeArt(Widget child, {FakeThemeThumbnailLoader? loader}) =>
    ThemeThumbnailScope(
      loader: loader ?? FakeThemeThumbnailLoader(),
      child: child,
    );
