// ============================================================================
//  thread.scad -- the screw connection shared by the corner parts
// ----------------------------------------------------------------------------
//  Ported verbatim from the sibling project corrugated-pipe-bend (pipe_bend.scad)
//  and, until now, carried as three identical copies in corner_bend.scad,
//  corner_elbow.scad and corner_elbow_clear.scad. One copy.
//
//  A helical ridge made by twisting one 2D cross-section: a star-shaped polygon
//  r(angle), wide at the root and narrow at the crest, so the flanks slope and
//  an FDM printer can follow them. The nut is cut from the SAME solid grown by
//  thread_clearance, so the two can never mismatch -- which is the whole reason
//  they belong in one file rather than three.
//
//  This is a library, not a part: it declares no parameters of its own and draws
//  nothing at the top level. `include <thread.scad>` and define these first --
//  they stay in the part file so the Customizer still shows them:
//
//      thread_starts, thread_pitch, thread_clearance    the thread itself
//      thread_root_r, thread_crest_r                    derived from the hole Ø
//      nut_od, nut_height, nut_lobes                    the nut's body
//      nut_grip, nut_fin_w, nut_fin_r                   its fins
//      nut_flange, nut_flange_t, nut_flange_od          its optional bearing flange
//
//  All dimensions are in millimetres.
// ============================================================================

// ── Small helpers ───────────────────────────────────────────────────────────
function pol(r, a) = [r * cos(a), r * sin(a)];
function angdist(a, c) = abs(((a - c + 540) % 360) - 180);

// ── The thread ──────────────────────────────────────────────────────────────
function thread_r(a, r0, r1, w, w1) =
    let (b = min([for (i = [0 : thread_starts - 1]) angdist(a, i * 360 / thread_starts)]))
    b <= w1 / 2 ? r1
  : b >= w  / 2 ? r0
  : r1 + (r0 - r1) * (b - w1 / 2) / (w / 2 - w1 / 2);

module thread_section2d(r0, r1) {
    w = 180 / thread_starts;
    n = max(160, $fn);
    polygon([for (i = [0 : n - 1])
                let (a = i * 360 / n) pol(thread_r(a, r0, r1, w, w * 0.45), a)]);
}

module thread_solid(h, extra = 0) {
    turns = h / (thread_pitch * thread_starts);
    linear_extrude(height = h, twist = -360 * turns,
                   slices = max(24, ceil(turns * 96)), convexity = 8)
        thread_section2d(thread_root_r + extra, thread_crest_r + extra);
}

// ── The nut ─────────────────────────────────────────────────────────────────
module nut_profile2d() {
    R = nut_od / 2;
    if (nut_grip > 0)
        union() {
            circle(r = R);
            for (i = [0 : nut_lobes - 1])
                rotate([0, 0, i * 360 / nut_lobes])
                    hull() {
                        translate([R - 2, 0]) circle(d = nut_fin_w, $fn = 24);
                        translate([nut_fin_r - nut_fin_w / 2, 0]) circle(d = nut_fin_w, $fn = 24);
                    }
        }
    else
        difference() {
            circle(r = R);
            for (i = [0 : nut_lobes - 1])
                rotate([0, 0, i * 360 / nut_lobes]) translate([R + 2.2, 0]) circle(r = 4);
        }
}

module nut() {
    difference() {
        union() {
            linear_extrude(height = nut_height, convexity = 6) nut_profile2d();
            if (nut_flange > 0) {
                translate([0, 0, nut_height - nut_flange_t])
                    cylinder(h = nut_flange_t - 0.8, d1 = nut_od, d2 = nut_flange_od);
                translate([0, 0, nut_height - 0.8]) cylinder(h = 0.8, d = nut_flange_od);
            }
        }
        translate([0, 0, -1]) thread_solid(nut_height + 2, thread_clearance / 2);
    }
}
