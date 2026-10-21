# Matrix migration baseline and plan

## Checkpoint

Stage 1 baseline (Stage 2 results follow below). Baseline: `9f89816` on `main`, matching the
local `origin/main` reference (no fetch performed). Branch:
`migration/godot-4.7.2`. Initial tracked/untracked Git status was clean.
Ignored local environment, credentials, IDE files, caches, and local documentation
were not discarded or committed. Git metadata and history remain in place.

The baseline contains 775 tracked files, including 105 Python files, 551 PNGs,
11 TMX maps, 13 TSX tilesets, 34 CSVs, 20 WAVs, 5 MP3s, 3 OGGs, 6 font files,
and a GIF and JPG. `baseline-files.json` records every original tracked path,
size, and SHA-256. These counts describe files, not verified runtime content.

The implementation, original documentation, dependencies, Makefile, Ruff
configuration, Tiled workspace, and packaging tools moved together into
`legacy/pygame/` using `git mv`. Relative runtime paths are unchanged inside
the archive. Repository workflows remain in `.github/`, with Python command
working directories and artifact paths updated. `scripts/notion_mcp.sh` stays
at root because it is repository tooling and refers to the root local `.env`.
Root README and AGENTS now describe this transitional layout; their originals
are preserved in the archive.

## Functionality inventory

This is a source inspection baseline, not a full gameplay certification.
Paths below are relative to `legacy/pygame/`.

| Module / terminal code | Implemented reference behavior | Important content / controls |
| --- | --- | --- |
| Hub | Any-key opening screen; resizable 1280×720 window; 2× internal rendering; map camera; animated player, axis-separated collisions and bounds; terminal hitbox interaction; uppercase input capped at 18 characters, trimmed case-insensitive lookup, invalid-code feedback; launches a separate Python game then exits | `matrix/assets/`: `matrix-opening.jpg`, `matrix.tmx`, interior TSX/PNG, Snoblin player sheet. WASD/arrows, E, Enter, Backspace, Escape. `matrix/main.py`, `world.py`, `player.py`, `terminal.py`, `registry.py` |
| Bouncing Ball / `BOUNCE` | Image moves and reflects at window edges | `levels/bouncing_ball/intro_ball.gif`; no gameplay input |
| Balls / `BALLS` | Two red circles, keyboard movement and screen wrapping | `levels/balls/balls.py`; WASD |
| The Bug / `BUG` | Cat image with live mouse position/button debug overlay | `levels/the_bug/cat.png`; mouse |
| Tom Pong / `PONG` | Two-player paddles and sprite ball with collision response | `levels/tom_pong/data/`; A/Z and Up/Down |
| Jump / `JUMP` | Intro/restart screen, gravity/jump, animated runner and obstacles, timed obstacle spawning, collision loss, survival score, music and jump sound | `levels/jump/graphics/`, `audio/`, `font/`; Space |
| Untitled / `UNTITLED` | Opening presentation, top-down animated exploration, camera, collision, player/NPC spawns, placeholder dialogue, ambience | `levels/untitled/assets/`, `shared_assets/tilesets/`; WASD/arrows, E, Escape. Optional Tiled interaction/transition layers are authoring conventions, not evidence of implemented travel |
| Mario / `MARIO` | Overworld node navigation/unlocking, scrolling platformer, gravity/jump, enemies, coins, health/UI, particles, decoration and music | `levels/mario/levels/` CSV/TMX and graphics/audio. Left/Right, Space. Six node definitions; nodes 3–5 reuse level 2 map data |
| Zelda / `ZELDA` | Top-down map, sorted rendering, enemies, weapons, magic/healing, particles, damage cooldowns, health/energy/experience, attribute upgrades and audio | `levels/zelda/code/` is active; older duplicate root scripts also preserved. CSV map, graphics/audio. Arrows, Space, Left Ctrl, Q/E, M; arrows/Space in upgrades |
| Monsters / `MONSTERS` | Multiple maps and transitions, animated water/coast, collisions, NPC/trainer/nurse dialogue, grass encounters, turn-based battles, party/index UI, stats/XP and evolution sequences, music/effects | `levels/monsters/code/`, `data/maps/`, `data/tilesets/`, graphics/audio. Arrows, Space, Return, Escape in menus. Battle details need a dedicated parity audit |
| You / `YOU` | First camera device capture displayed at 640×480; errors when no camera; camera shutdown | `levels/you/you.py` uses `pygame.camera`, not OpenCV directly. Escape/window close |

Every level exposes package `run()` and a `__main__.py`. The registry contains
all ten codes; the archived hub README omits UNTITLED and Jump's README still
calls itself the default root game. The actual root entry launches the hub.

Pinned dependencies: pygame-ce 2.5.6, pytmx 3.32, numpy 2.4.2,
opencv-python 4.13.0.92, ruff 0.14.5. A declared dependency is not necessarily
used by every level. PyInstaller is installed separately by Windows CI.

## Migration sequence and architecture

1. **Repository preparation:** preserve the source and asset baseline, keep
   archived checks/build paths usable, commit and pause for review.
2. **Godot foundation:** root `project.godot`, exact Godot 4.7.2 validation,
   GDScript, Compatibility rendering; `hub/`, `levels/`, `shared/`, and
   `scripts/` with clear ownership; ignore generated `.godot/` data and exports;
   establish headless import/load checks and development commands. Commit/pause.
3. **Hub:** opening, converted spaceship map, animated player/collision/camera,
   terminal and registry. A small application scene router owns scene changes
   and a return-to-hub contract; keep per-level mechanics and input local.
   Preserve hub position on return in memory only. Check routing with temporary
   test scenes without pretending unmigrated games are playable. Commit/pause.
4. **Individual levels:** Bouncing Ball, Balls, The Bug, Pong, Jump, Untitled,
   Mario, Zelda, Monsters. Audit You's camera feasibility separately early;
   schedule its port after a supported approach is validated. Inspect each
   source in depth before implementation; preserve controls, timing, art,
   sound, data and distinct mechanics. Commit and pause per completed level.
5. **Validation:** scene/resource loading, all ten code routes, hub return,
   gameplay checklist, audio and resize checks; document automated results and
   manual playtesting gaps. Commit fixes. Keep the archive until explicit
   removal authorization; removal must be a separate final commit.

No persistence, accounts, cloud infrastructure, or downloadable content.
Do not push or merge automatically. Import/copy needed assets into Godot-owned
locations so the finished runtime does not depend on the removable archive.
Retain attribution and source documentation with reused content.

## Risks and decisions to validate

- TMX/TSX/CSV maps need a deliberate Godot conversion/import process. Preserve
  tile IDs, transforms, object properties, collision/spawn rectangles, animation,
  layer order, map transitions, and relative tileset references. Do not flatten
  interactive maps into a background image. Audit external references first.
- Pygame loops mix frame-based and delta-based motion. Godot physics and input
  differ; compare movement speed, gravity, collision edges, cooldowns, animation
  timing, camera bounds, pixel filtering, UI scaling, and audio loops per level.
- Mario, Zelda, and especially Monsters contain substantial game systems;
  generic movement demos would not satisfy their parity requirements. Port data
  and subsystems incrementally, with individual gameplay checklists.
- You requires a physical camera, permissions, and platform-specific support.
  Cross-platform Godot camera capture feasibility is unresolved here; validate
  official APIs and target platforms before choosing an implementation. Report
  a blocker if a native extension is necessary; do not silently replace capture.
- GIF and font/audio formats need actual Godot import verification; visual and
  sound fidelity cannot be inferred from successful parsing.
- Returning to the hub must release level audio, timers, input handlers, and
  camera resources. No game state should leak into another module.
- Python Windows packaging currently builds standalone Untitled, not Matrix.
  Keep it available for comparison; Godot exports need their own later setup.
- Existing source bugs and unfinished content must be recorded separately from
  migration regressions. Asset provenance/credits remain with archived docs.

## Verification record

Before relocation: `make check` passed using `.venv/bin/python`: Ruff lint,
format check (105 Python files), and compilation. After relocation, repeat
from the archive with `PYTHON=../../.venv/bin/python`: passed.

Manifest verification passed for 773 unchanged original files; the two
workflow files contain only the intended path adjustments. All TMX/TSX
`source` references resolve after relocation. `git diff --check` passed.
The manifest allows byte-for-byte verification of moved files against the
baseline. Workflow files are intentionally edited; `.gitignore` and the Notion
helper remain unchanged. Root README/AGENTS are new transitional instructions.
No interactive gameplay, camera/audio behavior, Windows build, or Godot scene
loading has been certified in Stage 1. Godot was not found on the current shell
PATH; locate the user-validated app/CLI in Stage 2 rather than installing a
replacement version.

| Area | Preserved source/assets | Godot parity |
| --- | --- | --- |
| Opening, spaceship, movement/camera/collision | Yes | Pending |
| Terminal and all ten codes | Yes | Pending |
| Return from level to hub | Absent in original | Planned improvement |
| Bouncing Ball, Balls, Bug, Pong | Yes | Pending |
| Jump, Untitled | Yes | Pending |
| Mario, Zelda, Monsters | Yes | Pending |
| You camera | Yes | Pending feasibility and hardware test |
| Music, effects, sprites, fonts, map data, docs | Yes | Import and playback pending |

## Stage 2 — Godot foundation

Completed on `migration/godot-4.7.2`. Stage 1 commit `6bcd652` was pushed at
the user's request before beginning this checkpoint.

- Root `project.godot`, GDScript startup scene in `app/`, and module ownership
  notes in `hub/`, `levels/`, `shared/`. Startup shows a foundation message;
  there is no migrated hub or level gameplay yet.
- Compatibility is explicit for desktop, mobile, and web. Initial logical/window
  size is 1280×720, resizable, with canvas scaling and nearest texture filtering.
  Pixel camera/render behavior will be matched to the original in Stage 3.
- `legacy/.gdignore` prevents importing the preserved Python asset collection;
  `docs/.gdignore` excludes development documentation. `.godot/`, exports and
  export credentials are ignored; stable GDScript `.uid` sidecars are tracked.
- `make check` uses a Python development wrapper to reject other engine versions,
  import resources, load scripts/scenes/resources, instantiate scenes, check
  settings, and launch the main scene for five frames. It checks error output
  as well as exit codes, because script errors may otherwise return success.
- `make editor`, `make run`, and `make legacy-check` are documented at root.
  Set `GODOT` to a different executable path for other machines. Existing CI
  continues to check the Python archive; Godot CI/export packaging remains
  unconfigured. Local checks do not require another engine or dependencies.

Verification:

- Installed binary: `/Applications/Godot.app/Contents/MacOS/Godot`, version
  `4.7.2.stable.official.ed1daf0bf`.
- `make check`: passed import, configuration/resource checks, and main-scene
  startup. Initial sandbox attempt could not write normal macOS Godot settings;
  the rerun with normal directory access passed.
- A windowed ten-frame launch exited successfully and reported OpenGL 4.1,
  Compatibility, Intel Iris Plus Graphics 645, and the startup-ready message.
  This verifies window/renderer startup, not visual layout or gameplay parity.
- `make legacy-check`: passed. Validation wrapper Ruff lint/format and
  `git diff --check`: passed.
- Mobile/web/Windows exports, interactive resizing, audio, camera capture, and
  gameplay remain untested. No export presets or persistence were introduced.

Command and renderer reference:
[Godot command-line documentation](https://docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html)
and [ProjectSettings reference](https://docs.godotengine.org/en/stable/classes/class_projectsettings.html).
The installed engine was used to validate the actual commands and settings.

Next checkpoint: Stage 3, hub migration with explicit scene routing and return.

## Stage 3 — hub implementation

The root app now runs the migrated opening, native tiled room, player,
collision/camera, terminal and ten-code registry. A small scene router keeps the
hub in memory and frees independent levels on return. Actual level ports remain
Stage 4 work; pending-code screens explicitly say they are not migrated yet.

See [hub parity, verification and manual checks](hub-parity.md). The original
archive remains intact. This checkpoint pauses before the first level port.


## Stage 4a — Bouncing Ball

Hub commit `0db39ec` was pushed at the user's request before this work.
`BOUNCE` now loads `levels/bouncing_ball/bouncing_ball.tscn`, an independent
GDScript level extending MatrixLevel. The other nine codes remain explicit
pending destinations. The source GIF and its transparency-preserving PNG copy
are owned by the level; the archive is unchanged.

See [the level's controls, parity and timing differences](../../levels/bouncing_ball/README.md).
The source's one-pixel move/edge-reflection sequence is preserved, but its
uncapped loop is paced at 60 ticks/sec. The original 1200×1000 field fits the
shared resizable window. Escape returns to the retained hub; no persistence.

Validation passed: `make check` (imports/resources, hub regression suite, all
5,000 source-trace ticks, level behavior and startup); targeted imported-alpha
checks; actual Compatibility-window level checks and inspected screenshot
(`/tmp/matrix-bounce-review.png`); Python validation-tool lint/format; and
`git diff --check`. All 771 archived baseline files remain byte-identical.
The source GIF copy is identical and the converted PNG's rendered RGBA pixels
were compared successfully. Manual pacing/visual review and cross-platform
exports remain pending; full wall-clock timing parity is not claimed.
The next level is Balls (`BALLS`); pause for review before starting it.


## Stage 4b — Balls

Bouncing Ball commit `a21c423` was pushed at the user's request before this
checkpoint. `BALLS` now loads an independent GDScript scene under `levels/balls/`.
It retains the experiment's two different movement models, original circle
sizes/positions/colors, unnormalized controls, modulo and edge/corner copies,
previous-delta sampling, and draw-before-update order. The level temporarily
sets the 60 FPS cap and restores the prior value on exit. The original logical
field fits the shared window; Escape and the return hint are additions.

See [controls, parity and validation](../../levels/balls/README.md).
Eight level ports remain pending. The next checkpoint is The Bug (`BUG`).


Validation passed: full `make check` (resource imports, hub routing/return,
Bouncing Ball regressions, Balls trace/input/lifecycle/resize checks, startup),
a real Compatibility-window suite with inspected center/corner screenshots,
Python tooling lint/format, and `git diff --check`. The frame-based circle
matched all source results exactly; the elapsed-time circle's maximum toroidal
position error was 0.0001931 logical pixels, within the 0.001-pixel check.
The original drawing cases include all four corners. The center view was
compared with a fresh Pygame render; letterbox clipping was checked visually
and by sampling a margin pixel. All 771 archived files remain byte-identical.
Manual timing/appearance review and other-platform exports remain pending.


## Stage 4c — The Bug

Balls commit `3bced83` was pushed. The user authorized continuing without review
pauses, committing and pushing each completed level. Root agent instructions
now reflect that authorization; the archive-removal restriction remains.

`BUG` preserves the cat, white 600×600 field, coordinate/button debug text and
cursor-following label. Shared-window scaling, logical mouse coordinates,
fallback-font metrics and Escape return are documented in the level README.
Mouse motion and left/middle/right events and cleanup were checked headlessly
and in a real Compatibility window; the capture was inspected. A fractional
pixel-boundary assumption in the test was corrected to target a pixel interior.
Original source/assets remain unchanged; no full font/pixel parity is claimed.


## Stage 4d — Tom Pong

The Bug (`5e8480a`) was committed and pushed before this port. PONG now uses
an independent GDScript scene, preserving the source's square scaled bats,
integer ball motion, hit suppression, border reflections, key press/release
semantics, black field and sprites. There is no source scoring or AI to port.
Original Tom Chance/GNU GPL attribution is retained with copied original and
source-scaled PNGs. Fixed 60-tick physics replaces the capped frame loop;
shared-window fit and Escape return are documented differences.

The 1,600-tick source trace matched ball/paddle rectangles, angles and hit state.
The complete validation pipeline and real Compatibility-window checks passed.
Manual simultaneous-key/feel and other-platform export review remain pending.
See `levels/tom_pong/README.md`. Next: Jump.


## Stage 4e — Jump

Pong (`0d4fdfe`) was committed/pushed before Jump. The port preserves the intro,
runner, held-Space jumping, original animation/assets/font, obstacle types and
weights, timer phase, collision loss/restart, score and audio. Fixed 60-tick
updates replace the capped loop; window scaling/return and font/audio-rendering
differences are recorded in `levels/jump/README.md`.

Gameplay checks, all prior regressions and Compatibility-window validation
passed. A shutdown audio resource leak was caught and fixed with explicit stream
stops and settling audio cleanup before the test exits. The intro capture was
inspected. Audible playback, extended play and exports remain manual checks.
Next: Untitled, before the larger Mario/Zelda/Monsters systems.
