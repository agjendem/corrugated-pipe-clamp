// ============================================================================
//  Dimensioned drawing for corner_bend.scad
// ----------------------------------------------------------------------------
//  A flat elevation looking along the split plane. The outline is not redrawn
//  by hand -- it is projection(cut = true) through the real model at y = 0 --
//  and every number comes from the model's own derived values, so the drawing
//  cannot drift from the geometry. Render top-down / orthographic.
// ============================================================================

DIMENSIONS_ONLY = true;
include <corner_bend.scad>;

s    = max(1, body_len / 40);
ts   = 1.1  * s;
lh   = 1.8  * s;
lw   = 0.10 * s;
tick = 0.6  * s;

// ── The section ─────────────────────────────────────────────────────────────
//  rotate([-90,0,0]) lays the bend plane on the cutting plane and carries the
//  model's z into the drawing's y.
color("SteelBlue") projection(cut = true) rotate([-90, 0, 0]) body();

// The two surfaces the part is wedged between, ghosted.
color("Gainsboro") {
    translate([-hole_diameter, -plate_thickness])                     // back panel
        square([hole_diameter + outlet_x - hole_diameter / 2, plate_thickness]);
    translate([outlet_x + hole_diameter / 2, -plate_thickness])
        square([body_len + 8 * s - outlet_x - hole_diameter / 2, plate_thickness]);
    translate([-mount_flange_t - 6, 0]) square([6, body_h + 6 * s]);  // side wall
}
color("Bisque") translate([-mount_flange_t, pipe_axis_z - mount_flange_d / 2])
    square([mount_flange_t, mount_flange_d]);                          // the mount's flange

// ── Dimension helpers ───────────────────────────────────────────────────────
module hdim(x0, x1, y, label, below = false) {
    color("Black") {
        translate([min(x0, x1), y - lw / 2]) square([abs(x1 - x0), lw]);
        for (x = [x0, x1]) translate([x, y]) rotate(45) square(tick, center = true);
        translate([(x0 + x1) / 2, y + (below ? -1.4 * s : 0.4 * s)])
            text(label, size = ts, halign = "center");
    }
}
module vdim(y0, y1, x, label, left = false) {
    color("Black") {
        translate([x - lw / 2, min(y0, y1)]) square([lw, abs(y1 - y0)]);
        for (y = [y0, y1]) translate([x, y]) rotate(45) square(tick, center = true);
        translate([x + (left ? -0.5 * s : 0.5 * s), (y0 + y1) / 2])
            text(label, size = ts, valign = "center", halign = left ? "right" : "left");
    }
}

// ── The sizes that matter on site ───────────────────────────────────────────
x_L1 = -mount_flange_t -  9 * s;
x_L2 = -mount_flange_t - 20 * s;
y_B  = [for (i = [0 : 3]) -neck_length - (4 + 5 * i) * s];
x_R1 = body_len +  4 * s;

vdim(0, pipe_axis_z, x_L1, str("conduit axis ", pipe_axis_z), true);
vdim(-neck_length, -plate_thickness, x_L2, str("into cabinet ", stuss_depth), true);

hdim(outlet_x - hole_diameter / 2, outlet_x + hole_diameter / 2, y_B[0],
     str("hole Ø ", hole_diameter), true);
hdim(0, outlet_x, y_B[1], str("hole centre from the wall ", mm1(outlet_x)), true);
hdim(0, outlet_x - hole_diameter / 2, y_B[2],
     str("hole edge to the corner ", mm1(outlet_x - hole_diameter / 2)), true);
hdim(0, body_len, y_B[3], str("length ", mm1(body_len)), true);

vdim(0, body_h, x_R1, str("height ", mm1(body_h)));

hdim(-mount_flange_t, 0, body_h + 2.5 * s, str("glue joint ", mount_flange_t));
vdim(pipe_axis_z - inlet_bore / 2, pipe_axis_z + inlet_bore / 2, -mount_flange_t - 2.5 * s,
     str("Ø ", inlet_bore), true);

// ── Legend (auto-generated from the parameters) ─────────────────────────────
labels = [
    str("mount_flange_d = ", mount_flange_d, " mm   the face we glue to"),
    str("pipe_diameter  = ", pipe_diameter, " mm   -> axis sits ", pipe_axis_z, " mm off the panel"),
    str("inlet_bore     = ", inlet_bore, " mm   the conduit's usable bore"),
    str("outlet_bore    = ", outlet_bore, " mm"),
    "",
    str("Overall        = ", mm1(body_len), " long x ", mm1(body_h), " tall x ",
        mm1(body_w), " wide"),
    str("floor under the channel = ", mm1(floor_t), " mm"),
    str("bottom face overhangs the hole by ", mm1(bearing), " mm"),
    "",
    str("pipe recess    = Ø", pipe_diameter + pipe_recess_fit, " x ", pipe_recess,
        " deep in the glue face"),
    str("hole_diameter  = ", hole_diameter, " mm in the back panel"),
    str("  centre ", mm1(outlet_x), " mm from the side wall, edge ",
        mm1(outlet_x - hole_diameter / 2), " mm from the corner"),
    str("stuss_depth    = ", stuss_depth, " mm into the cabinet"),
    str("thread         = Ø", neck_od, " crest, pitch ", thread_pitch, ", ",
        mm1(thread_turns), " turns over ", neck_length, " mm"),
    str("nut            = Ø", nut_od, " body, Ø", 2 * nut_fin_r, " over fins, ",
        nut_height, " mm"),
    str("body           = Ø", inlet_od, " tube on a ", wall, " mm wall"),
    str("roof overhang  = ", mm1(roof_overhang), " deg from vertical, printed neck-down"),
    "",
    "The inside is a CHAMBER, not a tube: the conduit's axis sits only",
    str("its own radius (", pipe_axis_z, " mm) above the outlet plane, so a 90 deg arc"),
    str("would need a centreline radius of ", pipe_axis_z, " mm -- less than the"),
    "channel's own. The cable rides the outside of the turn instead."
];

color("Black")
    translate([body_len + 5 * s, -neck_length - 3 * s])
        for (i = [0 : len(labels) - 1])
            translate([0, -i * lh]) text(labels[i], size = ts, font = "Liberation Mono");
