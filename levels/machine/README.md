# Machine — The quiet hour (provisional Alpha 0.2 showcase)

Terminal code **MACHINE**. WASD/arrows move, E talks/travels, Space sparks,
Shift braces, Escape closes dialogue first or returns to Matrix.

Start in your room, enter the rest of home and speak to the caretaker if desired.
Leave home for town. Visit the workshop, library and cafe; each NPC provides one
relay and practical advice. Three relays open the east gate below the cafe.
Outside town, approach the clockwork governor and press E.

The governor marks a ground pulse with an orange ring. Move away or brace just
before impact. Its green recovery ring is the chance to get close and spark.
Six sparks restore it; repeated inputs have a cooldown. Losing all five hearts
returns safely to town with relays retained. You can retreat through the town
portal and retry. Victory has a short ending and restarts the town clock hand.
Nothing persists after returning to Matrix. Intended play length is a few
minutes; human completion time and boss balance still need testing.

## Reviewable creative choices

The clockwork settlement, stopped-at-noon premise, caretaker/technician/archivist/
baker, relay errands and repairable governor are provisional original fiction.
No personal context is required. Art style, narrative and boss mechanics are
substantive choices for owner review, not settled direction. The showcase is a
working first iteration, not a certified polished final experience.

## Native authoring and ownership

Seven scenes under `maps/`: bedroom, home, town, workshop, library, cafe,
outskirts. All use the external `town.tres` TileSet. Paint Ground/Details/Above;
edit Collisions rectangles, PlayerSpawn, Portals ReferenceRects and NPC markers.
Portal metadata owns target/arrival/label/three-relay gating. NPC metadata owns
dialogue/relay. Keep Governor and ClockHand names for their runtime hooks.
No runtime map conversion. Source art/export notes are in `art/machine/`.

Machine owns its room/progression/realtime boss state. The generic pixel actor
and original astronaut sheet are shared with the hub under `shared/actors/`;
hub movement behavior remains at its previous speed, Machine uses 145 units/s.
Sounds are short original generated tones; there is no new audio dependency.
All child room/effects/audio trees are freed on hub return.

Validation checks seven native scenes and portal arrivals, source editing/save/
reload, room/home/town/three NPC progression, relay gating/no duplicates, boss
attack windows/cooldown/dodge/brace/retry, completion/clock restart and return.
These positioned automated fixtures do not replace a human full-path walkthrough,
audio/feel/balance review, final art review or real-device testing.
