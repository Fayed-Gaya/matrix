# Bubby — provisional Alpha 0.2 slice

Terminal code **BUBBY**; ZELDA is not an alias. Move with WASD/arrows, E interacts
with doors/table/envelope, Space shoos the pigeon, Escape closes dialogue first
or returns to Matrix. This slice has two native rooms and no XP/upgrades.

Read the table if desired, go outside through the bottom-right door, approach
the pigeon and shoo it three times (short cooldown). Contact reduces composure;
at zero you restart inside, with a fresh encounter. The pigeon leaves unharmed.
Collect the envelope with E, return through the house door at bottom-left and
bring it to the table. A short placeholder ending completes the objective.
You may continue exploring or return to the pegasus. Nothing is saved.

**Provisional:** apartment/outdoor layout, narrative, delivery objective and
pigeon design are fictional implementation stand-ins. They do not describe
Kate's actual home, appearance, routines or experiences. Personal references,
emotional narrative, artistic acceptance and final enemy interpretation await
owner input. The reused tutorial avatar is visibly provisional, not Kate.

## Authoring and preservation

Open `maps/apartment.tscn` or `maps/outside.tscn`. Paint Ground/Details using the
external `.tres` TileSets. Move PlayerSpawn/PigeonSpawn, resize Exit/Table/Envelope
ReferenceRects and edit CollisionShape2D rectangles. Scenes are authoritative;
there is no runtime map conversion. `room.gd` reads native markers and geometry.
`player.gd` adapts the Zelda exploration/animation foundation with substeps and
scaled source frames; the room owns each player/bird tree. `bubby.gd` owns the
short objective, lightweight encounter and retry state. No shared RPG framework.

The complete original Zelda module and frozen checks remain under `source/`,
excluded by `.gdignore` and the web preset. Paths inside that historical source
are preserved, not rewritten into a second running game. The pinned original
suite remains available through `make archived-godot-check`.

Copied avatar frames/music retain their existing unresolved tutorial asset/code
provenance and notices; no new permission or license clearance is claimed.
Original provisional environment/pigeon source: `art/bubby/`; runtime PNGs here.
`assets/manifest.json` includes only active avatar frame dependencies.

Targeted validation checks full delivery progression, code/alias policy,
blocked pickup, shoo cooldown, contact/retry, dialogue and pegasus return, plus native
scene edit/save/reload. Headless checks do not establish human gameplay feel,
audio quality, personal meaning, art approval or mobile usability.
