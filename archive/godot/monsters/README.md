# Monsters — MONSTERS

Arrows move; Space talks/advances dialogue and selects battle choices. Enter
opens/closes the party index; Space marks a monster, then swaps it with the
selected entry. Battle menus use arrows, Space and Escape to go back. Escape
closes overlays first, then returns to Matrix. No progress is saved.

The independent module includes eight maps, six world transitions, animated
water/coasts, rectangular collision and Y sorting, trainer sight/approach and
dialogue, nurses, grass encounters, seven starting party members, party ordering,
three-versus-three initiative battles, attacks/elements/defense, switching,
capture, reserves, XP/leveling, evolution, music and effects. Source stat tables,
abilities, trainers, initial positions and controls are retained. Capture uses
the source's strict below-90%-health rule, without invented random odds.

## Native map editing

Open any of the eight `maps/*.tscn` scenes directly in Godot. Paint Terrain and
Terrain Top with the shared external `maps/terrain.tres` palette. All existing
atlas cutouts remain available, including source transformations already baked
into their preserved image cutouts. Native cell painting/erasing immediately
controls runtime terrain; no manifest regeneration or Tiled is involved.

Expand Groups to edit Objects, Collisions, Entities, Monsters encounter regions,
Transition rectangles, Water and Coast. Select/move/duplicate a native rectangle;
resize with the 2D handles or object_size. Inspect object_name, image_id and
properties for behavior. Entities use Player + pos/direction for named spawns;
trainers retain character_id/graphic/radius. Transitions use target/pos. Coast
retains terrain/side and encounters retain biome/monster levels/species.
Positions and sizes come from the scene; never edit a JSON map grid.

Editor previews show static sprite/water/coast frames with region outlines.
Runtime keeps the existing animation, depth sorting, special top-object order,
entity hitboxes, trainer behavior and battles. No shapes were simplified.
Paint beyond the old grid to extend terrain, including negative coordinates.
World.grid_size preserves empty map extent. Save normally.

The manifest now contains non-map image/frame/audio/stat/trainer/battle data.
792 deduplicated images (including transformed tiles and source color-keyed
cutouts) remain in five preserved atlas pages alongside original source art.
Godot rejects the source ADPCM explosion WAV; a PCM16 runtime conversion is used,
with the untouched original retained in `source/audio/`. Original project notes
credit Scarloxy for artwork and OpenGameArt sources for sounds; the original
README and attribution context remain in `legacy/pygame/levels/monsters/`.

Source limitations: the archived package fails to import because its settings
no longer export `pygame`. Reference captures used a temporary in-memory binding,
without editing the archive. The unused arena map references undefined trainers
`t3`, `t4`, `t6`; its seven affected NPC instances show an unavailable-content
dialogue, rather than inventing teams. No world transition leads to that arena.
The source hospital2 nurse lacks direction/radius properties; native loading uses
the existing Nurse defaults.

Differences: fixed 60-tick updates and shared-window fitting; menu layout/font
metrics and effect/timer phasing differ. Multiple ready monsters receive turns
in order rather than overwriting the active source selection. Empty attack or
switch lists are handled safely. Loss leaves a message with Escape return rather
than terminating the application. Multiple evolutions play sequentially instead
of overwriting the source animation; the visual transition uses a crossfade and
the original stars rather than the source white-mask effect. Source exact-level
evolution thresholds, replacement stat reset and single-level XP award behavior
are retained. No full gameplay/pixel/audio parity is claimed.

Checks cover every map/spawn/transition target, real transition fading, collision
and trainer visibility/approach, grass encounter timing, nurse healing, party
swaps, strict ability costs, elemental/defense formulas, initiative, defense,
switch/capture, reserve replacement, XP, victory/evolution and hub cleanup.
The full regression pipeline passed. Compatibility-window world, battle, index
and evolution captures were inspected; world/battle were compared with archived
renders. Long playthroughs, all species/attacks/trainers, audible mixing and
other-platform exports still require manual testing.
