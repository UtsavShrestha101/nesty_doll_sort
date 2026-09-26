"""Bake a variable font's FeatureVariations into its cmap for one location.

Usage: bake_feature_variations.py <in.ttf> <out.ttf> AXIS=value...

Material Symbols draws FILL=1 through a FeatureVariations record: at
FILL >= 0.99 its `rclt` feature swaps most icons for a separate
`<name>.fill` glyph. build_fonts.sh drops every layout table when it subsets
the icon font (the ligature tables are most of its size), which would also
drop that swap and leave the gvar-interpolated outline glyph: its hole
collapses into coincident, opposite-winding contours, so it looks filled but
is not the glyph upstream draws at FILL=1 (or the design prototypes show).
This script resolves the swap ahead of time instead: every codepoint's cmap
entry points straight at the glyph the font selects at the given location, so
the subset needs no GSUB and renders the same with any shaper.

It fails loudly (exit 1) on anything it does not understand: a missing axis
value, a condition format other than an axis range, or a substitution that is
not a one-to-one glyph swap.
"""

import sys

from fontTools.ttLib import TTFont
from fontTools.varLib.models import normalizeLocation, piecewiseLinearMap


def fail(message):
    print(f"bake_feature_variations: {message}", file=sys.stderr)
    sys.exit(1)


def normalized_location(font, target):
    axes = {a.axisTag: (a.minValue, a.defaultValue, a.maxValue) for a in font["fvar"].axes}
    missing = sorted(set(axes) - set(target))
    if missing:
        fail(f"no value given for axes {missing}")
    unknown = sorted(set(target) - set(axes))
    if unknown:
        fail(f"font has no axes {unknown}")
    location = normalizeLocation(target, axes)
    if "avar" in font:
        for tag, segments in font["avar"].segments.items():
            if segments:
                location[tag] = piecewiseLinearMap(location[tag], segments)
    return location


def active_record(gsub, tags, location):
    variations = getattr(gsub, "FeatureVariations", None)
    if variations is None:
        return None
    for record in variations.FeatureVariationRecord:
        conditions = record.ConditionSet.ConditionTable if record.ConditionSet else []
        for condition in conditions:
            if condition.Format != 1:
                fail(f"unsupported condition format {condition.Format}")
        if all(
            c.FilterRangeMinValue <= location[tags[c.AxisIndex]] <= c.FilterRangeMaxValue
            for c in conditions
        ):
            return record  # OpenType: the first matching record wins.
    return None


def single_substitutions(gsub, record):
    mapping = {}
    for substitution in record.FeatureTableSubstitution.SubstitutionRecord:
        for index in substitution.Feature.LookupListIndex:
            lookup = gsub.LookupList.Lookup[index]
            for subtable in lookup.SubTable:
                kind = lookup.LookupType
                if kind == 7:  # Extension: unwrap.
                    kind = subtable.ExtensionLookupType
                    subtable = subtable.ExtSubTable
                if kind != 1:
                    fail(f"lookup {index} is type {kind}, not a single substitution")
                mapping.update(subtable.mapping)
    return mapping


def main(argv):
    if len(argv) < 4:
        fail("usage: bake_feature_variations.py <in.ttf> <out.ttf> AXIS=value...")
    source, destination, *axis_args = argv[1:]
    target = {}
    for arg in axis_args:
        tag, _, value = arg.partition("=")
        if not value:
            fail(f"bad axis argument {arg!r}")
        target[tag] = float(value)

    font = TTFont(source)
    tags = [a.axisTag for a in font["fvar"].axes]
    location = normalized_location(font, target)
    record = active_record(font["GSUB"].table, tags, location) if "GSUB" in font else None
    mapping = single_substitutions(font["GSUB"].table, record) if record else {}

    remapped = 0
    for table in font["cmap"].tables:
        if not table.isUnicode():
            continue
        for codepoint, glyph in list(table.cmap.items()):
            swapped = mapping.get(glyph)
            if swapped is not None:
                table.cmap[codepoint] = swapped
                remapped += 1
    font.save(destination)
    print(f"    cmap entries pointed at their variation glyph: {remapped}")


if __name__ == "__main__":
    main(sys.argv)
