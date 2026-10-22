# Matrix hub

Run `make run` from the repository root. Press any key to dismiss the opening.
Move with WASD/arrows; walk toward the computer on the bottom counter. Press E
when the prompt appears, type a code, and press Enter. Backspace edits input;
Escape closes the terminal or quits from the room. Codes ignore surrounding
whitespace and letter case, and input is limited to 18 characters.

Current codes: `ZELDA`, `BALLS`, `BOUNCE`, `BUG`, `YOU`, `UNTITLED`.
PONG/JUMP/MARIO/MONSTERS are archived for Alpha 0.2; BUBBY/BUSBOY replacements
and MACHINE will enter the registry when their implementation is ready. Each opens its native Godot level module. Escape returns to
the same hub position without replaying the opening; some levels close a local
menu first. See each level README for controls and parity limitations. You camera
capture depends on native platform support and needs hardware testing.

- `hub.tscn` / `hub.gd`: lifecycle, input, terminal, 2x SubViewport, camera bounds.
- `overlay.gd`: opening, terminal and interaction hint at full window resolution.
- `player.gd`: sprite animation and 16x16 rectangle collision movement.
- `world.tscn`: authoritative native TileMapLayers, collision rectangles and markers
  stored as exported world properties. `world.gd` defines those properties.
- `assets/`: independent copies of the existing map, sheets and background.

The current map is preserved as authored, including its open green ground and
furniture arrangement. A more elaborate spaceship interior is future content.

Open `hub/world.tscn` directly in Godot. Select Ground, Details or Above and
paint using the TileMap panel; `tileset.tres` contains the original atlas sources.
Move PlayerSpawn and resize/move Terminal in the 2D editor. Expand Collisions to
edit rectangle shapes. Existing custom movement reads these shapes directly.
Map bounds are exported on World. Save normally; no regeneration is required.

`make check` compares the baseline cells/rectangles with a frozen regression
fixture and exercises terminal routing and movement. Intentional map changes
need corresponding regression expectations updated. The fixture is not an
editing source. See [native map authoring](../docs/migration/native-maps.md) and
[hub parity](../docs/migration/hub-parity.md).
