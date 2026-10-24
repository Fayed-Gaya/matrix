# Busboy — provisional Alpha 0.2 introduction

Terminal **BUSBOY** replaces UNTITLED; there is no old public alias. Space/Enter
leaves the forest opening. WASD/arrows move, E interacts, Escape closes dialogue
or retreats from battle first; otherwise it returns to Matrix.

Leave the starting room through the bottom-right door. In the forest, talk to
the blue waykeeper, then approach the purple corrupted roots on the east path.
Press E to begin one turn-based encounter. Choose with 1/2/3 or the buttons:

- Strike deals 4 damage.
- Guard halves the next enemy attack and restores 1 mana.
- Cleanse costs 2 mana, deals 6 damage and leaves a visible magic stain.

The enemy telegraphs gathering, heavy lash and thorn jab. Actions resolve one
turn at a time. Insufficient mana does not waste a turn. Stain increases enemy
damage slightly. Retreat starts the next attempt fresh. Defeat returns safely
to the starting room; the waykeeper's advice remains. Victory clears the actual
gate collision. Cross to the shrine and press E to finish this intro.

## Direction and limitations

The cursed forest, corrupting magic and future Earth/Fire/Blood regions retain
the planning vision. This slice does not implement three regions or bosses.
New story, root enemy, props and room/forest arrangement are explicit drafts,
not Kobe-approved preferences. No identified Kobe source art was available in
this session. Existing sprites/forest tiles/opening/ambience are reused and
preserved without inventing authorship or claiming permission clearance.

## Native authoring and architecture

Open `maps/cabin.tscn` or `maps/forest.tscn`. Ground/Path/Details/Above and
Corruption use the external `tileset.tres`; layers use 2× scale for the retained
16px atlas. Place sprites/props and resize native collision/interaction regions.
Edit NPCs/Waykeeper dialogue metadata directly. PlayerSpawn, Exit, Encounter,
Shrine, Guardian and named gate shapes are runtime contracts; preserve names.
Scenes are authoritative; no TMX/CSV/runtime conversion.

`room.gd` extends Untitled's native geometry/NPC reader. `player.gd` retains its
normalized substep collision and directional animation (160 logical units/s;
sprite drawn at 2× for readability). `busboy.gd` owns the intro state/camera and
room transitions. `encounter.gd` is a small typed turn model inspired by the
archived Monsters action flow, without its party/asset framework. `overlay.gd`
provides dialogue and keyboard/mouse battle controls. No persistent progress.

The original Untitled module/assets/native scene/checks remain intact under
excluded `source/`; use the pinned `make archived-godot-check` for the original
suite. Optional `make regression-check` exercises the complete draft introduction and resource
editing. Human full-path navigation, combat balance, audible ambience, creative
acceptance and real-device usability remain unverified.
