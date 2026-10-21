# Zelda — ZELDA

Arrows move; Space attacks; Ctrl casts; Q/E cycle weapons/magic. M toggles the
upgrade menu; arrows select a stat and Space purchases an affordable upgrade.
Escape closes upgrades first, then returns to Matrix. Progress is memory-only.

The port contains the source floor/map layers, sorted character/object drawing,
player and four enemy types, five weapons, flame/heal magic, destructible grass,
particles, damage/attack/switch cooldowns, contact AI, hit reaction, XP, five-stat
upgrade costs/caps, regeneration, HUD, original sprites/font/music/effects.
The source's initial half health, 80% energy, 5000 XP and stat tables are retained.
The source has **no player death/reset routine**; this port does not invent one.

Open `maps/world.tscn` directly in Godot. Paint Ground for scenery, and
map_FloorBlocks, map_Grass, map_Objects and map_Entities for collision and
population. Each has an external TileSet. Entity values 390–393 place the four
enemy species; 394 places the player. FloorBlocks are translucent editor guides.
Grass keeps the existing random visual variation at runtime. Objects retain
the original vertical offset, depth sorting and collision shrink rules.

The previous runtime drew `graphics/tilemap/ground.png` as one image; Ground now
references its exact 64×64 regions as individually paintable native cells.
No additional scenery was flattened. The unused CSV Floor/Details/LargeObjects
grids were not runtime layers and are not overlaid (which would change the art).
Paint beyond the old extent to expand the map, including negative coordinates.
The native scene is authoritative; save normally without regeneration.
`assets/manifest.json` retains only frame paths and weapon/magic/enemy tables.
Artwork, source images and attribution remain preserved; Python and the archive
are not runtime dependencies. Frozen fixtures are regression expectations only.

The archived launcher currently fails: `level.py` requests MAP_DIR from settings,
which does not expose it, and fallback imports then report a missing `level`.
The archive is untouched. Reference captures were rendered using only a transient
in-memory MAP_DIR binding, without editing the archived files.

Differences: fixed 60-tick updates, shared-window fitting and Escape return;
spatial buckets accelerate the same rectangular obstacles. Rendering uses current
model positions instead of the source's draw-before-update lag. Enemy attack
sound triggers on entering attack rather than restarting every frame. Pause-edge
cooldown expiry, particle/timer phasing, UI text/rasterization, randomness and
audio loops can differ. No full gameplay or pixel parity is claimed.

Checks cover map/population, collision, weapon damage and immunity, contact
immunity, healing/costs, five-flame casting, insufficient energy, grass clearing,
XP on defeat, upgrade scaling/caps, pause/Escape, cleanup and all earlier ports.
World and upgrade-menu captures were inspected and compared with the reference.
Manual full-map combat, every weapon/magic combination, audible effects and
other-platform exports remain necessary.
