#!/usr/bin/env bash
# Re-render all README images from the .scad sources.
# Requires OpenSCAD on PATH (or set OPENSCAD=/path/to/openscad).
set -euo pipefail

OPENSCAD="${OPENSCAD:-openscad}"
cd "$(dirname "$0")"
mkdir -p images

# 3D views: all use the DEFAULT parameters in pipe_clamp.scad; only the camera
# (gimbal: transX,transY,transZ,rotX,rotY,rotZ,dist) differs.
view() {
    "$OPENSCAD" -o "images/$1.png" --imgsize=1000,1000 \
        --camera="$2" --colorscheme=Tomorrow pipe_clamp.scad
}

view pipe_clamp        0,0,9,55,0,25,95     # main 3/4 view
view pipe_clamp_top    0,0,9,0,0,25,70      # straight down the bore
view pipe_clamp_back   0,0,9,60,0,205,95    # opposite side (solid wrap)
view pipe_clamp_flange 0,0,6,118,0,25,95    # flange end from below

# Dimensioned drawing: flat 2D, orthographic top view, auto-framed. The
# annotation scales with the part, so big parts stay readable.
dims() {  # out_name  [extra -D overrides...]
    out="$1"; shift
    "$OPENSCAD" -o "images/$out.png" --imgsize=1400,1000 \
        --projection=o --viewall --autocenter --camera=0,0,0,0,0,0,0 \
        --colorscheme=Tomorrow "$@" dimensions.scad
}

# Default 16 mm part.
dims pipe_clamp_dimensions

# 40 mm wall-mount geometry (shared by the 150/180/210° mount presets — coverage
# does not change the cross-section). Values mirror conduit_40mm_mount.
dims conduit_40mm_mount_dimensions \
    -D pipe_diameter=40 -D bore_diameter=70 -D corr_depth=3 -D corr_width=1.333 \
    -D groove_width=4 -D corr_count=10 -D corr_round=0.3 -D groove_fillet=0.6 \
    -D flange_overhang=27 -D flange_thickness=3

echo "Rendered images/*.png"
