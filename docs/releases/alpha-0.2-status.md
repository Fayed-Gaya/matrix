# Alpha 0.2 implementation status

## Scope and execution

Authorized: feature branches, checkpoint commits/pushes and PRs. **No merge,
release tag or public deployment.** Preserve published `v0.1.0-alpha.1` at
`f6146918b424af8cc64e1969c7447892b766cacb` and the Pygame archive.

Order: (1) retire PONG/JUMP/MARIO/MONSTERS; (2) original one-room spaceship hub;
(3) BUBBY replaces ZELDA; (4) BUSBOY replaces UNTITLED; (5) MACHINE and later
release work after confirming the truncated request. Keep BOUNCE/BALLS/BUG/YOU.
No old public aliases when Bubby/Busboy are implemented. MACHINE is not yet
implemented or advertised as playable.

Canonical Matrix and Busboy Google Docs were read on 2026-10-22. They describe
mobile feasibility/touch integration, a later full acceptance pass, and a new
showcase level, but important creative details remain open. The submitted
request cuts off at “Do not invent Kobe's preferences or”; a clarification was
requested asynchronously. Continue known independent work while awaiting it.

## Current checkpoint

Branch: `feature/alpha-0.2-catalog`, based on main `145771f`.
Phase 1 in progress: Godot modules/fixtures moved to `archive/godot/`, import and
export exclusions added, active validation/browser catalog reduced to six.
ZELDA/UNTITLED remain temporarily until their respective implementation phases.
No archive contents or published release files changed.

Next: validate actual pack exclusion and compare build size/test duration;
finish current documentation/inventory, commit/push and open PR. Then hub.

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
