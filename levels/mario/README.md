# Mario — MARIO

Overworld: Left/Right selects an unlocked node; Space enters it after the short
input delay. In a stage, Left/Right moves and Space jumps (held jumping repeats
on landing). Escape returns to Matrix. All progress is in memory for this visit.

## Source systems ported

- Six overworld nodes, animated available/black locked art, paths and moving hat
  icon. Nodes 0–2 start unlocked; nodes 3–5 reuse source map dataset 2. Winning
  raises the maximum unlocked node. Falling returns without clearing health.
- All three source CSV datasets, tile atlas/grass/crates/palm layers, coin and
  enemy/constraint/player/goal placements. Every manifest CSV cell was compared
  with the archived data. Placement now comes from native Godot scenes.
- Source motion constants: 8-pixel horizontal step, +0.8 gravity, -16 jump,
  50-pixel collision width, integer vertical position, axis-separated collision,
  ground/ceiling handling and quarter-screen horizontal scrolling. Right takes
  priority if both movement keys are held, as in the source.
- Animated player/coins/palms/enemies, random enemy speeds 3–5, constraint-based
  reversal, stomping/bounce/explosions, contact damage of 10, 0.5-second damage
  immunity/flicker, coin values 5/1, and health/coin HUD.
- Jump/landing/run dust, clouds, sky, overworld palms, water, hat goal, source UI
  and fonts, level/overworld music and jump/hit/coin/stomp effects. Health loss
  resets health to 100, coins to zero, unlocks to node 0 and returns to overworld.

## Native map editing

Open `maps/stage_0.tscn`, `stage_1.tscn` or `stage_2.tscn` in Godot.
Select a TileMapLayer and paint with its external TileSet palette. Terrain and
grass use the original complete sheet; other layers place animated actors,
coins, crates, palms, enemy constraints, and player/goal cells. Player palette
value 0 is spawn; 1 is the goal. Constraints are translucent red editor guides.
Actor palette images preview a frame; runtime retains the existing animations,
random enemy speeds, collision boxes and draw order. Changing a placement tile
changes the runtime population; no CSV or generation command is involved.

Paint beyond current bounds to extend the map, including negative coordinates.
World.grid_size preserves the original empty extent; painted cells expand it.
Nodes 3–5 still reuse stage_2. The overworld's six nodes and random scenery are
procedural gameplay rather than tile maps. `assets/manifest.json` now contains
only frame paths. Source artwork and attribution remain preserved.

Native cells feed the original gameplay algorithms. Static terrain/grass also
render directly from their native TileSet regions. `make check` compares all
baseline placements, tests native paint/erase/save/reload and gameplay behavior.
Intentional content edits require corresponding baseline expectations updated.

## Differences and limits

This is a GDScript/Rect2 platformer with its own renderer, not a shared RPG mode.
World coordinates and a camera replace shifting every sprite's coordinates.
The source's moving-icon detection zone is replaced by an exact arrival at each
node. Updates use fixed 60-tick physics; rendering is synchronized to current
collision positions rather than retaining the tutorial's render/update lag.

The logical 1200×704 field fits the shared resizable window, with a return hint.
Frame files are ordered by filename instead of filesystem enumeration. Particle
placement/phasing, fonts, clipping/rasterization, audio loops, random scenery and
input timing can differ. No full pixel or gameplay-feel parity is claimed.

Checks load all six node entries/three datasets, exercise movement/landing/jump,
coin collection, damage immunity, stomping, actual goal/unlock, scrolling,
fall-return, game-over reset and hub/audio cleanup. Real Compatibility-window
captures cover overworld/stage rendering and were compared with fresh archived
Pygame renders. That review caught temporary static textures being released
before drawing; explicit caching fixed the white scenery/UI and missing items. Full platforming routes, all enemy
contacts, particle/animation timing, audible mixing, and exports still require
manual playtesting. The untouched archive remains the comparison reference.
