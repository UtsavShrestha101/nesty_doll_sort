#!/usr/bin/env bash
# Rebuilds the bundled fonts in apps/game/assets/fonts from pinned upstream
# sources, reproducibly (the game is offline-first, so fonts ship in the app:
# design/README.md "Typography & icons", tokens.json `font`).
#
#   tools/fonts/build_fonts.sh           download, build, install, regenerate
#                                        nesty_icons.gen.dart
#   tools/fonts/build_fonts.sh --verify  build into a temp dir and compare
#                                        with the committed files (no writes)
#
# Needs: bash, curl, python3 (a throwaway venv gets fontTools), shasum, dart.
#
# Sources (pinned by commit; raw URLs at a commit SHA are immutable):
#   google/fonts @ GOOGLE_FONTS_SHA
#     ofl/fredoka/Fredoka[wdth,wght].ttf + OFL.txt   (SIL OFL 1.1)
#     ofl/nunito/Nunito[wght].ttf + OFL.txt          (SIL OFL 1.1)
#   google/material-design-icons @ MATERIAL_ICONS_SHA
#     variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf
#     variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].codepoints
#     LICENSE                                        (Apache 2.0)
#
# Upstream ships variable fonts only, so static instances are cut with
# fontTools varLib.instancer:
#   Fredoka  wdth=100, wght=500/600/700      → Fredoka-{Medium,SemiBold,Bold}.ttf
#   Nunito   wght=500/600/700/800            → Nunito-{Medium,SemiBold,Bold,ExtraBold}.ttf
#   Symbols  bake the FILL=1 glyph swap into the cmap
#            (bake_feature_variations.py), subset to tools/fonts/nesty_symbols.txt
#            (codepoints only, no layout tables), then FILL=1 wght=600 GRAD=0
#            opsz=24                         → NestySymbolsRounded.ttf
#            At FILL=1 Material Symbols swaps most icons (32 of our 48) for a
#            separate `<name>.fill` glyph through GSUB FeatureVariations (`rclt`
#            at FILL >= 0.99). Subsetting drops GSUB, which would leave the
#            gvar-interpolated outline glyph, whose hole collapses into a pair
#            of coincident, opposite-winding contours: it looks filled but is
#            not the glyph upstream draws (or the prototypes show), and larger.
# SOURCE_DATE_EPOCH pins the font `head` timestamps, so the output bytes (and
# tools/fonts/SHA256SUMS) are stable across runs and machines with the same
# fontTools version.
set -euo pipefail

GOOGLE_FONTS_SHA=8b0a1d0f5983c89bc2b93f1b5fb55f9e252744b5
MATERIAL_ICONS_SHA=bd8cb85bd4bad964fe6918f79665bb40c3a8efef
FONTTOOLS_VERSION=4.60.1
export SOURCE_DATE_EPOCH=1767225600 # 2026-01-01T00:00:00Z

# SHA-256 of the downloaded inputs (a mismatch means upstream bytes changed).
# A function, not an associative array: macOS ships bash 3.2.
input_sha256() {
  case "$1" in
    Fredoka-VF.ttf) echo 2ba02e68b152868aef9ba28e24b3648c7d457fe6f25c761f2c2c53fb61a73fc8 ;;
    Fredoka-OFL.txt) echo 5c9e7eee5c6b25f4b05b8d53b2e470ea4962f9ced742d044a98f7d95d1375bab ;;
    Nunito-VF.ttf) echo bb55a5ca5c2042335b3991af27c4d0705d0ef41cac6164ac737fd8f2a1e85207 ;;
    Nunito-OFL.txt) echo 580df76c95a1ec5ab878ceb25bb3d85c6a076804e9c970c8c6972aea775fdf65 ;;
    MaterialSymbols-VF.ttf) echo c2182b6337495e64cc9e2311c52522567ac277d25a842bd027f9c9e3a5cc6d86 ;;
    MaterialSymbols.codepoints) echo 225bd09137103cb7746bc93dc08d08764c9f0c3bd04f4b958d4a3c3c19432dd6 ;;
    MaterialSymbols-LICENSE.txt) echo 58d1e17ffe5109a7ae296caafcadfdbe6a7d176f0bc4ab01e12a689b0499d8bd ;;
    *) echo "unpinned input $1" >&2; exit 1 ;;
  esac
}

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
DEST="$ROOT/apps/game/assets/fonts"
GLYPHS="$HERE/nesty_symbols.txt"
SUMS="$HERE/SHA256SUMS"

VERIFY=false
case "${1:-}" in
  "") ;;
  --verify) VERIFY=true ;;
  *) echo "usage: $0 [--verify]" >&2; exit 64 ;;
esac

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
OUT="$WORK/out"
mkdir -p "$OUT"

echo "==> fontTools $FONTTOOLS_VERSION (throwaway venv)"
python3 -m venv "$WORK/venv"
"$WORK/venv/bin/pip" install --quiet --disable-pip-version-check \
  "fonttools==$FONTTOOLS_VERSION"
FT="$WORK/venv/bin/fonttools"
SUBSET="$WORK/venv/bin/pyftsubset"

fetch() { # <name> <url>
  curl -fsSL --retry 3 -o "$WORK/$1" "$2"
  local got
  got="$(shasum -a 256 "$WORK/$1" | cut -d' ' -f1)"
  local want
  want="$(input_sha256 "$1")"
  if [[ "$got" != "$want" ]]; then
    echo "SHA-256 mismatch for $1: got $got, pinned $want" >&2
    exit 1
  fi
}

echo "==> Downloading pinned sources"
GF="https://raw.githubusercontent.com/google/fonts/$GOOGLE_FONTS_SHA/ofl"
MDI="https://raw.githubusercontent.com/google/material-design-icons/$MATERIAL_ICONS_SHA"
fetch Fredoka-VF.ttf "$GF/fredoka/Fredoka%5Bwdth,wght%5D.ttf"
fetch Fredoka-OFL.txt "$GF/fredoka/OFL.txt"
fetch Nunito-VF.ttf "$GF/nunito/Nunito%5Bwght%5D.ttf"
fetch Nunito-OFL.txt "$GF/nunito/OFL.txt"
fetch MaterialSymbols-VF.ttf \
  "$MDI/variablefont/MaterialSymbolsRounded%5BFILL,GRAD,opsz,wght%5D.ttf"
fetch MaterialSymbols.codepoints \
  "$MDI/variablefont/MaterialSymbolsRounded%5BFILL,GRAD,opsz,wght%5D.codepoints"
fetch MaterialSymbols-LICENSE.txt "$MDI/LICENSE"

echo "==> Static instances"
instance() { # <input> <output> <axis=value>...
  local input="$1" output="$2"
  shift 2
  "$FT" varLib.instancer --quiet --update-name-table \
    -o "$OUT/$output" "$WORK/$input" "$@"
}
instance Fredoka-VF.ttf Fredoka-Medium.ttf wght=500 wdth=100
instance Fredoka-VF.ttf Fredoka-SemiBold.ttf wght=600 wdth=100
instance Fredoka-VF.ttf Fredoka-Bold.ttf wght=700 wdth=100
instance Nunito-VF.ttf Nunito-Medium.ttf wght=500
instance Nunito-VF.ttf Nunito-SemiBold.ttf wght=600
instance Nunito-VF.ttf Nunito-Bold.ttf wght=700
instance Nunito-VF.ttf Nunito-ExtraBold.ttf wght=800

echo "==> NestySymbolsRounded subset"
# name → codepoint for exactly the listed glyphs, in list order.
names=()
while IFS= read -r line; do
  line="${line%%#*}"
  line="${line//[[:space:]]/}"
  [[ -n "$line" ]] && names+=("$line")
done <"$GLYPHS"
: >"$OUT/NestySymbolsRounded.codepoints"
unicodes=()
for name in "${names[@]}"; do
  cp="$(awk -v n="$name" '$1 == n { print $2; exit }' "$WORK/MaterialSymbols.codepoints")"
  if [[ -z "$cp" ]]; then
    echo "Glyph \"$name\" is not in Material Symbols Rounded @ $MATERIAL_ICONS_SHA" >&2
    exit 1
  fi
  printf '%s %s\n' "$name" "$cp" >>"$OUT/NestySymbolsRounded.codepoints"
  unicodes+=("U+$cp")
done
# The design's icon settings (tokens.json font.icon.settings).
SYMBOL_AXES=(FILL=1 wght=600 GRAD=0 opsz=24)
# Point each codepoint at the glyph the font draws at SYMBOL_AXES (the
# `<name>.fill` swap lives in GSUB, which the subset below drops).
"$WORK/venv/bin/python" "$HERE/bake_feature_variations.py" \
  "$WORK/MaterialSymbols-VF.ttf" "$WORK/MaterialSymbols-baked.ttf" \
  "${SYMBOL_AXES[@]}"
# Codepoint lookup only: the ligature tables (GSUB) are most of the font.
"$SUBSET" "$WORK/MaterialSymbols-baked.ttf" \
  --unicodes="$(IFS=,; echo "${unicodes[*]}")" \
  --layout-features='' --no-hinting --notdef-outline \
  --output-file="$WORK/MaterialSymbols-subset.ttf"
"$FT" varLib.instancer --quiet -o "$OUT/NestySymbolsRounded.ttf" \
  "$WORK/MaterialSymbols-subset.ttf" "${SYMBOL_AXES[@]}"

cp "$WORK/Fredoka-OFL.txt" "$OUT/Fredoka-OFL.txt"
cp "$WORK/Nunito-OFL.txt" "$OUT/Nunito-OFL.txt"
cp "$WORK/MaterialSymbols-LICENSE.txt" "$OUT/MaterialSymbols-LICENSE.txt"

(cd "$OUT" && LC_ALL=C shasum -a 256 -- * | LC_ALL=C sort -k2) >"$WORK/SHA256SUMS"

if $VERIFY; then
  echo "==> Verifying against apps/game/assets/fonts and $SUMS"
  status=0
  if ! diff -u "$SUMS" "$WORK/SHA256SUMS"; then status=1; fi
  (cd "$DEST" && LC_ALL=C shasum -a 256 -c "$WORK/SHA256SUMS") || status=1
  exit $status
fi

echo "==> Installing into ${DEST#"$ROOT"/}"
mkdir -p "$DEST"
cp "$OUT"/* "$DEST/"
cp "$WORK/SHA256SUMS" "$SUMS"
cat "$SUMS"

echo "==> Regenerating apps/game/lib/core/ui/icons/nesty_icons.gen.dart"
(cd "$ROOT" && dart run nesty_tools:gen_nesty_icons)
