# Alpha 0.2 implementation status

Updated 2026-10-22. Alpha 0.2 PRs #7–#14 are merged into `main` with
merge commits; original commits preserved. Integrated code commit:
`90a8514786c14a7edccbbc1a587f3a25e4a08cac` (tree identical to validated
feature tip `f1192e810db916af9ce810586b06b750cb7bbfb2`).

The owner explicitly authorized integration and main validation, and deferred
manual testing to keep the private-alpha workflow lightweight. Physical-device
acceptance remains **unverified**, not a prerequisite for this integration.
Release tags, publication, Pages deployment and notifications remain outside
this authorization. Alpha 0.1 `v0.1.0-alpha.1` remains
`f6146918b424af8cc64e1969c7447892b766cacb`; its records/packages and the
Pygame archive are preserved.

## Current phase / next concrete action

All eight development/assessment phases have checkpoints below. Finish/check
CI on integrated `main`, then await a release-preparation/publication instruction.
No manual gameplay work is requested at this juncture. The owner may use
`alpha-0.2-mobile-testing.md` before sharing or refine testing later. Never claim
physical iPhone/Android, audible-audio or full human gameplay verification.

| Phase | Result | Commit / branch suffix (`feature/alpha-0.2-…`) | PR/base |
| --- | --- | --- | --- |
| 1 Catalog | Four modules archived/excluded | `3e840c2` / catalog | [#7](https://github.com/Fayed-Gaya/matrix/pull/7) → main |
| 2 Hub | Original one-room spaceship | `46f5f77` / hub | [#8](https://github.com/Fayed-Gaya/matrix/pull/8) → #7 |
| 3 Bubby | Provisional apartment/pigeon delivery | `38876f2` / bubby | [#9](https://github.com/Fayed-Gaya/matrix/pull/9) → #8 |
| 4 Busboy | Forest/NPC/turn encounter slice | `09771b3` / busboy | [#10](https://github.com/Fayed-Gaya/matrix/pull/10) → #9 |
| 5 Machine | Home/town/interiors/NPCs/boss | `b8d781b` / machine | [#11](https://github.com/Fayed-Gaya/matrix/pull/11) → #10 |
| 6 Workflow | Targeted/full checks, clean audited exports, art helper | `66448ab` / workflow | [#12](https://github.com/Fayed-Gaya/matrix/pull/12) → #11 |
| 7 Mobile | Touch/layout/rotation + automated browser coverage | `d9d457e`, `af0dffb`, `586b570` / mobile | [#13](https://github.com/Fayed-Gaya/matrix/pull/13) → #12 |
| 8 iOS | Read-only feasibility, no native build | `2587bab` + handoff / ios-feasibility | [#14](https://github.com/Fayed-Gaya/matrix/pull/14) → #13 |

All eight PRs were retargeted to main in dependency order and merged on
2026-10-22. Merge commits: #7 `0da07b5`, #8 `7f42436`, #9 `b8783da`,
#10 `b048186`, #11 `0424606`, #12 `b7d5878`, #13 `2f17ac2`, #14 `90a8514`.
The PR/base column above records the original stack, not outstanding PRs.
A documentation-only follow-up records authorization and integration status.

All final feature-head CI passed, including six browser checks at both mobile
`586b570` (run 39738016779) and final feature tip `f1192e8` (39738086285).
Final feature browser matrix: six passed in 2.5 min. Linux WebKit Machine
capture inspected: geometric arrows render correctly. Main push CI is automatic
(check the newest main SHA/run); the first integrated run is 39739655477, with
Checks 39739655444 already successful at this checkpoint. Further documentation
integration triggers a fresh main run; report its actual result separately.

Earlier CI failures were resolved, not ignored: short timed touches were
unreliable on software rendering; subsequent helpers demanded a pixel waypoint
beyond a usable desk collision edge. Helpers now stop at actual terminal range,
while terminal/launch/return assertions remain. Linux missing arrow glyphs were
replaced with geometry. Detailed local evidence remains below.

## Scope and playable content

Order preserved: retire four → hub → Bubby → Busboy → Machine → workflow →
browser/mobile → iOS feasibility. The owner supplied the truncated remainder.
[Matrix plan](https://docs.google.com/document/d/10g9vxXnyFI6-pNac0DiiAO6ksOC0VN4FpzJWzzscIlU/edit)
and [Busboy plan](https://docs.google.com/document/d/183hSTmkQ3NHhDRTlgq8zJkLPunC7iQTP3-npaEApzno/edit)
were read through Google Drive, including Bubby/release/mobile tabs.

Active: **BOUNCE, BALLS, BUG, YOU, BUBBY, BUSBOY, MACHINE**. ZELDA/UNTITLED
aliases and PONG/JUMP/MARIO/MONSTERS are rejected. Complete retired Godot modules
and original hub art/layout/fixtures remain in `archive/godot/`; original
Zelda/Untitled plus frozen checks remain in Bubby/Busboy `source/`. All excluded
from imports and PCK, including retired import-cache fingerprints. Original
full ten-level tests passed via `make archived-godot-check`, using pinned
`145771f` in a disposable tree. Pygame 771-file preservation passes: 709 original
bytes; 62 match exact in-memory LF→CRLF reconstruction after Git normalization.
No archive files rewritten. Historical Alpha 0.1 docs/inventory unchanged.

Twelve authoritative native maps: `hub/world.tscn`; Bubby apartment/outside;
Busboy cabin/forest; Machine bedroom/home/town/workshop/library/cafe/outskirts.
External TileSets/collisions/markers own editing; no TMX/CSV conversion. Editable
SVG/Aseprite art is under `art/{hub,bubby,busboy,machine}`; approved runtime PNGs
are in modules/shared. Shared avatar/movement remain small; games are independent.

- Hub: original cabin/bed/window/storage/plant/computer, boundaries, movement,
  opening, terminal and preserved return position.
- Bubby: generic **provisional** apartment/outside, tutorial avatar/music,
  three-shoo pigeon, composure/retry, envelope/table objective and draft ending.
  No Kate apartment/story specifics were available; no biography invented.
- Busboy: retained forest art/characters/opening/ambience, waykeeper dialogue,
  Strike/Guard/Cleanse with mana/stain/telegraphed turns, retreat/defeat/retry,
  cleared gate and shrine ending. Earth/Fire/Blood remain future vision.
  No identified Kobe artwork/approval; new fiction/props are provisional.
- Machine: original provisional clockwork premise/art, three NPC relays, gated
  governor boss with marked pulses, Spark/Brace, retry, ending/restarted clock.
  No XP/persistence. Intended few-minute length has not been human-measured.

## Verification and measured results

Passed locally: full `make check` (all active mechanics, touch combat adapters,
focus/multi-finger/release/rotation/routes), `make runtime-check`, staged
`make web-export` with isolated PCK/dynamic-manifest/exclusion audit, archive
checks, licensing inventory freshness, two export-replacement tests and diff
whitespace checks. A disposable Aseprite export passed without changing prefs.
Each new game also passed positioned-fixture progression in headless and actual
Compatibility windows; captures inspected. These are not human walkthroughs.

Actual editor opened/painted/erased/saved/reloaded all twelve maps. Sixteen
nonblank native/custom transform pixel comparisons passed. An occluded-window
frame-signal stall was fixed using explicit `RenderingServer.force_draw(false)`;
all comparisons retained plus a nonblank guard, no timeout increase.

Desktop Chrome/Firefox/Edge passed initial mobile CI. Local GPU-backed Chrome,
Firefox, mobile Chrome DPR 3 and mobile WebKit DPR 3 passed four tests (1.0 min).
Local Edge is absent; CI installs it. Short timed touch presses were unreliable
on CI; frame-observed input/release and realistic interaction waypoints replace
that assumption. High-DPI software Chrome also overshot due rendering latency.
CI now keeps full touch navigation at DPR 1 plus a separate DPR-3 scaling/touch/
rotation probe; WebKit retains full DPR-3 navigation. No route/proximity/return
assertions removed. Terminal-edge follow-up also stops at usable range instead
of demanding a point beyond the desk collision. Failure traces keep DOM/network/source and explicit scene/
failure PNGs, without continuous canvas screencasting. Local CI-flag retest:
Chrome full 24.4 s, Chrome DPR-3 layout 14.8 s, WebKit full 13.2 s; all passed
(three tests, 1.3 min). Physical iOS/Android acceptance is unverified.

Final terminal-edge/portable-arrow checkpoint: full make check, audited export
and five locally available browser tests passed (1.1 min): desktop Chrome 7.5 s,
Firefox 22.3 s, mobile Chrome DPR 3 10.2 s, Chrome DPR-3 layout 3.5 s and mobile
WebKit DPR 3 10.9 s. Local Edge remains absent; CI installs it. Logs:
`terminal-edge-{full,export,browsers}.log`. Geometry avoids platform-font tofu;
the hub now says Tap Begin/Use on touch devices.

Baseline main `145771f`: check 155.486 s, fresh runtime 67.049 s, export 40.124 s,
PCK audit 5.106 s; Chrome ten-code smoke ~1.4 min (rounded). Catalog-only:
53.904 / 30.792 / 55.140 / 4.181 s; Chrome 33.8 s. No catalog-only export-time
gain claimed. Workflow observations: Machine fast 8.538 s, full 13.101 s,
export 10.444 s before embedded audit, PCK 1.369 s. Final full Godot stage sum
14.46 s (excludes archive/tool overhead). Single local observations with cache/
editor effects, not controlled benchmarks.

Raw web bytes: baseline 58,556,112 → about 44,048,920 (−24.8%); PCK
18,547,604 → 4,041,252 (−78.2%). Engine WASM remains 39,514,754 B. These are
uncompressed file totals, not download transfer sizes. Generated exports ignored.
Logs/captures: `/tmp/matrix-alpha02/`, especially `mobile-final2-check.log`,
`mobile-runtime-check.log`, `mobile-synchronized-export.log`,
`mobile-density-split-browsers.log`; CI retains logs/scene PNGs/build/source.

## Remaining acceptance / safeguards

- Owner iPhone 17 Chrome/Safari: full paths, landscape/notch/browser bars,
  simultaneous controls, readable dialogue, audio, sleep/resume, loading/frame
  rate/memory. Android desired, unavailable hardware does not block private alpha.
- Human art/narrative/balance/feel acceptance remains. Kate-specific details and
  Kobe direction are provisional; do not require his participation or invent facts.
- Licensing remains unresolved: `alpha-0.2-licensing.md` and current
  `alpha-0.2-third-party-inventory.json`. Passing inventory is not clearance.
- iOS: see `alpha-0.2-ios-feasibility.md`. Intel MacBookPro15,4 / macOS 15.8.1;
  no full Xcode, iPhoneOS SDK or matching iOS templates, about 19 GiB free.
  Xcode 26.3 is a host-compatible candidate per Apple, not a verified phone/build.
  Newer Xcode needs an OS this model does not officially support. No installations,
  signing/account/device changes, enrollment or purchases performed.
- PixelLab HTTP MCP is configured/enabled, but no tools exposed to this session.
  No secrets printed/committed and no paid generation called. Isolated temporary
  `ASEPRITE_USER_FOLDER` avoids its batch-only extension dialog error. See
  `docs/art-pipeline.md`; do not alter user plugin/credential configuration.
- User's untracked `art/Sprite.aseprite` remains untouched/uncommitted, SHA256
  `a50dd0d09cd0e7f6753b81089849f0001f4c9a07b338926eb17ea8a29b51bd32`.
- Inspect Git/worktrees/concurrency before resuming. Do not stop user editors or
  discard work. Local gh auth fails; connected GitHub tools work. Use
  `make fast-check CHECKS=...` for iteration and `make release-check` for the
  comprehensive automated path. Real devices/art/audio require manual acceptance.

## Integrated-main CI follow-up

PRs #7–#15 are merged; integration/status tip `6a2f5ce`. Main run 39739932921
passed Godot/fresh runtime/inventory/export/PCK audit and five browser checks.
Edge failed only the vertical helper's 3-pixel waypoint tolerance at y=178,
inside the valid approach corridor. The desktop helper now uses the same
y=172 ±18 approach corridor as touch; actual terminal proximity, all seven
launches/returns, resize and error assertions remain mandatory. Exact movement
and collision traces remain in Godot validation. No gameplay settings changed.
This test-only correction goes through its own PR and final main CI rerun.

A concurrently opened Godot editor changed local project.godot (web renderer
and audio overrides removed). That uncommitted change and the user's sprite
are preserved, excluded from commits; CI's clean checkout is authoritative for
integrated main. Local make check/runtime/inventory/export also passed, but the
local export records that dirty settings state. No manual testing requested.
