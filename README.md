# Corrugated Pipe Clamp

A parametric, 3D-printable clamp that wraps **partially** around corrugated conduit
(electrical draw-in pipe). Internal circumferential ridges seat into the conduit's grooves
and **lock the pipe axially**, while a **flange** at one end is wider than the pipe so the
clamp + pipe cannot be pulled through a hole in a wall.

The whole model is defined in [`pipe_clamp.scad`](pipe_clamp.scad) using
[OpenSCAD](https://openscad.org/) — change the parameters at the top of the file and the
geometry updates automatically. All dimensions are in **millimetres**.

## Rendering example

Rendered with the default parameter values listed below (16 mm conduit → 18 mm bore,
200° coverage, 6 corrugations):

![Pipe clamp render](images/pipe_clamp.png)

This produces an arc covering ~200° of the pipe (open ~160° so it snaps on), with internal
circumferential grip ridges and a thin flange lip at one end. Resulting outer Ø ≈ 22 mm,
flange Ø ≈ 24 mm, length ≈ 18 mm.

## Parameters

| Parameter | Default | Meaning |
|---|---|---|
| `bore_diameter` | `18` | Inner bore over the conduit's corrugation crests (mm) |
| `corr_depth` | `1` | Radial depth the grip ridges protrude inward (→ grip Ø16) |
| `corr_width` | `1.5` | Width of each ridge along the pipe axis (mm) |
| `groove_width` | `1.5` | Width of each groove/recess along the pipe axis (mm) |
| `corr_count` | `6` | Number of corrugation periods → sets the length |
| `wall_thickness` | `2` | Solid material outside the bore, radial (→ outer Ø22) |
| `coverage_deg` | `200` | Degrees of the pipe circumference covered |
| `flange_overhang` | `3` | How far the flange extends beyond the pipe width (→ flange Ø24) |
| `flange_thickness` | `1` | Flange thickness along the pipe axis (mm) |

### Sizing logic

Corrugated conduit is often labelled by its nominal diameter (e.g. "16 mm"). Because the
crest and groove diameters differ, this model is parameterised by the **physical, printable
geometry** instead, to avoid ambiguity:

- `bore_diameter` is the bore over the conduit's **crests** (e.g. 18 mm).
- The clamp's grip ridges protrude inward by `corr_depth` and seat in the conduit's
  **grooves**, so the conduit's nominal/grip diameter ≈ `bore_diameter − 2·corr_depth`
  (here 18 − 2 = 16 mm).
- The wall is added outside the bore: outer Ø = `bore_diameter + 2·wall_thickness`.
- The flange extends `flange_overhang` mm beyond the pipe width:
  flange Ø = `bore_diameter + 2·flange_overhang`.
- Length = `corr_count · (corr_width + groove_width)` (always whole corrugation periods).

A coverage above 180° gives a snap-fit grip onto the pipe.

## Usage

Open `pipe_clamp.scad` in the OpenSCAD GUI to tweak parameters live (they appear in the
Customizer panel, grouped via `/* [Group] */` tags) and press **F5** to preview.

### Export an STL from the command line

```sh
openscad -o pipe_clamp.stl pipe_clamp.scad
```

### Re-render the README image

```sh
openscad -o images/pipe_clamp.png --imgsize=1000,1000 \
  --camera=0,0,9,55,0,25,95 --colorscheme=Tomorrow pipe_clamp.scad
```

## Requirements

- OpenSCAD (developed/verified with the 2026.04 snapshot/nightly build).
  - macOS: `brew install --cask openscad@snapshot`
