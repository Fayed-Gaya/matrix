# Tom Pong

## Overview

Tom Pong is a two-player Pong implementation based on Tom Chance's Pygame Pong
project. It uses bat and ball sprites with simple collision physics.

## Run

From the repository root:

```bash
python3 -m levels.tom_pong
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

This level uses paths based on the location of `tom_pong.py`, so it can run from
the repository root.
