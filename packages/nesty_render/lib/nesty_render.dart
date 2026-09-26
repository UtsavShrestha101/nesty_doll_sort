/// Flutter rendering for Nesty: Doll Sort, shared by the game and the admin
/// (spec §13.1). No Flame here, so the admin's `CustomPainter` board can use
/// it too.
library;

export 'package:nesty_render/src/doll_palette.dart';
export 'package:nesty_render/src/doll_renderer.dart';
export 'package:nesty_render/src/tokens/render_token_types.dart';
export 'package:nesty_render/src/tokens/render_tokens.gen.dart';

// TODO(M2): export PlaceholderDollPainter (spec §12.5), BoardLayout
// (spec §10.3), SvgSkinRenderer and SkinCache (spec §12.2; pulled in, D23).
