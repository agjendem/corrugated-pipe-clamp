#!/usr/bin/env bash
# Export an STL for every preset of every model into stl/.
# Requires OpenSCAD on PATH (or set OPENSCAD=/path/to/openscad).
#
# pipe_clamp presets cover the standard IEC/EN 61386 nominal conduit sizes.
# NOTE: the corrugation depth/pitch are NOT standardised -- those presets only
# set the diameters and inherit the default corr_* values, which you should
# verify against your actual pipe (see README "How to measure your conduit").
set -euo pipefail

OPENSCAD="${OPENSCAD:-openscad}"
cd "$(dirname "$0")"
mkdir -p stl

# Read the preset names straight from the JSON so this never drifts from it.
preset_names() {   # $1 = json file
    "$OPENSCAD" - <<SCAD 2>&1 >/dev/null | sed -n 's/^ECHO: "\(.*\)"$/\1/p'
        sets = parameter_set_names("$1");
        for (n = sets) echo(n);
SCAD
}

build_model() {    # $1 = json file, $2 = scad file
    local presets
    presets=$(preset_names "$1") || true

    # Fallback if the OpenSCAD build lacks parameter_set_names(): parse the JSON.
    if [ -z "${presets:-}" ]; then
        presets=$(sed -n 's/^[[:space:]]*"\([a-z0-9_]*\)":[[:space:]]*{[[:space:]]*$/\1/p;
                          s/^[[:space:]]*"\([a-z0-9_]*\)":[[:space:]]*{.*}.*/\1/p' "$1" \
                  | grep -v '^parameterSets$')
    fi

    for p in $presets; do
        echo "Building $p ..."
        "$OPENSCAD" -o "stl/$p.stl" -p "$1" -P "$p" "$2"
    done
}

build_model pipe_clamp.json       pipe_clamp.scad
build_model corner_bend.json      corner_bend.scad

echo "Done -> stl/*.stl"
