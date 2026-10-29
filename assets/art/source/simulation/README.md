# Provisional Simulation art

Original local pixel artwork, derived partly from the original Matrix cabin
palette/shapes and extended for a clockwork settlement. No external art input,
paid generation, personal details or claimed final artistic approval.

- `town-atlas`: 256×128, thirty-two 32px cells (8 columns).
- `governor`: 32×32, drawn larger in the game as a simple clockwork guardian.
- SVGs retain geometric construction; Aseprite copies support pixel editing.
  They do not auto-synchronize. Export the atlas to `assets/art/simulation/`
  and governor to `assets/art/sprites/simulation/governor/`
  without trimming/repacking/resizing; keep nearest filtering and `.import`.
- Room layout, portals, collision and NPC placement remain native Godot data.
- The shared avatar source remains in `assets/art/source/pegasus/`; its runtime sheet is
  `assets/art/sprites/shared/astronaut/astronaut.png` and is reused by Pegasus/Simulation.

Clockwork premise, colors, architecture and governor appearance/mechanics are
provisional choices for owner review. No new licensing clearance for other
Matrix content is implied.
