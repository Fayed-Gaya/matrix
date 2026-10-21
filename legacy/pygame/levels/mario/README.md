# Mario

## Overview

Mario is a larger platformer project. It includes an overworld, multiple levels,
terrain and object maps, enemies, coins, health tracking, UI, audio, and sprite
animations.

## Run

From the repository root:

```bash
python3 -m levels.mario
```

## Controls

Overworld:

- `Left Arrow`: move to the previous unlocked level node.
- `Right Arrow`: move to the next unlocked level node.
- `Space`: enter the selected level.

Level:

- `Left Arrow`: move left.
- `Right Arrow`: move right.
- `Space`: jump.
- Close the window to quit.

## Files

- `code/main.py`: main game loop and mode switching between overworld and level.
- `code/level.py`: level loading, scrolling, collisions, enemies, coins, and
  player state.
- `code/player.py`: player movement and animation.
- `code/overworld.py`: overworld map navigation.
- `code/game_data.py`: level metadata and map file paths.
- `levels/`: CSV and TMX level data.
- `graphics/`: character, enemy, terrain, coin, UI, overworld, and decoration
  sprites.
- `audio/`: level music, overworld music, and sound effects.

## Notes

This level uses paths based on the location of its code files, so it can run
from the repository root.
