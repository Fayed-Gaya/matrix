# Zelda

## Overview

Zelda is a larger top-down RPG project. It includes a tile map, player movement,
combat, enemies, weapons, magic, particles, UI, audio, and an upgrade menu.

## Run

From the repository root:

```bash
python -m levels.zelda.code.main
```

## Controls

- `Up Arrow`: move up.
- `Down Arrow`: move down.
- `Left Arrow`: move left.
- `Right Arrow`: move right.
- `Space`: attack with the selected weapon.
- `Left Ctrl`: use the selected magic.
- `Q`: switch weapon.
- `E`: switch magic.
- `M`: toggle the upgrade menu.

Upgrade menu:

- `Left Arrow`: move selection left.
- `Right Arrow`: move selection right.
- `Space`: upgrade the selected attribute if enough experience is available.

Close the window to quit.

## Files

- `code/main.py`: main game loop and top-level event handling.
- `code/level.py`: map loading, sprite groups, collisions, attacks, enemies, and
  level rendering.
- `code/player.py`: movement, attacks, magic, stats, and input handling.
- `code/settings.py`: dimensions, colors, weapons, magic, and enemy data.
- `code/resources.py`: asset and map paths.
- `map/`: CSV map layers.
- `graphics/`: player, monster, weapon, object, tilemap, particle, and font
  assets.
- `audio/`: music and sound effects.

## Notes

The `levels/zelda/code/` package is the newer path-safe version of this level.
There are also legacy files directly under `levels/zelda/`; prefer the `code/`
package for new work unless a task specifically targets the legacy files.
