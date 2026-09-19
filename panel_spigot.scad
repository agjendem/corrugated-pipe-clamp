// ============================================================================
//  Panel spigot -- a length of Ø50 tube on the corner parts' standard screw
// ----------------------------------------------------------------------------
//  The simplest member of the family: no turn, no chamber, no glue face. A
//  straight tube standing off the cabinet's back panel, held by the same
//  threaded stuss and the same fin-grip nut as corner_bend and corner_elbow,
//  through the same Ø50 hole.
//
//      tube_od 50, wall 1.5
//     +--+                  +--+     ---
//     |  |                  |  |      |
//     |  |   <- the tube    |  |      |  tube_len 25
//     |  |                  |  |      |
//    ++--++----------------++--++    -+-  the collar: flat underneath,
//    |                          |     |   Ø52, so it catches on the panel
//    ===========+==+=============    ---  cabinet panel, Ø50 hole
//               |  |
//               |==|  <- the thread, through the hole
//               +--+
//                v  nut, from inside
//
//  THREE THINGS DECIDE THIS PART, and they are all about the same millimetre.
//
//  THE TUBE CANNOT GO THROUGH THE HOLE. It is Ø50 and so is the hole; only the
//  thread, at a Ø49.2 crest, passes. That is not a compromise -- it is the
//  whole mechanism. The collar caught between them is what the part hangs on,
//  and the nut pulls the panel up against it from inside.
//
//  THE COLLAR IS FLAT UNDERNEATH. Whatever else is done for strength happens on
//  the tube side or inside the bore; the face that meets the panel is a plain
//  flat annulus, or the part rocks on a chamfer instead of bedding on the
//  panel. What it hangs on is the ring between the hole and the collar's rim --
//  `collar_over / 2` all round, which at the default Ø52 on a Ø50 hole is ONE
//  MILLIMETRE. That is thin, and it is echoed on every render for a reason: it
//  assumes the hole is drilled at size. Drill it 51 and half the ring is gone.
//  If you have the room, `panel_spigot_wide` gives it 2 mm instead.
//
//  THE ROOT OF THE TUBE IS THICKENED FROM THE INSIDE. A Ø50 x 1.5 mm tube
//  standing 25 mm proud is a cantilever, and the place it breaks is where it
//  meets the collar. The bore has to step down there anyway -- the tube carries
//  Ø47, the thread can only carry Ø41 with `neck_wall` left at its root -- so
//  that step is made a cone rather than a shoulder. It is the fillet at the
//  root of the cantilever and the funnel that keeps a cable off the edge, and
//  it costs nothing, because the material is there either way.
//
//  All dimensions are in millimetres.
// ============================================================================

/* [Part] */
part = "body";  // ["body":the part, "print":as it goes on the bed, "section":cut in half for viewing, "nut":the nut, "assembly":everything in place]

/* [The tube] */
tube_od  = 50;    // outside Ø of the tube (mm)
wall     = 1.5;   // its wall (mm). 1 mm prints and is a duct; 1.5 is what makes
                  // it survive being leant on -- see the root note above.
tube_len = 25;    // how far the tube stands proud of the collar (mm). This is
                  // the TUBE, not the part: the collar and the thread add to it,
                  // and the overall length is echoed below.

/* [The collar -- the ring it hangs on] */
collar_over = 2;  // how much bigger than the tube the collar's Ø is (mm). Half
                  // of it, all round, is the ring that bears on the panel.
collar_t    = 3;  // its thickness (mm). Flat underneath, always.
collar_blend = 1; // a chamfer where the collar meets the tube, on the TUBE side
                  // only (mm); 0 = a square ledge. Never on the bearing face.

/* [Cabinet panel] */
hole_diameter   = 50;  // the hole in the panel (mm) -- the same one the corner
                       // parts use, which is why they share a nut
plate_thickness = 2;   // the panel's own thickness (mm)  <- MEASURE YOURS
stuss_depth     = 9;   // how far the threaded neck carries on INTO the cabinet.
                       // With plate_thickness this is the whole threaded length,
                       // so it alone sets how many turns there are to run the
                       // nut down -- echoed below.

/* [Thread + nut]  (the same screw as corner_bend and corner_elbow) */
outlet_bore      = 41;   // bore through the stuss (mm)
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

/* [Render quality] */
$fn = 96;

// ── Derived ─────────────────────────────────────────────────────────────────
tube_bore = tube_od - 2 * wall;                    // what the tube carries
collar_d  = tube_od + collar_over;
bearing_w = (collar_d - hole_diameter) / 2;        // the ring it hangs on, all round

neck_od        = hole_diameter - neck_clearance;   // thread CREST diameter
thread_crest_r = neck_od / 2;
thread_root_r  = thread_crest_r - thread_depth;
neck_length    = plate_thickness + stuss_depth;
thread_turns   = neck_length / (thread_pitch * thread_starts);
outlet_r       = outlet_bore / 2;

nut_od         = neck_od + 2 * nut_wall;
nut_bore_r     = thread_root_r + thread_clearance / 2;
nut_flange_od  = 2 * (nut_bore_r + nut_flange);
nut_fin_r      = nut_grip <= 0 ? nut_od / 2
               : max(nut_od / 2 + nut_grip,
                     nut_flange > 0 ? nut_flange_od / 2 + nut_grip_clear : 0);

body_len = neck_length + collar_t + tube_len;      // tip of the thread -> tube's mouth
stand_on = tube_od;                                // the face it prints on

function mm1(x) = round(x * 10) / 10;

// ── Sanity checks ───────────────────────────────────────────────────────────
assert(bearing_w > 0,
       str("collar_over ", collar_over, " does not reach past the Ø", hole_diameter,
           " hole -- the part would drop straight through it."));
assert(bearing_w >= 0.5,
       str("The collar bears on only ", mm1(bearing_w), " mm of panel all round. A hole ",
           "drilled anywhere near size takes that away. Raise collar_over."));
assert(collar_d > neck_od,
       "the collar must be wider than the thread crest, or there is nothing to catch on");
assert(tube_bore > outlet_bore,
       str("The tube's bore is Ø", tube_bore, " but the thread's is Ø", outlet_bore,
           ". The step at the collar would go the wrong way and stand proud inside the ",
           "tube. Raise tube_od, or thin the wall."));
assert(wall >= 1,
       str("A ", wall, " mm wall is under one perimeter pair on most printers -- it will ",
           "come out as a gap, not a tube."));
assert(outlet_r <= thread_root_r - neck_wall,
       str("outlet_bore ", outlet_bore, " leaves less than ", neck_wall,
           " mm at the thread root of a Ø", hole_diameter, " hole. Max bore is ",
           2 * (thread_root_r - neck_wall), " mm."));
assert(nut_height <= stuss_depth - 1,
       "nut_height leaves no room inside stuss_depth -- the nut must fit in the cabinet");
assert(nut_flange == 0 || nut_flange_t < nut_height - 2, "nut_flange_t too thick for nut_height");
assert(collar_blend >= 0 && collar_blend < collar_t,
       "collar_blend must fit inside the collar and cannot be negative");
assert(collar_blend <= collar_over / 2 + 0.001,
       str("collar_blend ", collar_blend, " is deeper than the ", mm1(collar_over / 2),
           " mm ledge it is blending -- it would eat into the tube's wall."));

// ── What it comes to ────────────────────────────────────────────────────────
echo(str("Overall: ", mm1(body_len), " mm from the thread's tip to the tube's mouth (",
         tube_len, " tube + ", collar_t, " collar + ", neck_length, " thread), Ø",
         collar_d, " at its widest"));
echo(str("Tube: Ø", tube_od, " over a ", wall, " mm wall = Ø", tube_bore, " bore, ",
         tube_len, " mm proud of the panel"));
echo(str("Collar: Ø", collar_d, " x ", collar_t, " mm, flat underneath. It hangs on ",
         mm1(bearing_w), " mm of panel all round the Ø", hole_diameter, " hole",
         bearing_w < 1.5 ? " -- THIN: this assumes the hole is drilled at size" : ""));
echo(str("Bore: Ø", tube_bore, " down the tube, coned to Ø", outlet_bore,
         " through the collar and the thread. That cone is the fillet at the tube's root."));
echo(str("Neck: thread crest Ø ", neck_od, ", ", neck_length, " mm long (",
         stuss_depth, " mm inside the cabinet) = ", mm1(thread_turns),
         " turns at ", thread_pitch, " mm pitch; the nut takes ",
         mm1(nut_height / (thread_pitch * thread_starts)), " of them"));
echo(str("Nut: Ø ", nut_od, " body, Ø ", 2 * nut_fin_r, " over the fins, ", nut_height, " mm tall"));
echo(str("Printed standing on the tube's mouth, thread up: a Ø", stand_on, "/Ø", tube_bore,
         " ring on the bed, ", mm1(PI / 4 * (pow(tube_od, 2) - pow(tube_bore, 2)) / 100),
         " cm2. Use a brim -- it is ", mm1(body_len), " mm tall on that ring."));

// The screw connection -- thread and nut -- lives in one place for all the
// parts that use this hole. It needs thread_starts/pitch/clearance,
// thread_root_r, thread_crest_r and the nut_* values above.
include <thread.scad>

// ============================================================================
//  THE PART
// ----------------------------------------------------------------------------
//  One column on the z axis, and the panel's OUTER face is z = 0: the collar
//  sits on it, the tube grows up out of it, the thread goes down through it.
//  Everything else -- the assembly, the panel ghost, the print layout -- is
//  placed off that one plane.
// ============================================================================

// The collar, with the ledge where it meets the tube broken on the tube side.
// The z = 0 face is left alone: it is what beds on the panel.
module collar() {
    if (collar_blend > 0)
        union() {
            cylinder(h = collar_t - collar_blend, d = collar_d);
            translate([0, 0, collar_t - collar_blend])
                cylinder(h = collar_blend, d1 = collar_d, d2 = collar_d - 2 * collar_blend);
        }
    else
        cylinder(h = collar_t, d = collar_d);
}

module tube() { translate([0, 0, collar_t - 0.01]) cylinder(h = tube_len + 0.01, d = tube_od); }

// The same neck as corner_elbow: the twisted solid clipped to a plain cylinder,
// with a lead-in chamfer at the tip so the nut starts square.
module neck() {
    intersection() {
        translate([0, 0, -neck_length]) thread_solid(neck_length + 2);
        union() {
            translate([0, 0, -neck_length])
                cylinder(h = 1.6, d1 = neck_od - 3, d2 = neck_od + 1);   // lead-in chamfer
            translate([0, 0, -neck_length + 1.5]) cylinder(h = neck_length + 2, d = neck_od + 1);
        }
    }
}

// One bore, in three pieces that meet nowhere a cable can catch.
module bore() {
    translate([0, 0, collar_t - 0.01])                     // down the tube
        cylinder(h = tube_len + 0.02, d = tube_bore);
    translate([0, 0, -0.01])                               // the cone through the collar
        cylinder(h = collar_t + 0.02, d1 = outlet_bore, d2 = tube_bore);
    translate([0, 0, -neck_length - 1])                    // through the thread
        cylinder(h = neck_length + 1.01, d = outlet_bore);
    translate([0, 0, -neck_length - 0.01])                 // cable lead-out at the tip
        cylinder(h = 2.7, d1 = outlet_bore + 4.4, d2 = outlet_bore - 1);
}

module body() {
    difference() {
        union() { collar(); tube(); neck(); }
        bore();
    }
}

// Cut in half, for the renders: the wall, the collar and the cone at the root.
module body_section() {
    intersection() {
        body();
        translate([-400, 0, -400]) cube(800);
    }
}

// As it goes on the bed: standing on the tube's mouth with the thread pointing
// up. That is the orientation worth having -- the thread comes out vertical,
// which is where a printed thread is at its best, and the only overhang left is
// the collar's underside, a `collar_over / 2` mm ledge that carries itself.
// The footprint is a thin ring, so print it with a brim.
module body_print() {
    translate([0, 0, collar_t + tube_len]) rotate([180, 0, 0]) body();
}

// ============================================================================
//  ASSEMBLY
// ============================================================================
module panel_ghost() {
    color("silver", 0.35)
        difference() {
            translate([-60, -60, -plate_thickness]) cube([120, 120, plate_thickness]);
            translate([0, 0, -plate_thickness - 1])
                cylinder(h = plate_thickness + 2, d = hole_diameter);
        }
}

module assembly() {
    body();
    color("steelblue") translate([0, 0, -plate_thickness - nut_height]) nut();
    if (show_panel) panel_ghost();
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
