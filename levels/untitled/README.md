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
- `world.py`: Tiled map loading, tile drawing, collision objects, spawns, and NPCs.
- `camera.py`: camera follow logic.
- `interaction.py`: placeholder NPC and dialogue box.
- `settings.py`: display, color, movement, and dialogue constants.
- `paths.py`: file-relative asset paths.
- `assets/maps/area_earth.tmx`: first placeholder Tiled map.
- `assets/tilesets/placeholder_tiles.tsx`: placeholder Tiled tileset.
- `assets/backgrounds/environment_forestbackground.png`: opening background image.
- `assets/audio/forest_ambience.mp3`: looping forest ambience for the level.

## Tiled Map Conventions

The game currently loads `assets/maps/area_earth.tmx` with `pytmx`.

Use these Tiled layers:

- `Ground`: base tile layer.
- `Details`: normal decorative tile layer.
- `Above`: tile layer drawn after the player, for treetops or overhead art.
- `Collision`: object layer with rectangles that block player movement.
- `Spawn`: object layer with a point named `player`.
- `NPCs`: object layer with NPC points. Add a custom `dialogue` property for
  each NPC's text.

The placeholder tileset is intentionally rough. Replace the placeholder `.tmx`,
`.tsx`, and `.png` files with the real map and tilesets once the first Tiled map
is ready.
