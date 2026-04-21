# Tom Pong

## Overview

Tom Pong is a two-player Pong implementation based on Tom Chance's Pygame Pong
project. It uses bat and ball sprites with simple collision physics.

## Run

This level currently loads assets from a relative `data/` path, so run it from
the level directory:

```bash
cd levels/tom_pong
python tom_pong.py
```

## Controls

- `A`: move the left paddle up.
- `Z`: move the left paddle down.
- `Up Arrow`: move the right paddle up.
- `Down Arrow`: move the right paddle down.
- Close the window to quit.

## Files

- `tom_pong.py`: game loop, paddle logic, ball movement, and collision handling.
- `data/`: bat and ball sprites.

## Notes

This level has not yet been adapted to run from the repository root.
