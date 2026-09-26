// Every SVG in the design handoff carries a ~7.7 KB C2PA provenance manifest
// in <metadata>, declared with xmlns:c2pa on the root. flutter_svg warns on
// the unknown element and the bytes are dead weight in the app bundle, so the
// asset sync strips both before copying (design/README.md, plan Phase 1).
//
// This is a text-level edit on purpose: the rest of the file stays
// byte-identical to the design export, so a diff of an asset against its
// source shows only the removed provenance block.

final _metadataElement = RegExp(
  r'<metadata\b[^>]*?(?:/>|>[\s\S]*?</metadata\s*>)',
);
final _c2paNamespace = RegExp(r'''\s+xmlns:c2pa\s*=\s*(?:"[^"]*"|'[^']*')''');

/// Returns [svg] without its `<metadata>` elements and without the
/// `xmlns:c2pa` namespace declaration. Everything else is left untouched.
///
/// Idempotent: stripping an already stripped file returns it unchanged.
String stripSvgMetadata(String svg) =>
    svg.replaceAll(_metadataElement, '').replaceAll(_c2paNamespace, '');
