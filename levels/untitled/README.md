# Untitled — UNTITLED

Space/Enter leaves the forest opening. WASD/arrows move; E toggles the nearby
NPC's dialogue. Escape first closes dialogue, otherwise returns to Matrix.
The source intro map, player/NPC sheets, opening art and forest ambience are
preserved. The dialogue text is read from the original map property.

The source has exploration, rectangular collision, camera bounds and one NPC
interaction. It does not implement combat, quests, or map transitions; optional
Tiled layer names are authoring conventions, not missing ported gameplay.

Map source: `assets/maps/untitled-intro.tmx`, copied from the archived level with
its shared tileset path redirected to a local copy in `assets/tilesets/`. Run
`make untitled-map` after editing it. Runtime uses generated native TileMapLayers,
not Python/TMX parsing. The converter now accepts map/spawn/output/world-script
options while preserving its hub defaults. Runtime files/assets are independent
of the archive and hub. No new asset attribution or ownership claim is made.

Preserved: 800×800 map, original visible tile cells/layer order, eleven rounded
collision rectangles, (454,423) spawn, (392,448) NPC, 16×16 hitbox, normalized
260-unit motion, directional animation, 960×540 camera, NPC proximity and
movement lock, dialogue wrapping/toggling, opening input, looping ambience at
35% volume. Camera X stays at zero when the map is narrower than the viewport,
matching the original's unused right-hand space.

Differences: logical window scales to fit the shared display; smoother floating
movement/substeps replace per-frame rounded displacement; fonts, shadows and
rasterization can differ; Escape leaves the level instead of the application.
Optional map interactions/transitions remain unimplemented as in the source.

Checks compare every tile/collision rectangle to TMX, verify spawn/NPC, opening,
ambience state, E dialogue, movement lock, Escape's close-then-return behavior,
and cleanup. Audible playback, full-map navigation and cross-platform exports
remain manual checks; no full gameplay/pixel parity is claimed.
