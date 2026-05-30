// ============================================================================
//  Parametric clamp for corrugated conduit (electrical draw-in pipe)
// ----------------------------------------------------------------------------
//  A clamp that wraps partially (coverage_deg) around a corrugated conduit.
//  Internal circumferential ridges seat into the conduit's grooves and lock
//  the pipe axially. A flange at one end is wider than the pipe so the
//  clamp + pipe cannot be pulled through a hole in a wall.
//
//  Sizing logic (example: 16 mm conduit -> 18 mm bore):
//    bore_diameter = bore over the conduit's corrugation CRESTS (here 18 mm).
//    The clamp's own grip ridges protrude inward by corr_depth and seat in
//    the conduit's grooves. The pipe's nominal/grip diameter therefore is
//    approximately  bore_diameter - 2*corr_depth = 16 mm.
//    Wall is added outside the bore. The flange extends flange_overhang mm
//    beyond the pipe width (Ø18).
//
//  All dimensions are in millimetres.
// ============================================================================

/* [Pipe / bore] */
bore_diameter  = 18;   // inner bore over the conduit's corrugation crests (mm)
corr_depth     = 1;    // radial depth of the corrugation (mm)
corr_width     = 1.5;  // width of each ridge along the pipe axis (mm)
groove_width   = 1.5;  // width of each groove/recess along the pipe axis (mm)
corr_count     = 6;    // number of corrugation periods -> sets the length

/* [Clamp wall] */
wall_thickness = 2;    // solid material outside the bore, radial (mm)
coverage_deg   = 200;  // degrees of the pipe circumference covered

/* [Flange (end stop against a wall)] */
flange_overhang  = 3;  // how far the flange extends beyond the pipe width (mm)
flange_thickness = 1;  // flange thickness along the pipe axis (mm)

/* [Render quality] */
$fn = 180;

// ── Derived dimensions ──────────────────────────────────────────────────────
r_recess = bore_diameter / 2;            // bore over crests
r_grip   = r_recess - corr_depth;        // grip ridge seated in groove
r_outer  = r_recess + wall_thickness;    // outer wall (smooth)
period   = corr_width + groove_width;    // one corrugation period along the axis
length   = corr_count * period;          // total length along the pipe
r_flange = r_recess + flange_overhang;   // flange outer radius (beyond the pipe)

// ── Clamp body: square-wave inner edge, smooth outer edge ───────────────────
//  Cross-section in the (radius, axial-z) plane, revolved around Z.
inner_pts = [ for (i = [0 : corr_count - 1]) each [
    [r_recess, i * period],                  // groove start
    [r_recess, i * period + groove_width],   // groove end
    [r_grip,   i * period + groove_width],   // step in to grip ridge
    [r_grip,   (i + 1) * period]             // ridge end / next start
]];

// Close the profile along the outer wall (top -> bottom). polygon() closes
// automatically from [r_outer, 0] back to the first point [r_recess, 0].
profile = concat(inner_pts, [ [r_outer, length], [r_outer, 0] ]);

module clamp_body() {
    rotate_extrude(angle = coverage_deg)
        polygon(points = profile);
}

// ── Flange: sector ring at the end (z = 0 .. flange_thickness) ──────────────
//  Bore = r_recess so the pipe passes through and the flange fuses with the
//  clamp wall (overlapping radii r_recess..r_outer).
module flange() {
    rotate_extrude(angle = coverage_deg)
        polygon(points = [
            [r_recess, 0],
            [r_flange, 0],
            [r_flange, flange_thickness],
            [r_recess, flange_thickness]
        ]);
}

// ── Assembly ────────────────────────────────────────────────────────────────
union() {
    clamp_body();
    flange();
}
