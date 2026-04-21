# Mario

## Overview

Mario is a larger platformer project. It includes an overworld, multiple levels,
terrain and object maps, enemies, coins, health tracking, UI, audio, and sprite
animations.

## Run

This level currently uses tutorial-style relative paths, so run it from the code
directory:

```bash
cd levels/mario/code
python main.py
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

This level has not yet been adapted to run from the repository root. A future
cleanup should convert asset and map paths to be based on file locations instead
of the current working directory.
