// ============================================================================
//  Corner elbow, clear channel -- an addon to the 40 mm mount in pipe_clamp.scad
// ----------------------------------------------------------------------------
//  corner_elbow.scad with one thing taken out and one thing put back.
//
//  TAKEN OUT: the collar. In corner_elbow.scad the panel plate either floors the
//  channel (costing 4 mm of depth) or is bored through with a ring masked out
//  for the nut -- and that ring then stands proud of the open floor right where
//  the channel crosses it, a small threshold the cable has to ride over. Here
//  nothing at all crosses the channel. The bore goes clean through the plate,
//  the ring included, from the glue face to the hole.
//
//  PUT BACK: thickness. The cut takes 19.3 mm out of the bearing face, which
//  against a Ø50 -> Ø64 ring is 11 % of its area and about 40 deg of its
//  circumference -- the ring is a C, not a horseshoe. What holds it is that the
//  two legs either side of the slot are tied together by the elbow's own wall
//  arching over the channel, so the section is a closed box rather than two
//  loose flaps, and that the plate is thicker. Thickness is FREE here in a way
//  it is not in corner_elbow.scad: with the floor open the plate is no longer
//  what the cable lies on, so every millimetre added goes into stiffness and
//  none of it into the channel. At 6 mm the legs are 3.4x stiffer in bending
//  than the 4 mm plate ever was.
//
//  There is a free check on all of this: the finished solid is GENUS 1, and its
//  one handle is the stuss's own ring. Anything closing across the channel shows
//  up as a second handle -- which is exactly what corner_elbow.scad's collar is,
//  and why that variant is genus 2. See the assert on panel_bite below.
//
//  Everything else -- the frame, the four blocks, the bend radius, the thread,
//  the nut -- is corner_elbow.scad's, repeated here so this file stands alone:
//
//      side   -- a round plate on the mount's Ø94 flange   (the glue face)
//      pipe   -- a 90° elbow, constant bore, nothing else
//      side   -- a squared plate on the cabinet's back panel (the screw face)
//      screw  -- the threaded stuss + nut, unchanged
//
//      side   -- a round plate on the mount's Ø94 flange   (the glue face)
//      pipe   -- a 90° elbow, constant bore, nothing else
//      side   -- a squared plate on the cabinet's back panel (the screw face)
//      screw  -- the threaded stuss + nut, unchanged
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
plate_t         = 6;   // thickness of our plate on it (mm). Thicker than the
                       // 4 mm of corner_elbow.scad, and it costs the cable
                       // nothing: the channel is bored through the plate, so its
                       // thickness is all stiffness for the legs either side.
bearing         = 7;   // how far that plate must overhang the hole, so the nut
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
outlet_x = 55;   // glue face -> outlet axis (mm). The elbow eats bend_r of it and
                 // what is left is straight, so pushing the hole out from the
                 // wall does not open the turn -- the turn is fixed at R20 -- it
                 // lengthens the straight run out of the conduit. 55 puts the
                 // stuss 15 mm further from the wall than corner_elbow.scad's 40,
                 // for a corner too tight to get a nut into and a cabinet that is
                 // not quite square. Both are echoed below.
panel_bite = 6;  // how far the screw wall moves INTO the conduit's envelope (mm).
                 // 0 is the conduit lying on the panel, which is the roomiest the
                 // corner can be. Raise it when the cabinet sits closer than that:
                 // the part gets that much shorter, the elbow's round floor is
                 // sliced away, and the panel plate becomes the channel's floor
                 // instead. The channel goes from round to D-shaped -- how much
                 // it costs is echoed below.

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

// The channel's floor is the cabinet's own back panel: nothing of ours is left
// under the cable. The round bore is simply cut off flat where the panel is.
// Nothing below builds from these; they are here to report what the bite costs.
channel_floor = panel_bite;                  // the cabinet's own back panel
floor_drop    = pipe_axis_z - channel_floor;            // floor below the conduit's axis
cut_into_bore = max(0, bore / 2 - floor_drop);          // how deep the flat eats the bore
flat_w        = cut_into_bore <= 0 ? 0
              : 2 * sqrt(pow(bore / 2, 2) - pow(floor_drop, 2));
seg_area      = cut_into_bore <= 0 ? 0
              : pow(bore / 2, 2) * acos(floor_drop / (bore / 2)) * PI / 180
                - floor_drop * flat_w / 2;
bore_area     = PI * pow(bore / 2, 2) - seg_area;

// How much of the nut's bearing ring the channel takes with it. The slot is
// flat_w wide where it crosses the bearing face, and the ring runs from the
// hole's edge out to the plate's. Integrating the slot's angular width over the
// ring's radius closes in one step:
//      integral of 2*r*asin(h/r) dr  =  r^2*asin(h/r) + h*sqrt(r^2 - h^2)
function ring_cut(h, r) = pow(r, 2) * asin(min(1, h / r)) * PI / 180
                        + h * sqrt(max(0, pow(r, 2) - pow(h, 2)));
ring_ri   = hole_diameter / 2;
ring_ro   = ring_ri + bearing;
ring_lost = (ring_cut(flat_w / 2, ring_ro) - ring_cut(flat_w / 2, ring_ri))
          / (PI * (pow(ring_ro, 2) - pow(ring_ri, 2)));

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
assert(bearing >= 6 && plate_t >= 5,
       str("the bearing ring is cut through here, so what is left has to make up for it in ",
           "width and thickness. bearing ", bearing, " / plate_t ", plate_t,
           " is below the 6 / 5 this part is sized for -- use corner_elbow.scad instead."));
//  "Nothing crosses the channel" has a topological form, and it is worth stating
//  because it is checkable: the finished solid should be GENUS 1, the single
//  handle being the stuss's own ring. A second handle means something closed
//  across the channel. Past a bite of about 7.7 mm one does -- the plate and the
//  elbow bridge just short of the hole, which you can see as a band of material
//  on the underside view and which the genus flips to 2 to tell you. Measured,
//  not derived, so the bound is empirical; corner_elbow.scad with open_floor is
//  the file for a deeper bite, since it is built to carry a bridge anyway.
assert(panel_bite <= 7.5,
       str("panel_bite ", panel_bite, " is past the 7.5 mm this part is verified to. Above it ",
           "the plate and the elbow close a bridge across the channel just short of the hole ",
           "-- the one thing this part exists to avoid. Use corner_elbow.scad with ",
           "open_floor = true for a deeper bite."));
assert(panel_bite < pipe_axis_z,
       str("panel_bite ", panel_bite, " cuts at or above the conduit's axis: the channel would be ",
           "a shallow trough with nothing to hold a cable in. Max is ", pipe_axis_z - 1, " mm."));
assert(pipe_axis_z + bore / 2 - channel_floor >= 20,
       str("panel_bite ", panel_bite, " leaves only ",
           mm1(pipe_axis_z + bore / 2 - channel_floor), " mm of channel above the panel."));

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
     : str("Channel: a D on the cabinet's own panel, clear end to end -- ",
           mm1(flat_w), " mm flat floor, ",
           mm1(pipe_axis_z + bore / 2 - channel_floor), " mm of headroom, ",
           mm1(100 * bore_area / (PI * pow(bore / 2, 2))), "% of a full Ø", bore, " bore"));
echo(str("Nothing crosses the channel. The nut bears on a C, Ø", hole_diameter, " -> Ø",
         hole_diameter + 2 * bearing, ", with ", mm1(flat_w), " mm of it cut away -- ",
         mm1(100 - 100 * ring_lost), "% of the ring's area left, on a ", plate_t,
         " mm plate (", mm1(pow(plate_t / 4, 3)), "x the bending stiffness of a 4 mm one)"));
echo(str("Tube clears the back panel by ", mm1(pipe_axis_z - tube_r),
         " mm; through the turn the cable rides between R", mm1(bend_r - bore / 2),
         " inside and R", mm1(bend_r + bore / 2), " outside"));
echo(str("Hole centre sits ", mm1(outlet_x), " mm from the side wall -- its near edge is ",
         mm1(outlet_x - hole_diameter / 2), " mm from the corner"));
echo(str("Panel plate overhangs the hole by ", bearing, " mm all round for the nut"));
echo(str("Neck: thread crest Ø ", neck_od, ", ", neck_length, " mm long (",
         stuss_depth, " mm inside the cabinet)"));
echo(str("Nut: Ø ", nut_od, " body, Ø ", 2 * nut_fin_r, " over the fins, ", nut_height, " mm tall"));

// ── Small helpers ───────────────────────────────────────────────────────────
function pol(r, a) = [r * cos(a), r * sin(a)];
function angdist(a, c) = abs(((a - c + 540) % 360) - 180);

// ============================================================================
//  THREAD  (ported verbatim from corrugated-pipe-bend/pipe_bend.scad)
// ============================================================================
function thread_r(a, r0, r1, w, w1) =
    let (b = min([for (i = [0 : thread_starts - 1]) angdist(a, i * 360 / thread_starts)]))
    b <= w1 / 2 ? r1
  : b >= w  / 2 ? r0
  : r1 + (r0 - r1) * (b - w1 / 2) / (w / 2 - w1 / 2);

module thread_section2d(r0, r1) {
    w = 180 / thread_starts;
    n = max(160, $fn);
    polygon([for (i = [0 : n - 1])
                let (a = i * 360 / n) pol(thread_r(a, r0, r1, w, w * 0.45), a)]);
}

module thread_solid(h, extra = 0) {
    turns = h / (thread_pitch * thread_starts);
    linear_extrude(height = h, twist = -360 * turns,
                   slices = max(24, ceil(turns * 96)), convexity = 8)
        thread_section2d(thread_root_r + extra, thread_crest_r + extra);
}

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
            // The plate, with the same bore taken out of it -- ring and all, so
            // nothing of ours is left under the cable. What the nut gets is a C,
            // not a ring: 89 % of the bearing area, tied across the gap by the
            // elbow's wall above and stiffened by the plate's own thickness.
            difference() {
                panel_plate();
                pipe(bore, x0 = -1);
            }
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
//  NUT  (the fin-grip nut from corrugated-pipe-bend)
// ============================================================================
module nut_profile2d() {
    R = nut_od / 2;
    if (nut_grip > 0)
        union() {
            circle(r = R);
            for (i = [0 : nut_lobes - 1])
                rotate([0, 0, i * 360 / nut_lobes])
                    hull() {
                        translate([R - 2, 0]) circle(d = nut_fin_w, $fn = 24);
                        translate([nut_fin_r - nut_fin_w / 2, 0]) circle(d = nut_fin_w, $fn = 24);
                    }
        }
    else
        difference() {
            circle(r = R);
            for (i = [0 : nut_lobes - 1])
                rotate([0, 0, i * 360 / nut_lobes]) translate([R + 2.2, 0]) circle(r = 4);
        }
}

module nut() {
    difference() {
        union() {
            linear_extrude(height = nut_height, convexity = 6) nut_profile2d();
            if (nut_flange > 0) {
                translate([0, 0, nut_height - nut_flange_t])
                    cylinder(h = nut_flange_t - 0.8, d1 = nut_od, d2 = nut_flange_od);
                translate([0, 0, nut_height - 0.8]) cylinder(h = 0.8, d = nut_flange_od);
            }
        }
        translate([0, 0, -1]) thread_solid(nut_height + 2, thread_clearance / 2);
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
