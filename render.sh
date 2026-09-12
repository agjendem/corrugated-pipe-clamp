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

# 40 mm wall-mount geometry. Values mirror the conduit_40mm_mount preset in
# pipe_clamp.json — they must be repeated here because -P does not reach
# parameters that dimensions.scad picks up via include <pipe_clamp.scad>.
mount_params=(
    -D pipe_diameter=40 -D bore_diameter=71 -D corr_depth=2.5 -D corr_width=1.333
    -D groove_width=4 -D corr_count=7 -D corr_round=0.3 -D groove_fillet=0.6
    -D coverage_deg=180 -D flange_overhang=27 -D flange_thickness=3
)

dims conduit_40mm_mount_dimensions "${mount_params[@]}"

# 3D views of the 40 mm mount. Auto-framed (--viewall) rather than using a fixed
# camera distance, so they stay well composed if the mount's size changes.
mount_view() {
    "$OPENSCAD" -o "images/$1.png" --imgsize=1000,1000 \
        --viewall --autocenter --camera="$2" \
        --colorscheme=Tomorrow "${mount_params[@]}" pipe_clamp.scad
}

mount_view conduit_40mm_mount        0,0,0,55,0,-65,0   # main 3/4 view
mount_view conduit_40mm_mount_top    0,0,0,0,0,-90,0    # straight down the bore
mount_view conduit_40mm_mount_flange 0,0,0,118,0,25,0   # flange end from below

echo "Rendered images/*.png"
