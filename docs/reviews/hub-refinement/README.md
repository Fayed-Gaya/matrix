# Hub refinement review captures

Captured from the implementation in `371696c`, using Godot 4.7.2 Compatibility.
These are actual rendered frames, not concept art.

| Native desktop (1280×720) | Landscape Chrome touch emulation (844×390 CSS, DPR 3) |
| --- | --- |
| ![Cabin](room.png) | ![Touch cabin](mobile-room.png) |
| ![Terminal](terminal.png) | ![Touch terminal](mobile-terminal.png) |

The native captures use `scripts/validation/hub_check.gd -- --capture DIR`.
Browser captures come from Playwright's real canvas movement/code/return checks.
Touch emulation does not certify physical iPhone behavior or human movement feel.

Editable art: `art/hub/refinement/`; native room: `hub/world.tscn`. No PixelLab
generation was used. Full status: `docs/releases/alpha-0.2-hub-refinement.md`.
