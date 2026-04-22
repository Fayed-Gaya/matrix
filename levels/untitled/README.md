# Untitled Game

## Overview

Untitled Game is a first-pass 2D action RPG prototype. The current build focuses
on the exploration foundation: top-down movement, camera follow, collision, and
a placeholder NPC interaction.

## Run

From the repository root:

```bash
python3 -m levels.untitled
```

You can also launch it from the Matrix terminal with:

```text
UNTITLED
```

## Controls

- `WASD` or arrow keys: move.
- `E`: talk to the NPC when nearby.
- `Escape`: close dialogue, or quit if no dialogue is open.

## Files

- `main.py`: level entrypoint.
- `game.py`: main Pygame loop.
- `player.py`: player movement and collision.
- `world.py`: placeholder map geometry and collision objects.
- `camera.py`: camera follow logic.
- `interaction.py`: placeholder NPC and dialogue box.
- `settings.py`: display, color, movement, and dialogue constants.

## Notes

The level currently uses drawn placeholder geometry instead of external sprite
or Tiled assets. Tiled map loading should be added after the first playable
prototype is stable.
