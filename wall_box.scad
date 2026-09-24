// ============================================================================
//  Wall box -- a retrofit hollow-wall box whose back IS the cable's bend
// ----------------------------------------------------------------------------
//  The other end of the run. panel_elbow turns a Ø40 rigid pipe through a
//  cabinet panel; this is the box you cut into an existing wall for the pipe to
//  arrive in. It borrows the mechanism of a bought hollow-wall box -- a lip that
//  stops on the board, two metal wings that fold out behind it -- and throws
//  away everything else.
//
//      z = 0 is the BEARING FACE: the underside of the lip, on the board.
//      +y is UP: the direction the pipe comes from.
//
//        lip   board            the pipe, cut at 45 deg
//       |<->| |<-- 25 -->|              | |
//       ,-+-+-+----------------------.__| |__.
//       | |#|#|                          | |  |
//       | |#|#|                     +25.9 \|  |   <- the short side, 11 mm grip
//       | |#|#|                            \  |
//       | |#|#|      free box               \ |
//       | |#|#|                              \|
//       | |#|#|                        -14.5  |   <- the long side, 51 mm grip,
//       | |#|#|                    R20 \      |      and where the sweep starts
//       `-+-+-+------------------------_'-----'
//        -2 0            57.5              80
//
//  THE PIPE CANNOT STICK OUT, AND THAT IS PYTHAGORAS, NOT A PREFERENCE. A Ø45.4
//  socket standing proud of a Ø74 barrel cannot pass a Ø75 hole: its rim would
//  have to sit at y = sqrt(37.5^2 - 22.7^2) = 29.8 at most, which is below the
//  barrel's own surface. Tilting does not help -- the socket's width lies along
//  x and a tilt about x does not move x. Riding the box low does not help
//  either -- a Ø74 circle in a Ø75 hole has half a millimetre to give. So
//  nothing protrudes: the bore is simply a hole in the top of the barrel, and
//  all the grip happens inside.
//
//  THE 45 DEGREE CUT IS WHAT MAKES DEPTH CHEAP. Square-cut, a 30 mm socket is a
//  Ø45 tube hanging into the box and stealing a cylinder of space. Cut at 45
//  degrees with the long side at the BACK, the same socket is a chute in the
//  back corner: its inside IS box space, only a short lip hangs down at the
//  front, and the pipe is gripped 51 mm along the back and 11 mm at the front.
//  A 45 degree cut on Ø40.4 spans 40.4 mm of height -- that number is why the
//  two grips differ by so much, and it is not adjustable.
//
//  AND THE BACK IS A SWEEP, NOT A CHAMFER. `sweep_r` is tangent to the pipe's
//  back wall at the top and to the box's floor at the front, so a cable runs
//  down the pipe, onto the sweep and out forwards without meeting an edge
//  anywhere. It also buys room: a chord across that corner cuts straight
//  through space the arc gives back, and the floor stays whole all the way to
//  z = 57.5 instead of z = 30.
//
//  THE SWEEP AND THE GRIP ARE ONE NUMBER. The arc has to touch both the floor
//  and the pipe's back wall, so choosing the radius chooses the depth:
//
//      grip (mean) = 51.3 - sweep_r        grip (front) = 31.1 - sweep_r
//
//  At sweep_r 20 that is 31 mm mean and 11 mm at the front. At 30 there is
//  nothing left holding the pipe at the front. Both are derived and echoed.
//
//  NOTHING IS DOUBLE-WALLED. The shell follows the sweep at `wall` and the back
//  wall of the box is also the back wall of the socket -- the arc's outer
//  offset comes out tangent to z = box_depth by construction. There is no
//  closed void anywhere in the part.
//
//  All dimensions are in millimetres.
// ============================================================================

/* [Part] */
part = "body";  // ["body":the part, "section":cut on the pipe's plane, "assembly":in the wall, with the pipe]

/* [The box] */
body_od   = 74;   // outside Ø of the barrel -- what passes through the sawn hole
box_depth = 80;   // bearing face -> back face (mm)
wall      = 2.5;  // the shell, everywhere: barrel, back and sweep

/* [The lip -- what stops it on the board] */
lip_od = 76.5;  // bigger than the sawn hole, so it catches
lip_t  = 2;     // how far it stands proud of the board (mm). The bearing face
                // underneath is FLAT, always.

/* [The wall it goes into] */
board_t  = 25;  // the board's thickness (mm)  <- MEASURE YOURS. 25 is double 12.5.
hole_saw = 75;  // the hole you saw in it (mm)

/* [The pipe socket] */
pipe_od     = 40;   // outer Ø of the rigid pipe (mm)
pipe_fit    = 0.4;  // diametral sliding clearance (mm), as panel_elbow
collar_wall = 2.5;  // the socket's own wall where it hangs into the box (mm)
mouth_chamfer = 1;  // lead-in at the barrel's surface (mm)

/* [The sweep -- the back of the box, and the cable's bend] */
sweep_r = 20;   // radius of the arc (mm). Tangent to the floor at the front and
                // to the pipe's back wall at the top, so it sets the grip too --
                // see the echo. Bigger is gentler on the cable and shallower on
                // the pipe.

/* [Lid screws -- the standard 60 mm centres] */
lid_pcd     = 60;   // centre-to-centre (mm)
boss_d      = 10;   // the boss Ø (mm). Ø8 would stand clear of the wall.
pilot_d     = 2.9;  // pilot for a self-tapping M3.5 (mm)
pilot_depth = 15;   // how deep it is bored from the front (mm)
boss_len    = 55;   // how far the boss runs back (mm)

/* [The wings -- the metal plates that fold out behind the board] */
// Bought or salvaged hardware; every figure here is a placeholder.
wing_angle   = 45;   // degrees off the pipe, i.e. off 12 o'clock
wing_pcd     = 72;   // the screws' pitch circle (mm)
wing_screw_d = 4.4;  // clearance for an M4 (mm)
wing_head_d  = 8;    // its head, countersunk into the lip (mm)
wing_slot_w  = 10;   // the channel's width (mm)
wing_floor_r = 34.5; // the channel's floor, as a radius (mm)
wing_rib_r   = 29;   // how far the rib carrying the screw reaches in (mm)
wing_rib_w   = 16;   // the rib's width (mm)
wing_ramp_z  = 32;   // where the kick-out ramp sits (mm). Must be behind the board.
wing_ramp_a  = 40;   // the ramp's angle from the box's axis (deg)

/* [Assembly view] */
show_board = true;
show_pipe  = true;

/* [Render quality] */
$fn = 96;

// ── Derived: the shell ──────────────────────────────────────────────────────
r_out  = body_od / 2;
r_in   = r_out - wall;
floor_z = box_depth - wall;                 // the inside of the back wall

// ── Derived: the socket ─────────────────────────────────────────────────────
socket_bore = pipe_od + pipe_fit;
r_bore      = socket_bore / 2;
r_collar    = r_bore + collar_wall;
// As far back as it goes: the bore's back wall IS the box's back wall.
socket_z    = floor_z - r_bore;

// ── Derived: the sweep, and the 45 degree cut it hands the pipe ─────────────
// The arc touches the floor (y = -r_in) and the pipe's back wall (z = floor_z),
// which fixes its centre. Its outer offset then comes out tangent to the
// barrel's bottom and to z = box_depth -- no double wall, by construction.
arc_cy = sweep_r - r_in;
arc_cz = floor_z - sweep_r;
// The pipe's cut is the 45 degree plane y + z = mitre_k through that tangency.
mitre_k = arc_cy + floor_z;
mitre_front = mitre_k - (socket_z - r_bore);   // where the cut leaves the bore
mitre_back  = arc_cy;                          // and where its tip lands

grip_back  = r_out - mitre_back;
grip_front = r_out - mitre_front;
grip_mean  = (grip_back + grip_front) / 2;

// ── Derived: the wings ──────────────────────────────────────────────────────
wing_r        = wing_pcd / 2;
wing_axis_gap = wing_r * sin(wing_angle);
gap_to_bore   = wing_axis_gap - r_bore   - wing_screw_d / 2;
gap_to_collar = wing_axis_gap - r_collar - wing_screw_d / 2;
wing_ramp_len = (r_out - wing_floor_r) / tan(wing_ramp_a);
wing_a        = [90 - wing_angle, 270 - wing_angle];   // 12 o'clock is +y

function mm1(x) = round(x * 10) / 10;

// ── Sanity checks ───────────────────────────────────────────────────────────
assert(wall >= 1,
       str("A ", wall, " mm shell is under one perimeter pair on most printers."));
assert(lip_od > hole_saw,
       str("lip_od ", lip_od, " is not bigger than the Ø", hole_saw,
           " hole -- the box would drop straight through the wall."));
assert(box_depth > board_t + 20,
       str("box_depth ", box_depth, " leaves ", box_depth - board_t,
           " mm behind a ", board_t, " mm board. That is not a box."));
assert(sweep_r > 0 && sweep_r < r_in,
       str("sweep_r ", sweep_r, " must fit between the floor and the pipe's back wall, ",
           "so it has to be under ", mm1(r_in), "."));
assert(grip_front >= 5,
       str("sweep_r ", sweep_r, " leaves the pipe only ", mm1(grip_front),
           " mm of grip at the FRONT of the socket -- it will rock. The arc has to touch ",
           "both the floor and the pipe, so radius and grip are one number: cut sweep_r to ",
           mm1(31.1 - 5), " or less for 5 mm, ", 20, " gives 11."));
assert(arc_cz > board_t + 2,
       str("The sweep starts at z ", mm1(arc_cz), ", which is inside the ", board_t,
           " mm board. Cut sweep_r."));
// The socket's rim is a Ø45.4 circle standing on a Ø74 barrel: Pythagoras, not
// taste, says where it can be. This is the one that killed every other layout.
assert(r_collar <= sqrt(pow(hole_saw / 2, 2) - 0) && r_out <= hole_saw / 2,
       str("The barrel Ø", body_od, " does not pass the Ø", hole_saw, " hole."));
assert(gap_to_bore >= 1.2,
       str("The wing screw passes ", mm1(gap_to_bore), " mm from the pipe bore. Raise ",
           "wing_pcd (now ", wing_pcd, "), or move wing_angle off ", wing_angle, " deg."));
assert(wing_ramp_z > board_t + 2,
       str("The kick-out ramp sits ", wing_ramp_z, " mm in and the board owns 0..", board_t,
           ". The plate would open inside the wall."));
assert(boss_len < arc_cz,
       str("boss_len ", boss_len, " runs past where the sweep starts (", mm1(arc_cz), ")."));

// ── What it comes to ────────────────────────────────────────────────────────
echo(str("Overall: Ø", lip_od, " at the lip, Ø", body_od, " through the hole, ",
         mm1(box_depth + lip_t), " mm tall (", lip_t, " proud + ", box_depth, " in the wall)"));
echo(str("Depth budget: ", board_t, " mm of board, ", mm1(box_depth - board_t),
         " mm out in the cavity behind it -- 48 mm studs will not take this, 70 will."));
echo(str("Socket: Ø", socket_bore, " bore, axis ", mm1(socket_z),
         " mm in -- as far back as it goes, so the bore's back wall IS the box's back wall. ",
         "Nothing stands proud of the barrel: the rim is a hole in the top, not a boss."));
echo(str("The pipe's 45 deg cut: short side leaves the bore at y ", mm1(mitre_front),
         " (", mm1(grip_front), " mm of grip), long side lands at y ", mm1(mitre_back),
         " (", mm1(grip_back), " mm). Mean grip ", mm1(grip_mean),
         " mm. The cut spans ", mm1(grip_back - grip_front),
         " mm of height, which is just the bore's Ø at 45 deg."));
echo(str("Sweep: R", sweep_r, ", centre (y ", mm1(arc_cy), ", z ", mm1(arc_cz),
         "). Tangent to the floor at z ", mm1(arc_cz), " and to the pipe's back wall at y ",
         mm1(arc_cy), " -- the same point the pipe's tip lands on, so the cable meets no ",
         "edge from the pipe to the floor. The floor stays whole to z ", mm1(arc_cz), "."));
echo(str("Radius and grip are ONE number: mean grip = ", mm1(51.3), " - sweep_r, front grip = ",
         mm1(31.1), " - sweep_r. R16 -> 35/15, R20 -> 31/11, R24 -> 27/7, R30 -> 21/1."));
echo(str("Shell: ", wall, " mm, following the sweep. Its outer offset comes out tangent to ",
         "the barrel's bottom and to z ", box_depth,
         " by construction -- no double wall, no closed void."));
echo(str("Lid screws: ", lid_pcd, " mm centres, Ø", boss_d, " bosses ", boss_len,
         " mm long, Ø", pilot_d, " pilot ", pilot_depth, " mm deep for a self-tapping M3.5"));
echo(str("Wings: Ø", wing_pcd, " pitch circle at ", wing_angle,
         " deg off the pipe. The screw passes ", mm1(gap_to_bore), " mm from the bore."));
echo(str("NOTE: this is the shape, for checking. Print orientation is NOT solved yet -- ",
         "the back is a crescent now, not a disc, so it will not stand on it."));

include <brim.scad>

// ============================================================================
//  THE PART
// ============================================================================

// Anything built along +z, laid onto the pipe's axis pointing +y (12 o'clock).
module at_socket() { translate([0, 0, socket_z]) rotate([-90, 0, 0]) children(); }

module at_wings() { for (a = wing_a) rotate([0, 0, a]) children(); }

module barrel() { cylinder(h = box_depth, d = body_od); }
module lip()    { translate([0, 0, -lip_t]) cylinder(h = lip_t + 0.01, d = lip_od); }

// The back-bottom corner, with radius `r` left in it. Subtracting this is what
// turns the corner into the sweep -- at `sweep_r` for the inside and
// `sweep_r + wall` for the outside, which is why the shell comes out even.
module back_corner(r) {
    difference() {
        translate([-60, arc_cy - 90, arc_cz]) cube([120, 90, 90]);
        translate([-61, arc_cy, arc_cz]) rotate([0, 90, 0]) cylinder(h = 122, r = r);
    }
}

module envelope() { difference() { barrel(); back_corner(sweep_r + wall); } }

// Everything above the pipe's 45 degree cut, i.e. y + z > mitre_k.
module mitre_upper() {
    translate([0, 0, mitre_k]) rotate([45, 0, 0])
        translate([-300, 0, -300]) cube([600, 600, 600]);
}

module shell() {
    difference() {
        union() { envelope(); lip(); }
        difference() {
            translate([0, 0, -lip_t - 1])
                cylinder(h = floor_z + lip_t + 1, d = body_od - 2 * wall);
            back_corner(sweep_r);
        }
    }
}

// The socket's own wall, where it hangs into the box. Only the part above the
// pipe's cut exists -- below it there is no pipe, so there is nothing to hold.
module collar() {
    intersection() {
        at_socket() translate([0, 0, -90]) cylinder(h = 180, d = 2 * r_collar);
        mitre_upper();
        envelope();
    }
}

module lid_bosses() {
    intersection() {
        for (s = [-1, 1]) translate([s * lid_pcd / 2, 0, 0]) cylinder(h = boss_len, d = boss_d);
        envelope();
    }
}

module wing_ribs() {
    intersection() {
        at_wings() translate([wing_rib_r, -wing_rib_w / 2, 0])
            cube([r_out - wing_rib_r + 1, wing_rib_w, box_depth]);
        envelope();
    }
}

// ── The cuts ────────────────────────────────────────────────────────────────
// The bore is clipped by the SAME 45 degree plane that ends the collar, and
// two coincident faces in a difference() is how you earn sliver soup -- this
// one came out in 64 pieces before the epsilon went in. The bore's plane is
// pushed `bore_eps` deeper so the two never share a surface; what it cuts into
// below the collar is void either way.
bore_eps = 0.1;

module bore_cut() {
    intersection() {
        at_socket() {
            translate([0, 0, -90]) cylinder(h = 180, d = socket_bore);
        }
        translate([0, 0, -bore_eps]) mitre_upper();
    }
    // lead-in where the pipe meets the barrel's surface
    at_socket() translate([0, 0, r_out - mouth_chamfer])
        cylinder(h = mouth_chamfer + 2, d1 = socket_bore, d2 = socket_bore + 2 * mouth_chamfer);
}

module pilot_holes() {
    for (s = [-1, 1])
        translate([s * lid_pcd / 2, 0, -lip_t - 1])
            cylinder(h = pilot_depth + lip_t + 1, d = pilot_d);
}

module wing_channels() {
    at_wings() {
        translate([wing_floor_r, -wing_slot_w / 2, wing_ramp_z + wing_ramp_len])
            cube([r_out - wing_floor_r + 2, wing_slot_w,
                  box_depth - wing_ramp_z - wing_ramp_len + 2]);
        // The polygon is drawn in (radius, z); rotate([90,0,0]) is what puts a
        // linear_extrude's plane there and sweeps it across the channel's width.
        translate([0, wing_slot_w / 2, 0]) rotate([90, 0, 0])
            linear_extrude(height = wing_slot_w)
                polygon([[wing_floor_r, wing_ramp_z + wing_ramp_len],
                         [r_out + 2,    wing_ramp_z + wing_ramp_len],
                         [r_out + 2,    wing_ramp_z]]);
    }
}

module wing_screw_cuts() {
    translate([0, 0, -lip_t]) rotate([0, 0, -wing_angle])
        brim_screw_cuts(2, wing_pcd, 90, wing_screw_d, wing_head_d, 90, box_depth + lip_t);
}

module body() {
    difference() {
        union() { shell(); collar(); lid_bosses(); wing_ribs(); }
        bore_cut();
        pilot_holes();
        wing_channels();
        wing_screw_cuts();
    }
}

// Cut on the plane that holds both the box's axis and the pipe's -- the only
// one that shows the sweep, the cut and the two grips together.
module body_section() {
    intersection() { body(); translate([0, -500, -500]) cube(1000); }
}

// ============================================================================
//  ASSEMBLY -- what it is supposed to look like in the wall
// ============================================================================
module board_ghost() {
    color("silver", 0.3)
        difference() {
            translate([-90, -90, 0]) cube([180, 180, board_t]);
            translate([0, 0, -1]) cylinder(h = board_t + 2, d = hole_saw);
        }
}

// The pipe as it is delivered: cut at 45 degrees, long side to the BACK.
module pipe_ghost() {
    color("tan", 0.55)
        intersection() {
            at_socket() difference() {
                translate([0, 0, -90]) cylinder(h = 180, d = pipe_od);
                translate([0, 0, -91]) cylinder(h = 182, d = pipe_od - 2 * 2.0);
            }
            mitre_upper();
            translate([-100, -200, -100]) cube([200, 300, 300]);   // stop it at the top
        }
}

// Turned the way it is used: the board upright, the box going into it, and the
// pipe pointing UP. rotate([90,0,0]) takes the model's +y to +z.
module assembly() {
    rotate([90, 0, 0]) {
        body();
        if (show_board) board_ghost();
        if (show_pipe)  pipe_ghost();
    }
}

// The one view that settles whether the design is understood: the box, the
// board and the pipe, all cut on the pipe's own plane, so the 45 degree seat,
// the two grips and the sweep are visible at once.
module assembly_section() {
    intersection() {
        assembly();
        translate([0, -500, -500]) cube(1000);
    }
}

// ── Render ──────────────────────────────────────────────────────────────────
if (is_undef(DIMENSIONS_ONLY)) {
    if      (part == "body")              body();
    else if (part == "section")           body_section();
    else if (part == "assembly")          assembly();
    else if (part == "assembly_section")  assembly_section();
    else assert(false, str("unknown part: ", part));
}
