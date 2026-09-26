import 'package:flame/components.dart';

/// The shelves, slots and nests of one level.
///
/// Flame components never own game truth (CLAUDE.md rule 10): this will only
/// render state handed to it and animate `MoveEvent`s.
///
/// TODO(M2): render from nesty_core's `GameSession` via nesty_render's
/// `BoardLayout` (spec §10.3) with `SlotComponent` / `NestComponent`
/// children, play §11.1 animations from `MoveEvent`s in order (spec §4), and
/// forward tap-tap / drag input (spec §2.2) to the gameplay controller. Skin
/// layers are rasterized once into cached `ui.Image`s; nothing allocates per
/// frame (rule 8).
class BoardComponent extends PositionComponent {}
