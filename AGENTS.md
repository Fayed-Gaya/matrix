# Matrix Repo Guide

## Project Overview

This repository is a Python/Pygame sandbox named `matrix`. It contains several
separate mini-games and game experiments under `levels/`. Treat each level
directory as its own small project unless a task explicitly asks for a shared
launcher or cross-level refactor.

The current root entry point is `main.py`, which imports and runs the Jump game:

```bash
python3 main.py
```

Dependencies are listed in `requirements.txt`. The project uses `pygame-ce`.

Every launchable level package should expose `run()` from its `__init__.py` and
include a `__main__.py`, so levels can be started from the repository root with:

```bash
python3 -m levels.<level_name>
```

## Repository Layout

- `main.py`: root launcher; currently starts `levels.jump.jump.jump()`.
- `requirements.txt`: Python dependencies.
- `levels/`: collection of independent Pygame levels and experiments.
- `levels/jump/`: endless-runner style game; currently the default root game.
- `levels/mario/`: larger platformer project with code, maps, audio, and sprite
  assets.
- `levels/zelda/`: larger top-down RPG project with maps, combat, UI, enemies,
  particles, audio, and sprite assets.
- `levels/tom_pong/`: Pong implementation.
- `levels/balls/`: movement and screen-wrap experiment.
- `levels/bouncing_ball/`: small bouncing-ball demo.
- `levels/the_bug/`: mouse/debug display experiment.
- `levels/you/`: camera capture experiment.
- `Tiled/`: Tiled map editor files.

## Development Notes

- Prefer the existing style of the level being edited. The code is not fully
  standardized across levels.
- Keep changes scoped to the requested level or feature. Do not refactor other
  games unless needed for the task.
- Use `pathlib.Path` for new asset paths when practical; several newer files
  already follow that pattern.
- Some older tutorial files use relative paths that assume they are run from
  their own code directory. When touching a level, prefer file-relative paths
  based on `Path(__file__).resolve()` so it can run from the repository root.
- Pygame windows and audio may not work in headless environments. If runtime
  verification is not possible, at least run syntax checks for edited Python
  files.

## Git Hygiene

- Do not commit `.DS_Store`, `__pycache__/`, or `*.pyc` files.
- Do not commit virtual environments or IDE metadata.
- Asset files such as `.png`, `.wav`, `.ogg`, `.ttf`, `.csv`, `.tmx`, and `.tsx`
  are project files and may be committed when they belong to a level.
- Before committing, check `git status --short` and make sure staged files match
  the requested change.

## Useful Commands

Install dependencies:

```bash
python3 -m pip install -r requirements.txt
```

Run the default game:

```bash
python3 main.py
```

Run the Jump game directly:

```bash
python3 -m levels.jump
```

Run a syntax check for Python files:

```bash
python3 -m compileall main.py levels
```

## Current Direction

The repo is currently a collection of separate Pygame experiments. Future work
may turn it into a more coherent project, likely by adding a launcher/menu,
improving documentation, and gradually making individual levels easier to run
from the repository root.
