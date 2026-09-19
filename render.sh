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

# The same clamp with a screw brim: anchored to a stud rather than caught on the
# hole, which holds the pipe BOTH ways. From the head side.
"$OPENSCAD" -o "images/conduit_16mm_stud2.png" --imgsize=1000,1000 \
    --viewall --autocenter --camera=0,0,0,125,0,205,0 --colorscheme=Tomorrow \
    -p pipe_clamp.json -P conduit_16mm_stud2 pipe_clamp.scad

# ── Snap collar (addon) ─────────────────────────────────────────────────────
# All from the defaults in snap_collar.scad. Auto-framed (--viewall).
collar_view() {  # out_name  camera  part
    "$OPENSCAD" -o "images/$1.png" --imgsize=1000,1000 \
        --viewall --autocenter --camera="$2" --colorscheme=Tomorrow \
        -D "part=\"$3\"" snap_collar.scad
}

collar_view snap_collar          0,0,0,62,0,215,0 body      # main 3/4 view
collar_view snap_collar_flange   0,0,0,118,0,215,0 body     # flange end, from below
collar_view snap_collar_assembly 0,0,0,68,0,215,0 assembly  # in the panel, on the pipe

# Straight down the bore: the mouth, and how far past the equator it wraps.
# This is the view that shows what the part is.
"$OPENSCAD" -o "images/snap_collar_mouth.png" --imgsize=1000,1000 \
    --projection=o --viewall --autocenter --camera=0,0,0,0,0,0,0 \
    --colorscheme=Tomorrow snap_collar.scad

# Cut in half: the three teeth, and the fillet where the skirt meets the flange.
"$OPENSCAD" -o "images/snap_collar_split.png" --imgsize=1400,1000 \
    --viewall --autocenter --projection=o --camera=0,0,0,90,0,180,0 \
    --colorscheme=Tomorrow -D 'part="section"' snap_collar.scad

# The screw brim: the same collar, anchored to a stud instead of trusting the
# hole. One screw opposite the mouth, or two, one each side. Shown from the SKIRT
# side, which on this part is where the heads are -- it is fitted the other way
# up from pipe_clamp, so the flat face underneath is the one that bears.
stud_view() {  # out_name  preset  camera
    "$OPENSCAD" -o "images/$1.png" --imgsize=1000,1000 \
        --viewall --autocenter --camera="$3" --colorscheme=Tomorrow \
        -p snap_collar.json -P "$2" snap_collar.scad
}

stud_view snap_collar_stud1 snap_collar_16mm_stud1 0,0,0,58,0,215,0
stud_view snap_collar_stud2 snap_collar_16mm_stud2 0,0,0,58,0,215,0

# Dimensioned drawing. snap_collar_dimensions.scad picks the parameters up via
# include <snap_collar.scad>, so it renders from the defaults, not from -P.
"$OPENSCAD" -o "images/snap_collar_dimensions.png" --imgsize=1700,1100 \
    --projection=o --viewall --autocenter --camera=0,0,0,0,0,0,0 \
    --colorscheme=Tomorrow snap_collar_dimensions.scad

# ── Snap collar, 20 mm: the pointed tooth ───────────────────────────────────
# The measured 20 mm conduit has a groove that closes from ~1.0 mm at the crest
# to ~0.35 at the root, so the tooth is a wedge, not a square rib. Same repeat
# as mount_params above: these mirror the snap_collar_20mm preset and have to be
# written out because -P does not reach the dimensions file's included values.
collar20_params=(
    -D pipe_diameter=20 -D valley_diameter=17 -D corr_pitch=3.83
    -D valley_width=1.03 -D valley_root_width=0.35 -D tooth_bite=1.0
    -D corr_round=0.15 -D pipe_bore=14 -D panel_hole=25 -D flange_diameter=34
)

collar20_view() {  # out_name  camera  part
    "$OPENSCAD" -o "images/$1.png" --imgsize=1000,1000 \
        --viewall --autocenter --camera="$2" --colorscheme=Tomorrow \
        "${collar20_params[@]}" -D "part=\"$3\"" snap_collar.scad
}

collar20_view snap_collar_20mm          0,0,0,62,0,215,0 body
# Cut in half: this is the one to look at. The teeth are wedges following the
# groove's own walls, and they stop 0.5 mm short of the root on purpose.
collar20_view snap_collar_20mm_split    0,0,0,90,0,180,0 section
collar20_view snap_collar_20mm_assembly 0,0,0,68,0,215,0 assembly

"$OPENSCAD" -o "images/snap_collar_20mm_dimensions.png" --imgsize=1700,1100 \
    --projection=o --viewall --autocenter --camera=0,0,0,0,0,0,0 \
    --colorscheme=Tomorrow "${collar20_params[@]}" snap_collar_dimensions.scad

# ── Corner bend (addon) ─────────────────────────────────────────────────────
# All from the defaults in corner_bend.scad. Auto-framed (--viewall).
corner_view() {  # out_name  camera  part
    "$OPENSCAD" -o "images/$1.png" --imgsize=1200,1100 \
        --viewall --autocenter --camera="$2" --colorscheme=Tomorrow \
        -D "part=\"$3\"" corner_bend.scad
}

corner_view corner_bend          0,0,0,62,0,32,0  body
corner_view corner_bend_glue     0,0,0,62,0,200,0 body
corner_view corner_bend_stand    0,0,0,76,0,32,0  body
corner_view corner_bend_assembly 0,0,0,66,0,40,0  assembly
corner_view corner_bend_nut      0,0,0,58,0,20,0  nut

# Cut in half: the chamber, and the wall thickness all the way round it.
"$OPENSCAD" -o "images/corner_bend_split.png" --imgsize=1400,1000 \
    --viewall --autocenter --projection=o --camera=0,0,0,180,0,0,0 \
    --colorscheme=Tomorrow -D 'part="section"' corner_bend.scad

# Dimensioned drawing.
"$OPENSCAD" -o "images/corner_bend_dimensions.png" --imgsize=1600,1100 \
    --projection=o --viewall --autocenter --camera=0,0,0,0,0,0,0 \
    --colorscheme=Tomorrow corner_bend_dimensions.scad

# ── Corner elbow (the simpler addon) ────────────────────────────────────────
elbow_view() {  # out_name  camera  part
    "$OPENSCAD" -o "images/$1.png" --imgsize=1200,1100 \
        --viewall --autocenter --camera="$2" --colorscheme=Tomorrow \
        -D "part=\"$3\"" corner_elbow.scad
}

elbow_view corner_elbow          0,0,0,62,0,32,0  body
elbow_view corner_elbow_glue     0,0,0,62,0,200,0 body
elbow_view corner_elbow_print    0,0,0,68,0,50,0  print   # as it goes on the bed
elbow_view corner_elbow_assembly 0,0,0,66,0,40,0  assembly

"$OPENSCAD" -o "images/corner_elbow_split.png" --imgsize=1400,1000 \
    --viewall --autocenter --projection=o --camera=0,0,0,180,0,0,0 \
    --colorscheme=Tomorrow -D 'part="section"' corner_elbow.scad

# The tight variant: the screw wall driven 6 mm into the conduit's envelope.
"$OPENSCAD" -o "images/corner_elbow_tight.png" --imgsize=1200,1100 \
    --viewall --autocenter --camera=0,0,0,62,0,32,0 --colorscheme=Tomorrow \
    -D 'part="body"' -D panel_bite=6 corner_elbow.scad
"$OPENSCAD" -o "images/corner_elbow_tight_split.png" --imgsize=1400,1000 \
    --viewall --autocenter --projection=o --camera=0,0,0,180,0,0,0 \
    --colorscheme=Tomorrow -D 'part="section"' -D panel_bite=6 corner_elbow.scad
"$OPENSCAD" -o "images/corner_elbow_tight_under.png" --imgsize=1200,1100 \
    --viewall --autocenter --camera=0,0,0,118,0,25,0 --colorscheme=Tomorrow \
    -D 'part="body"' -D panel_bite=6 corner_elbow.scad

# ...and with the floor opened right through to the cabinet's panel.
"$OPENSCAD" -o "images/corner_elbow_open.png" --imgsize=1200,1100 \
    --viewall --autocenter --camera=0,0,0,62,0,32,0 --colorscheme=Tomorrow \
    -D 'part="body"' -D panel_bite=6 -D open_floor=true corner_elbow.scad
"$OPENSCAD" -o "images/corner_elbow_open_split.png" --imgsize=1400,1000 \
    --viewall --autocenter --projection=o --camera=0,0,0,180,0,0,0 \
    --colorscheme=Tomorrow -D 'part="section"' -D panel_bite=6 -D open_floor=true corner_elbow.scad
"$OPENSCAD" -o "images/corner_elbow_open_under.png" --imgsize=1200,1100 \
    --viewall --autocenter --camera=0,0,0,118,0,25,0 --colorscheme=Tomorrow \
    -D 'part="body"' -D panel_bite=6 -D open_floor=true corner_elbow.scad

# ── Corner elbow, clear channel (its own part) ──────────────────────────────
clear_view() {  # out_name  camera  part  [extra flags]
    "$OPENSCAD" -o "images/$1.png" --imgsize=1200,1100 \
        --viewall --autocenter --camera="$2" --colorscheme=Tomorrow \
        -D "part=\"$3\"" corner_elbow_clear.scad
}

clear_view corner_elbow_clear          0,0,0,62,0,32,0  body
clear_view corner_elbow_clear_print    0,0,0,68,0,50,0  print
clear_view corner_elbow_clear_assembly 0,0,0,66,0,40,0  assembly

# Straight up at the underside: the bearing face is a C, open where the channel
# runs in, and nothing at all crosses the channel.
"$OPENSCAD" -o "images/corner_elbow_clear_under.png" --imgsize=1100,1000 \
    --viewall --autocenter --projection=o --camera=0,0,0,180,0,0,0 \
    --colorscheme=Tomorrow -D 'part="body"' corner_elbow_clear.scad
"$OPENSCAD" -o "images/corner_elbow_clear_split.png" --imgsize=1400,1000 \
    --viewall --autocenter --projection=o --camera=0,0,0,180,0,0,0 \
    --colorscheme=Tomorrow -D 'part="section"' corner_elbow_clear.scad

# ── Panel spigot (the straight one) ─────────────────────────────────────────
# All from the defaults in panel_spigot.scad. Auto-framed (--viewall).
spigot_view() {  # out_name  camera  part
    "$OPENSCAD" -o "images/$1.png" --imgsize=1100,1200 \
        --viewall --autocenter --camera="$2" --colorscheme=Tomorrow \
        -D "part=\"$3\"" panel_spigot.scad
}

spigot_view panel_spigot          0,0,0,62,0,32,0 body
spigot_view panel_spigot_print    0,0,0,68,0,32,0 print   # as it goes on the bed
spigot_view panel_spigot_assembly 0,0,0,68,0,32,0 assembly

# Straight up at the underside: the flat bearing annulus, and how little of it
# there is between the thread's crest and the collar's rim. This is the view
# that shows what holds the part on.
"$OPENSCAD" -o "images/panel_spigot_under.png" --imgsize=1100,1000 \
    --viewall --autocenter --projection=o --camera=0,0,0,180,0,0,0 \
    --colorscheme=Tomorrow -D 'part="body"' panel_spigot.scad

# The two grips, side by side in the README: fins grown out of the body, and
# scallops cut into it. Same thread, same height, 17 mm apart in width.
"$OPENSCAD" -o "images/panel_spigot_nut.png" --imgsize=1000,1000 \
    --viewall --autocenter --camera=0,0,0,58,0,20,0 --colorscheme=Tomorrow \
    -D 'part="nut"' panel_spigot.scad
"$OPENSCAD" -o "images/panel_spigot_nut_slim.png" --imgsize=1000,1000 \
    --viewall --autocenter --camera=0,0,0,58,0,20,0 --colorscheme=Tomorrow \
    -p panel_spigot.json -P panel_spigot_nut_slim panel_spigot.scad

# Cut in half: the 2 mm wall, the flat collar, and the root cone that climbs
# out of it into the tube -- both the fillet at the tube's root and the funnel
# for the cable, and the thing that keeps the transition off 45 degrees.
"$OPENSCAD" -o "images/panel_spigot_split.png" --imgsize=1100,1200 \
    --viewall --autocenter --projection=o --camera=0,0,0,90,0,0,0 \
    --colorscheme=Tomorrow -D 'part="section"' panel_spigot.scad

# ── Panel elbow (the 90 deg one) ────────────────────────────────────────────
# All from the defaults in panel_elbow.scad -- Ø40 bore, 30 mm bend. Auto-framed.
elbow_view() {  # out_name  camera  part
    "$OPENSCAD" -o "images/$1.png" --imgsize=1200,1000 \
        --viewall --autocenter --camera="$2" --colorscheme=Tomorrow \
        -D "part=\"$3\"" panel_elbow.scad
}

elbow_view panel_elbow            0,0,0,62,0,32,0 body
elbow_view panel_elbow_assembly   0,0,0,68,0,32,0 assembly   # panel upright, socket up
elbow_view panel_elbow_print      0,0,0,66,0,28,0 print      # standing on the mouth
elbow_view panel_elbow_print_neck 0,0,0,66,0,28,0 print_neck # standing on the thread

# Cut on the bend plane: the constant Ø40 bore right through, the step at the
# socket's stop, the collar flat underneath and the cone climbing out of it.
"$OPENSCAD" -o "images/panel_elbow_split.png" --imgsize=1300,1000 \
    --viewall --autocenter --projection=o --camera=0,0,0,90,0,0,0 \
    --colorscheme=Tomorrow -D 'part="section"' panel_elbow.scad

# The same part at Ø25, on its own smaller hole and its own smaller nut.
"$OPENSCAD" -o "images/panel_elbow_25.png" --imgsize=1200,1000 \
    --viewall --autocenter --camera=0,0,0,62,0,32,0 --colorscheme=Tomorrow \
    -p panel_elbow.json -P panel_elbow_25 panel_elbow.scad

echo "Rendered images/*.png"
