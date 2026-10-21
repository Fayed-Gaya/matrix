# Native map authoring migration

Branch: `migration/native-godot-maps`; isolated checkout: `~/git/matrix-native-godot-maps`.
Base: latest fetched GitHub migration commit `d0fd58e` (2026-10-21).
Original checkout clean; cmux and its Codex process were still running. Neither is modified.

## Audit and implementation plan

Read the migration parity checklist; its gameplay/manual limitations continue to apply.

| Maps | Baseline authority and runtime | Native plan |
| --- | --- | --- |
| Spaceship hub | copied TMX/TSX -> convert_hub_map.py + build_hub_map.gd -> world.tscn TileMapLayers; exported collision/spawn/terminal values | Promote world.tscn; external TileSet; native collision shapes and markers; retain rectangle movement |
| Untitled forest | same converter; NPC dialogue and collision metadata in world.tscn | Promote world.tscn; external TileSet; native shapes/spawn/NPC markers |
| Mario (3 datasets, shared by 6 overworld nodes) | CSV -> build_mario_manifest.py -> manifest maps; canvas draws tiles, actors, effects | Paintable native layers for terrain, decoration and placement; runtime derives placements from native cells; preserve animation/scrolling/combat |
| Zelda | CSV -> build_zelda_manifest.py -> manifest maps; ground.png plus depth-sorted canvas | Native placement layers and ground sprite; retain depth sorting, random grass, hitbox rules and combat |
| Monsters (8 maps) | TMX/TSX -> build_monsters_manifest.py -> manifest maps + packed images; canvas draws terrain, water/coast, sorted objects/entities | Native terrain TileMapLayers; visual native object/region markers; retain image atlas, sprite/battle data and depth sorting |
| Bounce, Balls, Bug, Pong, Jump, You | procedural/simple drawing, runner background, camera | No tile map migration needed |

Collision rules are custom rectangle algorithms, not Godot physics. Preserve those rules,
feeding them native shapes/cells rather than switching physics engines. Sprite animations,
water/coast animation, random decorations and sorted actors remain gameplay responsibilities.
Do not flatten artwork or replace source art. Keep manifests for non-map frame/audio/stat data.

## Milestones / remaining work

- [x] Safety: fetch refs, inspect status/worktrees/processes, isolate branch.
- [x] Audit implementations and existing parity checklist.
- [x] Hub: native authority, editable TileSet/shapes/markers, validation, commit/push.
- [x] Untitled: same, including NPC/dialogue; validation, commit/push.
- [ ] Mario: three native maps, runtime adapter, parity/edit validation, commit/push.
- [ ] Zelda: native map and runtime adapter, parity/edit validation, commit/push.
- [ ] Monsters: eight native maps/objects/regions, parity/edit validation, commit/push.
- [ ] Retire conversion scripts/commands and redundant copied authoring inputs; update docs.
- [ ] Final make check, make runtime-check, archive integrity and editor/resource verification.

## Verification policy

Hub milestone: pinned Godot full validation passed, including every baseline tile,
all collision rectangles, terminal integration and ten launch/return routes.
Fresh-checkout archive check: 709 files byte-identical; 62 match the baseline
after exact in-memory LF-to-CRLF reconstruction (Git core.autocrlf=input).
No archived files were edited. The validator now handles this checkout behavior.

Compare every original cell and all metadata before removing old runtime map data.
Keep frozen baseline fixtures only as regression evidence, never a generation source.
Exercise save/reload edits through native resources and their runtime readers.
Run existing behavioral suites and all terminal routes. Record automatic evidence here.
Headless/resource checks do not certify visual or gameplay parity. Full exploration,
collision feel, dialogue, routes, combat, timing and audible playback remain manual.

Untitled milestone: `make check` passed on 2026-10-21, including every cell,
all 11 collision rectangles, spawn/NPC, dialogue, ambience and all ten routes.
The scene and external TileSet are authoritative; shapes and markers feed runtime.
