# Bubby — the Grand Coo

Terminal **BUBBY**, no ZELDA alias. WASD/arrows move, E/Use interacts, Space/Shoo
shoos. Escape closes dialogue first, then returns to Matrix. Touch retains
independent movement and action fingers; Matrix returns immediately.

Explore the provisional apartment and optionally read the notebook. The glass
doors at the right lead onto the balcony (approach their lower edge). The small
pigeons scatter. One rather grand pigeon remains. Dismiss the introduction:
step away from its **locked landing circle**, then approach within 86 pixels
and shoo during **SHOO WINDOW**. Six successful shoos convince it to relocate,
unharmed. Composure has five points; landing hits have a grace period. At zero,
continue to retry immediately on the balcony, fully refreshed. Stepping inside
also resets an unfinished encounter. Victory clears the mess and gives a short
ending; re-entry retains victory for this visit. Nothing is saved.

The envelope/table delivery errand has been replaced. The notebook is optional
flavor, not a required pickup or invented personal memory. There is no XP,
inventory, equipment or shared RPG framework.

## Provisional personal references

Apartment layout, furnishings, balcony architecture and dialogue are **stand-ins**,
not a claim about Kate's home or possessions. Kate now uses the selected PixelLab
32×32 idle rotations and four-frame directional walking loops. Appearance and
animation quality remain provisional. Frames use nearest filtering and share a
foot anchor; movement, collision, shoo and interaction rules are unchanged.
Ending language is generic, not attributed to her or the relationship.

## Native authoring

Open `maps/apartment.tscn` or `maps/outside.tscn` (the latter is now the balcony;
its internal filename is retained). Ground/Details use external TileSets.
Independent props have foot anchors and native Y sorting. Edit collision
rectangles, PlayerSpawn/ReturnSpawn/PigeonSpawn and Exit/Table regions directly.
The balcony's Mess node owns removable dirt/feathers; rails remain independent.
Scenes are authoritative: there is no TMX/CSV/JSON map conversion or runtime grid.

`bubby.gd` owns rest/tell/hop/depart/defeat states. The target locks once per hop;
only the landing circle can cause damage. Recovery is the shoo window; actions
have a cooldown. `player.gd` retains axis-separated substep collision/animation,
using idle/walking frames for unarmed shooing rather than a sword attack sprite.

Current art: `assets/art/source/bubby/refinement/README.md`; Aseprite masters → explicit PNG
exports → native props/TileSets. One PixelLab included trial created the pigeon;
local original raster studies created the environment. Music/exploration retain
unresolved tutorial provenance. Kate's selected PixelLab art replaces the tutorial
avatar; previous art remains preserved, not relicensed. Original Zelda source remains excluded
under `source/`, unchanged. Existing draft art is retained, not silently deleted.

## Validation

`make fast-check CHECKS="bubby mobile"` covers input, native edit/save/reload,
spawn-to-door collision navigation, scattering, locked tells, dodge, recovery
windows/range/cooldown, landing damage/grace, failure/retry, victory/re-entry and
hub return. Optional actual-window captures:

```sh
"$GODOT" --path . --script res://scripts/validation/bubby_check.gd -- /tmp/bubby
```

These positioned/accelerated automated fixtures do not establish human balance,
personal recognition, audio quality or physical iPhone usability.
