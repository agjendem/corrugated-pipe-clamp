// ============================================================================
//  Parametric clamp for corrugated conduit (electrical draw-in pipe)
// ----------------------------------------------------------------------------
//  A clamp that wraps partially (coverage_deg) around a corrugated conduit.
//  Internal circumferential teeth bite into the conduit's grooves and lock
//  the pipe axially. A flange at one end is wider than the pipe so the
//  clamp + pipe cannot be pulled through a hole in a wall.
//
//  Sizing logic (example: 16 mm conduit, 18 mm wall hole):
//    pipe_diameter = the conduit's outer (crest) diameter (here 16 mm).
//    bore_diameter = the hole the clamp must pass through, i.e. the clamp
//                    body's OUTER diameter (here 18 mm).
//    The available material is therefore (bore_diameter - pipe_diameter)/2
//    (here 1 mm radial) -- this is the smooth backing wall over the crests.
//    The grip teeth bite an additional corr_depth into the conduit grooves.
//    The flange extends flange_overhang mm beyond the pipe and catches on
//    the wall hole.
//
//  All dimensions are in millimetres.
// ============================================================================

/* [Pipe / bore] */
pipe_diameter  = 16;   // outer (crest) diameter of the corrugated conduit (mm)
bore_diameter  = 18;   // hole the clamp passes through = clamp body outer Ø (mm)
corr_depth     = 1;    // how far grip teeth bite into the conduit grooves (mm)
corr_width     = 1.5;  // width of each grip tooth along the pipe axis (mm)
groove_width   = 1.5;  // width of each recess (over a crest) along the axis (mm)
corr_count     = 6;    // number of corrugation periods -> sets the length

/* [Clamp] */
coverage_deg   = 200;  // degrees of the pipe circumference covered

/* [Flange (end stop against a wall)] */
flange_overhang  = 3;  // how far the flange extends beyond the pipe width (mm)
flange_thickness = 1;  // flange thickness along the pipe axis (mm)

/* [Render quality] */
$fn = 180;

// ── Derived dimensions ──────────────────────────────────────────────────────
material = (bore_diameter - pipe_diameter) / 2;  // backing wall over crests (mm)

r_outer  = bore_diameter / 2;            // smooth outer wall of the clamp body
r_recess = pipe_diameter / 2;            // inner radius over a pipe crest (clearance)
r_grip   = r_recess - corr_depth;        // grip tooth seated in a pipe groove
period   = corr_width + groove_width;    // one corrugation period along the axis
length   = corr_count * period;          // total length along the pipe
r_flange = r_recess + flange_overhang;   // flange outer radius (beyond the pipe)

assert(bore_diameter > pipe_diameter,
       "bore_diameter must be larger than pipe_diameter");
assert(r_grip > 0, "corr_depth too large for this pipe_diameter");

echo(str("Available material (radial): ", material, " mm"));
echo(str("Clamp body outer Ø: ", bore_diameter, " mm"));
echo(str("Flange Ø: ", 2 * r_flange, " mm"));
echo(str("Length: ", length, " mm"));

// ── Clamp body: square-wave inner edge, smooth outer edge ───────────────────
//  Cross-section in the (radius, axial-z) plane, revolved around Z.
//  Teeth (r_grip) sit in the conduit grooves; recesses (r_recess) clear crests.
inner_pts = [ for (i = [0 : corr_count - 1]) each [
    [r_recess, i * period],                  // recess start (over a crest)
    [r_recess, i * period + groove_width],   // recess end
    [r_grip,   i * period + groove_width],   // step in to grip tooth
    [r_grip,   (i + 1) * period]             // tooth end / next start
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
//  clamp body (overlapping radii r_recess..r_outer).
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
