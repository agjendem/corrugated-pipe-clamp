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
//      tooth_w    axial width of one tooth  = fits inside the pipe's groove
//      z0         where the run starts along the axis
function corr_inner(r_recess, r_grip, n, recess_w, tooth_w, z0 = 0) =
    let (period = recess_w + tooth_w)
    concat(
        [ [r_recess, z0] ],                                   // flat at the start
        [ for (i = [0 : n - 1]) each [
            [r_recess, z0 + i * period],                      // recess start (over a crest)
            [r_recess, z0 + i * period + recess_w],           // recess end
            [r_grip,   z0 + i * period + recess_w],           // step in to grip tooth
            [r_grip,   z0 + (i + 1) * period]                 // tooth end / next start
        ]],
        [ [r_recess, z0 + n * period] ]                       // flat at the far end
    );

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

function corr_fillet_checks(round_r, fillet_r, depth, recess_w, tooth_w) = [
    [ round_r  <= CORR_FILLET_MAX * min(recess_w, tooth_w),
      str("corr_round ", round_r, " must be <= ", CORR_FILLET_MAX,
          " x min(tooth, recess) = ",
          CORR_FILLET_MAX * min(recess_w, tooth_w),
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
