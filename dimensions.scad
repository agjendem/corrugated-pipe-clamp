// ============================================================================
//  Dimensioned drawing for pipe_clamp.scad
// ----------------------------------------------------------------------------
//  A flat 2D half-section with dimension lines and a legend. Every number is
//  read straight from pipe_clamp.scad's parameters, so this drawing always
//  matches the model. Render top-down / orthographic (see render.sh).
// ============================================================================

DIMENSIONS_ONLY = true;     // suppress the 3D model in the included file
include <pipe_clamp.scad>;

$fn = 64;

ts   = 1.1;   // text size (mm)
lh   = 1.8;   // legend line height (mm)
lw   = 0.08;  // dimension line width (mm)
tick = 0.6;   // arrow/tick size (mm)

// ── Half cross-section (right of the axis), in (x = radius, y = axial z) ─────
color("SteelBlue") {
    polygon(profile);                                    // clamp body wall
    polygon([[r_recess, 0], [r_flange, 0],               // flange
             [r_flange, flange_thickness], [r_recess, flange_thickness]]);
}

// Axis centreline
color("Crimson") translate([-lw/2, -3]) square([lw, length + 6]);

// ── Dimension helpers ───────────────────────────────────────────────────────
module hdim(x0, x1, y, label) {           // horizontal dimension
    color("Black") {
        translate([min(x0, x1), y - lw/2]) square([abs(x1 - x0), lw]);
        for (x = [x0, x1]) translate([x, y]) rotate(45) square(tick, center = true);
        translate([(x0 + x1) / 2, y + 0.4]) text(label, size = ts, halign = "center");
    }
}
module vdim(y0, y1, x, label) {           // vertical dimension
    color("Black") {
        translate([x - lw/2, min(y0, y1)]) square([lw, abs(y1 - y0)]);
        for (y = [y0, y1]) translate([x, y]) rotate(45) square(tick, center = true);
        translate([x + 0.5, (y0 + y1) / 2]) text(label, size = ts, valign = "center");
    }
}

// Diameters (drawn from the axis to the relevant radius, doubled in the label)
hdim(-r_outer,  r_outer,  length + 2.5, str("bore Ø ", bore_diameter));
hdim(-r_recess, r_recess, length + 0.8, str("pipe Ø ", pipe_diameter));
hdim(-r_flange, r_flange, -2,           str("flange Ø ", 2 * r_flange));

// Wall / corrugation detail on the right wall
vdim(0, length, r_flange + 0.5, str("length ", length));
vdim(0, flange_thickness, r_flange + 0.5, str(" t ", flange_thickness));

// ── Legend (auto-generated from the parameters) ─────────────────────────────
labels = [
    str("pipe_diameter  = ", pipe_diameter, " mm"),
    str("bore_diameter  = ", bore_diameter, " mm  (clamp outer)"),
    str("flange Ø       = ", 2 * r_flange, " mm"),
    str("material       = ", material, " mm  (= (bore-pipe)/2)"),
    str("corr_depth     = ", corr_depth, " mm"),
    str("corr_width     = ", corr_width, " mm"),
    str("groove_width   = ", groove_width, " mm"),
    str("corr_chamfer   = ", corr_chamfer, " mm"),
    str("flange_thick.  = ", flange_thickness, " mm"),
    str("coverage_deg   = ", coverage_deg),
    str("corr_count     = ", corr_count, "  ->  length ", length, " mm"),
];
color("Black")
    for (i = [0 : len(labels) - 1])
        translate([r_flange + 9, length - i * lh])
            text(labels[i], size = ts, font = "Liberation Mono:style=Regular");
