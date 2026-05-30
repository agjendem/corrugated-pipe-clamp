# Corrugated Pipe Clamp

A parametric, 3D-printable clamp that wraps **partially** around corrugated conduit
(electrical draw-in pipe). Internal circumferential teeth bite into the conduit's grooves
and **lock the pipe axially**, while a **flange** at one end is wider than the pipe so the
clamp + pipe cannot be pulled through a hole in a wall.

The whole model is defined in [`pipe_clamp.scad`](pipe_clamp.scad) using
[OpenSCAD](https://openscad.org/) — change the parameters at the top of the file and the
geometry updates automatically. All dimensions are in **millimetres**.

## Rendering example

Rendered with the default parameter values listed below (16 mm conduit, 18 mm wall hole,
200° coverage, 6 corrugations):

![Pipe clamp render](images/pipe_clamp.png)

This produces an arc covering ~200° of the pipe (open ~160° so it snaps on), with internal
circumferential grip teeth and a flange lip at one end. Computed result:

```
Available material (radial): 1 mm
Clamp body outer Ø: 18 mm     (= bore_diameter)
Flange Ø: 22 mm               (= pipe_diameter + 2·flange_overhang)
Length: 18 mm
```

## Parameters

| Parameter | Default | Meaning |
|---|---|---|
| `pipe_diameter` | `16` | Outer (crest) diameter of the corrugated conduit (mm) |
| `bore_diameter` | `18` | Hole the clamp passes through = clamp body outer Ø (mm) |
| `corr_depth` | `1` | How far the grip teeth bite into the conduit grooves (mm) |
| `corr_width` | `1.5` | Width of each grip tooth along the pipe axis (mm) |
| `groove_width` | `1.5` | Width of each recess (over a crest) along the axis (mm) |
| `corr_count` | `6` | Number of corrugation periods → sets the length |
| `coverage_deg` | `200` | Degrees of the pipe circumference covered |
| `flange_overhang` | `3` | How far the flange extends beyond the pipe width (mm) |
| `flange_thickness` | `1` | Flange thickness along the pipe axis (mm) |

### Sizing logic

You give the two diameters and the rest is **derived**:

- `pipe_diameter` is the conduit's outer (crest) diameter (e.g. 16 mm).
- `bore_diameter` is the hole the clamp must fit through — i.e. the clamp body's **outer
  diameter** (e.g. 18 mm).
- **Available material** (the smooth backing wall over the crests) =
  `(bore_diameter − pipe_diameter) / 2` (here 1 mm radial).
- The grip teeth bite an additional `corr_depth` into the conduit's grooves, so the part is
  thicker at the teeth and thinnest (= available material) at the recesses.
- Flange Ø = `pipe_diameter + 2·flange_overhang` (here 22 mm) — catches on the wall hole.
- Length = `corr_count · (corr_width + groove_width)` (always whole corrugation periods).

`bore_diameter` must be larger than `pipe_diameter` (asserted in the model). A coverage
above 180° gives a snap-fit grip onto the pipe.

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
