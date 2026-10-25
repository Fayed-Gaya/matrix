# Pegasus spaceship cabin

Press any key at the opening. Move with WASD/arrows. The computer is on the
upper-right desk: stand in front and press E when prompted. Type a code and
Enter; Backspace edits, Escape closes. Returning from a level preserves your
Pegasus position and skips the opening. Codes ignore surrounding space and case.

Current codes: BOUNCE, BALLS, BUG, YOU, BUBBY, BUSBOY, SIMULATION. PONG/JUMP/MARIO/MONSTERS are archived, not public aliases.

## Native editing

Open `world.tscn` in Godot. Paint Ground/Details/Above TileMapLayers with the
external `tileset.tres`. Move PlayerSpawn and resize Terminal's approach area.
Edit RectangleShape2D children under Collisions; these are read by the existing
axis-separated movement implementation. Bounds are 512×320. No runtime map
conversion, procedural room generator, extra rooms or additional interactions.
The open/empty chamber and opaque sealed chamber are scenery, not interactions. Native scenes/TileSets remain authoritative.

The current cabin uses `assets/art/pegasus/round2/`: a native deck/hull atlas, layered pod
art, service bay, framed viewport, CRT, worktable, storage and Pegasus-only avatar.
Three static PointLight2D nodes add restrained amber/teal light.
Props use native y-sorting with their position anchored at floor level and
negative Sprite2D offsets, so the player passes naturally behind their tops.
Move these named Sprite2D nodes directly in Godot; their collision shapes are
separate named children under Collisions. Keep sprite footprints and shapes aligned.
Previous drafts remain under `assets/art/pegasus/alpha02/` and `assets/art/pegasus/refinement/`. Editable raster/Aseprite
sources and export notes: `assets/art/source/pegasus/README.md`. The old spaceship art/layout and frozen
fixture remain excluded under `archive/godot/`. This cabin is a first visual
iteration for owner refinement, not a claim of approved final art direction.

Optional `make regression-check` covers movement normalization, boundaries, thin obstacles, input,
landmarks, collision rectangles, computer reachability, terminal input, all
active routes, Pegasus return and window/camera resizing. Native resource checks
also edit/save/reload disposable scene copies. Human movement feel and artistic
acceptance remain manual. See `docs/releases/alpha-0.2.md` for evidence.

Pegasus walking is 182 px/s (30% below the previous 260), configured only in
`player.gd`. Shared actors and other levels keep their own speeds. The cabin
uses integer 2× rendering where the full room fits, 1× on smaller windows and
landscape phones, and a clamped camera only below native room size.

The terminal reveals no directory or destination names. Keyboard codes still work.
`web_terminal.gd` owns a real browser input/form (including text editing, paste and
OS keyboard focus via a user tap); no code registry is copied into HTML. Its
layout follows visualViewport for keyboard space and removes focus on close.
Native touch uses an actual LineEdit with virtual keyboard enabled.
Native terminal typography requests the installed Menlo/DejaVu/Liberation mono
family; browsers use CSS monospace. No new font asset is bundled.
No identity or story is assigned to the sealed chamber occupant.
