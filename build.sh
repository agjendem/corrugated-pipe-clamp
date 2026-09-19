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
#
# This used to ask OpenSCAD via parameter_set_names(), which returns nothing on
# the build we use -- and asking it costs more than nothing: `openscad -` with
# no -o starts the GUI and sits there forever waiting for a window nobody is
# looking at, which hangs the whole script. So: parse the JSON.
preset_names() {   # $1 = json file
    sed -n 's/^[[:space:]]*"\([a-z0-9_]*\)":[[:space:]]*{[[:space:]]*$/\1/p;
            s/^[[:space:]]*"\([a-z0-9_]*\)":[[:space:]]*{.*}.*/\1/p' "$1" \
        | grep -v '^parameterSets$'
}

build_model() {    # $1 = json file, $2 = scad file
    local presets
    presets=$(preset_names "$1")

    if [ -z "${presets:-}" ]; then
        echo "No presets found in $1" >&2
        return 1
    fi

    for p in $presets; do
        echo "Building $p ..."
        "$OPENSCAD" -o "stl/$p.stl" -p "$1" -P "$p" "$2"
    done
}

build_model pipe_clamp.json       pipe_clamp.scad
build_model snap_collar.json      snap_collar.scad
build_model corner_bend.json      corner_bend.scad
build_model corner_elbow.json     corner_elbow.scad
build_model corner_elbow_clear.json corner_elbow_clear.scad
build_model panel_spigot.json      panel_spigot.scad
build_model panel_elbow.json       panel_elbow.scad

echo "Done -> stl/*.stl"
