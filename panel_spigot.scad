// ============================================================================
//  Panel spigot -- a length of Ø50 tube on the corner parts' standard screw
// ----------------------------------------------------------------------------
//  The simplest member of the family: no turn, no chamber, no glue face. A
//  straight tube standing off the cabinet's back panel, held by the same
//  threaded stuss and the same fin-grip nut as corner_bend and corner_elbow,
//  through the same Ø50 hole.
//
//      tube_od 50, wall 2
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
//  THE ROOT OF THE TUBE IS THICKENED FROM THE INSIDE. A Ø50 tube standing 25 mm
//  proud is a cantilever, and the place it breaks is where it meets the collar.
//  The bore has to step down there anyway -- the tube carries Ø46, the thread
//  can only carry Ø41 with `neck_wall` left at its root -- so that step is made
//  a cone rather than a shoulder. It is the fillet at the root of the
//  cantilever and the funnel that keeps a cable off the edge, and it costs
//  nothing, because the material is there either way.
//
//  HOW LONG THAT CONE IS, THOUGH, IS THE WHOLE PART. The first print of this
//  failed exactly here, and it was not a support problem -- it was an angle
//  problem. The cone used to be as tall as the collar and no taller: 3 mm to
//  fall Ø47 -> Ø41, which is 3 mm of radius over 3 mm of height, a 45 degree
//  overhang. Outside, the collar's chamfer did the same 1 mm over 1 mm. So the
//  entire transition, inside and out, was one continuous 45 degree surface --
//  810 mm2 of it, by far the largest overhang in the part -- and the printer
//  met it at the top of a free-standing shell 25 mm tall. 45 degrees is the
//  angle that works when everything else is right; nothing else was.
//
//  So `root_cone` is the cone's own length and is free to climb into the tube,
//  and the collar's chamfer is free to be taller than it is deep. At the
//  defaults that is 22.6 degrees inside and 26.6 outside. Both are derived and
//  echoed below, and an assert refuses to export a part that asks for more than
//  40 -- the rule of thumb with something left over, because the printer meets
//  this on top of a shell and not on solid ground. The wall helps twice over: a
//  thicker tube has a smaller bore, so the cone has less radius to fall.
//
//  All dimensions are in millimetres.
// ============================================================================

/* [Part] */
part = "body";  // ["body":the part, "print":as it goes on the bed, "section":cut in half for viewing, "nut":the nut, "assembly":everything in place]

/* [The tube] */
tube_od  = 50;    // outside Ø of the tube (mm)
wall     = 2;     // its wall (mm). Two things want it thick and neither is
                  // strength alone: it is a 25 mm tall free-standing shell while
                  // it prints, and every millimetre of it is a millimetre the
                  // root cone does not have to fall. 2 mm is also five lines of
                  // a 0.4 nozzle, where 1.5 was three and a half -- two
                  // perimeters and a ribbon of gap fill up the whole tube.
root_cone = 6;    // how far the bore's funnel climbs from the panel face (mm).
                  // It must clear the collar; what is left over thickens the
                  // tube's root. This is what sets the overhang at the
                  // transition -- see the note above, and the echo below.
tube_len = 25;    // how far the tube stands proud of the collar (mm). This is
                  // the TUBE, not the part: the collar and the thread add to it,
                  // and the overall length is echoed below.

/* [The collar -- the ring it hangs on] */
collar_over = 2;  // how much bigger than the tube the collar's Ø is (mm). Half
                  // of it, all round, is the ring that bears on the panel.
collar_t    = 3;  // its thickness (mm). Flat underneath, always.
collar_blend = 1; // how deep the chamfer where the collar meets the tube cuts,
                  // on the TUBE side only (mm); 0 = a square ledge. Never on
                  // the bearing face. It is TALLER than it is deep -- it gets
                  // all of collar_t bar the millimetre of straight wall that
                  // keeps the bearing face flat -- so it is not a 45 degree
                  // ledge hanging over the tube.

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
tip_rim          = 1.2;  // the flat left at the very tip of the thread, between
                         // the lead-in chamfer outside and the cable lead-out
                         // inside (mm). It is the LAST ring the printer lays;
                         // the two chamfers used to leave it 0.4 mm, which
                         // curls, and a curled tip is what the nut starts on.

nut_wall       = 2.6;
nut_height     = 6;
nut_lobes      = 6;
nut_grip       = 10;
nut_fin_w      = 8;
nut_grip_clear = 4;
// The OTHER grip: hollows cut INTO the body instead of fins grown out of it.
// Selected by nut_grip = 0, and worth having because it is the same nut ~20 mm
// narrower across -- in a cabinet that is the difference between the nut
// turning and not. What it costs is wall: the hollows eat the only material
// holding the thread in, which is why nut_grip_wall is derived and asserted.
nut_grip_r     = 4;    // radius of the cutter rolled round the body (mm)
nut_grip_depth = 1.8;  // how deep it bites (mm). 1.8 on the stock 2.6 mm wall
                       // leaves 0.6 -- too little at this size. Either cut it
                       // back or give the nut a thicker wall; both are presets.
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

// The chamfer at the collar's shoulder is TALLER than it is deep: it gets the
// whole collar bar `collar_flat`, the straight wall that keeps the bearing face
// flat. That is what turns a 45 degree ledge into a 27 degree one.
collar_flat  = 1;                                  // straight wall above the bearing face
collar_blend_h = collar_t - collar_flat;

neck_od        = hole_diameter - neck_clearance;   // thread CREST diameter
neck_tip_od    = neck_od - 3;                      // the lead-in chamfer's small end
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
// What is left under the deepest point of a scallop. The nut's bore is the
// thread grown by half the clearance, so the wall is measured from the CREST of
// that grown thread, not from the root -- the root would flatter it by 0.8 mm.
nut_grip_wall  = nut_wall - nut_grip_depth - thread_clearance / 2;

body_len = neck_length + collar_t + tube_len;      // tip of the thread -> tube's mouth
stand_on = tube_od;                                // the face it prints on

// The mouth of the cable lead-out, held back so `tip_rim` of flat survives at
// the thread's tip -- the last ring the printer lays, and the one the nut has
// to start on.
lead_out_od = min(outlet_bore + 4.4, neck_tip_od - 2 * tip_rim);
tip_rim_got = (neck_tip_od - lead_out_od) / 2;

function mm1(x) = round(x * 10) / 10;

// THE TWO ANGLES THE PRINT LIVES ON, both measured the way a slicer measures
// them: degrees from VERTICAL, so 0 is a wall and 90 is a ceiling. Everything
// else on this part is a wall, a flat or a thread.
root_slope  = atan(((tube_bore - outlet_bore) / 2) / root_cone);   // inside, at the root
blend_slope = collar_blend <= 0 ? 0 : atan(collar_blend / collar_blend_h);  // outside, at the shoulder
worst_slope = max(root_slope, blend_slope);

// What the blend does NOT reach: a flat ring under the collar, and once the
// part is turned over to print it is a flat overhang. A short one bridges off
// the tube's wall and carries itself -- that is the documented `collar_blend = 0`
// case -- but it is easy to leave one by accident, because raising collar_over
// widens the ledge without widening the chamfer. So it is echoed.
collar_ledge = collar_over / 2 - collar_blend;

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
assert(root_cone >= collar_t,
       str("root_cone ", root_cone, " is shorter than the ", collar_t, " mm collar it has to ",
           "cross. The bore would step, not cone, and the step would stand proud inside ",
           "the collar."));
assert(root_cone <= collar_t + tube_len - 2,
       str("root_cone ", root_cone, " leaves under 2 mm of plain bore before the tube's ",
           "mouth. Shorten it, or lengthen the tube."));
// 45 degrees is the angle the FIRST print of this part failed at, so the bound
// is 40: the rule of thumb with something left over, because the printer meets
// this overhang on top of a shell 25 mm tall and not on solid ground.
assert(worst_slope <= 40,
       str("The transition from tube to thread overhangs ", mm1(worst_slope),
           " degrees from vertical. Past 40 it is being asked to carry itself on top of a ",
           tube_len, " mm shell, which is what failed before -- and supports do not reach ",
           "inside the tube to help. Lengthen root_cone (now ", root_cone,
           " mm), or thicken wall (now ", wall, " mm) so the cone has less to fall."));
assert(tip_rim_got >= 0.8,
       str("The thread's tip is left ", mm1(tip_rim_got), " mm of flat -- about two lines, ",
           "and it will curl into the way of the nut. Cut tip_rim, or raise outlet_bore."));
assert(outlet_r <= thread_root_r - neck_wall,
       str("outlet_bore ", outlet_bore, " leaves less than ", neck_wall,
           " mm at the thread root of a Ø", hole_diameter, " hole. Max bore is ",
           2 * (thread_root_r - neck_wall), " mm."));
assert(nut_height <= stuss_depth - 1,
       "nut_height leaves no room inside stuss_depth -- the nut must fit in the cabinet");
assert(nut_flange == 0 || nut_flange_t < nut_height - 2, "nut_flange_t too thick for nut_height");
assert(collar_blend >= 0 && collar_blend < collar_t,
       "collar_blend must fit inside the collar and cannot be negative");
assert(collar_blend <= 0 || collar_blend_h > 0,
       str("collar_t ", collar_t, " leaves no height for the chamfer above the ", collar_flat,
           " mm of straight wall the bearing face needs. Raise collar_t."));
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
echo(str("Bore: Ø", tube_bore, " down the tube, coned to Ø", outlet_bore, " over the ",
         root_cone, " mm from the panel face -- through the ", collar_t, " mm collar and ",
         mm1(root_cone - collar_t), " mm on into the tube, which is the fillet at its root. ",
         "That cone overhangs ", mm1(root_slope), " degrees from vertical."));
echo(str("Neck: thread crest Ø ", neck_od, ", ", neck_length, " mm long (",
         stuss_depth, " mm inside the cabinet) = ", mm1(thread_turns),
         " turns at ", thread_pitch, " mm pitch; the nut takes ",
         mm1(nut_height / (thread_pitch * thread_starts)), " of them"));
echo(nut_grip > 0
     ? str("Nut: Ø ", nut_od, " body, Ø ", 2 * nut_fin_r, " over the fins, ",
           nut_height, " mm tall")
     : str("Nut: Ø ", nut_od, " across -- scalloped grip, no fins, ", nut_height,
           " mm tall; ", mm1(nut_grip_wall), " mm of wall under the grip"));
echo(str("Printed standing on the tube's mouth, thread up: a Ø", stand_on, "/Ø", tube_bore,
         " ring on the bed, ", mm1(PI / 4 * (pow(tube_od, 2) - pow(tube_bore, 2)) / 100),
         " cm2. Use a brim -- it is ", mm1(body_len), " mm tall on that ring."));
echo(str("Overhang: ", mm1(worst_slope), " degrees from vertical at worst (", mm1(root_slope),
         " inside at the root, ", mm1(blend_slope), " outside at the collar's shoulder)",
         collar_ledge > 0.05
           ? str(", plus a flat ", mm1(collar_ledge),
                 " mm ledge under the collar that the chamfer does not reach")
           : ", and no flat ledge under the collar", ". ",
         "Nothing here needs support; what it needs is the tube not to wobble, so print ",
         "the ", wall, " mm wall as ", mm1(wall / 0.4), " lines of a 0.4 nozzle and slow the ",
         "last 5 mm before the collar."));

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
            cylinder(h = collar_flat, d = collar_d);
            translate([0, 0, collar_flat])
                cylinder(h = collar_blend_h, d1 = collar_d, d2 = collar_d - 2 * collar_blend);
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
                cylinder(h = 1.6, d1 = neck_tip_od, d2 = neck_od + 1);   // lead-in chamfer
            translate([0, 0, -neck_length + 1.5]) cylinder(h = neck_length + 2, d = neck_od + 1);
        }
    }
}

// One bore, in four pieces that meet nowhere a cable can catch.
//
// The root cone is the piece that matters. It runs the whole `root_cone` from
// the panel face, so it crosses the collar and then keeps climbing inside the
// tube, and it is carried 1 mm BELOW the face on its own slope so it meets the
// thread's plain bore on the line rather than in a hairline ledge.
module bore() {
    translate([0, 0, root_cone])                           // down the tube
        cylinder(h = collar_t + tube_len - root_cone + 0.01, d = tube_bore);
    translate([0, 0, -1])                                  // the root cone
        cylinder(h = root_cone + 1,
                 d1 = outlet_bore - (tube_bore - outlet_bore) / root_cone,
                 d2 = tube_bore);
    translate([0, 0, -neck_length - 1])                    // through the thread
        cylinder(h = neck_length + 1.01, d = outlet_bore);
    translate([0, 0, -neck_length - 0.01])                 // cable lead-out at the tip
        cylinder(h = 2.7, d1 = lead_out_od, d2 = outlet_bore - 1);
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
// which is where a printed thread is at its best -- and it is the only one on
// offer: turned over, the collar's bearing face becomes a 300 mm2 flat ceiling
// and the part stands on the thread's Ø46 tip.
//
// So the transition is printed as an overhang either way, and the answer is the
// angle, not supports: `root_cone` inside and a tall `collar_blend` outside keep
// it near 27 degrees from vertical, where it carries itself. What is left to get
// right is the tube, which is a free-standing shell 25 mm tall on a ring of a
// footprint: print it with a brim, and slow down before the collar.
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
