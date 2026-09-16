// ============================================================================
//  brim.scad -- countersunk screw holes in a flange, shared
// ----------------------------------------------------------------------------
//  Both parts here end in a flange that lies flat against something: pipe_clamp
//  against the wall its body passes through, snap_collar against the inside of
//  the cabinet panel. Widen that flange a little and put countersunk holes in
//  it and the same part anchors to a TIMBER STUD instead -- which changes what
//  it can do, not just how it is held:
//
//    held by a hole   the pipe is stopped from travelling OUTWARD only. Inward
//                     is harmless, so nothing has to latch. (See snap_collar.)
//    held by screws   the pipe is stopped BOTH ways, and the part no longer
//                     depends on the hole being any particular size.
//
//  WHICH FACE THE HEAD SITS ON is a property of how the part is fitted, and the
//  two parts here are fitted opposite ways round, so it is an argument:
//
//    head_at_body = false     head on z = 0, the flange's outer face. The body
//                             points into the hole, the flange lies on the near
//                             side of what it is screwed to. (pipe_clamp.)
//
//         z=0  ___                 ___     <- head flush here
//              \  \               /  /
//               \  \_____________/  /      <- 90 deg countersink
//                \                 /
//         z=t     -----------------        <- bears here, on the stud
//
//    head_at_body = true      head on z = t, the face the body rises from. The
//                             flange lies on the stud the OTHER way up, with the
//                             body pointing back at you. (snap_collar.)
//
//         z=0     -----------------        <- bears here, on the stud
//                /                 \
//               /  /-------------\  \
//              /  /               \  \
//         z=t  ---                 ---     <- head flush here
//
//  Sized for a 3.5 mm drywall screw (gipsskrue): Ø4.0 clearance, Ø8.0 bugle
//  head. A 90 deg cone is a good enough seat for a bugle head.
//
//  This is a library, not a part: no parameters of its own, nothing drawn at the
//  top level, everything passed as an argument.
//
//  All dimensions are in millimetres.
// ============================================================================

// How deep the cone has to be to swallow the head. With head 8, shank 4 and a
// 90 deg cone this is exactly 2 mm -- which is a whole 2 mm flange, and that is
// fine: a countersunk hole in thin material has no flat land under the head, the
// cone IS the bearing surface. What it does mean is that the outermost ring of
// the brim is a wedge rather than a plate, so it wants perimeters rather than
// infill, and a screw driven too hard will split it outward.
function brim_cs_depth(head_d, shank_d, cs_angle) =
    (head_d - shank_d) / 2 / tan(cs_angle / 2);

// Where the screws sit, in degrees from the middle of the material. One screw
// goes dead centre -- on a C that is the point opposite the mouth, the thickest
// and best-supported part of the arc. Two go one to each side. More spread
// evenly across the same span.
function brim_screw_angles(count, spread) =
    count <= 0 ? [] :
    count == 1 ? [0] :
    [for (i = [0 : count - 1]) -spread + i * (2 * spread / (count - 1))];

// The cuts. `t` is the flange thickness; the through hole is drawn generously
// past both faces, and the cone is extrapolated past z = 0 at its own angle so
// the countersink keeps exactly cs_angle right up to the surface.
// The holes with the head on z = 0, before any flipping.
module brim_screw_cuts_local(count, pcd, spread, shank_d, head_d, cs_angle, t) {
    for (a = brim_screw_angles(count, spread))
        rotate([0, 0, a]) translate([pcd / 2, 0, 0]) {
            translate([0, 0, -1]) cylinder(h = t + 2, d = shank_d);
            translate([0, 0, -1])
                cylinder(h = brim_cs_depth(head_d, shank_d, cs_angle) + 1,
                         d1 = head_d + 2 * tan(cs_angle / 2), d2 = shank_d);
        }
}

module brim_screw_cuts(count, pcd, spread, shank_d, head_d, cs_angle, t,
                       head_at_body = false) {
    if (count > 0) {
        // Reflected in the flange's mid-plane to put the head on the far face.
        // The through hole is symmetric, so in practice only the cone moves.
        if (head_at_body)
            translate([0, 0, t]) mirror([0, 0, 1])
                brim_screw_cuts_local(count, pcd, spread, shank_d, head_d,
                                      cs_angle, t);
        else
            brim_screw_cuts_local(count, pcd, spread, shank_d, head_d,
                                  cs_angle, t);
    }
}

// Returns [ok, message] pairs so the caller can assert() them under its own
// names. `r_body` is whatever the flange stands on -- the clamp body, the skirt
// -- and `r_brim` the flange's own outer radius. `arc` is the half-angle of
// material available, i.e. coverage_deg / 2, or 180 for a full ring.
function brim_checks(count, pcd, spread, shank_d, head_d, cs_angle, t,
                     r_body, r_brim, arc, margin = 0.8) =
    count <= 0 ? [] : [
    [ head_d > shank_d,
      str("screw_head_d ", head_d, " must be bigger than screw_d ", shank_d) ],
    [ brim_cs_depth(head_d, shank_d, cs_angle) <= t,
      str("the countersink is ", brim_cs_depth(head_d, shank_d, cs_angle),
          " mm deep but the flange is only ", t,
          " -- it would break through wider than the shank. Thicken the flange, ",
          "shrink screw_head_d, or open screw_cs_angle") ],
    [ pcd / 2 - head_d / 2 >= r_body + margin,
      str("the screw head reaches in to r ", pcd / 2 - head_d / 2,
          ", but the body is out at r ", r_body, ". Raise screw_pcd to at least ",
          2 * (r_body + margin + head_d / 2)) ],
    [ pcd / 2 + head_d / 2 <= r_brim - margin,
      str("the screw head reaches out to r ", pcd / 2 + head_d / 2,
          ", past the brim edge at r ", r_brim,
          ". Widen the flange to at least Ø", 2 * (pcd / 2 + head_d / 2 + margin)) ],
    [ count == 1 || spread + asin(min(1, head_d / pcd)) <= arc,
      str("a screw at ", spread, " deg plus its head's ",
          asin(min(1, head_d / pcd)), " deg runs off the end of the ", arc,
          " deg of material. Lower screw_spread") ]
];
