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
//
//  Conduit standard (IEC/EN 61386):
//    Electrical conduit is standardised by IEC 61386 ("Conduit systems for
//    cable management"); flexible/corrugated conduit by part -22. The NOMINAL
//    size = the outer (crest) diameter -> set pipe_diameter to one of:
//        16, 20, 25, 32, 40, 50, 63 mm   (16/20/25 are the common domestic sizes)
//    The standard does NOT fix the corrugation depth or pitch -- these vary by
//    maker. Measure your actual pipe and set the corrugation params:
//        pipe_diameter        = crest (outer) Ø
//        corr_depth           = (crest Ø - valley Ø) / 2
//        corr_width+groove_width (pitch) = (length of N corrugations) / N
// ============================================================================

/* [Pipe / bore] */
pipe_diameter  = 15.8; // outer (crest) diameter of the corrugated conduit (mm)
bore_diameter  = 18;   // hole the clamp passes through = clamp body outer Ø (mm)
corr_depth     = 1.4;   // how far grip teeth bite into the conduit grooves (mm)
corr_width     = 1.2;   // width of each grip tooth along the pipe axis (mm)
groove_width   = 2.59;  // width of each recess (over a crest) along the axis (mm)
corr_count     = 6;     // number of corrugation periods -> sets the length
corr_round     = 0.1;   // fillet radius rounding the tooth/recess edges (mm);
                        // real conduit is U-shaped, not square. 0 = sharp corners.
// Defaults measured off a real "16 mm" conduit: crest Ø 15.8, valley Ø 13.0
// (-> corr_depth 1.4), 6 corrugations spanned 22.74 mm (pitch 3.79 = 1.2 + 2.59).

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
assert(corr_round <= min(corr_width, groove_width) / 2,
       "corr_round must be <= min(corr_width, groove_width)/2");
assert(corr_round <= corr_depth,
       "corr_round must be <= corr_depth");

echo(str("Available material (radial): ", material, " mm"));
echo(str("Clamp body outer Ø: ", bore_diameter, " mm"));
echo(str("Flange Ø: ", 2 * r_flange, " mm"));
echo(str("Length: ", length, " mm"));

// ── Clamp body: square-wave inner edge rounded by a fillet ──────────────────
//  Cross-section in the (radius, axial-z) plane, revolved around Z.
//  Teeth (r_grip) sit in the conduit grooves; recesses (r_recess) clear crests.
//  The raw profile is a sharp square wave; corr_round then fillets every inner
//  corner via the offset(r) offset(-r) trick, so both the concave recess
//  corners and the convex tooth tips get a true radius (real conduit is
//  U-shaped, not square).
inner_pts = concat(
    [ [r_recess, 0] ],                               // flat at the flange end
    [ for (i = [0 : corr_count - 1]) each [
        [r_recess, i * period],                      // recess start (over a crest)
        [r_recess, i * period + groove_width],       // recess end
        [r_grip,   i * period + groove_width],       // step in to grip tooth
        [r_grip,   (i + 1) * period]                 // tooth end / next start
    ]],
    [ [r_recess, length] ]                           // flat at the far end
);

// Close the profile along the outer wall (top -> bottom). polygon() closes
// automatically from [r_outer, 0] back to the first point [r_recess, 0].
profile = concat(inner_pts, [ [r_outer, length], [r_outer, 0] ]);

// 2D half-section, with the corrugation corners rounded by corr_round.
// The offset(r) offset(-r) pair fillets every corner by corr_round: convex
// tooth tips AND the concave recess corners, while leaving the overall size,
// the straight outer wall and the flat ends essentially untouched.
module section_2d() {
    if (corr_round > 0)
        offset(r = corr_round) offset(r = -corr_round)
            polygon(points = profile);
    else
        polygon(points = profile);
}

module clamp_body() {
    rotate_extrude(angle = coverage_deg) section_2d();
}

// ── Flange: sector ring at the end (z = 0 .. flange_thickness) ──────────────
//  Bore = r_recess so the pipe passes through and the flange fuses with the
//  clamp body (overlapping radii r_recess..r_outer). With flange_overhang = 0
//  there is no lip to add, so the module is a no-op.
module flange() {
    if (flange_overhang > 0)
        rotate_extrude(angle = coverage_deg)
            polygon(points = [
                [r_recess, 0],
                [r_flange, 0],
                [r_flange, flange_thickness],
                [r_recess, flange_thickness]
            ]);
}

// ── Assembly ────────────────────────────────────────────────────────────────
// Render the model, unless another file (e.g. dimensions.scad) includes this
// one only for its parameters and modules — it sets DIMENSIONS_ONLY first.
if (is_undef(DIMENSIONS_ONLY)) union() {
    clamp_body();
    flange();
}
