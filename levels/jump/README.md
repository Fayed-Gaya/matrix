# Jump

## Overview

Jump is an endless-runner style game. The player runs across the screen and
jumps over incoming obstacles while the score counts survival time.

This is the current default game launched by the root `main.py`.

## Run

From the repository root:

```bash
python3 main.py
```

Or run the level directly:

```bash
python3 -m levels.jump
```

## Controls

- `Space`: start the game from the intro screen.
- `Space`: jump while running.
- Close the window to quit.

## Files

- `jump.py`: game loop, player, obstacles, scoring, rendering, and audio.
- `graphics/`: player, obstacle, sky, and ground sprites.
- `audio/`: jump sound and background music.
- `font/`: pixel font used for score and intro text.

## Notes

This level uses paths based on the location of `jump.py`, so it can run from the
repository root.
