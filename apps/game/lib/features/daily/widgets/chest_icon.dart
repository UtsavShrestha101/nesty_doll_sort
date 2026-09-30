import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/ui/art/ui_art.dart';
import 'package:nesty_game/core/ui/art/ui_art_image.dart';

/// The chest (m7-3 `ui/chest/chest_closed.svg`, `chest_open.svg`; phase 4
/// architecture §3.4): the day strip's and the chest row's closed chest
/// (frame 5.1), the win card's chest row (10.3), Chapters' level-10 mark
/// (18×15) and the reward sequence's fallback when `ui_chest` can't load.
///
/// The art's 180×150 viewBox sets the height: `size × 150 / 180`. It is
/// decorative: its row or card says what it is.
class ChestIcon extends StatelessWidget {
  /// Closed, [size] wide (frame 5.1's chest row).
  const ChestIcon({this.size = 62, super.key}) : open = false;

  /// Open, [size] wide (frames 5.6b, 10.3c: the lid up, the gold inside).
  const ChestIcon.open({this.size = openWidth, super.key}) : open = true;

  /// The open chest's default width (frame 5.6's 200×170 box, M3).
  static const double openWidth = 200;

  final double size;
  final bool open;

  /// The art's height for a [size]-wide chest.
  static double heightFor(double size) =>
      size * UiArt.chestClosed.viewBox.height / UiArt.chestClosed.viewBox.width;

  /// The closed chest's lock, on a [size]-wide icon: the keyhole plate's
  /// centre in the art, (90, 80) of 180×150. Lets a caller (the reward
  /// sequence's idle glint) place something on the lock without the art's
  /// numbers.
  static Offset lockCenter(double size) =>
      Offset(size / 2, heightFor(size) * 80 / 150);

  @override
  Widget build(BuildContext context) => UiArtImage(
    open ? UiArt.chestOpen : UiArt.chestClosed,
    size: Size(size, heightFor(size)),
  );
}
