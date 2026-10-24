# Pegasus visual reference

Rendered Godot 4.7.2 Compatibility / browser frames of the cabin refined in PR
#17, preserved for art direction rather than as an ongoing test report. Original
layered raster/Aseprite artwork; no PixelLab generation was used in this pass.

| Room | Terminal |
| --- | --- |
| ![Pegasus](room.png) | ![Terminal](terminal.png) |
| ![Landscape phone room](mobile-room.png) | ![Phone text field](mobile-terminal.png) |

![Open empty and opaque sealed chambers](chambers-closeup.png)

![Foot-anchor depth sorting](depth-check.png)

Sources: `assets/art/source/pegasus/round2/`; map: `pegasus/world.tscn`.
The sealed occupant has no visible identity. Props use foot anchors and native
y-sorting. Browser emulation does not certify the real iPhone keyboard.
[Art workflow](../../art-pipeline.md) describes editing/export; palette/perspective,
repetitive modules and avatar refinement remain artistic choices, not test gates.
