/// Flutter rendering for Nesty: Doll Sort, shared by the game and the admin
/// (spec §13.1). No Flame here, so the admin's `CustomPainter` board can use
/// it too.
library;

export 'package:nesty_render/src/board/board_geometry.dart';
export 'package:nesty_render/src/board/board_layout.dart';
export 'package:nesty_render/src/board/board_layout_constants.dart';
export 'package:nesty_render/src/board/board_shape.dart';
export 'package:nesty_render/src/board/board_sprites.dart';
export 'package:nesty_render/src/board/debug_board_painter.dart';
export 'package:nesty_render/src/board/shelf_presets.dart';
export 'package:nesty_render/src/doll/doll_art.dart';
export 'package:nesty_render/src/doll/doll_paint_params.dart';
export 'package:nesty_render/src/doll/doll_painter.dart';
export 'package:nesty_render/src/doll/doll_renderer.dart';
export 'package:nesty_render/src/doll/fallback_doll_renderer.dart';
export 'package:nesty_render/src/doll/part_raster_doll_renderer.dart';
export 'package:nesty_render/src/doll/placeholder_doll_painter.dart';
export 'package:nesty_render/src/doll/svg_skin_renderer.dart';
export 'package:nesty_render/src/palette/color_math.dart'
    show grayLevelOf, hexOf, multiplyByGray, rampColor;
export 'package:nesty_render/src/palette/doll_palette.dart';
export 'package:nesty_render/src/palette/doll_tint.dart';
export 'package:nesty_render/src/raster/svg_raster.dart';
export 'package:nesty_render/src/skin/doll_part_rasters.dart';
export 'package:nesty_render/src/skin/skin_cache.dart';
export 'package:nesty_render/src/skin/skin_image_set.dart';
export 'package:nesty_render/src/skin/skin_layer.dart';
export 'package:nesty_render/src/skin/skin_loader.dart';
export 'package:nesty_render/src/skin/skin_manifest.dart';
export 'package:nesty_render/src/skin/skin_rasterizer.dart';
export 'package:nesty_render/src/skin/svg/skin_svg_splitter.dart';
export 'package:nesty_render/src/skin/svg/svg_color_rewriter.dart';
export 'package:nesty_render/src/skin/symbol_atlas.dart';
export 'package:nesty_render/src/skin/symbol_raster.dart';
export 'package:nesty_render/src/theme/chapter_theme.dart';
export 'package:nesty_render/src/theme/theme_background.dart';
export 'package:nesty_render/src/tokens/render_token_types.dart';
export 'package:nesty_render/src/tokens/render_tokens.gen.dart';
