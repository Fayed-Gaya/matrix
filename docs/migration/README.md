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
