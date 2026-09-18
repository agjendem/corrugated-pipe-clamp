// ============================================================================
//  Corner bend -- an addon to the 40 mm wall mount in pipe_clamp.scad
// ----------------------------------------------------------------------------
//  The conduit comes out of the SIDE wall, behind the cabinet, and lies hard
//  against the cabinet's back panel. It has to turn 90° and go straight in
//  through that panel, and there is almost no room to do it in.
//
//  The layout, in section through the bend plane:
//
//      side wall
//     |
//     | Ø94 flange of the mount = the face we glue to
//     |+--------------------+        ---
//     ||                    |         |  flange radius   47
//     ||  ===== cut conduit |         |
//     ||                    |        -+- conduit axis
//     ||                    |         |  conduit radius  20
//     |+---------+----------+        ---
//     ===========|==============  cabinet back panel
//                v
//            threaded stuss + nut, into the cabinet
//
//  Two things fall straight out of that picture and shape the whole part:
//
//  IT CANNOT BE AN ELBOW. The conduit's axis sits only its own radius above
//  the outlet plane, so a 90° arc would need a centreline radius of 20 mm --
//  smaller than the channel's own radius. A swept tube would fold through
//  itself. So the inside is not a tube but a CHAMBER: the convex hull of the
//  two ports, which gives a smooth surface tangent to both and lets the cable
//  ride round the outside of the turn instead of being pinched.
//
//  THE CHANNEL TAKES THE CONDUIT'S BORE, NOT ITS CREST. The conduit is cut off
//  at the flange, so nothing has to slide over it -- the channel only has to
//  carry what the pipe carries. At Ø34 that leaves 3 mm of floor under it; at
//  the Ø41.5 crest the channel would break out through the bottom face.
//
//  The outside is a thin shell that follows the chamber, not a solid wedge.
//  Only three things need to be substantial: the flange that takes the glue,
//  the bearing ring the nut pulls against, and a decent taper between them.
//  Along the inlet the shell comes out at exactly the conduit's own Ø40 -- it
//  reads as the pipe carrying on, and it sits tangent to the back panel.
//
//  All dimensions are in millimetres.
// ============================================================================

/* [Part] */
part = "body";  // ["body":the part, "section":cut in half for viewing, "nut":the nut, "assembly":everything in place]

/* [What it glues to -- the conduit_40mm_mount in the side wall] */
mount_flange_d = 94;   // the mount's flange Ø -- the part must cover it (mm)
pipe_diameter  = 40;   // conduit crest Ø (mm). The conduit lies against the panel,
                       // so this alone fixes how far its axis sits off the panel.
mount_flange_t = 3;    // the mount's flange thickness (mm)
pipe_stub      = 1;    // how far the cut conduit end stands proud of the flange (mm)
// The glue face is counterbored so the cut conduit end has somewhere to go. It
// is given its own depth rather than being derived from pipe_stub + a fudge:
// the pipe is never cut off as square as the drawing says, and the flange has
// to bed on the mount, not on the pipe's ragged end. Depth is measured from the
// glue face; the plate is glue_t thick, and what is left behind the recess is
// the annular seat the pipe butts against -- asserted below.
pipe_recess     = 2;   // depth of that recess (mm)
pipe_recess_fit = 2.8; // diametral clearance over the conduit crest (mm)
glue_t         = 4;    // thickness of the plate that beds on the flange (mm)
locator_h      = 15;   // height of the lip that grips the flange's rim (mm); 0 = none.
                       // It runs only along the BOTTOM of the flange, because that is
                       // where there is room to be wider without being taller -- the
                       // 67 mm height is spoken for, the width is not.
locator_wall   = 3;    // thickness of that lip (mm)
locator_fit    = 0.4;  // diametral clearance over the flange (mm)

/* [Channel] */
// inlet_bore is what the CONDUIT actually carries, not its outside Ø. Measure
// down the pipe. Too big and the channel breaks out through the bottom face --
// asserted below.
inlet_bore  = 34;   // usable bore of the conduit (mm)  <- MEASURE YOURS
outlet_bore = 41;   // bore through the stuss (mm)
wall        = 3;    // material around the chamber (mm)

/* [Cabinet panel] */
hole_diameter   = 50;  // the NEW hole to drill in the back panel (mm)
plate_thickness = 2;   // the panel's own thickness (mm)  <- MEASURE YOURS
stuss_depth     = 9;   // how far the threaded neck carries on INTO the cabinet (mm).
                       // With plate_thickness this is the whole threaded length,
                       // so it alone sets how many turns of thread there are to
                       // run the nut down -- echoed below. At 7 mm the neck did not
                       // reach far enough through the panel to take the nut.

/* [Layout] */
outlet_x = 40;   // glue face -> outlet axis (mm). This sets the overall length,
                 // how gentle the cable's turn is, and how close to the corner
                 // you have to drill. All three are echoed below.
bearing  = 5;    // how far the part's bottom face must overhang the hole, so the
                 // nut has a ring of panel to clamp against (mm)
boss_h   = 8;    // height of the flare from the bearing ring up to the tube (mm)
chamber_h = 7;   // height of the outlet port inside the chamber (mm)
inlet_len = 28;  // how far the inlet port runs before the chamber opens out (mm).
                 // This also sets the slope of the chamber's roof, which is the
                 // only internal overhang when the part is printed in one piece
                 // -- the angle is echoed below. Shorter = roomier chamber but a
                 // shallower roof that needs support inside.

/* [Thread + nut]  (ported from corrugated-pipe-bend) */
thread_pitch     = 3;
thread_starts    = 1;
thread_depth     = 0.8;
thread_clearance = 0.4;
neck_clearance   = 0.8;  // diametral gap thread crest -> the hole
neck_wall        = 3;    // material between the bore and the thread root (mm)

nut_wall       = 2.6;
nut_height     = 6;
nut_lobes      = 6;
nut_grip       = 10;
nut_fin_w      = 8;
nut_grip_clear = 4;
nut_flange     = 0;
nut_flange_t   = 2.5;

/* [Assembly view] */
show_panel = true;
show_mount = true;

/* [Render quality] */
$fn = 96;

// ── Derived: where everything sits ──────────────────────────────────────────
pipe_axis_z = pipe_diameter / 2;                 // conduit axis above the panel
glue_d      = mount_flange_d;
body_h      = pipe_axis_z + glue_d / 2;          // height of the part at the glue face

inlet_r  = inlet_bore / 2;
floor_t  = pipe_axis_z - inlet_r;                // material under the channel at the inlet

neck_od        = hole_diameter - neck_clearance; // thread CREST diameter
thread_crest_r = neck_od / 2;
thread_root_r  = thread_crest_r - thread_depth;
neck_length    = plate_thickness + stuss_depth;
thread_turns   = neck_length / (thread_pitch * thread_starts);
outlet_r       = outlet_bore / 2;
boss_d         = max(2 * outlet_r + 2 * wall, hole_diameter + 2 * bearing);

nut_od         = neck_od + 2 * nut_wall;
nut_bore_r     = thread_root_r + thread_clearance / 2;
nut_flange_od  = 2 * (nut_bore_r + nut_flange);
nut_bearing_od = nut_flange > 0 ? nut_flange_od : nut_od;
nut_fin_r      = nut_grip <= 0 ? nut_od / 2
               : max(nut_od / 2 + nut_grip,
                     nut_flange > 0 ? nut_flange_od / 2 + nut_grip_clear : 0);

locator_id = mount_flange_d + locator_fit;
locator_od = locator_id + 2 * locator_wall;
locator_d  = mount_flange_t - 0.5;

inlet_od  = inlet_bore  + 2 * wall;   // the body's tube -- lands on the conduit's own Ø
outlet_od = 2 * outlet_r + 2 * wall;

body_len = outlet_x + boss_d / 2;                // glue face -> far edge
body_w   = locator_h > 0 ? locator_od : mount_flange_d;   // the locator lip is the widest thing

// What the cable actually gets: it rides the OUTSIDE of the turn, from the top
// of the inlet port round to the far side of the outlet. Reporting the straight
// chord between those two is a fair measure of how hard the turn is.
ride_dx = outlet_x + outlet_r;
ride_dz = pipe_axis_z + inlet_r;

// Printed in one piece the part stands on its neck, so "up" is +z, and the
// chamber's roof -- the hull's ruled face from the inlet port to the outlet
// port -- is the only surface inside that overhangs. Measured from vertical:
// under about 50 deg it carries itself and needs nothing inside the cavity.
roof_overhang = atan((outlet_x + outlet_r - inlet_len) / (ride_dz - chamber_h));

// ── Sanity checks ───────────────────────────────────────────────────────────
assert(floor_t >= 2.5,
       str("Only ", floor_t, " mm of floor under the channel. inlet_bore is too big for a ",
           pipe_diameter, " mm conduit lying on the panel -- it would break out of the bottom face."));
assert(outlet_r <= thread_root_r - neck_wall,
       str("outlet_bore ", outlet_bore, " leaves less than ", neck_wall,
           " mm at the thread root of a Ø", hole_diameter, " hole. Max bore is ",
           2 * (thread_root_r - neck_wall), " mm."));
assert(outlet_x - outlet_r > 0,
       "the outlet would break through the glue face -- increase outlet_x");
assert(nut_height <= stuss_depth - 1,
       "nut_height leaves no room inside stuss_depth -- the nut must fit in the cabinet");
assert(nut_flange == 0 || nut_flange_t < nut_height - 2, "nut_flange_t too thick for nut_height");
assert(chamber_h <= boss_h, "chamber_h must not reach past the outlet flare");
assert(inlet_od / 2 <= pipe_axis_z + 0.001,
       str("The body's tube is Ø", inlet_od, ", wider than the conduit it follows -- it would ",
           "sit proud of the back panel. Reduce inlet_bore or wall."));
assert(pipe_recess >= pipe_stub,
       str("The recess is only ", pipe_recess, " mm deep but the conduit stands ", pipe_stub,
           " mm proud of the flange -- the glue face would bed on the pipe, not the mount."));
assert(glue_t - pipe_recess >= 1.5,
       str("Only ", mm1(glue_t - pipe_recess), " mm of glue plate left behind the recess. That ",
           "annulus is the seat the pipe end butts against -- raise glue_t or cut the recess back."));
assert(inlet_len > glue_t, "inlet_len must run past the glue plate");
assert(locator_h == 0 || locator_h < mount_flange_d / 2 - pipe_axis_z + 1,
       "locator_h reaches past the widest point of the flange -- it could not be pushed on");

function mm1(x) = round(x * 10) / 10;

echo(str("Overall: ", mm1(body_len), " long x ", mm1(body_h), " tall x ", mm1(body_w), " wide"));
echo(str("  (long = glue face -> far edge, tall = back panel -> top of the flange)"));
echo(str("Conduit axis sits ", pipe_axis_z, " mm off the panel; floor under the channel ",
         mm1(floor_t), " mm"));
echo(str("Channel: Ø", inlet_bore, " in  ->  Ø", outlet_bore, " out"));
echo(str("Body: Ø", inlet_od, " tube on a ", wall, " mm wall, flaring to Ø", boss_d,
         " at the panel; the taper behind the flange is a ", wall, " mm shell too"));
echo(str("Cable's turn, outside of the bend: ", mm1(ride_dx), " mm across by ",
         mm1(ride_dz), " mm down"));
echo(str("Glue face: Ø", mount_flange_d, " flange, cut off ", pipe_axis_z,
         " mm below its centre by the panel", locator_h > 0
         ? str("; located by a ", locator_h, " mm lip, Ø", locator_od, " over the rim") : ""));
// Measured from the WALL, which is where you will hold the tape -- not from the
// glue face, which is mount_flange_t further out with the mount's flange in
// between. Getting those two confused is a hole drilled 3 mm out of place.
echo(str("Hole centre sits ", mm1(outlet_x + mount_flange_t), " mm from the wall face (",
         mm1(outlet_x), " mm from the glue face, + the mount's ", mount_flange_t,
         " mm flange); the hole's near edge is ",
         mm1(outlet_x - hole_diameter / 2 + mount_flange_t), " mm out of the corner"));
echo(str("Bottom face overhangs the hole by ", mm1(bearing), " mm for the nut to clamp"));
echo(str("One piece, standing on its neck: chamber roof overhangs ", mm1(roof_overhang),
         " deg from vertical", roof_overhang < 50 ? " -- carries itself" :
         " -- OVER 50 deg, will want support inside the chamber"));
echo(str("Neck: thread crest Ø ", neck_od, ", ", neck_length, " mm long (",
         stuss_depth, " mm inside the cabinet) = ", mm1(thread_turns),
         " turns at ", thread_pitch, " mm pitch; the nut takes ",
         mm1(nut_height / (thread_pitch * thread_starts)), " of them"));
echo(str("Glue face: recess Ø", pipe_diameter + pipe_recess_fit, " x ", pipe_recess,
         " mm deep for the cut pipe end (it stands ", pipe_stub, " mm proud); ",
         mm1(glue_t - pipe_recess), " mm of plate behind it"));
echo(str("Nut: Ø ", nut_od, " body, Ø ", 2 * nut_fin_r, " over the fins, ", nut_height, " mm tall"));

// The screw connection -- thread and nut -- lives in one place for all three
// corner parts. It needs thread_starts/pitch/clearance, thread_root_r,
// thread_crest_r and the nut_* values above; the file lists the contract.
include <thread.scad>

// ============================================================================
//  THE PART
// ============================================================================

// A disc standing on the conduit's axis at x, growing in +X.
module at_x(x0, h, d) { translate([x0, 0, pipe_axis_z]) rotate([0, 90, 0]) cylinder(h = h, d = d); }
module at_glue(h, d)  { at_x(0, h, d); }

// The wedge. Both elements sit on z = 0, so the hull does too -- that is the
// face that beds on the back panel. The x = 0 face is the full flange disc,
// which is the face that beds on the mount. Clipping at z = 0 afterwards is
// what cuts the flange down from Ø94 to the 67 mm the conduit's height allows.
//  The panel and the side wall between them fix everything except sliding along
//  the wall, and if it slides it stops covering the flange. The lip closes that
//  last degree of freedom: an arc that wraps the flange's rim, stopping 0.5 mm
//  short of the wall so it can never hold the glue face off its seat.
module locator() {
    if (locator_h > 0)
        intersection() {
            translate([-locator_d, 0, pipe_axis_z]) rotate([0, 90, 0])
                difference() {
                    // Runs 2 mm PAST the glue face, and the bore that makes it a
                    // ring stops at that face -- so the last 2 mm is solid and
                    // fuses with the body. Meeting it face to face would leave
                    // two separate shells.
                    cylinder(h = locator_d + 2, d = locator_od);
                    translate([0, 0, -1]) cylinder(h = locator_d + 1, d = locator_id);
                }
            translate([-500, -500, 0]) cube([1000, 1000, locator_h]);
        }
}

module inlet_outer()  { at_glue(inlet_len, inlet_od); }

// The outlet end flares from the bearing ring the nut clamps, up to the tube.
module outlet_outer() {
    translate([outlet_x, 0, 0]) cylinder(h = boss_h, d1 = boss_d, d2 = outlet_od);
}

// Two hulls, not one. Hulling the flange straight to the outlet fills everything
// between them solid -- a wedge of plastic doing no work. Hulling the flange
// only as far as the tube gives the taper, and hulling the tube to the outlet
// gives a shell that follows the chamber at `wall` thickness.
//
// Every element sits on z = 0, so the hulls do too: that is the face that beds
// on the back panel. The x = 0 face is the full flange disc. Clipping at z = 0
// is what cuts the flange down from Ø94 to the 67 mm the conduit's height
// allows, and what turns the tube's tangent line into the panel contact.
module body_solid() {
    intersection() {
        union() {
            hull() { at_glue(glue_t, glue_d); inlet_outer(); }   // flange and its taper
            hull() { inlet_outer(); outlet_outer(); }            // shell over the chamber
        }
        translate([-500, -500, 0]) cube(1000);
    }
}

// The chamber: the convex hull of the two ports. Tangent to both, so the cable
// meets no edge anywhere -- it comes in along the inlet, rides the ruled face
// round the outside of the turn, and drops out of the outlet.
//  Clipped at the inlet's own floor level. Without that, the hull's underside
//  runs from the inlet port's floor down to the outlet port's, so the chamber
//  converges on the bottom face somewhere in between and breaks out through it.
//  Flat at floor_t instead: the cable slides along it and drops into the hole.
//  The bell is the transition hollowed out. The taper from the Ø94 flange down
//  to the tube is a big cone, and left solid it is most of the part's mass for
//  no work at all -- the glue plate in front of it is what carries the joint.
//  So the cavity flares to match, `wall` inside the outer cone the whole way,
//  and what is left is a 3 mm conical shell. It is hulled from a slice AT the
//  tube rather than from the whole inlet port, or it would open out backwards
//  and eat the glue plate's seat.
module chamber() {
    intersection() {
        union() {
            hull() {
                at_x(glue_t, 0.01, glue_d - 2 * wall);
                at_x(inlet_len - 0.01, 0.01, inlet_bore);
            }
            hull() {
                at_glue(inlet_len, inlet_bore);
                translate([outlet_x, 0, 0]) cylinder(h = chamber_h, d = 2 * outlet_r);
            }
        }
        translate([-500, -500, floor_t]) cube(1000);
    }
}

module neck() {
    intersection() {
        translate([outlet_x, 0, -neck_length]) thread_solid(neck_length + 2);
        translate([outlet_x, 0, 0]) union() {
            translate([0, 0, -neck_length])
                cylinder(h = 1.6, d1 = neck_od - 3, d2 = neck_od + 1);   // lead-in chamfer
            translate([0, 0, -neck_length + 1.5]) cylinder(h = neck_length + 2, d = neck_od + 1);
        }
    }
}

module body() {
    difference() {
        union() { body_solid(); neck(); locator(); }
        chamber();
        translate([outlet_x, 0, -neck_length - 1])                   // bore through the neck
            cylinder(h = neck_length + 1 + floor_t + 0.01, d = 2 * outlet_r);
        translate([outlet_x, 0, -0.01])                               // funnel the floor in
            cylinder(h = floor_t + 0.02, d1 = 2 * outlet_r, d2 = 2 * outlet_r + 2 * floor_t);
        translate([outlet_x, 0, -neck_length - 0.01])                // cable lead-out
            cylinder(h = 2.7, d1 = 2 * outlet_r + 4.4, d2 = 2 * outlet_r - 1);
        // The recess for the cut pipe end. It starts 0.1 mm proud of the glue
        // face so the cut has no coincident face with it.
        translate([-0.1, 0, pipe_axis_z]) rotate([0, 90, 0])
            cylinder(h = pipe_recess + 0.1, d = pipe_diameter + pipe_recess_fit);
    }
}

// A half of the body, for the cutaway renders only. (The part used to be split
// here and glued, to print without support; a 3 mm wall leaves nowhere for a
// dowel, so it is one piece now and the neck-down orientation carries it.)
module body_section() {
    rotate([90, 0, 0]) intersection() {
        body();
        translate([-400, 0, -400]) cube(800);
    }
}

// ============================================================================
//  ASSEMBLY
// ============================================================================
module panel_ghost() {
    color("silver", 0.35)
        difference() {
            translate([-30, -80, -plate_thickness]) cube([body_len + 60, 160, plate_thickness]);
            translate([outlet_x, 0, -plate_thickness - 1])
                cylinder(h = plate_thickness + 2, d = hole_diameter);
        }
}

module wall_ghost() {
    color("silver", 0.22)
        translate([-mount_flange_t - 8, -80, 0]) cube([8, 160, body_h + 20]);
}

// The conduit_40mm_mount, sketched: Ø71 body through the side wall, Ø94 flange
// on this side, and the conduit cut off pipe_stub proud of it.
module mount_ghost() {
    color("darkorange", 0.55) translate([-mount_flange_t, 0, pipe_axis_z]) rotate([0, 90, 0])
        cylinder(h = mount_flange_t, d = mount_flange_d);
    color("darkorange", 0.35) translate([-mount_flange_t - 37, 0, pipe_axis_z])
        rotate([0, 90, 0]) cylinder(h = 37, d = 71);
    color("dimgray", 0.6) translate([-55, 0, pipe_axis_z]) rotate([0, 90, 0])
        cylinder(h = 55 + pipe_stub, d = pipe_diameter);
}

module assembly() {
    body();
    color("steelblue") translate([outlet_x, 0, -plate_thickness - nut_height]) nut();
    if (show_panel) { panel_ghost(); wall_ghost(); }
    if (show_mount) mount_ghost();
}

// ── Render ──────────────────────────────────────────────────────────────────
if (is_undef(DIMENSIONS_ONLY)) {
    if      (part == "body")     body();
    else if (part == "section")  body_section();
    else if (part == "nut")      nut();
    else if (part == "assembly") assembly();
    else assert(false, str("unknown part: ", part));
}
