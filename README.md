# Matrix

Matrix is migrating to **Godot 4.7.2, GDScript, Compatibility renderer** in this
existing repository. The root Godot project now runs the opening screen and Matrix hub. `BOUNCE`, `BALLS`, `BUG`, `PONG`, `JUMP`, `UNTITLED`, `MARIO`, `ZELDA`, `MONSTERS`, and `YOU` have Godot modules. You uses native
camera feeds; live hardware remains untested and stock Godot has no Windows/web
camera backend. Each level documents parity differences and manual checks.

```sh
make editor  # Open the Godot project
make run     # Launch the Matrix hub
make check   # Archive guard, Godot imports, hub/level behavior and startup
make runtime-check # Fresh archive-free import and all ten routes
```

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
Untitled; Godot export presets and platform packaging are not established yet.

The archive remains tracked until manual Godot playtesting and explicit
approval to remove it. See [hub parity and manual checks](docs/migration/hub-parity.md) for verification
and known differences. Move with WASD/arrows; E opens the nearby terminal.
Escape closes the terminal, returns from a level, or quits from the room.
