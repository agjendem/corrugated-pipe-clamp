// ============================================================================
//  Corner elbow -- a minimal addon to the 40 mm wall mount in pipe_clamp.scad
// ----------------------------------------------------------------------------
//  Same problem as corner_bend.scad, solved with four blocks instead of a
//  hulled chamber:
//
//      side   -- a round plate on the mount's Ø94 flange   (the glue face)
//      pipe   -- a 90° elbow, constant bore, nothing else
//      side   -- a squared plate on the cabinet's back panel (the screw face)
//      screw  -- the threaded stuss + nut, unchanged
//
//  Two flat faces at 90° to each other, and the shortest tube that can join
//  them. Nothing is hulled, nothing is a wedge; every surface belongs to one
//  of those four blocks.
//
//      side wall
//     |
//     | Ø94 flange of the mount = the face we glue to
//     |+---+                          ---
//     ||   |  ===== cut conduit        |  flange radius  47
//     ||   | /                        -+- conduit axis
//     ||   |(   <- the elbow           |  conduit radius 20
//     |+---+ \__                      ---
//     =========|=================  cabinet back panel
//              v
//          threaded stuss + nut, into the cabinet
//
//  THE BEND RADIUS IS NOT A CHOICE. The elbow has to be tangent to the conduit
//  going in and tangent to the panel coming out, and the conduit's axis sits
//  exactly its own radius -- 20 mm -- above that panel. So the centreline
//  radius is 20 mm, full stop: bend_r = pipe_diameter / 2.
//
//  That is also why corner_bend.scad is a chamber and not an elbow: it opens
//  out to Ø41 at the outlet, and a tube that wide is already 20.5 mm in radius
//  before any wall is added -- more than the 20 mm the arc has to give, so it
//  would fold through itself. Hold the channel at the conduit's BORE the whole
//  way and the elbow fits -- just. The one inequality that decides it,
//
//      bore / 2 + wall  <=  pipe_diameter / 2
//
//  is the same inequality that keeps the tube from standing proud of the back
//  panel. Satisfy it and both are true at once; break it and both fail.
//
//  All dimensions are in millimetres.
// ============================================================================

/* [Part] */
part = "body";  // ["body":the part, "print":the part laid out for the printer, "section":cut in half for viewing, "nut":the nut, "assembly":everything in place]

/* [Block 1 -- the glue face, on the mount in the side wall] */
mount_flange_d = 94;   // the mount's flange Ø -- the plate must cover it (mm)
pipe_diameter  = 40;   // conduit crest Ø (mm). The conduit lies on the panel, so
                       // this alone fixes both the axis height and the bend radius.
mount_flange_t = 3;    // the mount's flange thickness (mm)
pipe_stub      = 1;    // how far the cut conduit end stands proud of the flange (mm)
glue_t         = 4;    // thickness of the glue plate (mm)
locator_h      = 0;    // height of a lip that grips the flange's rim (mm); 0 = none.
                       // Off by default: it has to stand 2.5 mm proud of the glue
                       // face to reach the rim, which is exactly the face the part
                       // is meant to be printed on. Once the hole is drilled the
                       // stuss locates the part anyway -- the lip only helps you
                       // hold it while the glue goes off.
locator_wall   = 3;    // thickness of that lip (mm)
locator_fit    = 0.4;  // diametral clearance over the flange (mm)

/* [Block 2 -- the pipe] */
// bore is what the CONDUIT carries, not its outside Ø: the pipe is cut off at
// the flange, so nothing has to slide over it. Too big and the elbow cannot
// exist -- asserted below.
bore = 34;     // bore through the elbow (mm)  <- MEASURE YOURS
wall = 2.5;    // wall of the elbow (mm). It is a duct, not a structural member:
               // the glue plate carries the joint and the panel plate the nut.

/* [Block 3 -- the screw face, on the cabinet's back panel] */
hole_diameter   = 50;  // the NEW hole to drill in the back panel (mm)
plate_thickness = 2;   // the panel's own thickness (mm)  <- MEASURE YOURS
plate_t         = 4;   // thickness of our plate on it (mm)
bearing         = 5;   // how far that plate must overhang the hole, so the nut
                       // has a ring of panel to clamp against (mm)
plate_round     = 8;   // corner radius of the squared plate (mm)

/* [Block 4 -- the screw connection] */
outlet_bore      = 41;   // bore through the stuss (mm); wider than the elbow's,
                         // so the cable leaves through the biggest hole it meets
stuss_depth      = 7;    // how far the threaded neck carries on INTO the cabinet
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

/* [Layout] */
outlet_x = 40;   // glue face -> outlet axis (mm). The elbow eats bend_r of it;
                 // what is left is the straight run, echoed below.
panel_bite = 0;  // how far the screw wall moves INTO the conduit's envelope (mm).
                 // 0 is the conduit lying on the panel, which is the roomiest the
                 // corner can be. Raise it when the cabinet sits closer than that:
                 // the part gets that much shorter, the elbow's round floor is
                 // sliced away, and the panel plate becomes the channel's floor
                 // instead. The channel goes from round to D-shaped -- how much
                 // it costs is echoed below.
open_floor = false;  // let the channel cut clean THROUGH the panel plate, so the
                 // cable lies on the cabinet's own back panel and gets the whole
                 // cross-section back. Everything the plate does for the channel
                 // it gives up -- except the ring the nut pulls against, which is
                 // masked out of the cut and left whole. See screw_collar().

/* [Assembly view] */
show_panel = true;
show_mount = true;

/* [Render quality] */
$fn = 96;

// ── Derived ─────────────────────────────────────────────────────────────────
pipe_axis_z = pipe_diameter / 2;      // conduit axis above the panel
bend_r      = pipe_axis_z;            // ...and therefore the elbow's radius
tube_od     = bore + 2 * wall;
tube_r      = tube_od / 2;

glue_d       = mount_flange_d;
axis_z       = pipe_axis_z - panel_bite;      // conduit axis above the FINISHED panel face
body_h       = axis_z + glue_d / 2;           // the panel cuts the flange off at 67
straight_len = outlet_x - bend_r;             // what is left of the run to the arc

neck_od        = hole_diameter - neck_clearance;   // thread CREST diameter
thread_crest_r = neck_od / 2;
thread_root_r  = thread_crest_r - thread_depth;
neck_length    = plate_thickness + stuss_depth;
outlet_r       = outlet_bore / 2;

plate_w  = hole_diameter + 2 * bearing;       // the squared plate, across the flats
collar_od = hole_diameter + 2 * bearing;     // the ring the nut actually pulls on
collar_chamfer = max(0, min(plate_t - 1.5, bearing - 1.5));  // break its edge: the cable rides up

// The channel's floor. Below panel_bite there is no part at all, and between
// panel_bite and the top of the plate there is plate -- so the plate is what the
// cable ends up lying on, and the round bore is cut off flat at its top face.
// Nothing below builds from these; they are here to report what the bite costs.
channel_floor = open_floor ? panel_bite                  // the cabinet's own panel
                           : panel_bite + plate_t;      // the top of our plate
floor_drop    = pipe_axis_z - channel_floor;            // floor below the conduit's axis
cut_into_bore = max(0, bore / 2 - floor_drop);          // how deep the flat eats the bore
flat_w        = cut_into_bore <= 0 ? 0
              : 2 * sqrt(pow(bore / 2, 2) - pow(floor_drop, 2));
seg_area      = cut_into_bore <= 0 ? 0
              : pow(bore / 2, 2) * acos(floor_drop / (bore / 2)) * PI / 180
                - floor_drop * flat_w / 2;
bore_area     = PI * pow(bore / 2, 2) - seg_area;

nut_od         = neck_od + 2 * nut_wall;
nut_bore_r     = thread_root_r + thread_clearance / 2;
nut_flange_od  = 2 * (nut_bore_r + nut_flange);
nut_fin_r      = nut_grip <= 0 ? nut_od / 2
               : max(nut_od / 2 + nut_grip,
                     nut_flange > 0 ? nut_flange_od / 2 + nut_grip_clear : 0);

locator_id = mount_flange_d + locator_fit;
locator_od = locator_id + 2 * locator_wall;
locator_d  = mount_flange_t - 0.5;

body_len = max(outlet_x + plate_w / 2, glue_t);
body_w   = max(locator_h > 0 ? locator_od : mount_flange_d, plate_w);

// ── Sanity checks ───────────────────────────────────────────────────────────
assert(tube_r <= pipe_axis_z,
       str("bore ", bore, " on a ", wall, " mm wall makes a Ø", tube_od, " tube, wider than the Ø",
           pipe_diameter, " conduit it replaces. It would both stand proud of the back panel and ",
           "fold through itself in the bend. Max bore here is ", pipe_diameter - 2 * wall, " mm."));
assert(tube_r < bend_r - 0.25,
       "the elbow's inner surface degenerates to a point -- give up 0.5 mm of bore or wall");
assert(straight_len > glue_t + 1,
       str("outlet_x ", outlet_x, " leaves only ", straight_len,
           " mm of straight run before the arc, which does not clear the glue plate. Min is ",
           bend_r + glue_t + 1, " mm."));
assert(glue_t > pipe_stub + 1.5,
       "glue_t must leave material behind the recess that takes the cut conduit end");
assert(outlet_r <= thread_root_r - neck_wall,
       str("outlet_bore ", outlet_bore, " leaves less than ", neck_wall,
           " mm at the thread root of a Ø", hole_diameter, " hole. Max bore is ",
           2 * (thread_root_r - neck_wall), " mm."));
assert(plate_round < plate_w / 2,
       "plate_round is more than half the plate's width");
assert(nut_height <= stuss_depth - 1,
       "nut_height leaves no room inside stuss_depth -- the nut must fit in the cabinet");
assert(nut_flange == 0 || nut_flange_t < nut_height - 2, "nut_flange_t too thick for nut_height");
assert(locator_h == 0 || panel_bite + locator_h <= pipe_axis_z,
       str("the lip reaches past the widest point of the flange -- it could not be pushed on. ",
           "Max locator_h here is ", pipe_axis_z - panel_bite, " mm."));
assert(panel_bite >= 0, "panel_bite is how far the screw wall moves IN; it cannot be negative");
assert(!open_floor || bearing >= 2.5,
       str("open_floor takes the plate out from under the channel, so the collar is the ONLY ",
           "thing the nut has left to pull on. bearing ", bearing, " mm is too thin for that."));
assert(panel_bite < pipe_axis_z,
       str("panel_bite ", panel_bite, " cuts at or above the conduit's axis: the channel would be ",
           "a shallow trough with nothing to hold a cable in. Max is ", pipe_axis_z - 1, " mm."));
assert(pipe_axis_z + bore / 2 - channel_floor >= 20,
       str("panel_bite ", panel_bite, " leaves only ",
           mm1(pipe_axis_z + bore / 2 - channel_floor), " mm of channel above the plate."));

function mm1(x) = round(x * 10) / 10;

echo(str("Overall: ", mm1(body_len), " long x ", mm1(body_h), " tall x ", mm1(body_w), " wide"));
echo(str("Blocks: Ø", mount_flange_d, "x", glue_t, " glue plate | Ø", tube_od, " elbow, ",
         bore, " bore, R", bend_r, " | ", plate_w, " sq x ", plate_t,
         " panel plate | Ø", neck_od, " stuss"));
echo(str("Elbow: ", mm1(straight_len), " mm straight, then a ", bend_r,
         " mm radius quarter turn -- R/D = ", mm1(bend_r / bore)));
echo(panel_bite == 0
     ? "Screw wall sits on the conduit's own tangent -- the roomiest the corner can be"
     : str("Screw wall ", panel_bite, " mm into the conduit: ", mm1(body_h), " tall instead of ",
           mm1(pipe_axis_z + glue_d / 2)));
echo(cut_into_bore <= 0
     ? str("Channel: a full Ø", bore, " round, clear of the plate")
     : str("Channel: a D on ", open_floor ? "the cabinet's own panel" : "the plate",
           " -- ", mm1(flat_w), " mm flat floor, ",
           mm1(pipe_axis_z + bore / 2 - channel_floor), " mm of headroom, ",
           mm1(100 * bore_area / (PI * pow(bore / 2, 2))), "% of a full Ø", bore, " bore"));
echo(open_floor
     ? str("Floor open to the cabinet's own panel. The nut's collar is the only plate left in ",
           "the channel: a ", bearing, " mm ring standing ", plate_t, " mm proud between ",
           mm1(outlet_x - collar_od / 2), " and ", mm1(outlet_x - hole_diameter / 2),
           " mm from the wall, ramped at 45 deg so the cable rides over it")
     : str("The panel plate is the channel's floor, uncut: the nut's bearing ring is a complete ",
           plate_t, " mm collar all round the stuss"));
echo(str("Tube clears the back panel by ", mm1(pipe_axis_z - tube_r),
         " mm; through the turn the cable rides between R", mm1(bend_r - bore / 2),
         " inside and R", mm1(bend_r + bore / 2), " outside"));
// Measured from the WALL, which is where you will hold the tape -- not from the
// glue face, which is mount_flange_t further out with the mount's flange in
// between. Getting those two confused is a hole drilled 3 mm out of place.
echo(str("Hole centre sits ", mm1(outlet_x + mount_flange_t), " mm from the wall face (",
         mm1(outlet_x), " mm from the glue face, + the mount's ", mount_flange_t,
         " mm flange); the hole's near edge is ",
         mm1(outlet_x - hole_diameter / 2 + mount_flange_t), " mm out of the corner"));
echo(str("Panel plate overhangs the hole by ", bearing, " mm all round for the nut"));
echo(str("Neck: thread crest Ø ", neck_od, ", ", neck_length, " mm long (",
         stuss_depth, " mm inside the cabinet)"));
echo(str("Nut: Ø ", nut_od, " body, Ø ", 2 * nut_fin_r, " over the fins, ", nut_height, " mm tall"));

// The screw connection -- thread and nut -- lives in one place for all three
// corner parts. It needs thread_starts/pitch/clearance, thread_root_r,
// thread_crest_r and the nut_* values above; the file lists the contract.
include <thread.scad>

// ============================================================================
//  THE FOUR BLOCKS
// ============================================================================

// ── 2. The pipe ─────────────────────────────────────────────────────────────
// One shape used twice: at tube_od it is the elbow, at bore it is the hole
// through it. A straight run along the conduit's axis, then a quarter turn of
// radius bend_r that lands tangent to the back panel. The arc's centre sits at
// z = pipe_axis_z - bend_r = 0, i.e. ON the panel, which is the whole reason
// the turn closes in the height available.
module pipe(d, x0 = 0, past = 0) {
    translate([x0, 0, pipe_axis_z]) rotate([0, 90, 0])
        cylinder(h = straight_len - x0, d = d);
    translate([outlet_x - bend_r, 0, 0]) rotate([90, 0, 0])
        rotate_extrude(angle = 90, convexity = 6)
            translate([bend_r, 0]) circle(d = d);
    if (past > 0)                                  // carry the bore on down the neck
        translate([outlet_x, 0, -past]) cylinder(h = past + 0.01, d = d);
}

// ── 1. The glue face ────────────────────────────────────────────────────────
// A plain disc the size of the mount's flange, cut off flat by the back panel.
// That cut is what makes the part 67 mm tall: 47 of flange plus 20 of conduit.
module glue_plate() {
    intersection() {
        translate([0, 0, pipe_axis_z]) rotate([0, 90, 0])
            cylinder(h = glue_t, d = glue_d);
        translate([-500, -500, panel_bite]) cube(1000);
    }
}

// The panel and the side wall between them fix everything except sliding along
// the wall, and if it slides it stops covering the flange. The lip closes that
// last degree of freedom: an arc wrapping the flange's rim, running 2 mm PAST
// the glue face so it fuses with the plate instead of meeting it face to face.
module locator() {
    if (locator_h > 0)
        intersection() {
            translate([-locator_d, 0, pipe_axis_z]) rotate([0, 90, 0])
                difference() {
                    cylinder(h = locator_d + 2, d = locator_od);
                    translate([0, 0, -1]) cylinder(h = locator_d + 1, d = locator_id);
                }
            translate([-500, -500, panel_bite]) cube([1000, 1000, locator_h]);
        }
}

// ── 3. The screw face ───────────────────────────────────────────────────────
// Squared, not round: at the same overhang past the hole it gives the nut more
// ring to pull on, and it is the one face with nothing round to match.
//  It runs all the way back to the glue face rather than stopping at the
// bearing ring, and the last 10 mm is what pays for itself: it makes the two
// faces one rigid L instead of two plates joined only by a Ø39 tube, and when
// the part is printed standing on its glue face this plate then rises straight
// off the bed instead of starting 10 mm up in mid-air.
module panel_plate() {
    len = outlet_x + plate_w / 2;                  // glue face -> far edge
    translate([0, 0, panel_bite]) linear_extrude(height = plate_t)
        hull() {
            translate([0, -plate_w / 2]) square([0.01, plate_w]);        // square, at the wall
            translate([len - plate_round,  plate_w / 2 - plate_round]) circle(r = plate_round);
            translate([len - plate_round, -plate_w / 2 + plate_round]) circle(r = plate_round);
        }
}

// The ring the nut actually pulls against: from the edge of the hole out to the
// edge of the plate, all the way round. With open_floor it is masked out of the
// channel's cut, so the bore takes the rest of the plate and leaves this whole.
//  It ends up standing plate_t proud of the open floor where the channel crosses
// it, so its outer edge is chamfered at 45° -- the cable rides up a ramp rather
// than meeting a square step. The chamfer is on the TOP; the bearing face
// underneath keeps its full width.
//  Run past the plate in z at both ends: a mask whose faces sit in the same
// planes as the plate's own is how you get slivers along them.
module screw_collar() {
    translate([outlet_x, 0, panel_bite])
        difference() {
            union() {
                translate([0, 0, -1])
                    cylinder(h = 1 + plate_t - collar_chamfer, d = collar_od);
                translate([0, 0, plate_t - collar_chamfer])
                    cylinder(h = collar_chamfer + 1,
                             d1 = collar_od, d2 = collar_od - 2 * (collar_chamfer + 1));
            }
            translate([0, 0, -2]) cylinder(h = plate_t + 4, d = hole_diameter);
        }
}

// ── 4. The screw connection ─────────────────────────────────────────────────
module neck() {
    translate([0, 0, panel_bite]) intersection() {
        translate([outlet_x, 0, -neck_length]) thread_solid(neck_length + 2);
        translate([outlet_x, 0, 0]) union() {
            translate([0, 0, -neck_length])
                cylinder(h = 1.6, d1 = neck_od - 3, d2 = neck_od + 1);   // lead-in chamfer
            translate([0, 0, -neck_length + 1.5]) cylinder(h = neck_length + 2, d = neck_od + 1);
        }
    }
}

// ============================================================================
//  THE PART
// ============================================================================
//  Built with the screw face at z = panel_bite and then dropped so that face
//  lands on z = 0, which keeps the assembly, the ghosts and the print layout in
//  one frame whatever the bite is.
//
//  The channel stops at the TOP of the panel plate rather than cutting through
//  it. That is the one thing the bite must not be allowed to do: run the bore
//  down through the plate and it opens a slot from the glue face right into the
//  bearing ring, and the nut loses the collar it pulls against. Stopped at the
//  plate, the plate simply becomes the channel's floor and the screw stays a
//  complete, uncut ring at full plate thickness.
module body() {
    translate([0, 0, -panel_bite])
    difference() {
        union() {
            // The tube and the glue plate, with the channel bored clean through
            // them -- and only them.
            difference() {
                intersection() {
                    union() { glue_plate(); pipe(tube_od); locator(); }
                    translate([-500, -500, panel_bite]) cube(1000);
                }
                pipe(bore, x0 = -1);
            }
            // Then the plate is laid in underneath -- solid, so it fills the
            // bottom of the bore and becomes its floor. (Laid in AFTER the bore
            // rather than the bore being clipped against its top face: clipping
            // put two coincident surfaces in one plane, which is how you earn
            // slivers.)
            //  With open_floor the channel is taken out of it as well, all but
            // the collar, and the cable lies on the cabinet's own panel instead.
            if (open_floor)
                difference() {
                    panel_plate();
                    difference() { pipe(bore, x0 = -1); screw_collar(); }
                }
            else
                panel_plate();
            neck();
        }

        translate([0, 0, panel_bite]) {
            translate([outlet_x, 0, -neck_length - 1])          // bore out the stuss
                cylinder(h = neck_length + 1, d = outlet_bore);
            translate([outlet_x, 0, -0.01])                     // and flare up into the elbow
                cylinder(h = plate_t + 0.02, d1 = outlet_bore, d2 = bore);
            translate([outlet_x, 0, -neck_length - 0.01])       // cable lead-out
                cylinder(h = 2.7, d1 = outlet_bore + 4.4, d2 = outlet_bore - 1);
        }
        translate([-0.1, 0, pipe_axis_z]) rotate([0, 90, 0])   // seat for the cut conduit end
            cylinder(h = pipe_stub + 0.7 + 0.1, d = pipe_diameter + 0.8);
    }
}

// Cut in half on the bend plane, for the renders.
module body_section() {
    rotate([90, 0, 0]) intersection() {
        body();
        translate([-400, 0, -400]) cube(800);
    }
}

// Laid out for the printer: standing on the glue face. See README -- this is
// the orientation the shape is built for, and the only flat face big enough to
// hold it down.
module body_print() {
    translate([0, 0, locator_h > 0 ? locator_d : 0]) rotate([0, -90, 0]) body();
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

module mount_ghost() {
    color("darkorange", 0.55) translate([-mount_flange_t, 0, axis_z]) rotate([0, 90, 0])
        cylinder(h = mount_flange_t, d = mount_flange_d);
    color("darkorange", 0.35) translate([-mount_flange_t - 37, 0, axis_z])
        rotate([0, 90, 0]) cylinder(h = 37, d = 71);
    color("dimgray", 0.6) translate([-55, 0, axis_z]) rotate([0, 90, 0])
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
    else if (part == "print")    body_print();
    else if (part == "section")  body_section();
    else if (part == "nut")      nut();
    else if (part == "assembly") assembly();
    else assert(false, str("unknown part: ", part));
}
