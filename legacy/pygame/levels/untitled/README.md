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
- `sprites.py`: character sheet slicing for player and NPC sprites.
- `assets/maps/untitled-intro.tmx`: current intro map authored in Tiled.
- `../../shared_assets/tilesets/intro_forest.tsx`: shared intro tileset definition.
- `../../shared_assets/tilesets/16x16.png`: shared intro tileset image.
- `assets/sprites/player_snoblin.png`: player prototype sprite sheet.
- `assets/sprites/npc_snoblin_blue.png`: placeholder NPC sprite sheet.
- `assets/backgrounds/environment_forestbackground.png`: opening background image.
- `assets/audio/forest_ambience.mp3`: looping forest ambience for the level.

## Tiled Map Conventions

The game currently loads `assets/maps/untitled-intro.tmx` with `pytmx`.

Use these Tiled layers:

- `Ground`: base tile layer.
- `Details`: normal decorative tile layer.
- `Above`: tile layer drawn after the player, for treetops or overhead art.
- `Collision`: object layer with rectangles that block player movement.
- `Spawn`: object layer with a point named `player`.
- `NPCs`: object layer with NPC points. Add a custom `dialogue` property for
  each NPC's text.
- `Interactions`: optional object layer for signs, campfires, inspect points,
  and other non-NPC triggers.
- `Transitions`: optional object layer for map exits and spawn-targeted travel.

`Tiled/` is the repo-wide Tiled workspace. Runtime maps live with the level that
owns them, and reused tilesets live in `shared_assets/`.

## Packaging

The Windows build packages `untitled` as a standalone app that launches
directly into this level rather than through Matrix.

Packaging files:

- `../../packaging/untitled_main.py`: standalone packaging entrypoint.
- `../../packaging/untitled_windows.spec`: PyInstaller build definition.
- `../../scripts/build_untitled_windows.py`: local/CI build script.
- `../../.github/workflows/build-untitled-windows.yml`: manual GitHub Actions
  workflow that builds and uploads `untitled-windows.zip`.
