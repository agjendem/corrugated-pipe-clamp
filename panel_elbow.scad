// ============================================================================
//  Panel elbow -- a tight 90 deg turn onto the corner parts' standard screw
// ----------------------------------------------------------------------------
//  A rigid pipe comes down from above, turns 90 degrees in the shortest arc the
//  bore allows, and leaves horizontally through a panel on the same threaded
//  stuss and the same fin-grip nut as corner_bend, corner_elbow and
//  panel_spigot. The socket end is the only place anything is fitted; the panel
//  end is as short as a bend can be.
//
//                 |    | <- 40 mm socket, the rigid pipe slides in here
//                 |    |
//                 |    |
//                  \    \
//         panel     \    |
//          |         \__/    <- the arc: bend_r on the centreline
//          |+--+   __/
//          ||  |__/
//          |+--+
//       ===|===========     the arc lands straight on the collar: no straight
//          |                run between them, which is what makes it short
//          |  brim (collar), flat on the OUTSIDE of the panel
//         >|| thread, through the hole, stuss_depth into the box
//           v  nut, from inside
//
//  THE BORE NEVER CHANGES. Ø`pipe_od` from the socket's mouth, round the arc,
//  through the collar and out of the thread's tip. That is the whole brief, and
//  it is also what makes this part simpler than panel_spigot: with one diameter
//  end to end there is no step at the collar, so there is no root cone inside
//  and none of the overhang trouble that came with it. What thickening the root
//  needs happens OUTSIDE instead, where there is room -- see `root_cone`.
//
//  THE ARC IS TANGENT AT BOTH ENDS AND NOTHING ELSE DECIDES IT. It leaves the
//  collar pointing straight along the neck's axis and arrives pointing straight
//  along the socket's, so the only free number is `bend_r`, the centreline
//  radius. The floor under it is hard: the tube's own outer radius. At
//  bend_r = elbow_od / 2 the inside of the turn closes to a cusp and the solid
//  folds through itself, so the assert holds it clear of that with
//  `bend_min_clear` of daylight left in the throat. The default is 0.75 x the
//  bore, which on Ø40 is a 30 mm centreline and 7.5 mm of clear throat -- tight
//  for conduit, ordinary for a waste elbow, and the reason the part reaches
//  only 33 mm from the panel face to the socket's axis.
//
//  THE COLLAR IS SIZED OFF THE HOLE, NOT OFF THE TUBE. Unlike panel_spigot,
//  whose Ø50 tube is the same size as the hole and physically cannot pass
//  through it, this elbow is NARROWER than its hole -- Ø45 through Ø50 -- so
//  nothing but the collar stops it going in. That is what a collar is for, and
//  here it gets the bearing ring panel_spigot never had room for:
//  `collar_bearing` all round, 4 mm by default against panel_spigot's 1 -- set
//  so the collar comes out at least as wide as the nut on the other side, the
//  thick-walled `nut_slim` included, since the two are the same clamp and the
//  panel is in between. The echo says which way round they came out.
//
//  TWO WAYS TO PRINT IT, AND NEITHER IS FREE. A 90 degree elbow has two axes at
//  right angles, so whichever one stands up, the other lies down and the last
//  stretch of the arc under it is an overhang. `print` stands on the socket's
//  mouth: the biggest flat face on the part, and the supports land on the bare
//  outside of the neck and the collar's rim. `print_neck` stands on the
//  thread's tip instead: the thread then comes out vertical, which is the best
//  a printed thread gets, and no support touches it -- but the part is standing
//  on the `tip_rim` ring, which is about 1.5 mm wide, and that is a first layer
//  you can lose. Both are echoed with their footprints below. Support either
//  way; brim either way.
//
//  All dimensions are in millimetres.
// ============================================================================

/* [Part] */
part = "body";  // ["body":the part, "print":on the bed, standing on the socket's mouth, "print_neck":on the bed, standing on the thread's tip, "section":cut on the bend plane, "nut":the nut, "assembly":everything in place]

/* [The pipe it takes] */
// The RIGID pipe's outer Ø, and therefore the bore everywhere: the brief is one
// diameter from end to end, so the pipe's outside and the channel's inside are
// the same number. 40 and 25 are the two presets.
pipe_od  = 40;   // outer Ø of the rigid pipe = bore of the whole part (mm)
pipe_fit = 0.4;  // diametral clearance in the SOCKET only (mm). It is the
                 // sliding fit, and -- because the bore behind the socket is
                 // back at pipe_od -- it is also the stop: the pipe runs in
                 // socket_len and meets a step pipe_fit/2 deep all round.
wall     = 2.5;  // wall of the elbow and the socket (mm)

/* [The socket -- the end that points up] */
socket_len    = 40;   // straight run at the socket end (mm) = how deep the
                      // rigid pipe goes in, measured from the mouth to the
                      // end of the arc
mouth_chamfer = 0.5;  // lead-in cut into the socket's mouth (mm); 0 = a square
                      // edge. Keep it small: with part = "print" the mouth is
                      // the face on the bed, and every millimetre of chamfer is
                      // a millimetre off the ring holding the part down. The
                      // ring that is left is echoed below.

/* [The bend] */
bend_radius    = 0;   // centreline radius of the arc (mm); 0 = auto, 0.75 x the
                      // bore, which is as tight as this bore is worth turning
bend_min_clear = 1.5; // daylight that must be left in the throat on the inside
                      // of the turn (mm). This is the number the assert defends:
                      // below zero the tube folds through itself.

/* [The collar -- the brim it hangs on] */
collar_bearing = 4;   // how far the collar reaches past the HOLE, all round (mm).
                      // This is the ring the panel is clamped against. Sized off
                      // the hole and not off the tube, because the tube is
                      // narrower than the hole -- and sized to be at least as
                      // wide as the NUT, which is the other half of the same
                      // clamp. A collar narrower than the nut pinches the panel
                      // on a ring that has nothing behind it; the echo below
                      // says which way round they came out.
collar_t       = 3;   // its thickness (mm). Flat underneath, always: whatever is
                      // done for strength happens above it, or the part rocks on
                      // a chamfer instead of bedding on the panel.
root_cone      = 8;   // how far the collar's Ø is carried up the elbow as a cone
                      // (mm). This is the fillet at the root of the cantilever,
                      // and with the bore constant it is the ONLY place the root
                      // gets any extra material -- panel_spigot could thicken
                      // from the inside, this cannot.

/* [Cabinet panel] */
hole_diameter   = 50;  // the hole in the panel (mm) -- the same one the corner
                       // parts use, which is why Ø40 shares their nut
plate_thickness = 2;   // the panel's own thickness (mm)  <- MEASURE YOURS
stuss_depth     = 10;  // how far the threaded neck carries on INTO the box (mm).
                       // With plate_thickness this is the whole threaded length,
                       // so it alone sets how many turns there are to run the
                       // nut down -- echoed below.

/* [Thread + nut]  (the same screw as corner_bend, corner_elbow and panel_spigot) */
thread_pitch     = 3;
thread_starts    = 1;
thread_depth     = 0.8;
thread_clearance = 0.4;
neck_clearance   = 0.8;  // diametral gap thread crest -> the hole
neck_wall        = 3;    // material between the bore and the thread root (mm)
tip_rim          = 1.2;  // the flat left at the very tip of the thread, between
                         // the lead-in chamfer outside and the cable lead-out
                         // inside (mm). It is the last ring the printer lays in
                         // "print", and the FIRST one in "print_neck".

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
nut_grip_depth = 1.8;  // how deep it bites (mm)
nut_flange     = 0;
nut_flange_t   = 2.5;

/* [Assembly view] */
show_panel = true;

/* [Render quality] */
$fn = 96;

// ── Derived: the channel ────────────────────────────────────────────────────
bore        = pipe_od;                 // one diameter, end to end
socket_bore = pipe_od + pipe_fit;      // the sliding fit, socket only
elbow_od    = pipe_od + 2 * wall;
bend_r      = bend_radius > 0 ? bend_radius : 0.75 * pipe_od;
throat      = bend_r - elbow_od / 2;   // daylight on the inside of the turn
socket_stop = pipe_fit / 2;            // the step the rigid pipe butts against

// ── Derived: collar, neck, nut ──────────────────────────────────────────────
collar_d  = hole_diameter + 2 * collar_bearing;

neck_od        = hole_diameter - neck_clearance;   // thread CREST diameter
neck_tip_od    = neck_od - 3;                      // the lead-in chamfer's small end
thread_crest_r = neck_od / 2;
thread_root_r  = thread_crest_r - thread_depth;
neck_length    = plate_thickness + stuss_depth;
thread_turns   = neck_length / (thread_pitch * thread_starts);

nut_od         = neck_od + 2 * nut_wall;
nut_bore_r     = thread_root_r + thread_clearance / 2;
nut_flange_od  = 2 * (nut_bore_r + nut_flange);
nut_fin_r      = nut_grip <= 0 ? nut_od / 2
               : max(nut_od / 2 + nut_grip,
                     nut_flange > 0 ? nut_flange_od / 2 + nut_grip_clear : 0);
nut_grip_wall  = nut_wall - nut_grip_depth - thread_clearance / 2;

// The mouth of the cable lead-out at the thread's tip, held back so `tip_rim` of
// flat survives -- the ring the nut has to start on, and the one the part stands
// on in "print_neck".
lead_out_od = min(bore + 4.4, neck_tip_od - 2 * tip_rim);
tip_rim_got = (neck_tip_od - lead_out_od) / 2;

// ── Derived: where things are ───────────────────────────────────────────────
//  The panel's OUTER face is z = 0. The neck goes DOWN through it, the collar
//  sits on it, the arc leaves it going UP and lands pointing along +X. In use
//  the panel is vertical and +X is up -- the assembly view turns it that way.
arc_z0     = collar_t;                       // where the arc starts
socket_x   = bend_r;                         // the socket's axis, off the neck's
socket_z   = arc_z0 + bend_r;                // its height
socket_tip = socket_x + socket_len;          // the mouth

reach      = socket_tip + collar_d / 2;      // overall, along the panel
height     = socket_z + elbow_od / 2 + neck_length;   // overall, through it
stub_out   = arc_z0 + bend_r;                // panel face -> socket axis

// The two footprints, both thin rings, so both get a brim. "print" stands on
// the socket's mouth, less whatever the lead-in chamfer has eaten; "print_neck"
// stands on tip_rim at the thread's tip.
mouth_ring  = (elbow_od - socket_bore) / 2 - mouth_chamfer;
mouth_area  = PI / 4 * (pow(elbow_od, 2) - pow(socket_bore + 2 * mouth_chamfer, 2));
tip_area    = PI / 4 * (pow(neck_tip_od, 2) - pow(lead_out_od, 2));

function mm1(x) = round(x * 10) / 10;

// The fillet at the root of the cantilever, measured the way a slicer measures
// an overhang: degrees from VERTICAL. It is only a floor overhang in
// "print_neck" -- and there it points the harmless way, narrowing as it rises --
// but it is the root of a cantilever in every orientation, so it is echoed.
root_slope = atan(((collar_d - elbow_od) / 2) / root_cone);

// ── Sanity checks ───────────────────────────────────────────────────────────
assert(wall >= 1,
       str("A ", wall, " mm wall is under one perimeter pair on most printers -- it will ",
           "come out as a gap, not a tube."));
assert(throat >= bend_min_clear,
       str("bend_r ", mm1(bend_r), " on a Ø", elbow_od, " tube leaves ", mm1(throat),
           " mm of throat on the inside of the turn. Below ", bend_min_clear,
           " mm there is nothing there, and at 0 the tube folds through itself. ",
           "Minimum bend_radius here is ", mm1(elbow_od / 2 + bend_min_clear), " mm."));
assert(collar_d > hole_diameter,
       str("collar_bearing ", collar_bearing, " does not reach past the Ø", hole_diameter,
           " hole -- the part would drop straight through it."));
assert(collar_bearing >= 0.5,
       str("The collar bears on only ", collar_bearing, " mm of panel all round. A hole ",
           "drilled anywhere near size takes that away. Raise collar_bearing."));
assert(collar_d > neck_od,
       "the collar must be wider than the thread crest, or there is nothing to catch on");
assert(collar_d >= elbow_od + 2,
       str("The collar is Ø", collar_d, " and the elbow Ø", elbow_od,
           " -- the root cone has nothing to fall, or falls the wrong way. Either the hole ",
           "is too small for this pipe, or the wall is too thick."));
assert(root_cone > 0 && root_cone <= bend_r / 2,
       str("root_cone ", root_cone, " must fit inside the first half of a ", mm1(bend_r),
           " mm arc; past that it is no longer a fillet at the root, it is a taper on the ",
           "bend."));
assert(bore / 2 <= thread_root_r - neck_wall,
       str("A Ø", bore, " bore leaves less than ", neck_wall, " mm at the thread root of a Ø",
           hole_diameter, " hole. The widest bore this hole can carry is ",
           mm1(2 * (thread_root_r - neck_wall)), " mm -- drill the panel bigger, or thin ",
           "neck_wall."));
assert(tip_rim_got >= 0.8,
       str("The thread's tip is left ", mm1(tip_rim_got), " mm of flat -- about two lines, ",
           "and it will curl into the way of the nut. Cut tip_rim, or widen the hole."));
assert(mouth_ring >= 0.8,
       str("The socket's mouth is left a ", mm1(mouth_ring), " mm ring -- that is the face ",
           "part = \"print\" stands on, and it is too thin to hold. Cut mouth_chamfer (now ",
           mouth_chamfer, " mm), or thicken wall."));
assert(socket_len >= 5,
       "socket_len under 5 mm is not a socket, it is a chamfer");
assert(nut_height <= stuss_depth - 1,
       "nut_height leaves no room inside stuss_depth -- the nut must fit in the box");
assert(nut_flange == 0 || nut_flange_t < nut_height - 2,
       "nut_flange_t too thick for nut_height");

// ── What it comes to ────────────────────────────────────────────────────────
echo(str("Overall: ", mm1(reach), " mm along the panel x ", mm1(height),
         " mm through it, Ø", collar_d, " at the collar"));
echo(str("Bore: Ø", bore, " from the thread's tip to the socket -- unchanged the whole ",
         "way, so there is no step at the collar and nothing inside for a cable to catch."));
echo(str("Socket: Ø", socket_bore, " x ", socket_len, " mm deep for a Ø", pipe_od,
         " rigid pipe. It stops on a ", mm1(socket_stop),
         " mm step all round, which is the fit clearance running out -- that is what ",
         "holding the bore at Ø", bore, " behind it costs."));
echo(str("Bend: ", mm1(bend_r), " mm on the centreline, ", round(bend_r / pipe_od * 100) / 100,
         " x the bore, leaving ", mm1(throat), " mm of throat inside the turn. Panel face -> ",
         "socket axis is ", mm1(stub_out), " mm, which is as short as a ", mm1(bend_r),
         " mm arc can land."));
echo(str("Collar: Ø", collar_d, " x ", collar_t, " mm, flat underneath. It hangs on ",
         collar_bearing, " mm of panel all round the Ø", hole_diameter, " hole. The elbow is ",
         "Ø", elbow_od, " -- NARROWER than the hole, so the collar is the only thing ",
         "stopping the part going through.",
         collar_d >= nut_od
           ? str(" It is Ø", mm1(collar_d - nut_od), " wider than the nut, so the panel is ",
                 "clamped between two rings that face each other.")
           : str(" WARNING: the nut is Ø", nut_od, ", wider than the collar -- it will pinch ",
                 mm1((nut_od - collar_d) / 2), " mm of panel all round with nothing behind ",
                 "it. Raise collar_bearing to ", mm1((nut_od - hole_diameter) / 2), ".")));
echo(str("Neck: thread crest Ø ", neck_od, ", ", neck_length, " mm long (",
         stuss_depth, " mm inside the box) = ", mm1(thread_turns),
         " turns at ", thread_pitch, " mm pitch; the nut takes ",
         mm1(nut_height / (thread_pitch * thread_starts)), " of them"));
echo(nut_grip > 0
     ? str("Nut: Ø ", nut_od, " body, Ø ", 2 * nut_fin_r, " over the fins, ",
           nut_height, " mm tall")
     : str("Nut: Ø ", nut_od, " across -- scalloped grip, no fins, ", nut_height,
           " mm tall; ", mm1(nut_grip_wall), " mm of wall under the grip"));
echo(str("Root: the collar's Ø is carried ", root_cone, " mm up the elbow as a cone, ",
         mm1(root_slope), " degrees from vertical. With the bore held at Ø", bore,
         " this is the only material the root of the cantilever gets."));
echo(str("print: stands on the socket's mouth, a ", mm1(mouth_ring), " mm ring, ",
         mm1(mouth_area / 100), " cm2, with the neck and collar ", mm1(socket_len),
         " mm up in the air. print_neck: stands on the thread's tip, a ",
         mm1(tip_rim_got), " mm ring, ", mm1(tip_area / 100),
         " cm2, with the socket lying across the top. Brim either way; the last ~45 ",
         "degrees of the arc wants support either way; what differs is whether the ",
         "support lands on the thread (print) or on bare tube (print_neck)."));

// The screw connection -- thread and nut -- lives in one place for all the
// parts that use this hole.
include <thread.scad>

// ============================================================================
//  THE PART
// ----------------------------------------------------------------------------
//  Centreline: starts at the thread's tip on the -z axis, runs up through the
//  panel face at z = 0 and the collar, then turns 90 degrees over `bend_r` in
//  the XZ plane toward +X and finishes as a straight socket.
// ============================================================================

// The arc, as one swept circle. Built the way pipe_bend.scad builds its elbow:
// a circle swept about a horizontal axis, shifted so the start is tangent to
// the z axis, and mirrored so it turns toward +X.
module elbow(d) {
    translate([0, 0, arc_z0])
        mirror([1, 0, 0]) translate([-bend_r, 0, 0]) rotate([90, 0, 0])
            rotate_extrude(angle = 90, convexity = 6)
                translate([bend_r, 0]) circle(d = d);
}

// Anything built along +Z, placed at the end of the arc pointing along +X.
module at_socket() {
    translate([socket_x, 0, socket_z]) rotate([0, 90, 0]) children();
}

// The collar and the cone that carries its Ø up into the elbow. The z = 0 face
// is left alone: it is what beds on the panel.
module collar() {
    cylinder(h = collar_t, d = collar_d);
    translate([0, 0, collar_t - 0.01])
        cylinder(h = root_cone + 0.01, d1 = collar_d, d2 = elbow_od);
}

// The same neck as panel_spigot and corner_elbow: the twisted solid clipped to
// a plain cylinder, with a lead-in chamfer at the tip so the nut starts square.
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

// One bore, in four pieces. The first three are all Ø`bore` and meet on their
// own tangents, so there is no edge anywhere between the thread's tip and the
// socket. The fourth is the socket's fit clearance, and the step where it ends
// is the pipe's stop.
module bore_cut() {
    translate([0, 0, -neck_length - 1])                    // up through the thread
        cylinder(h = neck_length + arc_z0 + 1.01, d = bore);
    elbow(bore);                                           // round the arc
    at_socket() translate([0, 0, -0.01])                   // the straight socket
        cylinder(h = socket_len + 0.02, d = bore);
    at_socket() {
        cylinder(h = socket_len + 0.01, d = socket_bore);  // the fit, and its stop
        if (mouth_chamfer > 0)
            translate([0, 0, socket_len - mouth_chamfer])
                cylinder(h = mouth_chamfer + 0.01,
                         d1 = socket_bore, d2 = socket_bore + 2 * mouth_chamfer);
    }
    translate([0, 0, -neck_length - 0.01])                 // cable lead-out at the tip
        cylinder(h = 2.7, d1 = lead_out_od, d2 = bore - 1);
}

module body() {
    difference() {
        union() {
            collar();
            elbow(elbow_od);
            at_socket() cylinder(h = socket_len, d = elbow_od);
            neck();
        }
        bore_cut();
    }
}

// Cut on the bend plane, for the renders: the wall round the turn, the collar,
// the socket's stop and the thread all in one section.
module body_section() {
    intersection() {
        body();
        translate([-500, 0, -500]) cube(1000);
    }
}

// ── As it goes on the bed ───────────────────────────────────────────────────
// Standing on the socket's mouth: the biggest flat face the part has, and the
// one orientation where no support has to reach inside anything. The neck and
// the collar are then horizontal at the top of the tube, so the supports land
// on the thread -- which is the price, and why print_neck exists.
module body_print() {
    translate([0, 0, socket_tip]) rotate([0, 90, 0]) body();
}

// Standing on the thread's tip instead. The thread comes out vertical, which is
// the best a printed thread gets, the collar's bearing face bridges off the
// neck, and every support lands on bare tube. What you are trusting is the
// first layer: a ring tip_rim wide, echoed above.
module body_print_neck() {
    translate([0, 0, neck_length]) body();
}

// ============================================================================
//  ASSEMBLY -- turned the way it is used: panel vertical, socket pointing up
// ============================================================================
module panel_ghost() {
    color("silver", 0.35)
        difference() {
            translate([-70, -70, -plate_thickness]) cube([140, 140, plate_thickness]);
            translate([0, 0, -plate_thickness - 1])
                cylinder(h = plate_thickness + 2, d = hole_diameter);
        }
}

module assembly() {
    rotate([0, -90, 0]) {                  // +X (the socket) -> +Z (up)
        body();
        color("steelblue") translate([0, 0, -plate_thickness - nut_height]) nut();
        if (show_panel) panel_ghost();
    }
}

// ── Render ──────────────────────────────────────────────────────────────────
if (is_undef(DIMENSIONS_ONLY)) {
    if      (part == "body")       body();
    else if (part == "print")      body_print();
    else if (part == "print_neck") body_print_neck();
    else if (part == "section")    body_section();
    else if (part == "nut")        nut();
    else if (part == "assembly")   assembly();
    else assert(false, str("unknown part: ", part));
}
