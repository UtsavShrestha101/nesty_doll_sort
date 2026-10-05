"""Writes the role families of one script face (docs l10n.md §4.6, m7-4 9.1).

    script_faces.py <tokens.json> <script> <design-family> <src-dir> <out-dir>

tokens.json `font.scripts.<script>.weights` maps each Latin role weight to a
script weight, e.g. Devanagari `body700: 600` (Nunito 700 text draws its
Devanagari in Baloo 2 SemiBold) and Japanese `display700: 800`. A text
style's FontWeight is the Latin one, and the engine matches it against each
file's OS/2 usWeightClass (it never reads pubspec's `weight:`). So each role
gets its own family, `<Base><Role>` (Baloo2Display, Baloo2Body), whose files
are the subset script weights re-labelled with the Latin weight they answer:

    Baloo2Body-SemiBold.ttf = Baloo 2 SemiBold, usWeightClass 700

When several Latin weights map to one script weight (Japanese body800 and
body700 both draw Bold), the file carries the lowest of them; CSS weight
matching sends the heavier requests down to it. tools/test/fonts checks
that every mapping resolves to the right outlines.

<src-dir> holds `<Base>-<Style>.ttf`, the subset face at each script weight
(Base is the design family without spaces). The name table is rewritten so
no two bundled files share a PostScript name (CoreText caches by it).
"""

import json
import os
import sys

from fontTools.ttLib import TTFont

STYLES = {
    100: "Thin",
    200: "ExtraLight",
    300: "Light",
    400: "Regular",
    500: "Medium",
    600: "SemiBold",
    700: "Bold",
    800: "ExtraBold",
    900: "Black",
}
ROLES = {"display": "Display", "body": "Body"}


def role_files(weights):
    """{role: {script weight: OS/2 weight class}} from the tokens map."""
    plan = {}
    for key, script_weight in weights.items():
        role = next((r for r in ROLES if key.startswith(r)), None)
        if role is None or not key[len(role):].isdigit():
            sys.exit(f"font.scripts weights: unexpected key {key!r}")
        latin = int(key[len(role):])
        files = plan.setdefault(role, {})
        files[script_weight] = min(files.get(script_weight, latin), latin)
    return plan


def set_names(font, family, style, postscript):
    name = font["name"]
    ribbi = style in ("Regular", "Bold")
    full = family if style == "Regular" else f"{family} {style}"
    values = {
        1: family if ribbi else full,
        2: style if ribbi else "Regular",
        3: f"{postscript};nesty",
        4: full,
        6: postscript,
        16: family,
        17: style,
    }
    for name_id in (1, 2, 3, 4, 6, 16, 17):
        name.removeNames(nameID=name_id)
        name.setName(values[name_id], name_id, 3, 1, 0x409)


def main():
    if len(sys.argv) != 6:
        sys.exit(__doc__)
    tokens_path, script, design_family, src_dir, out_dir = sys.argv[1:]
    with open(tokens_path, encoding="utf-8") as f:
        tokens = json.load(f)
    entry = tokens["font"]["scripts"][script]
    if entry["family"] != design_family:
        sys.exit(
            f"tokens.json font.scripts.{script}.family is "
            f"{entry['family']!r}, not {design_family!r}"
        )
    base = design_family.replace(" ", "")
    for role, files in sorted(role_files(entry["weights"]).items()):
        family = f"{base}{ROLES[role]}"
        for script_weight, weight_class in sorted(files.items()):
            style = STYLES[script_weight]
            src = os.path.join(src_dir, f"{base}-{style}.ttf")
            if not os.path.exists(src):
                sys.exit(f"{src} is missing: cut the {script_weight} instance")
            font = TTFont(src)
            font["OS/2"].usWeightClass = weight_class
            set_names(
                font,
                f"{design_family} {ROLES[role]}",
                style,
                f"{family}-{style}",
            )
            out = os.path.join(out_dir, f"{family}-{style}.ttf")
            font.save(out)
            print(f"  {family}-{style}.ttf  {design_family} {script_weight}, "
                  f"usWeightClass {weight_class}")


if __name__ == "__main__":
    main()
