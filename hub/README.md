# Matrix hub

Run `make run` from the repository root. Press any key to dismiss the opening.
Move with WASD/arrows; walk toward the computer on the bottom counter. Press E
when the prompt appears, type a code, and press Enter. Backspace edits input;
Escape closes the terminal or quits from the room. Codes ignore surrounding
whitespace and letter case, and input is limited to 18 characters.

Codes: `JUMP`, `MARIO`, `MONSTERS`, `ZELDA`, `PONG`, `BALLS`, `BOUNCE`, `BUG`,
`YOU`, `UNTITLED`. Each currently opens an explicit not-yet-migrated screen.
Escape or its Return button returns to the same hub position without replaying
the opening. These screens test routing; they are not migrated games.

- `hub.tscn` / `hub.gd`: lifecycle, input, terminal, 2x SubViewport, camera bounds.
- `overlay.gd`: opening, terminal and interaction hint at full window resolution.
- `player.gd`: sprite animation and 16x16 rectangle collision movement.
- `world.tscn`: generated native TileMapLayers, collision rectangles and markers
  stored as exported world properties. `world.gd` defines those properties.
- `assets/`: independent copies of the existing map, sheets and background.

The current map is preserved as authored, including its open green ground and
furniture arrangement. A more elaborate spaceship interior is future content.

Edit `assets/maps/matrix.tmx` in Tiled, then run `make hub-map` and `make check`.
The converter deliberately supports this map's finite orthogonal CSV layers and
rectangle/point objects; unsupported transforms or custom/animated tiles fail
instead of being silently discarded. For direct Godot editing, the generated
`world.tscn` is native and editable, but regenerating overwrites those edits.
Keep the TMX as the authoring source for this checkpoint.

`make check` compares every converted cell and collision rectangle with TMX and
checks input, camera/resize, terminal, routing, cleanup, and return behavior.
See `docs/migration/hub-parity.md` for known differences and manual checks.
