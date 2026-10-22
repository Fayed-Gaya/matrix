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
axis-separated movement implementation. Bounds are 640×352. No runtime map
conversion, procedural room generator, extra rooms or additional interactions.
The hatch is scenery, not an exit. Native scenes/TileSets remain authoritative.

The original Alpha 0.2 art is under `assets/alpha02/`. Editable SVG/Aseprite
sources and export notes: `art/hub/README.md`. The old hub art/layout and frozen
fixture remain excluded under `archive/godot/`. This cabin is a first visual
iteration for owner refinement, not a claim of approved final art direction.

Validation covers movement normalization, boundaries, thin obstacles, input,
landmarks, collision rectangles, computer reachability, terminal input, all
active routes, hub return and window/camera resizing. Native resource checks
also edit/save/reload disposable scene copies. Human movement feel and artistic
acceptance remain manual. See `docs/releases/alpha-0.2-status.md` for evidence.
