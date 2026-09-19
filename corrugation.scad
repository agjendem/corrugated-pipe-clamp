// ============================================================================
//  corrugation.scad -- the conduit corrugation profile, shared
// ----------------------------------------------------------------------------
//  Every part here that touches a corrugated conduit needs the same two things:
//  a square-wave cross-section in the (radius, axial-z) plane, and the pair of
//  morphological passes that turn that square wave into the rounded, U-shaped
//  thing a real pipe actually is. It was written once in pipe_clamp.scad and is
//  needed again by snap_collar.scad -- and a fourth copy lives in the sibling
//  project corrugated-pipe-bend. One copy.
//
//  The wave always starts on a RECESS (the part's bore over a pipe crest) and
//  ends on a TOOTH (the part's bore seated in a pipe groove), so one period is
//  recess_w + tooth_w and a run of n periods spans n * (recess_w + tooth_w).
//
//      r_recess  ___        ___        ___
//               |   |      |   |      |   |        <- clears the pipe's crests
//      r_grip   |   |______|   |______|   |____    <- bites into its grooves
//               |<--->|<-->|
//               recess tooth
//                 _w    _w
//
//  A tooth may also taper. Give tip_w < tooth_w and it comes out a symmetric
//  trapezoid instead of a square rib, which is what a groove that narrows
//  towards its root -- a U, or near enough a V -- actually wants:
//
//      r_recess  ___         ___
//               |   |       |   |
//               |    \     /    \      <- flanks parallel to the groove's own
//      r_grip   |     |___|      |__    <- a flat of tip_w, not a knife edge
//                     |<->|
//                     tip_w
//
//  This is a library, not a part: it declares no parameters of its own, draws
//  nothing at the top level, and reads no globals -- everything arrives as an
//  argument. `include <corrugation.scad>` and call it.
//
//  All dimensions are in millimetres.
// ============================================================================

// ── The square wave ─────────────────────────────────────────────────────────
//  The inner (bore-side) edge of the section, from z0 upwards, as a point list
//  running in +z. It is open: the caller closes it along whatever outer wall it
//  happens to have -- a plain cylinder in pipe_clamp, a flange plus a skirt in
//  snap_collar -- which is exactly the part that is NOT shared.
//
//      r_recess   bore radius over a pipe crest (clearance, no contact)
//      r_grip     bore radius of a tooth, seated in a pipe groove
//      n          how many whole periods
//      recess_w   axial width of one recess = the pipe's crest width + play
//      tooth_w    axial width of one tooth AT ITS BASE, i.e. out at r_recess
//      z0         where the run starts along the axis
//      tip_w      axial width of the tooth AT ITS TIP, in at r_grip. Leave it
//                 undef (or equal to tooth_w) for the square tooth; anything
//                 less tapers the flanks -- see "Pointed teeth" below.
//
//  Note there is no explicit point at the top of the trailing flank: the next
//  period's opening [r_recess, ...] is that point, and the final flat closes the
//  last one. Which is why taper = 0 reproduces the square wave exactly, point
//  for point, rather than merely equivalently.
function corr_inner(r_recess, r_grip, n, recess_w, tooth_w, z0 = 0, tip_w = undef) =
    let (period = recess_w + tooth_w,
         taper  = (tooth_w - (is_undef(tip_w) ? tooth_w : tip_w)) / 2)
    concat(
        [ [r_recess, z0] ],                                   // flat at the start
        [ for (i = [0 : n - 1]) each [
            [r_recess, z0 + i * period],                      // recess start (over a crest)
            [r_recess, z0 + i * period + recess_w],           // recess end = tooth base
            [r_grip,   z0 + i * period + recess_w + taper],   // down the leading flank
            [r_grip,   z0 + (i + 1) * period - taper]         // across the tip
        ]],
        [ [r_recess, z0 + n * period] ]                       // flat at the far end
    );

// ── Pointed teeth ───────────────────────────────────────────────────────────
//  A square tooth assumes a square groove. Some conduit has one; plenty does
//  not. Measure a 20 mm pipe and the groove is a U tending towards a V -- about
//  1.0 mm across where it opens at the crest, a third of that at the root. A
//  square 1.0 mm tooth dropped into that lands on the flanks at the very top and
//  stops. It reads as a tooth and grips like a bump.
//
//  So don't reach for the root. Pick how deep to bite, ask the groove how wide
//  it is down there, and cut the tooth to that. The flanks then run parallel to
//  the groove's own and the tooth beds against both of them over its whole
//  depth, instead of pinching at one corner.
//
//  Linear interpolation along a flank: the width at radius r, given the width
//  measured at two radii. w_tip belongs to r_tip (deeper, narrower), w_base to
//  r_base (shallower, wider). Extrapolates happily past either end.
function corr_taper_width(r, r_tip, r_base, w_tip, w_base) =
    w_tip + (w_base - w_tip) * (r - r_tip) / (r_base - r_tip);

//  Two things to keep an eye on, and both have an assert waiting below or in the
//  caller. A tooth you sharpen is a rib you thin, and the opening pass erases
//  ribs -- so tip_w, not tooth_w, is what the fillet bound has to clear. And a
//  sloped load face is a wedge: pull on it and some fraction of the pull tries
//  to lift the tooth out of the groove, which is a thing the part around it now
//  has to resist.

// Total axial length of a corr_inner() run -- so callers never re-derive it.
function corr_length(n, recess_w, tooth_w) = n * (recess_w + tooth_w);

// ── The two fillets ─────────────────────────────────────────────────────────
//  Real conduit crests and valleys are rounded, not square, and the two corners
//  want different radii for different reasons, so they get independent passes:
//
//    - fillet_r ("closing", grow then shrink) fills the CONCAVE groove corners,
//      including the downward-facing tooth undersides. That is the overhang an
//      FDM printer finds hardest, so a larger radius here prints cleaner. A
//      closing cannot erode the thin teeth.
//    - round_r ("opening", shrink then grow) rounds the CONVEX tooth tips.
//      Applied SECOND so it also softens any tip the closing pass left sharp.
//
//  Each pair is a no-op at radius 0, so straight walls and flat ends are left
//  exactly as the caller drew them.
module corr_soften(round_r, fillet_r) {
    offset(r = round_r)  offset(r = -round_r)     // opening by round_r  (tips)
        offset(r = -fillet_r) offset(r = fillet_r)  // closing by fillet_r (grooves)
            children();
}

// ── Bounds on those fillets ─────────────────────────────────────────────────
//  Both parts assert the same four things; the reasons belong with the code
//  that does the filleting, not copied into each caller. Returns a list of
//  [ok, message] pairs so the caller can assert() them under its own names.
//
//  The two width bounds are NOT cosmetic. A closing of radius R seals any slot
//  narrower than 2R outright -- the dilation bridges it and the erosion cannot
//  reopen what is no longer a slot -- and an opening of radius R erases any rib
//  thinner than 2R the same way. At exactly half the width the operation is
//  critical and the result is whatever the arithmetic rounds to, so both bounds
//  stop short of it. CORR_FILLET_MAX is that margin, and it is the reason a
//  16 mm conduit's own 1.2 mm groove cannot take the 0.6 fillet our much wider
//  recesses are happy with.
CORR_FILLET_MAX = 0.45;

//  tip_w defaults to tooth_w, the square tooth, where base and tip are the same
//  rib. When the tooth tapers it is the TIP that has to survive the opening, so
//  that is the width the first bound is measured against.
function corr_fillet_checks(round_r, fillet_r, depth, recess_w, tooth_w,
                            tip_w = undef) =
    let (thinnest = min(tooth_w, is_undef(tip_w) ? tooth_w : tip_w)) [
    [ round_r  <= CORR_FILLET_MAX * min(recess_w, thinnest),
      str("corr_round ", round_r, " must be <= ", CORR_FILLET_MAX,
          " x min(tooth tip, recess) = ",
          CORR_FILLET_MAX * min(recess_w, thinnest),
          " -- above that the opening erases the tooth instead of rounding it") ],
    [ round_r  <= depth,
      str("corr_round ", round_r, " must be <= the tooth depth ", depth) ],
    [ fillet_r <= depth,
      str("groove_fillet ", fillet_r, " must be <= the tooth depth ", depth) ],
    [ fillet_r <= CORR_FILLET_MAX * recess_w,
      str("groove_fillet ", fillet_r, " must be <= ", CORR_FILLET_MAX,
          " x recess = ", CORR_FILLET_MAX * recess_w,
          " -- above that the closing seals the recess instead of filleting it") ]
];
