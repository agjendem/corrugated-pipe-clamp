// ============================================================================
//  Dimensioned drawing for snap_collar.scad
// ----------------------------------------------------------------------------
//  Two figures, both cut from the real model rather than redrawn, so neither can
//  drift from the geometry:
//
//    below  a full axial section -- the collar in its panel, on its pipe. This
//           one is section_2d() itself, the same 2D the body is revolved from.
//    above  a cut through the middle of the first tooth, looking down the pipe.
//           This is the figure that matters: it shows the mouth, and the mouth
//           is the whole part. It is projection(cut = true) through body().
//
//  Every number comes from the model's own derived values. Render top-down /
//  orthographic.
// ============================================================================

DIMENSIONS_ONLY = true;
include <snap_collar.scad>;

$fn  = 64;
s    = max(1, flange_diameter / 28);
ts   = 1.2  * s;
lh   = 1.9  * s;
lw   = 0.09 * s;
tick = 0.6  * s;

// One period of pipe shown each side of the collar: enough to read the phase,
// not so much that the part gets lost in the middle of a long tube.
y_pipe0 = -corr_pitch;
y_pipe1 = length + corr_pitch;

// ── Dimension helpers (same idiom as corner_bend_dimensions.scad) ────────────
module hdim(x0, x1, y, label, below = false) {
    color("Black") {
        translate([min(x0, x1), y - lw / 2]) square([abs(x1 - x0), lw]);
        for (x = [x0, x1]) translate([x, y]) rotate(45) square(tick, center = true);
        translate([(x0 + x1) / 2, y + (below ? -1.4 * s : 0.4 * s)])
            text(label, size = ts, halign = "center");
    }
}
module vdim(y0, y1, x, label, left = false) {
    color("Black") {
        translate([x - lw / 2, min(y0, y1)]) square([lw, abs(y1 - y0)]);
        for (y = [y0, y1]) translate([x, y]) rotate(45) square(tick, center = true);
        translate([x + (left ? -0.5 * s : 0.5 * s), (y0 + y1) / 2])
            text(label, size = ts, valign = "center", halign = left ? "right" : "left");
    }
}

// ============================================================================
//  FIGURE 1 -- axial section.  x = radius, y = along the pipe (+y into the wall)
// ============================================================================
module pipe_section_2d() {
    zz = pipe_z0;
    nn = pipe_n;
    len = corr_length(nn, pipe_crest_w, valley_width);
    difference() {
        corr_soften(corr_round, pipe_fillet)
            polygon(points = concat(
                corr_inner(r_crest, r_valley, nn, pipe_crest_w, valley_width, zz,
                           tip_w = groove_tip_w),
                [[pipe_bore / 2, zz + len], [pipe_bore / 2, zz]]));
        translate([-1, zz - 1]) square([1 + pipe_bore / 2, len + 2]);
    }
}

// The pipe, then the panel, then the collar on top -- reading order on site.
color("Bisque")
    for (m = [0, 1]) mirror([m, 0])
        intersection() {
            pipe_section_2d();
            translate([0, y_pipe0]) square([r_crest + 1, y_pipe1 - y_pipe0]);
        }
color("Gainsboro")
    for (m = [0, 1]) mirror([m, 0])
        translate([panel_hole / 2 + hole_tolerance / 2, flange_thickness])
            square([25 * s - panel_hole / 2, panel_thickness]);
color("SteelBlue") for (m = [0, 1]) mirror([m, 0]) section_2d();

// Centreline
color("Crimson") translate([-r_flange - 6 * s, -lw / 2])
    square([2 * r_flange + 12 * s, lw]);

// Which way is which -- the section alone does not say.
color("Black") {
    translate([-r_flange - 7 * s, flange_thickness / 2])
        text("v  in the cabinet", size = ts, halign = "right", valign = "center");
    translate([-r_flange - 7 * s, length - 1.5 * s])
        text("^  in the wall", size = ts, halign = "right", valign = "center");
}

y_top = length + 2.0 * s;
y_bot = [for (i = [0 : 3]) -(3 + 4 * i) * s];

hdim(-r_flange, r_flange, y_bot[0], str("flange Ø", flange_diameter), true);
hdim(-panel_hole / 2, panel_hole / 2, y_bot[1],
     str("drill Ø", panel_hole, "  (skirt Ø", mm2(2 * r_skirt), ")"), true);
hdim(-r_recess, r_recess, y_bot[2],
     str("bore over the crests Ø", mm2(2 * r_recess)), true);
hdim(-r_tooth, r_tooth, y_bot[3],
     str("teeth Ø", mm2(2 * r_tooth), "  (pipe groove Ø", valley_diameter, ")"), true);

vdim(0, length, r_flange + 3.0 * s, str("length ", mm2(length)));
vdim(0, flange_thickness, r_flange + 8.0 * s,
     str("into the cabinet ", mm2(flange_thickness)));
vdim(flange_thickness, flange_thickness + panel_thickness, r_flange + 13.5 * s,
     str("panel ", panel_thickness));

// ============================================================================
//  FIGURE 2 -- cut through the middle of the first tooth, looking down the pipe
// ============================================================================
z_cut  = recess_w + tooth_w / 2;
y_fig2 = y_pipe1 + 5 * s + r_flange;
tip_x  = r_tooth * cos(coverage_deg / 2);
tip_y  = r_tooth * sin(coverage_deg / 2);

translate([0, y_fig2]) {
    color("Bisque")
        projection(cut = true) translate([0, 0, -z_cut]) conduit();
    color("SteelBlue")
        projection(cut = true) translate([0, 0, -z_cut]) body();

    vdim(-tip_y, tip_y, tip_x - 1.5 * s,
         str("mouth ", mm2(chord_tooth), " < groove Ø", valley_diameter,
             " -> spreads ", mm2(spread_needed), " to clip on"), true);
    hdim(-r_skirt, r_skirt, -r_flange - 2.5 * s,
         str("skirt Ø", mm2(2 * r_skirt), " in a Ø", panel_hole,
             " hole -> ", mm2(hole_slack), " to spread. It cannot."), true);
    color("Black") translate([0, r_flange + 1.5 * s])
        text(str(coverage_deg, "° of wrap"), size = ts, halign = "center");
}

// ── Legend (auto-generated from the parameters) ─────────────────────────────
labels = [
    str("pipe_diameter   = ", pipe_diameter, " mm   crest Ø  -- MEASURE YOURS"),
    str("valley_diameter = ", valley_diameter, " mm   groove root Ø"),
    str("corr_pitch      = ", corr_pitch, " mm   x ", tooth_count, " teeth"),
    str("valley_width    = ", valley_width, " mm   groove at the crest"),
    valley_root_width > 0
      ? str("valley_root_w   = ", valley_root_width,
            " mm   and at the root -- a V")
      : "                      (groove taken as square-bottomed)",
    str("-> tooth ", mm2(tooth_w), " at the base, ", mm2(tooth_tip_w),
        " at the tip, ", mm2(r_crest - r_tooth), " mm deep"),
    "",
    str("panel_hole      = ", panel_hole, " mm   RECOMMENDED drill"),
    str("panel_thickness = ", panel_thickness, " mm"),
    str("coverage_deg    = ", coverage_deg, " deg"),
    "",
    str("Overall         = Ø", flange_diameter, " x ", mm2(length), " long"),
    str("Into the cabinet= ", mm2(flange_thickness), " mm -- the flange, nothing else"),
    str("Skirt           = Ø", mm2(2 * r_skirt), " on ", mm2(skirt_wall),
        " mm of gods over the crests"),
    "",
    "THE LOCK",
    str("  to clip over the pipe the arms spread ", mm2(spread_needed), " mm"),
    str("  in the hole they have ", mm2(hole_slack), " mm to move"),
    str("  -> ", mm2(lock_ratio), "x. The collar cannot let go of the pipe"),
    "     without first leaving the hole.",
    "",
    "THE LOAD SEATS IT",
    "  The pipe pulls outward, the teeth hand that to the collar,",
    "  the flange lies on the inside face of the panel. The force",
    str("  we resist is what holds it home -- over ", mm1(flange_bearing), " mm^2."),
    "",
    str("Bearing, ", tooth_count, " teeth on the crests: ", mm1(tooth_bearing), " mm^2"),
    str("Print flange-down, ", groove_fillet,
        " mm groove fillet eases the tooth overhang.")
];

color("Black")
    translate([r_flange + 27 * s, y_fig2 + r_flange + 2 * s])
        for (i = [0 : len(labels) - 1])
            translate([0, -i * lh]) text(labels[i], size = ts, font = "Liberation Mono");
