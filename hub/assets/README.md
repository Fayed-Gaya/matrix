# Hub asset sources

These assets were copied from the existing repository, without replacing or
modifying archived originals:

- `backgrounds/matrix-opening.jpg`: `legacy/pygame/matrix/assets/backgrounds/`.
- `sprites/player_snoblin.png`: `legacy/pygame/matrix/assets/sprites/`.
- `tilesets/basic-interior.tsx`, `interiors_free_16x16.png`: archived Matrix tilesets.
- `tilesets/intro_forest.tsx`, `16x16.png`: archived shared tilesets.
- `maps/matrix.tmx`: archived Matrix map; only the shared tileset reference was
  changed to the portable local `../tilesets/intro_forest.tsx`.

Original documentation is retained in `legacy/pygame/`; this copy establishes
no new authorship or licensing claim. No new external artwork was added.
The TMX authoring directory is excluded from Godot scanning; runtime uses the
native `hub/world.tscn` generated with `make hub-map`.
