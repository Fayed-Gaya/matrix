# Godot migration parity checklist

Historical migration record. The current spaceship is Pegasus (`pegasus/`);
runtime assets are centralized under `assets/`. See [current layout and retirement audit](../repository-cleanup.md).
Original names below describe their recorded revisions.


Checkpoint: Godot 4.7.2, GDScript, Compatibility, branch
`migration/native-godot-maps` (based on `migration/godot-4.7.2`). All ten original terminal codes have independent native
scenes inside one application. The hub remains in memory on return; leaving a
level discards that visit's game state. No persistence/accounts/cloud/DLC added.
This is an implementation and validation record, **not full gameplay parity**.

| Area / code | Implemented and automatically checked | Differences / manual review remaining |
| --- | --- | --- |
| Matrix hub | Opening, original map/art, player, collision/camera/resize, terminal proximity/pause, code editing/errors, all ten actual routes, preserved hub position and freed level roots | Floating movement/substeps, font/shadow rendering, deferred launch; walk around all furniture and review resizing/feel. [Details](hub-parity.md) |
| `BOUNCE` | Original ball pixels/transparency, edge reflection; 5,000 source-trace ticks | Original uncapped loop now fixed 60 ticks; shared-window fit. Check pacing. [Details](../../levels/bouncing_ball/README.md) |
| `BALLS` | Two distinct movement models, controls, wrap/seam copies, prior-delta/draw order; 400 source-trace updates and 13 drawing cases | Float tolerance ≤0.001 px across seams; shared-window scaling. Check elapsed-time behavior under load. [Details](../../levels/balls/README.md) |
| `BUG` | Original cat, mouse coordinates/button tuple and cursor label; all three buttons | Font metrics, logical mouse mapping and shared-window fit. Check mouse tracking after resizing. [Details](../../levels/the_bug/README.md) |
| `PONG` | Original scaled sprites, integer movement/reflections/hits, press/release controls; 1,600 source-trace ticks | Fixed physics replaces capped loop; no scoring/AI existed in source. Check two-player feel. [Details](../../levels/tom_pong/README.md) |
| `JUMP` | Intro/restart, held jumping/gravity, obstacle timing/types, collisions, survival score, animation/audio lifecycle | Physics/timer phasing, fonts/audio loops. Play multiple runs; listen to music/SFX. [Details](../../levels/jump/README.md) |
| `UNTITLED` | Opening, all map cells/collision rectangles, player/NPC, camera, dialogue and ambience state | Smooth movement/rendering differences; optional Tiled transitions were never runtime functionality. Walk the whole map/listen. [Details](../../levels/untitled/README.md) |
| `MARIO` | Six nodes/three datasets, collision/jump/scrolling, coins, damage/stomp, goals/unlocks, loss/reset, art/UI/audio cleanup | World-coordinate scrolling, exact node arrival, sorted frames, synchronized drawing and particles differ. Full routes/combat/audio need playtesting. [Details](../../levels/mario/README.md) |
| `ZELDA` | Source map/data, weapons, four enemy types, damage/cooldowns, flame/heal, grass, XP/upgrades, pause/return | Timing/particle/menu edges and attack-audio retrigger differ. Source has no player-death routine; archived launcher has MAP_DIR import bug. Test full map/all weapons/spells/audio. [Details](../../levels/zelda/README.md) |
| `MONSTERS` | Eight maps, transitions, collisions, trainer approach/dialogue, nurse, grass encounters, party swaps, initiative/attacks/elements/defense, reserves/switch/capture, XP/evolution, audio cleanup | Unused arena has undefined trainers; explicit unavailable dialogue. Source pygame binding missing. Menu/evolution/timing/turn tie handling differ; loss returns instead of quitting. Test all reachable trainers/maps/battle combinations/audio. [Details](../../levels/monsters/README.md) |
| `YOU` | Native first-feed/format selection, 640×480 preview, RGB and combined/separate YCbCr, UV transform, disconnection and release; synthetic output pixels tested | **Live camera untested. Stock Windows/web camera backends absent; external texture preview unsupported.** Test permissions, resolution/colors/orientation, unplug/re-entry and LED shutdown. [Details](../../levels/you/README.md) |

## Validation evidence and reproducible commands

- `make check`: exact stable engine pin, imports, load/instantiate native
  resources, all-code terminal integration, per-level behavioral suites and
  startup. Rejects error output and leaked-instance warnings even on exit code 0.
  Tests never activate physical camera feeds.
- `make archive-check`: SHA-256 comparison of all 771 relocated baseline files;
  exact in-memory CRLF reconstruction is accepted for Git-normalized text.
- `make runtime-check`: copies only the root Godot project plus app/hub/levels/
  shared into a temporary directory, imports without existing cache, launches all
  ten actual scenes and returns. No archive, Python runtime or old import cache
  is available to that application. Synthetic mode skips camera hardware.
- `make legacy-check`: preserved Python Ruff/format/compilation pipeline; this
  is a source quality check, not proof every archived launcher works.
- Native Compatibility-window captures were inspected for every port. World/
  battle/overworld views were compared with archived renders where practical.
  You's synthetic RGB/orientation/neutral-YCbCr pixels were checked in the actual
  renderer. Headless success alone is not used as visual proof.

All above commands passed on the migration Mac. No exported Windows/Linux/web/
mobile build, real-device camera, audible audio review, extended full gameplay
or controller/touch support is certified. Asset licensing/provenance was retained
from source documentation; migration does not establish new ownership rights.
Godot export presets/templates/packaging remain future work: explicitly include
`*.json` runtime manifests when configuring exports, and set platform camera
permissions/usage descriptions before camera-capable application packaging.

## Manual acceptance before archive removal

1. `make run`: opening, WASD/arrows, furniture collisions, terminal editing and
   each code; resize the window during gameplay and return repeatedly.
2. Play Jump and every Mario dataset through normal loss/win paths; compare
   movement, collision, timing, scoring/health and music/effects with the archive.
3. Explore Zelda and Monsters; exercise all reachable encounters, menus, spells,
   trainer/nurse interactions, capture, switching, XP and evolution. Source bugs
   listed above are separate from port regressions.
4. On this Mac, enter YOU and verify OS access, live video, orientation/colors,
   no-camera/denied/unplugged handling, and camera shutdown after Escape.
5. Test intended target exports separately once packaging is configured.

**Keep `legacy/pygame/` tracked.** Removal requires explicit user authorization
following manual review and must be a separate final commit. Do not merge the
migration branch automatically.

## Native map authoring (2026-10-21)

All 14 maps now have authoritative editable Godot scenes and external TileSets.
See [native migration evidence and editing instructions](native-maps.md).
No current map-editing command depends on Tiled or the preserved Pygame archive.
Existing manual gameplay/audio/export limitations above still apply.

`make editor-map-check` opens all fourteen scenes in a disposable Compatibility
editor, programmatically paints/erases/saves/reloads cells and compares custom
static tile drawing with native TileMapLayer pixels for flip/transpose combinations.
This is automated editor/API evidence, not a human usability test. Native resource
checks also cover collision/interaction/NPC/object properties and map extension.
