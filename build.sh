#!/usr/bin/env bash
# Export an STL for every preset in pipe_clamp.json into stl/.
# Requires OpenSCAD on PATH (or set OPENSCAD=/path/to/openscad).
#
# Presets cover the standard IEC/EN 61386 nominal conduit sizes. NOTE: the
# corrugation depth/pitch are NOT standardised -- the presets only set the
# diameters and inherit the default corr_* values, which you should verify
# against your actual pipe (see README "How to measure your conduit").
set -euo pipefail

OPENSCAD="${OPENSCAD:-openscad}"
cd "$(dirname "$0")"
mkdir -p stl

# Read the preset names straight from the JSON so this never drifts from it.
presets=$(
    "$OPENSCAD" - <<'SCAD' 2>&1 >/dev/null | sed -n 's/^ECHO: "\(.*\)"$/\1/p'
        sets = parameter_set_names("pipe_clamp.json");
        for (n = sets) echo(n);
SCAD
) || true

# Fallback if the OpenSCAD build lacks parameter_set_names(): parse the JSON.
if [ -z "${presets:-}" ]; then
    presets=$(sed -n 's/^[[:space:]]*"\(conduit_[^"]*\)":[[:space:]]*{.*/\1/p' pipe_clamp.json)
fi

for p in $presets; do
    echo "Building $p ..."
    "$OPENSCAD" -o "stl/$p.stl" -p pipe_clamp.json -P "$p" pipe_clamp.scad
done

echo "Done -> stl/*.stl"
