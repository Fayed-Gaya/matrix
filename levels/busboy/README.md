# Busboy — the first clearing

Terminal **BUSBOY**, no UNTITLED alias. Enter/Space (or Begin) leaves the opening.
WASD/arrows move; E/Use inspects, talks and crosses thresholds. Escape closes
conversation or retreats from battle first, otherwise returns to Matrix. Touch
Matrix returns immediately. No progress is saved.

Start in a small woodland refuge. Its lantern table is optional environmental
flavor. Leave through the lower-right threshold. Follow the pale trail and
amber lanterns to the waykeeper; talk before approaching the bound root knot
on the eastern path. The knot blocks the shrine clearing.

## One turn-based encounter

Traveller: **24 health**, **4 mana**. Root knot: **28 health**. During YOUR TURN:

| Action | Immediate effect | Cost / consequence |
| --- | --- | --- |
| 1 / Strike | 4 root damage | No mana or stain |
| 2 / Guard | Halve the upcoming reply, rounding down | +1 mana (cap 4), shed 1 stain (minimum 0); no root damage |
| 3 / Cleanse | 7 root damage | 2 mana, +1 stain |

Each point of stain adds **1 damage to every damaging root reply** for this
attempt. Gather still deals zero. The visible next intention repeats Gather →
Heavy Lash (7 + stain) → Thorn Jab (3 + stain). Guard grounds a point of stain
before calculating its reduced reply. This makes the tradeoff visible before
you act; a strong spell changes the displayed upcoming damage immediately.

Actions lock while ROOTS RESPONDING (0.85 seconds). The action and reply have
separate log lines, with brief spell/guard/hit effects. Insufficient mana changes
the feedback but spends **no turn**. A slower non-magic victory and a mixed
Guard/Cleanse approach are both viable. Keyboard, mouse and three real touch
buttons use the same turn model.

Defeat: Try again / Enter immediately refreshes the encounter here. Retreat /
Escape leaves safely; the next attempt starts with full health/mana, zero stain
and fresh roots. Victory: Continue opens the actual gate and removes the knot.
Cross the passage and use the shrine; it lights and ends the introduction. The
ending briefly reflects whether stain remained, without resolving the larger
mystery. You can explore or return to Matrix.

## Art, scope and provenance

The forest now has layered drooping canopies, exposed trunks, fungi, ferns,
lanterns, contrasting terrain/trail and a pale shrine. Provisional hooded
traveller/waykeeper sheets replace the prototype blobs. New art sources and
exact PixelLab trial records: `art/busboy/refinement/README.md`.

Existing atlas tent, opening image and ambience are selectively reused. Existing
prototype assets and original Untitled remain preserved. Neither their file
names nor the planning document establish Kobe authorship or permission. The
Doc's embedded art image was a placeholder; its linked Clockwork Raven pack is
an identifiable reference, not proof of the repository assets' origin. No new
art is claimed Kobe-approved. Licensing questions remain unresolved.

Earth, Fire, Blood and a larger antagonist arc remain future vision. There are
no new regions, party systems, XP, inventory, grinding or persistence here.
Dialogue/design are provisional; they avoid a definitive antagonist/backstory.

## Native authoring

Open `maps/cabin.tscn` / `maps/forest.tscn`. Native Ground/Path/Details/Above/
Corruption use external `maps/woodland.tres`: **16px cells, scale 2**. Paint these
layers directly. Trees, props, actors and markers use foot anchors/native depth
sorting; lantern halos are independent transparent sprites, not shaders or a
baked room background. Resize named collision rectangles and interaction
regions; move PlayerSpawn, NPCs/Waykeeper, Guardian and ShrineArt. NPC dialogue
is editable metadata. Preserve named runtime contracts in `room.gd`.

Scenes are authoritative. There is no TMX/CSV/JSON conversion or runtime map grid.
The original `tileset.tres`/assets remain reference material; current scenery
uses the new external TileSet and independent sprites. The refuge exterior is
an AtlasTexture crop from the preserved original atlas.

`player.gd` retains normalized substeps/directional animation and the 160-unit
movement speed. `encounter.gd` is one small turn model; `busboy.gd` owns the
intro/room/ending state. Original Untitled source and checks stay untouched
under excluded `source/`; `make archived-godot-check` still targets its baseline.

`make fast-check CHECKS="busboy mobile"` covers the full collision route, dialogue,
editor save/reload, magic costs, failure/retry/retreat, cleared gate/shrine and
hub return. Browser smoke adds real navigation and actual battle button taps.
Physical-device input, audible ambience, human balance/art acceptance remain
unverified. Actual review captures: `docs/reviews/busboy-refinement/README.md`.
