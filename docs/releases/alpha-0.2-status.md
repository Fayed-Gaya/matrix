# Alpha 0.2 implementation status

Updated 2026-10-22. Work in `/Users/Fayed/git/matrix`; current branch
`feature/alpha-0.2-ios-feasibility`, stacked on mobile PR #13. **No merges, release tags or
public deployments authorized.** Keep Alpha 0.1 tag `v0.1.0-alpha.1` at
`f6146918b424af8cc64e1969c7447892b766cacb`, published bytes and Pygame archive.

## Scope/order and current action

1. Retire PONG/JUMP/MARIO/MONSTERS — implemented.
2. Original one-room spaceship hub — implemented.
3. BUBBY replaces ZELDA — playable provisional delivery/pigeon slice.
4. BUSBOY replaces UNTITLED — playable provisional forest/turn encounter.
5. MACHINE — playable provisional home/town/three interiors/NPCs/boss showcase.
6. Workflow/performance — implemented; added targeted/full validation paths,
   prevent development/output imports, clean reproducible exports, isolated
   Aseprite batch helper and practical tooling/authoring documentation.
7. Desktop/mobile browsers — implemented; physical acceptance pending; landscape/touch, all seven routes/return,
   BUG pointer/touch, YOU fallback, iPhone Chrome/Safari prioritized. Android
   desired without blocking on unavailable hardware. Real iPhone needs owner.
8. Native iOS feasibility — assessment complete; personal-device milestone only; no purchases,
   enrollment, certificates, TestFlight/App Store or native publication.

The owner supplied the truncated remainder; no missing-scope blocker remains.
Proceed with thoughtful provisional choices, no paid API generation, no invented
Kate details/Kobe preferences, and do not require Kobe participation. Canonical
[Matrix plan](https://docs.google.com/document/d/10g9vxXnyFI6-pNac0DiiAO6ksOC0VN4FpzJWzzscIlU/edit)
and [Busboy plan](https://docs.google.com/document/d/183hSTmkQ3NHhDRTlgq8zJkLPunC7iQTP3-npaEApzno/edit)
were read through Google Drive, including Bubby and release/mobile tabs.

## Commits/stacked PRs

| Phase | Commit | Branch suffix (`feature/alpha-0.2-…`) | PR/base |
| --- | --- | --- | --- |
| Catalog/archive | `3e840c2` | catalog | [#7](https://github.com/Fayed-Gaya/matrix/pull/7) → main |
| Hub/art | `46f5f77` | hub | [#8](https://github.com/Fayed-Gaya/matrix/pull/8) → #7 |
| Bubby | `38876f2` | bubby | [#9](https://github.com/Fayed-Gaya/matrix/pull/9) → #8 |
| Busboy | `09771b3` | busboy | [#10](https://github.com/Fayed-Gaya/matrix/pull/10) → #9 |
| Machine/shared actor | `b8d781b` | machine | [#11](https://github.com/Fayed-Gaya/matrix/pull/11) → #10 |
| Workflow/export | `66448ab` | workflow | [#12](https://github.com/Fayed-Gaya/matrix/pull/12) → #11 |
| Touch/mobile | `d9d457e` | mobile | [#13](https://github.com/Fayed-Gaya/matrix/pull/13) → #12 |

All pushed, none merged. #7–#12 GitHub Checks/Godot/Web are green, including
Chrome/Firefox/Edge. Workflow CI green (Godot/Web 39729243722; Checks 39729243773). Mobile Checks green (39730221407); Godot/Web 39730221390 pending last inspection. PR validation also runs
on stacked Alpha 0.2 bases. Retarget descendants after approved base merges.

## Implemented game/catalog details

Active: BOUNCE, BALLS, BUG, YOU, BUBBY, BUSBOY, MACHINE. Old public aliases
ZELDA/UNTITLED and the four retired codes are rejected. Complete retired modules
and original hub art/layout/fixtures remain under `archive/godot/`. Original
Zelda/Untitled and frozen checks remain under Bubby/Busboy `source/`, excluded
by `.gdignore` and export policy. `make archived-godot-check` validates the full
original ten-level suite in a disposable tree from pinned `145771f`; it passed.
Pygame `legacy/pygame/` remains unchanged (all 771 checksums verified).

Twelve native editable maps: `hub/world.tscn`; Bubby apartment/outside; Busboy
cabin/forest; Machine bedroom/home/town/workshop/library/cafe/outskirts. Scenes,
external TileSets, collision shapes and markers own editing; no TMX/CSV conversion.
Editable original SVG/Aseprite sources under `art/{hub,bubby,busboy,machine}`;
approved runtime PNGs in modules and shared avatar under `shared/actors/`.

Bubby: generic provisional apartment/outside, reused tutorial avatar/music,
three-shoo pigeon, composure/retry, envelope objective and placeholder ending.
No Kate apartment/story references were available; nothing asserts her biography.
Busboy: retained forest art/characters/opening/ambience, NPC conversation,
Strike/Guard/Cleanse with mana/stain/telegraphed turns, retreat/retry, cleared
collision gate and shrine ending. Earth/Fire/Blood remain future vision. No
identified Kobe art/approval; new props/fiction explicitly provisional.
Machine: original provisional clockwork premise/art, shared Matrix avatar,
three NPC relays, realtime marked pulses/spark/brace/retry, ending and restarted
town clock. No XP/persistence. Intended few-minute length is not human-measured.

## Evidence and limitations

Per meaningful checkpoint: headless resource/behavior checks, fresh runtime,
web export, isolated PCK/dynamic/import-cache exclusion audit and Chrome real
keyboard terminal/return/resize smoke passed. Each new game also passed targeted
headless and actual Compatibility-window progression; rendered captures inspected.
These use positioned fixtures, not full human walkthroughs.

Actual editor passed open/paint/erase/save/reload on all twelve scenes, plus all
sixteen nonblank native/custom transform pixel comparisons. Initial twelve-map
run stalled after successful edits waiting for an occluded-window draw signal;
fixed with explicit offscreen `RenderingServer.force_draw(false)`, keeping all
comparisons and adding a nonblank guard. Rerun passed; no timeout increase.
Machine Chrome seven-code suite: 10.0 s. Local logs/captures:
`/tmp/matrix-alpha02/` (`baseline*`, `catalog*`, `hub*`, `bubby*`, `busboy*`, `machine*`).

Baseline main `145771f`: make check 155.486 s, fresh runtime 67.049 s,
export 40.124 s, PCK audit 5.106 s; Chrome ten-code suite ~1.4 min (rounded).
After catalog-only retirement: check 53.904 s, runtime 30.792 s, export 55.140 s
(no export-time improvement), PCK 4.181 s, Chrome 33.8 s. Raw web bytes
58,556,112 → 46,033,285 (−21.4%); PCK 18,547,604 → 6,024,772 (−67.5%).
Engine WASM alone 39,514,754 B. Later six-game Busboy build 43,964,097 B,
PCK 3,955,584 B; workflow build 44,038,744 B (seven levels). Single local observations
with cache/editor effects, not controlled benchmarks or network transfer sizes.

Human full-path gameplay, artistic acceptance, personal narrative, encounter
balance/feel, audible audio and real device/mobile/browser acceptance remain
unverified for redesigned content. Licensing issues remain unresolved. Historical
Alpha 0.1 docs/inventory unchanged in final stack; current inventory/addendum:
`alpha-0.2-third-party-inventory.json`, `alpha-0.2-licensing.md`.

## Tooling observations/resume safeguards

- User's untracked `art/Sprite.aseprite` is untouched/uncommitted; SHA256
  `a50dd0d09cd0e7f6753b81089849f0001f4c9a07b338926eb17ea8a29b51bd32`.
- An existing root Godot editor and idle Codex app sessions were observed;
  no concurrent edits detected. Do not terminate or overwrite them.
- PixelLab HTTP MCP is configured/enabled locally with Authorization; no secret
  printed/committed. No PixelLab tools are exposed to this session and no paid
  generation called. Local original art avoided this dependency.
- Installed Aseprite PixelLab extension logs a batch-only dialog error. Verified
  documented temporary `ASEPRITE_USER_FOLDER` exports successfully without that
  error or changing user configuration; wrapper implemented in Phase 6.
- Local gh CLI authentication returns 401; connected GitHub tools work for PR/CI.
- Next session: inspect Git/status/concurrency first, continue Phase 7 validation on the
  current branch, then iOS feasibility Phase 8. Keep all archives,
  notices, user art and immutable release intact; commit/push checkpoints.

## Phase 6 checkpoint

Implemented targeted `make fast-check CHECKS=...`, full `make release-check`,
per-stage timings, tracked build/export import barriers, clean staged web exports
with mandatory PCK audit before replacement, and explicit isolated Aseprite
exports. Failed builds preserve the previous local preview; successful builds
remove obsolete workers/sidecars. Two focused replacement tests pass. Full CI
coverage remains enabled; duplicate post-export audit removed because it now
runs inside the export command. See docs/development.md and art-pipeline.md.

Local observations: selected Machine check 8.538 s, full check 13.101 s, export
10.444 s before embedded audit, isolated PCK audit 1.369 s. Not controlled
benchmarks. Final full check and Chrome seven-code smoke passed (10.0 s);
clean embedded-audit export and explicit disposable Aseprite export passed.
Logs: /tmp/matrix-alpha02/workflow-*. Next: Phase 7 mobile controls and tests.

## Phase 7 implementation checkpoint

Landscape multi-touch adapter reuses existing movement/key actions, with Use,
Shoo, Spark/Brace and direct Matrix return. All seven terminal codes are touch
buttons. Portrait pauses/resumes; focus/context changes release held inputs.
BUG supports held/dragged/released touch and keeps original mouse behavior.
Compact exploration overlays preserve dialogue; native camera path unchanged.
Phone browser CSS coordinates now drive logical canvas sizing (initial DPR-3
probe otherwise rendered a 2532×1170 root for 844×390 CSS pixels).

Full make check including multi-touch/focus/rotation/combat/route checks passed,
fresh runtime passed, final staged export/PCK audit passed, license inventory
refreshed and checked. First browser matrix: desktop Chrome/Firefox and mobile
Chrome passed. Local Edge is absent (not a gameplay failure); CI installs it.
WebKit loaded the game but its Touch constructor rejected the harness; changed
to generic canvas touch events and rerunning all available browsers. Initial
combat fixture exited before audio mixer cleanup; a 0.15 s drain resolves the
leak with strict leak detection retained. Direction labels changed to arrows
after inspecting phone captures. No real iPhone/Android test claimed.

Owner steps: docs/releases/alpha-0.2-mobile-testing.md. Final rerun: desktop Chrome 7.2 s, Firefox 21.1 s, mobile Chrome 10.9 s and
mobile WebKit 12.9 s passed (four tests, 1.0 min total). Physical-device behavior
is unverified. Final full check includes combat adapters and passes without leaks;
fresh runtime and audited export pass. Local Edge remains unavailable; full CI
installs Edge and WebKit. Next concrete action: commit/push Phase 7 and open its
stacked PR, then read-only Phase 8 assessment.

## Phase 8 / release handoff

Read-only native iOS assessment is in alpha-0.2-ios-feasibility.md. This Intel
MacBookPro15,4 runs macOS 15.8.1, only Command Line Tools, no full Xcode/iOS SDK
or matching iOS templates; about 19 GiB free. Xcode 26.3 is a host-compatible
candidate per Apple, not a proven phone/engine combination. Newer Xcode needs
a newer OS than this model officially supports. No signing/account/device
changes or installations performed. Personal-device development is plausible
but blocked on toolchain setup and owner device/account steps.

All eight queue phases now have implementation/assessment work recorded.
Remaining acceptance: real iPhone 17 Chrome/Safari, Android if available, full
human paths/balance/audio/art, licensing clearance and explicit authorization
before merging/publishing. Kate/Kobe-specific personalization remains provisional.
Next session: inspect status/concurrency, check final PR CI, address failures,
then follow alpha-0.2-mobile-testing.md with the owner. Keep private user art,
all archives and Alpha 0.1 tag/packages untouched. No Alpha 0.2 deployment/tag.
