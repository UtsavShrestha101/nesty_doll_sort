/// The rasters a skin is drawn from, one image each per prepared height
/// (docs/plans/design-foundation-m2-design.md §1 "Layer set per height").
///
/// Adjacent groups that always draw together (and are never tinted) share
/// one raster to save draw calls. Paint order for a closed coloured doll:
/// [shadow], [bottomMask], [bottomDetail], symbol, interior rim (open only),
/// [lidMask], [lidOverlay], [bodyShine] — the group order of spec §12.2 with
/// the symbol inserted after `bottom_detail` as design/generator/nesty-doll.js
/// does.
enum SkinLayer {
  /// `shadow`.
  shadow(['shadow']),

  /// `bottom_mask`, gray; tinted at draw time with `BlendMode.modulate`.
  bottomMask(['bottom_mask'], tinted: true),

  /// `bottom_detail`.
  bottomDetail(['bottom_detail']),

  /// `top_mask`, gray; tinted at draw time and lifted with the lid.
  lidMask(['top_mask'], tinted: true, lid: true),

  /// `face` + `top_detail` + `shine_top`, lifted with the lid.
  lidOverlay(['face', 'top_detail', 'shine_top'], lid: true),

  /// `shine_bottom`, drawn after the lid (it is last in the SVG).
  bodyShine(['shine_bottom']),

  /// `bottom_mask` with its grays rewritten through the gold ramp.
  goldBottomMask(['bottom_mask']),

  /// `top_mask` with its grays rewritten through the gold ramp.
  goldLidMask(['top_mask'], lid: true),

  /// The buried-nest silhouette (spec §3.2, D21): both masks tinted wood,
  /// both shines at 45 %, no detail or face (design/README.md "Doll
  /// rendering" step 5). The shadow is left out so the silhouette can also
  /// mask the completion shine; painters draw [shadow] under it.
  silhouette(['bottom_mask', 'top_mask', 'shine_top', 'shine_bottom']);

  const SkinLayer(this.groups, {this.tinted = false, this.lid = false});

  /// The skin groups (spec §12.2 ids) composited into this raster, in order.
  final List<String> groups;

  /// Drawn with the doll colour's modulate filter.
  final bool tinted;

  /// Moves with the lid.
  final bool lid;
}
