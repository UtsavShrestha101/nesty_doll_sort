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
# Reads tools/fonts/nesty_symbols.txt, tools/fonts/subset/{hi,ja}.txt and
# design/tokens.json `font.scripts` (the script faces' weights).
#
# Sources (pinned by commit; raw URLs at a commit SHA are immutable):
#   google/fonts @ GOOGLE_FONTS_SHA
#     ofl/fredoka/Fredoka[wdth,wght].ttf + OFL.txt   (SIL OFL 1.1)
#     ofl/nunito/Nunito[wght].ttf + OFL.txt          (SIL OFL 1.1)
#     ofl/baloo2/Baloo2[wght].ttf + OFL.txt          (SIL OFL 1.1)
#     ofl/mplusrounded1c/MPLUSRounded1c-{Medium,Bold,ExtraBold}.ttf
#       + METADATA.pb (its copyright line)           (SIL OFL 1.1)
#     ofl/mplus1p/OFL.txt (the OFL body for M PLUS Rounded 1c, whose folder
#       ships none)
#   google/material-design-icons @ MATERIAL_ICONS_SHA
#     variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf
#     variablefont/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].codepoints
#     LICENSE                                        (Apache 2.0)
#
# Upstream ships variable fonts only, so static instances are cut with
# fontTools varLib.instancer:
#   Fredoka  wdth=100, wght=500/600/700      → Fredoka-{Medium,SemiBold,Bold}.ttf
#   Nunito   wght=500/600/700/800            → Nunito-{Medium,SemiBold,Bold,ExtraBold}.ttf
#   Baloo 2  wght=500/600/700, subset to tools/fonts/subset/hi.txt (the
#            Devanagari block), and M PLUS Rounded 1c Medium/Bold/ExtraBold
#            (static upstream), subset to tools/fonts/subset/ja.txt (kana,
#            CJK punctuation, full-width, the kanji the copy uses; written by
#            `dart run nesty_tools:gen_font_subsets`): the weights tokens.json
#            font.scripts names. script_faces.py then writes each script's
#            two role families from font.scripts.<script>.weights
#                                            → Baloo2{Display,Body}-*.ttf,
#                                              MPLUSRounded1c{Display,Body}-*.ttf
#            (Latin letters and digits stay Fredoka/Nunito: the app lists
#            these as fontFamilyFallback, so they draw only their script.)
#   Baloo 2  again, for Turkish (font.scripts.latnTr): wght=500/600/700
#            subset to subset/tr.txt (Latin, Latin Extended-A), whole strings,
#            → Baloo2LatnTr-{Medium,SemiBold,Bold}.ttf
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
# The subset lists' comments carry the characters (UTF-8 whatever the locale).
export PYTHONUTF8=1

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
    Baloo2-VF.ttf) echo d47a6852548059b1db49a1319d06d499d546c3fa2237cf9eee9c43c8abb025c2 ;;
    Baloo2-OFL.txt) echo ad09b05dc8bc678c9daf7c4c5f7ef1f55e5726127f4330b2e98e40b9dffcb860 ;;
    MPLUSRounded1c-Medium.ttf) echo adfde1b6bae58719c4e0144612a94232e72fc5ca655c4722165fe88d06521a70 ;;
    MPLUSRounded1c-Bold.ttf) echo c358630584e8e2d8fbd6121d0f4693255ffef6d1e6d4f3441fd6e5a963a11f9e ;;
    MPLUSRounded1c-ExtraBold.ttf) echo 8e7c15901dca87f1451b356dda594f7d092ba252a5dcc47da74523a242493c36 ;;
    MPLUSRounded1c-METADATA.pb) echo 2fafa3943741259c2cd3331b9ed0e22ec3412802dc7acaf6aa33b15b80229f34 ;;
    MPlus1p-OFL.txt) echo da15da6b1496d4de18f97e2ad1b722ef8a1c121149c2c93b2cf7eac6ac27b35c ;;
    *) echo "unpinned input $1" >&2; exit 1 ;;
  esac
}

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
DEST="$ROOT/apps/game/assets/fonts"
GLYPHS="$HERE/nesty_symbols.txt"
SUBSETS="$HERE/subset"
TOKENS="$ROOT/design/tokens.json"
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
fetch Baloo2-VF.ttf "$GF/baloo2/Baloo2%5Bwght%5D.ttf"
fetch Baloo2-OFL.txt "$GF/baloo2/OFL.txt"
for style in Medium Bold ExtraBold; do
  fetch "MPLUSRounded1c-$style.ttf" "$GF/mplusrounded1c/MPLUSRounded1c-$style.ttf"
done
fetch MPLUSRounded1c-METADATA.pb "$GF/mplusrounded1c/METADATA.pb"
fetch MPlus1p-OFL.txt "$GF/mplus1p/OFL.txt"

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

echo "==> Script faces (Devanagari, Japanese)"
# Each subset keeps every layout feature: Devanagari shaping needs GSUB and
# GPOS (conjuncts, matras), and the closure keeps the glyphs they reach.
SCRIPT="$WORK/script"
mkdir -p "$SCRIPT/deva" "$SCRIPT/jpan"
script_subset() { # <input> <output> <list> [pyftsubset flag...]
  local input="$1" output="$2" list="$3"
  shift 3
  "$SUBSET" "$input" --unicodes-file="$list" --layout-features='*' \
    --no-hinting "$@" --output-file="$output"
}
for pair in 500:Medium 600:SemiBold 700:Bold; do
  wght="${pair%%:*}" style="${pair#*:}"
  "$FT" varLib.instancer --quiet --update-name-table \
    -o "$WORK/Baloo2-$style-full.ttf" "$WORK/Baloo2-VF.ttf" "wght=$wght"
  script_subset "$WORK/Baloo2-$style-full.ttf" "$SCRIPT/deva/Baloo2-$style.ttf" \
    "$SUBSETS/hi.txt" --notdef-outline
done
for style in Medium Bold ExtraBold; do
  script_subset "$WORK/MPLUSRounded1c-$style.ttf" \
    "$SCRIPT/jpan/MPLUSRounded1c-$style.ttf" "$SUBSETS/ja.txt"
done
"$WORK/venv/bin/python" "$HERE/script_faces.py" "$TOKENS" deva "Baloo 2" \
  "$SCRIPT/deva" "$OUT"
"$WORK/venv/bin/python" "$HERE/script_faces.py" "$TOKENS" jpan \
  "M PLUS Rounded 1c" "$SCRIPT/jpan" "$OUT"

echo "==> Turkish face (Baloo 2, whole strings: font.scripts.latnTr)"
# Fredoka lacks ğ Ğ İ ş Ş: in tr every Fredoka role draws in Baloo 2, whole
# strings, never per glyph. Latin + Latin Extended-A at the display weights,
# its own family (Baloo2LatnTr), the same pinned Baloo2-VF.ttf as deva.
mkdir -p "$SCRIPT/latn"
for pair in 500:Medium 600:SemiBold 700:Bold; do
  style="${pair#*:}"
  script_subset "$WORK/Baloo2-$style-full.ttf" "$SCRIPT/latn/Baloo2-$style.ttf" \
    "$SUBSETS/tr.txt" --notdef-outline
done
"$WORK/venv/bin/python" "$HERE/script_faces.py" "$TOKENS" latnTr "Baloo 2" \
  "$SCRIPT/latn" "$OUT" Baloo2LatnTr

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
cp "$WORK/Baloo2-OFL.txt" "$OUT/Baloo2-OFL.txt"
# google/fonts ships no OFL.txt for M PLUS Rounded 1c (METADATA.pb says OFL):
# its own copyright line from METADATA.pb, then the OFL 1.1 text of the M+
# family's ofl/mplus1p/OFL.txt (line 2 to the licence's last line, without
# that file's own copyright lines).
{
  copyright="$(sed -n 's/^  copyright: "\(.*\)"$/\1/p' "$WORK/MPLUSRounded1c-METADATA.pb" | sort -u)"
  if [[ "$(printf '%s\n' "$copyright" | wc -l | tr -d ' ')" != 1 || -z "$copyright" ]]; then
    echo "MPLUSRounded1c METADATA.pb: expected one copyright line" >&2
    exit 1
  fi
  printf '%s\n' "$copyright"
  sed -n '2,/^OTHER DEALINGS IN THE FONT SOFTWARE\.$/p' "$WORK/MPlus1p-OFL.txt"
} >"$OUT/MPLUSRounded1c-OFL.txt"

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
