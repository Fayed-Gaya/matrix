# Bubby refinement art

Twelve original four-layer raster Aseprite masters: soft timber/plaster, sage
furnishings, lavender stone, potted plants and hazy skyline. Native scenes own
composition; props, rails, dirt, collision and interactive doors are separate.
All assets use the same 1px drawing grid; small birds use the large sprite at
reduced scale (a deliberate economical compromise, not bespoke animation).

`seed_art.py` records the initial original raster construction. It refuses to
overwrite masters unless explicitly `--reseed`; **never reseed over hand edits**.
This is an art study tool, not map conversion, runtime dependency or build step.
Aseprite layers are the daily editable source. Export individual masters:

```sh
make art-export SOURCE=art/bubby/refinement/sofa.aseprite OUTPUT=levels/bubby/assets/refinement/sofa.png
make art-export SOURCE=art/bubby/refinement/grand-coo.aseprite OUTPUT=levels/bubby/assets/refinement/grand-coo.png
```

## Actual PixelLab experiment

On 2026-10-22 the session exposed PixelLab MCP tools. `get_balance` reported
trial: 39 included generations, $0 credits. One `create_image_pixflux` call
(96×96 transparent, seed 220226) consumed **one included generation**.
Job `0aa8cca5-8951-4909-b3f3-0faeb740b199`, gallery asset
`33f1e308-ce8a-5c78-a749-283e297cac37`. No credit purchase, paid fallback,
account/credential/configuration changes or extra generations were used.

`pixellab-grand-coo-original.png` preserves the unmodified downloaded result.
`grand-coo.aseprite` preserves that raster as a named base layer plus an empty
refinement layer for future edits. It is not a claim of hand-painted cleanup.
The runtime export is the same picture. Prompt: one oversized friendly ordinary
city pigeon, tiny head/large pearl breast, slate layered wings, sage/lavender
neck, coral feet/beak, kind eyes, low top-down RPG perspective, transparent,
selective plum outline, muted palette; no clothing/crown/weapon/text.

Assessment: strong readable silhouette, appealing expression and useful feather
shading; materially stronger than the old geometric pigeon. It is one static
view, not a validated directional/animated pipeline. Hops, squash and departure
are simple Godot transforms; flying birds do not have a wing-flap cycle.
Furniture remains a simpler locally drawn style. An artist could unify edge
weight/perspective and improve organic detail; generation did not eliminate
integration/design work. PixelLab service output is recorded transparently;
this document does not assert legal clearance or alter third-party notices.

Apartment/character details remain provisional. Most valuable inputs: a simple
floor plan plus apartment/balcony photographs, approved character reference,
then one meaningful object/line for the ending. No authentic details invented.
