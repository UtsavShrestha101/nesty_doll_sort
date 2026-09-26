import 'package:nesty_core/nesty_core.dart';

/// Which part of a doll to paint.
///
/// The nest animations draw one doll in three passes around another, as the
/// design's nest frame does (design/prototypes/NestyBoard.dc.html: lid, the
/// dark hollow, the guest, then the body below the split), so the doll going
/// in covers the hollow and the host's body covers the doll's lower part
/// (docs/plans/design-foundation-m2-design.md §1):
/// - nesting inside: host [lid] → host [interior] → guest ([full], shadow
///   off) → host [bodyFront];
/// - swallow: moving [lid] → moving [interior] → target ([full]) → moving
///   [bodyFront] (shadow off while it is in the air).
///
/// [body] + [lid] is [full]; [body] is the part for an open doll with
/// nothing inside it.
enum DollPart {
  /// Body and lid.
  full,

  /// Shadow, lower body, belly symbol, interior rim (when open or the lid is
  /// up) and the lower shine.
  body,

  /// The lid: upper body, face, top detail and upper shine, raised by
  /// `DollPaintParams.lidLift`.
  lid,

  /// The interior rim alone (the open doll's hollow), at the body's place,
  /// whatever `open` and `lidLift` say. Drawn before the doll that goes in.
  interior,

  /// [body] without the interior rim, cut at the split line (art y
  /// `SkinTokens.splitY`) like the nest frame's body: drawn over the doll
  /// that goes in, so it hides that doll's lower part and the front of the
  /// hollow.
  bodyFront,
}

/// Belly symbol mode (spec §12.3; settings `symbols`, D19).
enum DollSymbols {
  /// No symbol.
  none,

  /// The default: ink at 94 % in a 110 art-unit box.
  subtle,

  /// Large-symbols mode: a cream disc with an ink ring and the symbol at
  /// 117 art units, fully opaque.
  large,
}

/// Everything a renderer needs to draw one doll in one frame.
///
/// Mutable on purpose: each component owns one instance and rewrites its
/// fields every frame, so painting allocates nothing (CLAUDE.md rule 8).
/// Positions and sizes are logical pixels of the canvas being painted.
final class DollPaintParams {
  DollColor color = DollColor.red;

  /// Doll height: the full 768-unit artboard (design/README.md "Board
  /// layout": the base is at 742/768 of it, the width is 2/3 of it).
  double height = 0;

  /// Where the art's base point (256, 742) lands.
  double baseX = 0;
  double baseY = 0;

  /// How far the lid is raised, as a fraction of [height] (the nest clip
  /// lifts it `MotionTokens.nestLidLiftFraction` = 0.3). The design's
  /// "_open" renders use `SkinManifest.openLidLift` (120 / 768).
  double lidLift = 0;

  /// Draws the interior rim even while [lidLift] is 0 (it is drawn whenever
  /// the lid is raised, as in design/generator/nesty-doll.js).
  bool open = false;

  DollPart part = DollPart.full;
  DollSymbols symbols = DollSymbols.subtle;

  /// Draws the doll's ground shadow (with [DollPart.full], [DollPart.body],
  /// [DollPart.bodyFront] and [silhouette]). A doll inside another, or in the
  /// air above one, turns it off so its shadow doesn't darken the other.
  bool shadow = true;

  /// Paints the buried-nest wood silhouette instead (spec §3.2, D21):
  /// [color], [symbols], [part], [lidLift] and [open] are ignored (it is
  /// always closed and whole).
  bool silhouette = false;

  /// 0–1. Below 1 the doll is drawn through one layer, so overlapping parts
  /// fade as a whole.
  double opacity = 1;

  /// Scale about the base point (squash, pick-up, fly-away).
  double scaleX = 1;
  double scaleY = 1;

  /// Rotation about the base point, in radians (clockwise on screen).
  double rotation = 0;

  /// Completion shine sweep progress 0–1 (tokens `motion.complete.shine`),
  /// or −1 for none.
  double shine = -1;

  /// Tower reveal (spec §3.2): progress 0–1 of the circular paint wipe from
  /// (50 %, 62 %) of the doll over its silhouette, or −1 for none.
  double reveal = -1;

  /// Restores every field to its default.
  void reset() {
    color = DollColor.red;
    height = 0;
    baseX = 0;
    baseY = 0;
    lidLift = 0;
    open = false;
    part = DollPart.full;
    symbols = DollSymbols.subtle;
    shadow = true;
    silhouette = false;
    opacity = 1;
    scaleX = 1;
    scaleY = 1;
    rotation = 0;
    shine = -1;
    reveal = -1;
  }

  /// Copies every field of [other] (no allocation).
  void copyFrom(DollPaintParams other) {
    color = other.color;
    height = other.height;
    baseX = other.baseX;
    baseY = other.baseY;
    lidLift = other.lidLift;
    open = other.open;
    part = other.part;
    symbols = other.symbols;
    shadow = other.shadow;
    silhouette = other.silhouette;
    opacity = other.opacity;
    scaleX = other.scaleX;
    scaleY = other.scaleY;
    rotation = other.rotation;
    shine = other.shine;
    reveal = other.reveal;
  }
}
