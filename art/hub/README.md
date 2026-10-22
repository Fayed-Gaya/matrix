# Original Alpha 0.2 cabin artwork

These geometric pixel-art cabin tiles and provisional astronaut were authored
locally for Matrix with Codex, without external art inputs or paid generation.
They do not copy Pokémon artwork. Palette: navy/slate, teal lights, warm ivory
and coral. No Kate/Kobe personal references or artistic approvals are implied.

- `cabin-atlas.aseprite`: editable 128×128 atlas, sixteen 32×32 tiles.
- `cabin-player.aseprite`: editable 96×192 sheet; three 32px columns, down/right/up
  in rows 3/4/5 to preserve the current player animator. Left mirrors right.
- Matching SVGs retain the initial editable geometric construction. After
  editing Aseprite sources, exported PNGs are authoritative runtime images;
  SVGs do not automatically synchronize or regenerate.

Export each Aseprite sheet as PNG, at its original size, to
`hub/assets/alpha02/` with the matching name. Do not trim, resize, rotate or
repack cells; nearest filtering preserves pixels. Commit the PNG `.import`
settings. Room composition is edited in Godot, not baked into the image.
`art/.gdignore` and export exclusions keep editable sources out of the game.
The unrelated user `art/Sprite.aseprite` was not used or modified.

On this Mac, Aseprite batch export succeeds but its installed PixelLab plugin
logs dialog errors in batch mode; GUI export avoids that plugin limitation.
No plugin configuration was changed. PixelLab tools were unavailable to this
session, and no generation/API charges were incurred.
