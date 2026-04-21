# Matrix

Matrix is a Python/Pygame sandbox containing small games, demos, and
tutorial-style projects. The repo is currently organized as a collection of
independent levels under `levels/`, with a root launcher that starts the Jump
game.

## Setup

Create and activate a virtual environment, then install the project
dependencies:

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
```

The project uses `pygame-ce`.

## Run

Run the current default game from the repository root:

```bash
python main.py
```

At the moment, `main.py` launches `levels.jump.jump.jump()`.

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

## Project Structure

- `main.py`: root entry point; currently starts the Jump game.
- `requirements.txt`: Python dependency list.
- `levels/`: independent Pygame games and experiments.
- `Tiled/`: Tiled map editor files.
- `AGENTS.md`: repo guide for Codex and other coding agents.

## Development Notes

- Treat each level as mostly independent unless a task explicitly asks for a
  shared launcher or cross-level refactor.
- Some older tutorial files use relative asset paths and need to be run from a
  specific directory. The per-level README should say when that is true.
- Asset files such as images, audio, fonts, CSV maps, TMX maps, and TSX tilesets
  are part of the project when they belong to a level.
- Do not commit `.DS_Store`, `__pycache__/`, `.pyc`, virtual environments, or
  IDE metadata.

## Current Direction

Matrix is currently a collection of Pygame experiments. A likely next step is a
proper launcher/menu that can start each level from one place, followed by
cleaning up path handling so every level can run reliably from the repository
root.
