# Monsters

## Overview

Monsters is an RPG inspired by Pokemon and older Final Fantasy games. It
includes an overworld, trainer dialogs, random monster encounters, turn-based
battles, monster stats, evolution, maps, audio, and sprite assets.

## Run

From the repository root:

```bash
python3 -m levels.monsters
```

Or launch it from Matrix with the terminal code:

```text
MONSTERS
```

## Controls

- Arrow keys: move.
- `Space`: interact with characters and advance dialog.
- `Return`: open or close the monster index.
- Battle menus use arrow keys, `Space`, and `Escape`.
- Close the window to quit.

## Files

- `code/`: game logic, battles, entities, data, UI, and support helpers.
- `audio/`: music and sound effects.
- `data/maps/`: Tiled maps.
- `data/tilesets/`: Tiled tileset definitions.
- `graphics/`: characters, monsters, backgrounds, attacks, UI, fonts, objects,
  and tilesets.

## Notes

The imported code is based on the finished version of the external
`Python-Monsters-main` project. It has been adapted to use file-relative paths
and the Matrix level launch convention.

Original project notes credit Scarloxy for the artwork and list several
OpenGameArt sources for sounds.
