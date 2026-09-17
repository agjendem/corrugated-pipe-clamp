// ============================================================================
//  snap_collar.scad -- strain relief where conduit enters a cabinet wall
// ----------------------------------------------------------------------------
//  A 16 mm corrugated conduit comes through a drilled hole in the side of a
//  low-voltage / data cabinet ("svakstrømsskap"). Nothing holds it: it is not
//  fixed in the wall and cannot be, so it can slide back out of the cabinet and
//  disappear into the cavity. This is the part that stops it.
//
//  It is NOT pipe_clamp.scad. That one's outer diameter IS the wall hole, so the
//  pipe has to be threaded through the hole before the clamp goes on. Here the
//  pipe is already in place, so this one clips on SIDEWAYS -- a C of
//  coverage_deg, snapped over the pipe and down into its grooves.
//
//      <- in the cabinet | panel | in the wall ->
//      __________________|_______|_________________
//     |     flange       | skirt |                 |
//     |     Ø28          | Ø19.6 |                 |
//     |__________________|__ ##__|_##____##________|   teeth, in the grooves
//     - - - - - - - - - - - - - - - - - - - - - - -    centreline
//     |      2 mm        |  2 mm |     7,4 mm      |
//
//  TWO THINGS HOLD IT, and neither is a screw:
//
//  1. The load seats it. The pipe pulls OUTWARD; the teeth hand that load to the
//     collar; the collar's flange lies against the INSIDE face of the panel.
//     The very force we are resisting is what presses the part home. Inward is
//     harmless. So nothing has to latch, and everything except the flange can
//     live in the hole and out in the wall -- 2 mm of build height inside the
//     cabinet, which is all the room there is.
//
//  2. The hole locks the C shut. To clip over the pipe the arms must spread
//     spread_needed (1.77 mm at the defaults). Once the skirt is in the hole
//     they have hole_slack (0.9 mm) to move in. The collar cannot let go of the
//     pipe without first leaving the hole, and it cannot leave the hole while
//     the pipe is pulling it against the panel. That ratio is asserted below:
//     it is the whole design in one number.
//
//  To remove it: push the pipe further in (harmless), pull the collar out of the
//  hole, then unclip it.
//
//  All dimensions are in millimetres.
//
//  Conduit standard (IEC/EN 61386): the nominal size is the outer (crest) Ø --
//  16, 20, 25, 32, 40, 50, 63 mm. The standard does NOT fix the corrugation
//  depth or pitch, and the two projects here measured two different "16 mm"
//  pipes (15.8/13.0/3.79 here, 16.0/14.0/3.372 in corrugated-pipe-bend).
//  MEASURE YOURS. Print the snap_collar_16mm_fittest preset first.
// ============================================================================

/* [Part] */
part = "body";  // [body:the collar, section:cutaway, assembly:in the panel, pipe:a test length of conduit]

/* [Conduit -- MEASURE YOURS] */
pipe_diameter   = 15.8; // crest (outer) Ø of the conduit (mm)
valley_diameter = 13.0; // groove (root) Ø of the conduit (mm)
corr_pitch      = 3.79; // one corrugation period along the axis (mm)
valley_width    = 1.2;  // axial width of one groove -- where a tooth sits (mm)
pipe_bore       = 11;   // the conduit's own bore; only used by part = "pipe" (mm)
corr_round      = 0.3;  // fillet on the convex tooth TIPS (mm)
groove_fillet   = 0.6;  // fillet in the concave groove bottoms (mm); this is the
                        // printed tooth-underside overhang, so bigger prints cleaner

/* [Fits] */
pipe_clearance   = 0.4; // diametral, bore over the pipe's crests (mm)
bottom_clearance = 0.4; // diametral, tooth tip against the groove root (mm)
tooth_side_play  = 0.2; // axial, tooth inside the groove (mm)
skirt_clearance  = 0.4; // diametral, skirt inside the drilled hole (mm)
hole_tolerance   = 0.5; // how far over nominal a drilled hole may come out (mm)

/* [Cabinet panel] */
panel_hole      = 20;   // RECOMMENDED drill Ø -- see the report below (mm)
panel_thickness = 2;    // the cabinet wall (mm)

/* [Collar] */
coverage_deg = 240;     // [235:5:285] degrees of pipe wrapped -- sets the snap.
                        // The window is narrow and the two asserts below define
                        // its real ends: too little and the collar neither holds
                        // the pipe nor gets locked by the hole, too much and
                        // there is no mouth left to get the pipe in.
tooth_count  = 3;       // corrugations gripped -> also sets the length
mouth_lead   = 0.6;     // lead-in radius on the arm tips (mm); 0 = square lip

/* [Flange (bears on the inside of the panel)] */
flange_diameter  = 28;  // must cover the hole with a ring to spare (mm)
flange_thickness = 2;   // the ONLY thing that builds into the cabinet (mm)

/* [Screw brim -- anchor to a stud instead of trusting the hole] */
screw_count   = 0;      // [0:none, 1:one, dead opposite the mouth, 2:one each side, 3:three]
screw_pcd     = 31;     // circle the screw centres sit on (mm)
screw_spread  = 90;     // degrees either side of centre (ignored when count = 1)
screw_d       = 4.0;    // clearance hole for a 3.5 mm gipsskrue (mm)
screw_head_d  = 8.0;    // its bugle head (mm)
screw_cs_angle = 90;    // included angle of the countersink (deg)
screw_head_at_skirt = true; // head on the face the SKIRT rises from -- this part
                        // is fitted the other way up from pipe_clamp, which has
                        // its heads on the flange's outer face. Set false to
                        // match pipe_clamp.
// With the defaults the cone is exactly 2 mm deep -- the whole brim. That is
// how a countersunk hole in thin material works: the cone is the bearing face.
// Widen flange_diameter to suit; the asserts below say by how much.

/* [Render quality] */
$fn = 96;

// ── Derived ─────────────────────────────────────────────────────────────────
r_crest   = pipe_diameter   / 2;                    // the pipe, at a crest
r_valley  = valley_diameter / 2;                    // the pipe, at a groove
r_recess  = r_crest  + pipe_clearance   / 2;        // our bore, clearing a crest
r_tooth   = r_valley + bottom_clearance / 2;        // our bore, seated in a groove
r_skirt   = (panel_hole - skirt_clearance) / 2;     // our OD, filling the hole
r_flange  = flange_diameter / 2;

tooth_w   = valley_width - tooth_side_play;         // tooth, axially
recess_w  = corr_pitch - tooth_w;                   // recess, axially
corr_depth = r_recess - r_tooth;                    // how far a tooth reaches in
length    = corr_length(tooth_count, recess_w, tooth_w);
skirt_wall = r_skirt - r_recess;                    // thinnest gods, over a crest

// The snap, in chords across the mouth. The arms have to let two things past:
// the pipe's crests must clear the recess walls, and its grooves must clear the
// tooth tips. Whichever needs more spread is the one you feel when you clip it
// on; the tooth one is also what holds the collar on the pipe afterwards.
half_gap     = (360 - coverage_deg) / 2;
chord_tooth  = 2 * r_tooth  * sin(half_gap);
chord_recess = 2 * r_recess * sin(half_gap);
snap_overlap  = valley_diameter - chord_tooth;      // sideways hold, diametral
spread_needed = max(pipe_diameter - chord_recess, snap_overlap);
hole_slack    = skirt_clearance + hole_tolerance;   // room to spread, in the hole
lock_ratio    = spread_needed / hole_slack;

inside = flange_thickness;                          // build height in the cabinet
flange_bearing = PI / 4 * (pow(flange_diameter, 2) - pow(panel_hole, 2))
                 * coverage_deg / 360;
tooth_bearing  = tooth_count * PI * (pow(r_crest, 2) - pow(r_tooth, 2))
                 * coverage_deg / 360;

// How far the skirt actually sits inside the hole. With a 2 mm cabinet panel it
// is the panel; with a 45 mm stud bored through it is however much skirt there
// is. Either way this is what the hole has to grip to lock the C.
engagement = min(panel_thickness, length - flange_thickness);

// The corrugation profile and its two fillets, shared with pipe_clamp.scad.
include <corrugation.scad>
// Countersunk screw holes in the brim, shared with pipe_clamp.scad.
include <brim.scad>

function mm1(x) = round(x * 10) / 10;
function mm2(x) = round(x * 100) / 100;

// ── Sanity checks ───────────────────────────────────────────────────────────
assert(valley_diameter < pipe_diameter,
       str("valley_diameter ", valley_diameter, " must be under the crest Ø ",
           pipe_diameter, " -- they are the groove root and the outside"));
assert(valley_width < corr_pitch,
       str("valley_width ", valley_width, " must be under the pitch ", corr_pitch));
assert(tooth_w > 0.4,
       str("tooth ", mm2(tooth_w), " mm wide is too thin to print or to hold -- ",
           "measure valley_width again, or cut tooth_side_play"));
assert(r_tooth > 0, "bottom_clearance leaves no tooth");
assert(coverage_deg > 180,
       str("coverage_deg ", coverage_deg, " does not pass the equator, so the ",
           "collar cannot clip on at all"));
assert(coverage_deg < 300,
       str("coverage_deg ", coverage_deg, " leaves no mouth to get the pipe in"));
assert(snap_overlap >= 0.6,
       str("sideways hold is only ", mm2(snap_overlap), " mm -- the collar would ",
           "fall off the pipe. Raise coverage_deg (it is ", coverage_deg, ")"));

// The design, as one assertion: spreading the C must be harder than the hole
// allows, by a clear margin, or the collar can open while it is seated.
assert(spread_needed >= 1.5 * hole_slack,
       str("the hole does not lock the collar: it must spread ",
           mm2(spread_needed), " mm to release the pipe but has ",
           mm2(hole_slack), " mm of room in the hole. Raise coverage_deg, or ",
           "tighten skirt_clearance / hole_tolerance"));

assert(skirt_wall >= 1.2,
       str("only ", mm2(skirt_wall), " mm of skirt over the crests -- drill at ",
           "least Ø", mm1(pipe_diameter + pipe_clearance + 2 * 1.2 + skirt_clearance),
           " (panel_hole is ", panel_hole, ")"));
assert(flange_diameter >= panel_hole + 6,
       str("flange Ø", flange_diameter, " leaves under 3 mm of bearing ring ",
           "around a Ø", panel_hole, " hole"));
// Not "the teeth must reach past the wall" -- that is the wrong question once
// the thing being bored is a 45 mm stud rather than a 2 mm panel. What matters
// either way is that enough skirt sits inside the hole for the hole to hold the
// C shut.
// panel_thickness = 0 means there is no panel at all -- a bare fit-test clip, or
// one screwed down where nothing is bored for the skirt to enter. Then there is
// no hole to lock the C and the snap is on its own, which is what the
// snap_overlap assert above is for.
assert(panel_thickness == 0 || engagement >= 1.5,
       str("only ", mm2(engagement), " mm of skirt sits in the hole, so the hole ",
           "cannot lock the C. Raise tooth_count (the collar is ", mm2(length),
           " mm long and the flange takes ", flange_thickness, ")"));
assert(mouth_lead < r_tooth / 2,
       str("mouth_lead ", mouth_lead, " would eat the arm tips"));

for (c = corr_fillet_checks(corr_round, groove_fillet, corr_depth,
                            recess_w, tooth_w))
    assert(c[0], c[1]);

for (c = brim_checks(screw_count, screw_pcd, screw_spread, screw_d, screw_head_d,
                     screw_cs_angle, flange_thickness,
                     r_skirt + groove_fillet, r_flange, coverage_deg / 2))
    assert(c[0], c[1]);

// ── Report ──────────────────────────────────────────────────────────────────
echo(str("Drill the panel: Ø", panel_hole, " (skirt Ø", mm2(2 * r_skirt),
         ", ", mm2(skirt_wall), " mm of gods over the crests)"));
echo(str("Build height inside the cabinet: ", mm2(inside),
         " mm  (the flange, and nothing else)"));
echo(str("Overall length: ", mm2(length), " mm -- ", mm2(inside), " in, ",
         panel_thickness, " in the panel, ",
         mm2(length - inside - panel_thickness), " out in the wall"));
echo(str("Collar Ø", mm2(2 * r_skirt), ", flange Ø", flange_diameter,
         ", bore Ø", mm2(2 * r_recess), " over crests / Ø", mm2(2 * r_tooth),
         " at the teeth"));
echo(str("Clip-on spread: ", mm2(spread_needed), " mm  (crest past the recess ",
         "walls ", mm2(pipe_diameter - chord_recess), ", groove past the tooth ",
         "tips ", mm2(snap_overlap), ")"));
echo(str("Sideways hold on the pipe: ", mm2(snap_overlap), " mm diametral"));
echo(str("LOCK: needs ", mm2(spread_needed), " mm to open, has ",
         mm2(hole_slack), " mm in the hole -> ", mm2(lock_ratio), "x"));
echo(str("Bearing area, flange on panel: ", mm1(flange_bearing), " mm^2"));
echo(str("Bearing area, ", tooth_count, " teeth on the crests: ",
         mm1(tooth_bearing), " mm^2"));
echo(str("Teeth grip ", tooth_count, " corrugations over ", mm2(length), " mm"));
echo(panel_thickness == 0
     ? "No panel: nothing bored for the skirt, so the snap alone holds the C shut"
     : str("Skirt sits ", mm2(engagement), " mm into the hole"));
if (screw_count > 0) {
    echo(str("Screw brim: ", screw_count, " x Ø", screw_d, " on a Ø", screw_pcd,
             " circle, ", screw_cs_angle, "° countersink ",
             mm2(brim_cs_depth(screw_head_d, screw_d, screw_cs_angle)),
             " mm deep in a ", flange_thickness, " mm brim"));
    echo(str("  head is countersunk into the ",
             screw_head_at_skirt ? "SKIRT side (z = " : "outer face (z = ",
             screw_head_at_skirt ? flange_thickness : 0,
             ") -- the flange bears on the other face"));
    echo(str("  head Ø", screw_head_d, " sits between r ",
             mm2(screw_pcd / 2 - screw_head_d / 2), " and r ",
             mm2(screw_pcd / 2 + screw_head_d / 2), "; body out to r ",
             mm2(r_skirt + groove_fillet), ", brim edge r ", mm2(r_flange)));
    echo("  Screwed down, the pipe is held BOTH ways -- not just from pulling out.");
}

// ====  THE PART  ============================================================
//  Cross-section in the (radius, axial-z) plane, revolved through coverage_deg.
//  z = 0 is the cabinet-side face of the flange; +z runs out into the wall.
//  The bore is the shared corrugation wave; what is local to this part is how
//  the section is CLOSED on the outside -- a flange, then a constant-Ø skirt.
inner = corr_inner(r_recess, r_tooth, tooth_count, recess_w, tooth_w);

profile = concat(inner, [
    [r_skirt,  length],             // out to the skirt at the far end
    [r_skirt,  flange_thickness],   // down the skirt to the flange
    [r_flange, flange_thickness],   // out across the top of the flange
    [r_flange, 0]                   // down the flange rim; polygon closes home
]);

module section_2d() {
    corr_soften(corr_round, groove_fillet) polygon(points = profile);
}

module collar_raw() {
    rotate_extrude(angle = coverage_deg, convexity = 6) section_2d();
}

// Rounds the edge where the mouth face meets the tooth tips, so a pipe pushed
// at the mouth cams the arms open instead of butting into a square lip. The
// tooth tips are the innermost thing on the arm and so the first thing the pipe
// touches; the recess walls sit corr_depth further out and meet the pipe's own
// rounded crest, which cams by itself.
//
// A convex edge is rounded by removing the corner MINUS a rod laid in it -- not
// the rod, which would just drill a hole tangent to both faces.
module mouth_fillet() {
    R  = mouth_lead;
    cx = sqrt(pow(r_tooth + R, 2) - R * R);   // rod axis: R off both faces
    difference() {
        intersection() {                                   // the square corner
            translate([0, 0, -1]) cylinder(h = length + 2, r = r_tooth + R);
            // Reaching 1 mm PAST the mouth plane, not stopping dead on it. The
            // extrusion's own start face lies at y = 0 and the arc is empty
            // below it at these x, so the overshoot cuts nothing -- but a
            // subtrahend that ends exactly on the face it is cutting leaves
            // slivers, and here they came out as loose 0.06 mm flecks sitting
            // on the tooth tips, four separate shells hanging off the part.
            translate([0, -1, -1])
                cube([r_tooth + R + 1, R + 1, length + 2]);
        }
        translate([cx, R, -2])                             // the rod in it
            cylinder(h = length + 4, r = R, $fn = 24);
    }
}

module mouth_lead_cuts() {
    if (mouth_lead > 0) {
        mouth_fillet();                                    // the theta = 0 arm
        rotate([0, 0, coverage_deg]) mirror([0, 1, 0])     // the far arm
            mouth_fillet();
    }
}

// Turned so the mouth straddles -X: the part is symmetric about the X axis,
// which is what every view and the section below assume.
module body() {
    difference() {
        rotate([0, 0, -coverage_deg / 2])
            difference() {
                collar_raw();
                mouth_lead_cuts();
            }
        // Cut after the rotation, so a screw angle is measured from the middle
        // of the material -- which is where one screw has to go anyway.
        brim_screw_cuts(screw_count, screw_pcd, screw_spread, screw_d,
                        screw_head_d, screw_cs_angle, flange_thickness,
                        screw_head_at_skirt);
    }
}

module body_section() {
    intersection() {
        body();
        translate([-50, -100, -1]) cube([100, 100, length + 2]);
    }
}

// ====  THE CONDUIT  =========================================================
//  A real corrugated pipe, not a smooth cylinder -- the same wave, run with the
//  PIPE's own duty cycle (crest wide, groove narrow) instead of ours. Exportable
//  as part = "pipe": a stub to test the clip on if you have no offcut handy.
pipe_crest_w = corr_pitch - valley_width;
pipe_n       = tooth_count + 6;
pipe_z0      = tooth_side_play / 2 - 3 * corr_pitch;   // centres our teeth in its grooves

// The pipe's groove is only valley_width (1.2 mm) wide, a third of the recesses
// we cut for its crests, so it cannot take the same fillet: groove_fillet 0.6 is
// exactly half of 1.2, the closing seals the grooves outright and the "pipe"
// comes out a smooth tube that our teeth then crash into. Clamp it to the same
// margin corrugation.scad asserts for our own recesses.
pipe_fillet = min(groove_fillet, CORR_FILLET_MAX * valley_width);

module conduit(n = undef, z0 = undef) {
    nn = is_undef(n)  ? pipe_n  : n;
    zz = is_undef(z0) ? pipe_z0 : z0;
    outer = corr_inner(r_crest, r_valley, nn, pipe_crest_w, valley_width, zz);
    len   = corr_length(nn, pipe_crest_w, valley_width);
    rotate_extrude(convexity = 6)
        difference() {
            corr_soften(corr_round, pipe_fillet)
                polygon(points = concat(outer, [
                    [pipe_bore / 2, zz + len],
                    [pipe_bore / 2, zz]
                ]));
            translate([-1, zz - 1]) square([1 + pipe_bore / 2, len + 2]);
        }
}

// ====  ASSEMBLY  ============================================================
module panel_ghost() {
    color("silver", 0.35)
        translate([0, 0, flange_thickness])
            difference() {
                translate([-25, -25, 0]) cube([50, 50, panel_thickness]);
                translate([0, 0, -1]) cylinder(h = panel_thickness + 2,
                                               d = panel_hole + hole_tolerance);
            }
}

module pipe_ghost() {
    color("darkorange", 0.55) conduit();
}

module assembly() {
    body();
    panel_ghost();
    pipe_ghost();
}

// Render the model, unless another file (e.g. snap_collar_dimensions.scad)
// includes this one only for its parameters and modules -- it sets
// DIMENSIONS_ONLY first.
if (is_undef(DIMENSIONS_ONLY)) {
    if      (part == "body")     body();
    else if (part == "section")  body_section();
    else if (part == "assembly") assembly();
    else if (part == "pipe")     conduit(n = 8, z0 = 0);
    else assert(false, str("unknown part: ", part));
}
