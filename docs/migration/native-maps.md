# Native map authoring migration

Branch: `migration/native-godot-maps`; isolated checkout: `~/git/matrix-native-godot-maps`.
Base: latest fetched GitHub migration commit `d0fd58e` (2026-10-21).
Original checkout clean; cmux and its Codex process were still running. Neither is modified.

## Current authoring workflow

Routine `make check` now means minimal integration smoke. Detailed migration
fixtures below are optional via `make regression-check`; actual editor probes
remain available via `make editor-map-check`. See [testing tiers](../development.md).

Native scenes and external TileSets are the sole map authority. Open the scene
in Godot, select a TileMapLayer and paint using its palette, then save normally.
No Tiled installation, Python map parser, CSV edit or generation command is needed.

| Editable scenes | Editing guide |
| --- | --- |
| `pegasus/world.tscn` | [Pegasus](../../pegasus/README.md): layers, bounds, collision shapes, spawn and terminal |
| `levels/bubby/maps/{apartment,outside}.tscn` | [Bubby](../../levels/bubby/README.md) |
| `levels/busboy/maps/{cabin,forest}.tscn` | [Busboy](../../levels/busboy/README.md) |
| `levels/machine/maps/*.tscn` (seven rooms) | [Machine](../../levels/machine/README.md) |

External TileSets reference graphics under `assets/art/`. Static native cells,
collision shapes and markers are authoritative; custom movement/animation and
sorting remain game code. Frozen fixtures are regression expectations, never
map-generation inputs. `make editor-map-check` edits disposable copies only.

The remaining sections are the original migration record: hub/Untitled/Zelda
names and paths describe those historical revisions. Current active paths above
supersede them; retired modules remain under `archive/godot/`, with original
Bubby/Busboy foundations under their excluded `source/` directories.

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
- [x] Mario: three native maps, runtime adapter, parity/edit validation, commit/push.
- [x] Zelda: native map and runtime adapter, parity/edit validation, commit/push.
- [x] Monsters: eight native maps/objects/regions, parity/edit validation, commit/push.
- [x] Retire conversion scripts/commands and redundant copied authoring inputs; update docs.
- [x] Final make check, make runtime-check, archive integrity and editor/resource verification.
- [x] CLI handoff: review retirement/docs/editor tests and finalize the cleanup milestone.

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

Mario milestone: all three native scene grids equal the frozen baseline, all six
node entries and gameplay checks pass, and native paint/erase/positive and negative
extension survives resource save/reload. Deterministic stage_0 Compatibility PNG
is byte-identical before/after. Manifest map grids removed; frame paths retained.
Manual platforming and other camera positions remain unverified in this milestone.

Zelda milestone: every active placement cell equals the baseline; collision,
combat, spells, grass, XP, upgrades and lifecycle checks pass. Native save/reload
and extension checks pass. Deterministic Compatibility world PNG is byte-identical
and was visually inspected. Ground preserves the previous precomposed image as
paintable 64px regions; no new flattening. Previously unused source CSV layers
remain regression/reference evidence, not new runtime overlays. Manifest map
grids removed; gameplay/stat/frame data retained. Full-map playtesting remains.

Monsters milestone: all eight native maps reproduce every baseline terrain cell,
object position/size/image and property dictionary. All named spawns/transitions,
trainer/encounter/nurse and battle/evolution checks pass. Native region edits and
terrain painting/extension survive save/reload. Deterministic Compatibility world
PNG is byte-identical. Manifest maps removed; 792-image atlas, animation, audio,
trainer and battle data retained. Region nodes are editable Control rectangles;
previews use static frames while runtime retains animation and depth sorting.

Tool retirement: removed 59 redundant non-archive TMX/TSX/CSV authoring files,
four Python map/manifest converters, the Godot generation helper and both make
regeneration targets. PNG/source artwork, atlas cutouts, licenses/attribution,
non-map manifests and the complete Pygame archive remain. Current docs instruct
native editing. Historical source inventory remains explicitly historical.
Final verification completed on 2026-10-21:
- `make check`: all resource/behavior/native authoring stages passed; 14 native maps.
- `make runtime-check`: fresh imports and all ten launch/return routes passed
  without the archive, Python application runtime, or old Godot cache.
- `make editor-map-check`: actual Compatibility editor opened all 14 scenes,
  selected native TileMapLayers, painted/erased cells, saved via EditorInterface,
  and reloaded the edited scratch scenes successfully in a disposable project.
  Initial test startup raced with editor scene restoration; waiting for startup
  fixed the test, and the final run passed all scenes. Repository maps were not
  edited by this test. This test does not replace manual gameplay acceptance.
- `git diff --check` passed; no changes under `legacy/pygame/`.

## Handoff record and final CLI review

User requested this app agent stop and hand off on 2026-10-21. All map milestones
were pushed through `10ece18` at handoff. Tooling retirement, documentation,
validation improvements and editor tests were handed over uncommitted, with
source deletions already staged. The CLI retained this worktree and those edits;
its completion record follows below. The app agent left no validation processes
running.

Recent validation logs remain at `/tmp/matrix-native-final-check.log`,
`/tmp/matrix-native-runtime-check.log`, `/tmp/matrix-native-editor-check.log`.
Deterministic captures: `/tmp/matrix-before-{mario,zelda,monsters}.png` and
`/tmp/matrix-{mario,zelda,monsters}-native-{mario,zelda,monsters}.png`.
The representative Mario/Zelda/Monsters native captures are byte-identical to
baseline; only Zelda was explicitly visually inspected during this phase.
Full-map gameplay, editor usability by a human, sound and exports remain manual.


The CLI completed the handoff review without resetting or replacing this worktree.
Staged source/tool deletions were checked against resource references; no current
map-authoring dependency on Tiled remains. Python validation tools were formatted.
Review caught a custom-renderer defect: Godot cell flip/transpose flags were not
applied to static native tiles. The renderer now combines cell flags with TileData
transforms and preserves rectangular tile dimensions and texture origins. An actual
Compatibility-editor pixel comparison against native TileMapLayer drawing covers
16 combinations in disposable resources. No authored scene/layout was changed.

CLI acceptance commands passed: `make check`, `make runtime-check`,
`make editor-map-check`, Python tooling Ruff lint/format and `git diff --check`.
Logs: `/tmp/matrix-native-cli-final-check.log`,
`/tmp/matrix-native-cli-runtime-check.log`, `/tmp/matrix-native-cli-editor-check.log`.
The final archive check reports 709 byte-identical files and 62 matching after
exact in-memory CRLF reconstruction; no archive bytes were rewritten.
Final cleanup is committed/pushed to the same migration branch; no merge or
archive modification/removal is part of this milestone.

Manual acceptance still required: open each scene and try palette painting,
selection/duplication and rectangle handles as a human; confirm runtime placement
changes; walk every map boundary/collision and Monster transition; test Mario routes,
Zelda combat and Monsters encounters/dialogue/battles; listen to music/effects.
Exports and real camera hardware remain outside this map-authoring verification.
