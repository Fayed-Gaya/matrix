# Matrix spaceship cabin

Press any key at the opening. Move with WASD/arrows. The computer is on the
upper-right desk: stand in front and press E when prompted. Type a code and
Enter; Backspace edits, Escape closes. Returning from a level preserves your
hub position and skips the opening. Codes ignore surrounding space and case.

Current codes: BOUNCE, BALLS, BUG, YOU, BUBBY, BUSBOY, MACHINE. PONG/JUMP/MARIO/MONSTERS are archived, not public aliases.

## Native editing

Open `world.tscn` in Godot. Paint Ground/Details/Above TileMapLayers with the
external `tileset.tres`. Move PlayerSpawn and resize Terminal's approach area.
Edit RectangleShape2D children under Collisions; these are read by the existing
axis-separated movement implementation. Bounds are 512×320. No runtime map
conversion, procedural room generator, extra rooms or additional interactions.
The open/empty chamber and opaque sealed chamber are scenery, not interactions. Native scenes/TileSets remain authoritative.

The refined cabin uses `assets/refinement/`: a four-cell hull atlas and separate
open pod, sealed pod, star viewport, computer and amber wall-light sprites.
Move these named Sprite2D nodes directly in Godot; their collision shapes are
separate named children under Collisions. Keep sprite footprints and shapes aligned.
The original Alpha 0.2 draft art remains under `assets/alpha02/`. Editable SVG/Aseprite
sources and export notes: `art/hub/README.md`. The old hub art/layout and frozen
fixture remain excluded under `archive/godot/`. This cabin is a first visual
iteration for owner refinement, not a claim of approved final art direction.

Validation covers movement normalization, boundaries, thin obstacles, input,
landmarks, collision rectangles, computer reachability, terminal input, all
active routes, hub return and window/camera resizing. Native resource checks
also edit/save/reload disposable scene copies. Human movement feel and artistic
acceptance remain manual. See `docs/releases/alpha-0.2-status.md` for evidence.

Hub walking is 182 px/s (30% below the previous 260), configured only in
`player.gd`. Shared actors and other levels keep their own speeds. The cabin
uses integer 2× rendering where the full room fits, 1× on smaller windows and
landscape phones, and a clamped camera only below native room size.

The terminal draws a bounded panel over the cabin. Keyboard codes still work;
mobile destination hit areas share `HubOverlay.code_rect()` with its layout.
No identity or story is assigned to the sealed chamber occupant.
