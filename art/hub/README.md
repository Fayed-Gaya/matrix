# Original Alpha 0.2 cabin artwork

These geometric pixel-art cabin tiles and provisional astronaut were authored
locally for Matrix with Codex, without external art inputs or paid generation.
They do not copy Pokémon artwork. Palette: navy/slate, teal lights, warm ivory
and coral. No Kate/Kobe personal references or artistic approvals are implied.

- `cabin-atlas.aseprite`: editable 128×128 atlas, sixteen 32×32 tiles.
- `cabin-player.aseprite`: editable 96×192 sheet; three 32px columns, down/right/up
  in rows 3/4/5 to preserve the current player animator. Left mirrors right.
- Matching SVGs retain the initial editable geometric construction. After
  editing Aseprite sources, exported PNGs are authoritative runtime images;
  SVGs do not automatically synchronize or regenerate.

Export each Aseprite sheet as PNG, at its original size, to
`hub/assets/alpha02/` for the atlas; the player sheet is shared at
`shared/actors/astronaut.png`. Do not trim, resize, rotate or
repack cells; nearest filtering preserves pixels. Commit the PNG `.import`
settings. Room composition is edited in Godot, not baked into the image.
`art/.gdignore` and export exclusions keep editable sources out of the game.
The unrelated user `art/Sprite.aseprite` was not used or modified.

On this Mac, Aseprite batch export succeeds but its installed PixelLab plugin
logs dialog errors in batch mode; GUI export avoids that plugin limitation.
No plugin configuration was changed. PixelLab tools were unavailable to this
session, and no generation/API charges were incurred.

## Hub refinement (2026-10-22)

`refinement/` contains six original geometric pixel-art sources, each with an
editable SVG construction and single-frame Aseprite file:

- `hull-atlas`: 128×32, four 32px architectural cells.
- `pod-open`, `pod-sealed`: 80×112 separate environmental sprites.
- `viewport`: 192×64 framed star field.
- `terminal`: 64×80 retro computer with a restrained M display.
- `wall-light`: 32×32 amber sconce, instanced twice.

The open pod's inset padding is empty; the other pod is entirely opaque.
No reference artwork or generated PixelLab output was used. Original sources
were authored as integer-coordinate SVG rectangles, rasterized without scaling
and imported into Aseprite. Aseprite sources are editable raster sprites; SVGs
retain independently editable shapes. Neither automatically synchronizes after
later edits. Export the Aseprite source using the existing explicit helper:

```sh
make art-export SOURCE=art/hub/refinement/pod-open.aseprite OUTPUT=hub/assets/refinement/pod-open.png
```

Repeat for the other five names. No trimming/repacking/resizing. Room architecture
is native TileMapLayer cells; props, markers and collision shapes are separate
scene nodes, never a generated room backdrop. The new assets reuse the existing
32px tile/player scale. Shared astronaut artwork remains unchanged.

PixelLab's enabled HTTP configuration exists, but **no PixelLab tools are exposed
to this running session**. Authentication/account settings were not changed;
credentials were not printed. An included/no-cost generation allowance could
not be verified, so no generation call or paid experiment was made. Generation
quality/consistency and AI-to-Aseprite cleanup savings remain unevaluated. The
original-art → Aseprite → Godot export/import path was tested separately.

## Current round 2 raster masters

`round2/` replaces the flat SVG construction method for the active hub. The eleven
`.aseprite` files each have **Shadow / Construction / Shading / Detail** layers.
They are single-frame masters, including the player's arranged animation sheet.
Native sizes: deck atlas 256×128 (32px cells), service bay 208×144, pods 80×112,
viewport 192×64, CRT 64×80, worktable 80×80, locker 64×56, sconce 32×32, light
64×64, player sheet 96×192. Player row/column layout remains compatible with the
existing shared animator; only the hub points at this new sheet.

These are original raster studies, created using locally authored pixel brushes,
polygon/ellipse masks, shading ramps and restrained texture, assembled through
Aseprite's Lua interface, then actually exported with the isolated helper:

```sh
make art-export SOURCE=art/hub/round2/pod-open.aseprite OUTPUT=hub/assets/round2/pod-open.png
```

Choose one file explicitly. Keep transparent canvas sizes, anchors and atlas
coordinates stable. Edit the four layers in Aseprite; do not overwrite masters
by rerunning the initial construction study. `seed_art.py` is retained for
provenance and reproducibility; its explicit `--reseed` replaces the original
studies. It is never part of game startup, editor import, build or map authoring.
It does not consume the previous PNG/SVG or any third-party artwork. Old sources
remain as history; SVGs are not authoritative for this new raster set.

No PixelLab or other AI image generation was used. Account allowance and tool
exposure remain unverified. Layer metadata and export success establish editability
and integration; they do not certify artistic quality. See the round-2 report
for strengths, remaining weaknesses and the human inputs with highest value.
