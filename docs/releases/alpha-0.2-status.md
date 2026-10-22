# Alpha 0.2 implementation status

## Scope and execution

Authorized: feature branches, checkpoint commits/pushes and PRs. **No merge,
release tag or public deployment.** Preserve published `v0.1.0-alpha.1` at
`f6146918b424af8cc64e1969c7447892b766cacb` and the Pygame archive.

Order: (1) retire four unused levels; (2) original spaceship hub; (3) Bubby;
(4) Busboy; (5) Machine; (6) workflow/performance improvements; (7) desktop and
mobile-browser integration/testing; (8) native iOS feasibility, last.
The owner supplied the previously truncated remainder: no participation from
Kobe is required. Machine may use thoughtful provisional art/story/boss choices.
Its sequence is bedroom → home → town → several interiors/NPCs → outside-town
boss, a few minutes of accessible play. Mobile landscape/touch is committed;
prioritize iPhone Chrome/Safari, preserve desktop, Android is desired without
blocking on unavailable hardware. Real iPhone acceptance requires owner help.
iOS feasibility only: no enrollment, purchases, distribution certificates or
publication. Continue technically unblocked phases without review pauses.

## Current checkpoint

Branch: `feature/alpha-0.2-busboy`, stacked on Bubby.
- Phase 1: `3e840c2`, PR [#7](https://github.com/Fayed-Gaya/matrix/pull/7), green CI.
- Phase 2: `46f5f77`, PR [#8](https://github.com/Fayed-Gaya/matrix/pull/8), green CI; base #7.
- Phase 3: `38876f2`, PR [#9](https://github.com/Fayed-Gaya/matrix/pull/9), base #8.
All pushed, none merged. Alpha 0.1/Pygame archive/user sprite unchanged.

Busboy implementation complete, uncommitted checkpoint awaiting final commit/push.
Passed make check, fresh runtime, five-scene actual editor persistence, web
export/PCK audit, targeted headless/windowed progression and final Chrome smoke
(9.7 s). Final visual wall adjustment rechecked with resources/progression/export.
Raw web directory 43,964,097 B; PCK 3,955,584 B. Alpha 0.1 historical licensing
snapshot restored unchanged; current inventory has its own Alpha 0.2 filename.
Next: commit/push Busboy and open stacked PR, then implement Machine.
Machine direction: provisional clockwork town, a home and several civic interiors,
helpful NPCs and a clearly telegraphed guardian boss; no personal context needed.

## Baseline evidence

Pre-change main `145771f`, local Godot 4.7.2, Compatibility, this Mac:

| Check | Result | Wall time |
| --- | --- | --- |
| make check | Passed | 155.486 s |
| make runtime-check | Passed | 67.049 s |
| make web-export | Passed | 40.124 s |
| isolated exported PCK check | Passed, all ten codes | 5.106 s |

Existing web directory before rebuilding: 58,556,112 bytes; PCK 18,547,604 bytes.
Engine WASM alone: 39,514,754 bytes. Rebuilt baseline and Chrome route timing
are being captured before comparison. Logs/measurements:
`/tmp/matrix-alpha02/baseline*.log`, `/tmp/matrix-alpha02/baseline.json`.
These are local evidence, not committed build artifacts or universal benchmarks.

## Preservation and unresolved inputs

- User's untracked `art/Sprite.aseprite` must remain untouched/uncommitted:
  SHA256 `a50dd0d09cd0e7f6753b81089849f0001f4c9a07b338926eb17ea8a29b51bd32`.
- One existing Godot editor and idle Codex app processes were observed; no
  concurrent edits detected. Do not terminate them or overwrite their work.
- No Kate apartment photographs/personal narrative specifics in accessible docs.
  Bubby environments/story must be explicitly provisional, never biography.
- Kobe source artwork has not been identified as such in accessible documents.
  Inspect existing assets and preserve references; do not assert approval/authorship.
- PixelLab generation tools are not exposed in this session; paid generation is
  prohibited. Original local pixel artwork and editable sources are feasible.
- Licensing issues from Alpha 0.1 remain unresolved; notices must stay intact.
- Human editor usability, full gameplay/audio, real devices and browser/platform
  acceptance are separate from automated verification. None newly certified.

Baseline desktop Chrome real-input smoke passed all ten codes (1.4 minutes
reported suite wall time; 1.2 minutes test body). No physical camera activated.
`tests/.gdignore` and `art/.gdignore` exclude development dependencies and user
editable art from Godot scanning; runtime art must be deliberately exported.

## Phase 1 verification (2026-10-22)

| Metric | Original | Reduced catalog | Observed change |
| --- | ---: | ---: | ---: |
| Total local web directory | 58,556,112 B | 46,033,285 B | −12,522,827 B (21.4%) |
| PCK | 18,547,604 B | 6,024,772 B | −12,522,832 B (67.5%) |
| make check | 155.486 s | 53.904 s | −65.3% |
| fresh runtime | 67.049 s | 30.792 s | −54.1% |
| web export | 40.124 s | 55.140 s | slower; no export-time improvement claimed |
| isolated pack checks | 5.106 s | 4.181 s | Passed both |

Pack directory traversal confirms no retired module directories, archive,
legacy, user art, tests or toolchain. All six retained routes and Zelda dynamic
manifest resources loaded from the isolated PCK, without checkout resources.
WASM is unchanged (39,514,754 B), limiting total download reduction. Timings are
single local observations with cache/editor effects, not controlled benchmarks.
Retained levels still receive their behavioral checks; original complete tests
remain separately reproducible. Licensing inventory regenerated; no permissions
resolved. `git diff --check` and targeted Python lint passed.

Reduced-catalog desktop Chrome smoke passed all six real terminal routes,
return-to-hub and resize (25.3 s body, 33.8 s suite, versus baseline 1.2/1.4 min
rounded reporter times). An expanded exported dependency audit also rejected
retired import-cache fingerprints, not merely directory names; passed.
Alpha 0.1 tag and user sprite SHA256 rechecked unchanged; no legacy diff.
New historical-check command is undergoing its first isolated full-suite run.
CI PR triggers include stacked Alpha 0.2 branches; no deployment trigger changed.

The new `make archived-godot-check` passed the complete original ten-level
suite, including all fourteen original native maps, in an isolated pinned
historical checkout. Phase 1 implementation and verification are complete.
Next phase: original one-room hub and editable source artwork; preserve input,
terminal/return routing and targeted collision tests while replacing old layout
expectations deliberately. No full manual gameplay acceptance is claimed.

## Phase 2 in progress

Phase 1 pushed as `3e840c2`, PR https://github.com/Fayed-Gaya/matrix/pull/7
(target main; not merged). Current branch `feature/alpha-0.2-hub` is stacked
on that branch. Original cabin tile/player art has SVG and Aseprite editable
sources under art/hub, PNG runtime exports under hub/assets/alpha02. No paid
generation calls. Old hub art/layout/fixture retained under archive/godot.
One native 640×352 scene, external TileSet, bed/window/storage/plant/computer,
collisions and interaction markers replace the old room. Existing movement,
camera, terminal and return contract retained. Opening uses original starfield.
Next: validate new layout/navigation, inspect actual rendered scene, document
authoring, commit/push and open a stacked PR. Aseprite's installed PixelLab
extension logs batch-only dialog errors; source files were still created.

Phase 1 CI passed on GitHub: Checks and Godot/Web run
https://github.com/Fayed-Gaya/matrix/actions/runs/39721990740, including desktop
Chrome/Firefox/Edge smoke checks and downloadable web/source artifacts. The
web artifact is `matrix-web-df2c0fc6706ae600d8047fa609f0d5dddabc0cac` (PR merge
ref build, not a published release). Local gh authentication is invalid (401);
the connected GitHub tools work, and were used for the PR/CI inspection.

Phase 2 targeted resource/hub/native-map checks passed, followed by disposable
actual-editor paint/erase/save/reload of all three active scenes and sixteen
renderer transform combinations. Fresh archive-free runtime, web export and
isolated PCK/dependency audit passed. Actual Compatibility window hub input
and routing test passed; captured cabin visually inspected. Remaining: Chrome
smoke and final journal/commit/stacked PR. Human artistic acceptance, gameplay
feel, sound, touch/device/platform coverage remain unverified for the new hub.

New hub Chrome real-input smoke passed (six routes, terminal launch/return,
resize; 10.4 s suite). Actual cabin wall/furniture long-step collision checks
also passed. Phase 2 checkpoint is ready. No public release or merge performed.
Next: Bubby, replacing the ZELDA public code with a provisional apartment →
outside → pigeon → small objective/ending slice. Personalization remains blocked
on references; implement clearly marked fictional placeholders, not Kate facts.

## Phase 3 implementation (uncommitted)

BUBBY now replaces ZELDA without a public alias. Two native rooms, copied
provisional Zelda avatar/music, original local environment/pigeon art with
SVG/Aseprite sources, door/table/envelope markers, three-shoo encounter,
composure/retry, delivery objective and placeholder ending are implemented.
The complete Zelda source/assets/frozen checks are retained under excluded
`levels/bubby/source/`; no Pygame archive changes. Existing tutorial asset
permissions remain unresolved. Active validation skips `.gdignore` source
references; historical full suite remains available separately.

Targeted headless and actual Compatibility-window progression checks passed,
including alias rejection, native edit/save/reload, pickup gating, cooldown,
contact/retry, return, dialogue and completion. Rendered apartment/outside
inspected; moved notices into the upper wall HUD so doors stay visible. This
is automated progression with positioned fixtures, not human walkthrough.
Next: final current-doc/catalog updates, full checks/fresh runtime/export/PCK
resource audit, actual editor persistence and Chrome smoke; then commit/push
and stacked PR against the hub branch. No personal/story/art approval claimed.

Phase 2 GitHub CI passed (Checks plus Godot/Web, including three desktop
browsers): https://github.com/Fayed-Gaya/matrix/actions/runs/39722744758.
Phase 3 final `make check`, fresh runtime, actual editor (four scenes), web
export, isolated PCK import-dependency audit and Chrome six-code smoke passed.
Native cameras remained disabled in automated routes. No legacy diff; user
sprite SHA256 unchanged. Human full-path playthrough, encounter feel/balance,
audible music, personal references/art direction and real devices remain open.

## Phase 4 implementation (uncommitted)

BUSBOY replaces UNTITLED without a public alias. Retained the existing forest
tiles, avatar/NPC sprites, opening and ambience; complete Untitled reference
and frozen tests remain under excluded `levels/busboy/source/`. New native
starting room and scrolling forest have editable regions/NPC dialogue, collision
rectangles, a corruption gate and shrine. One NPC unlocks the introductory
turn encounter. Strike/Guard/Cleanse have telegraphed turns, mana/stain costs,
resolution delay, retreat, defeat/retry, victory and physical gate clearing.
Reaching the shrine completes a short provisional introduction. The independent
turn model borrows the retained Monsters action-flow idea without its assets,
party/capture/XP dependencies. No persistence or new external dependencies.

New root/room props have original SVG/Aseprite sources. These and all new
dialogue/layout are provisional, not attributed to or approved by Kobe. Earth,
Fire and Blood remain documented future regions; not implemented as new maps.
Avatar/NPC are drawn at 2× source scale for forest readability; movement speed
retuned to 160 logical units/s, while normalized movement/substeps remain.

Targeted headless and actual Compatibility-window intro checks passed: NPC
gating/dialogue movement lock, turn/cooldown/mana/guard rules, defeat/retry and
retreat, victory/gate collision, shrine completion, scene edit/save/reload and
hub return. Renders inspected; corrected a wrong border tile used as floor,
actor readability and tree collision alignment. Full-path human playtesting,
combat balance, sound, final art/narrative and device testing remain manual.
Next: final docs/inventory and checks, editor persistence, browser export/PCK
audit and smoke; commit/push, stacked PR.

The full remaining scope arrived before interruption; MACHINE is no longer
blocked on missing instructions. Earlier journal references to that blocker
are superseded by the current scope above. Bubby CI is green:
https://github.com/Fayed-Gaya/matrix/actions/runs/39723990748.

## Phase 5 started
Busboy pushed as `09771b3`, PR https://github.com/Fayed-Gaya/matrix/pull/10
(base #9). Current branch `feature/alpha-0.2-machine`, stacked on Busboy.
Machine uses a provisional clockwork settlement: bedroom → home → town →
workshop/library/cafe NPCs (three relays) → outside-town governor boss.
Reuse the original Matrix avatar/movement as a shared actor, keep Machine
room/objective/realtime boss state independent. Boss telegraphs ground strikes;
move, spark attack and timed brace, with safe retry and a short ending.
Creative premise/art/boss are reviewable placeholders, not final direction.
Next: native rooms, dialogue/relay progression, boss, targeted checks and export.

Machine targeted headless and actual Compatibility-window progression passed:
all seven rooms/portal arrivals, native edit/save/reload, relays/no duplicates,
gated outskirts, boss recovery/cooldown/dodge/brace, safe defeat preserving
relays, completion/clock restart and hub return. Rendered town and boss inspected.
This is positioned automated progression, not human full-path play or measured
completion time. New art has editable SVG/Aseprite sources; shared avatar/motion
refactor preserves hub speed while Machine uses 145 logical units/s.
Next: full checks/fresh runtime, twelve-scene editor check, web/PCK/browser smoke,
then commit/push/stacked PR and continue Phase 6. Busboy CI green:
https://github.com/Fayed-Gaya/matrix/actions/runs/39725887989.

Machine editor test opened/painted/saved/reloaded all twelve scenes, then timed
out waiting for `frame_post_draw` in the independent offscreen transform probe.
No scene/edit failure or script error was reported. Updated that probe to force
an offscreen draw (supported RenderingServer API) and require nontransparent
pixels, retaining all sixteen exact comparisons. Rerun pending; no timeout
increase or test removal. Main full checks and fresh runtime had already passed.

The editor probe fix passed all twelve scenes and all sixteen nonblank exact
pixel comparisons. See RenderingServer.force_draw documentation:
https://docs.godotengine.org/en/stable/classes/class_renderingserver.html#class-renderingserver-method-force-draw
No renderer comparison was skipped or timeout increased. Web/PCK/seven-code
Chrome checks now running. Phase 6 research found a verified Aseprite fix: a
temporary ASEPRITE_USER_FOLDER avoids PixelLab's batch-only dialog errors,
without changing installed plugins/preferences. PixelLab is configured/enabled
as HTTP MCP locally (credentials not printed), but exposes no tools in this
session; no paid generation calls were made.

Machine checkpoint: full make check and fresh runtime passed; actual editor
passed all twelve scenes and sixteen nonblank renderer comparisons after the
occlusion fix. Web export, isolated PCK audit and Chrome seven-code real-input
smoke passed (10.0 s suite). No full human playthrough or completion-time claim.
Next phase: workflow fast/release paths, exclude tool/output directories from
Godot scans, safe repeatable exports and isolated Aseprite batch helper, then
mobile controls/testing and finally native iOS feasibility. No merge/publish.
