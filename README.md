# Matrix

Matrix is a Python/Pygame sandbox containing a top-level hub world plus small
games, demos, and tutorial-style projects. The player starts in Matrix, walks to
a terminal, enters a level code, and launches a level from `levels/`.

## Setup

Create and activate a virtual environment, then install the project
dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install -r requirements.txt
```

The project uses `pygame-ce`.

## Run

Run Matrix from the repository root:

```bash
python3 main.py
```

`main.py` launches the Matrix hub.

You can also run the hub package directly:

```bash
python3 -m matrix
```

## Levels

| Level | Description |
| --- | --- |
| `jump` | Endless runner where the player jumps over incoming obstacles. |
| `mario` | Platformer project with an overworld, levels, enemies, coins, health, and UI. |
| `zelda` | Top-down RPG project with movement, combat, enemies, weapons, magic, upgrades, and UI. |
| `tom_pong` | Two-player Pong implementation. |
| `balls` | Movement and screen-wrap experiment. |
| `bouncing_ball` | Minimal bouncing-ball demo. |
| `the_bug` | Mouse/debug overlay experiment. |
| `you` | Camera capture experiment. |

See `levels/README.md` and each level's own `README.md` for run commands,
controls, and notes.

The Matrix terminal currently recognizes these level codes:

```text
JUMP  MARIO  ZELDA  PONG  BALLS  BOUNCE  BUG  YOU
```

Each launchable level can also be run directly from the repository root:

```bash
python3 -m levels.jump
python3 -m levels.mario
python3 -m levels.zelda
```

## Project Structure

- `main.py`: root entry point; starts the Matrix hub.
- `matrix/`: hub world, terminal UI, and level registry.
- `requirements.txt`: Python dependency list.
- `levels/`: independent Pygame games and experiments.
- `Tiled/`: Tiled map editor files.
- `AGENTS.md`: repo guide for Codex and other coding agents.

## Development Notes

- Treat each level as mostly independent unless a task explicitly asks for a
  shared launcher or cross-level refactor.
- Levels should use file-relative asset paths and expose a package-level
  `run()` function so they can be launched from the repository root.
- Asset files such as images, audio, fonts, CSV maps, TMX maps, and TSX tilesets
  are part of the project when they belong to a level.
- Do not commit `.DS_Store`, `__pycache__/`, `.pyc`, virtual environments, or
  IDE metadata.

## Current Direction

Matrix now has a first-pass hub and terminal launcher. Returning to Matrix after
a launched level exits is not implemented yet.
