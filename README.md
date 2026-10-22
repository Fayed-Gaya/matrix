# Matrix

Matrix uses **Godot 4.7.2, GDScript, Compatibility renderer** in this
existing repository. Alpha 0.2 development retains `BOUNCE`, `BALLS`, `BUG`,
`YOU`, and the two RPG foundations (`BUBBY` and `UNTITLED` until the Busboy checkpoint). `PONG`, `JUMP`, `MARIO`, and `MONSTERS` are preserved
under `archive/godot/`, excluded from the playable catalog and browser pack.
MACHINE is planned, not yet playable. YOU retains native camera functionality
and a clear browser fallback. See [current implementation status](docs/releases/alpha-0.2-status.md).

The published Alpha 0.1 preview is unchanged and still contains all ten levels.

```sh
make editor  # Open the Godot project
make run     # Launch the Matrix hub
make check   # Archive guard, Godot imports, hub/level behavior and startup
make runtime-check # Fresh archive-free import and all active routes
```

Maps are authored directly in Godot. Open `hub/world.tscn`,
`levels/untitled/world.tscn`, or a scene under
`levels/bubby/maps/`; select a TileMapLayer and paint.
Save the scene normally. Edit collision/interaction markers in the 2D editor.
No Tiled, CSV edits or scene-generation command is required.
See [native map editing and verification](docs/migration/native-maps.md).
`make editor-map-check` verifies open/paint/erase/save/reload in an actual
Godot editor using a disposable copy; it requires a desktop display.

On this Mac the default executable is
`/Applications/Godot.app/Contents/MacOS/Godot`. On another machine, use
`make check GODOT=/path/to/godot` (or `GODOT=godot` if on PATH). Validation
requires Python 3 as development tooling and rejects engines other than
4.7.2 stable. The game itself uses GDScript only.

- `app/`: application startup, registry and level routing.
- `hub/`: opening, room, player, camera and terminal.
- `levels/`: independent Godot level modules (Stage 4).
- `shared/`: intentionally reused Godot resources.
- `scripts/`: development tools and validation.

See [the parity checklist and manual acceptance steps](docs/migration/parity-checklist.md)
and [migration inventory/log](docs/migration/README.md).
The original [project documentation](legacy/pygame/README.md), games, assets,
Tiled workspace, and Windows packaging tools remain in `legacy/pygame/`.
Godot excludes the archive from resource scanning. Ported assets
live with their Godot modules, with attribution preserved.

Run the archived hub using the existing local environment:

```sh
cd legacy/pygame
../../.venv/bin/python main.py
```

Or install `legacy/pygame/requirements.txt` into a Python environment and run
`python3 main.py` from that directory. Individual levels still support
`python3 -m levels.<level_name>` there. `make legacy-check` at root checks the
archive with the local environment. Its Windows workflow still builds archived
Untitled. A reproducible single-threaded Godot Web preset is configured;
other platform packaging is not configured or certified.

The archive remains tracked until manual Godot playtesting and explicit
approval to remove it. See [hub parity and manual checks](docs/migration/hub-parity.md) for verification
and known differences. Move with WASD/arrows; E opens the nearby terminal.
Escape closes the terminal, returns from a level, or quits from the room.

## Alpha 0.1 technical preview

**[Play in your desktop browser](https://fayed-gaya.github.io/matrix/)** ·
[Release, web/source downloads and checksums](https://github.com/Fayed-Gaya/matrix/releases/tag/v0.1.0-alpha.1)

Published as `v0.1.0-alpha.1` with explicit owner acknowledgement of unresolved
licensing issues. This is not licensing clearance or full gameplay certification.

See [development workflow](docs/development.md), [web build/hosting/CI](docs/releases/web-release.md),
[preliminary licensing blockers](docs/releases/licensing-audit.md), and
[implementation status](docs/releases/alpha-0.1-status.md). Build with
`make web-templates && make web-export`, then `make web-serve`. All ten levels
remain included. Publication, tags and merges require explicit authorization.
