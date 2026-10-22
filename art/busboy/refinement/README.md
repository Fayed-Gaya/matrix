# Busboy art trial and editable sources

## Actually used

Ten original local raster masters (terrain, traveller, waykeeper, bedroll, table,
shrine, lantern, fern, fungi and glow), with four named Aseprite layers each.
`seed_art.py` records their initial brush/polygon construction and refuses to
replace existing masters without explicit `--reseed`. Never reseed over future
hand edits. Daily sources are Aseprite masters; no map generator/build/runtime
art dependency was added. Explicit isolated batch exports preserve preferences:

```sh
make art-export SOURCE=art/busboy/refinement/terrain.aseprite OUTPUT=levels/busboy/assets/refinement/terrain.png
make art-export SOURCE=art/busboy/refinement/root.aseprite OUTPUT=levels/busboy/assets/refinement/root.png
```

The 16px terrain and 32px directional actor frames retain the source scale;
Godot draws the woodland at 2×. Native layers, individual props, collision and
interaction markers own composition. Background/ambience and a cropped tent
are reused from the existing source; original assets remain intact.

## PixelLab: two actual included-generation trials

Balance before: trial **38 generations**, **$0 credits**. After: **36**, **$0**.
No purchase, paid fallback, subscription, credentials or configuration changes.
A second request was initially rejected by the free plan's one-job concurrency
limit; it was submitted only after the tree completed. Exactly two jobs ran:

| Asset | Job / seed | Output |
| --- | --- | --- |
| Tree | `e313cb05-b7ff-46fa-bb43-e3a8f19a5fb6` / 2210261 | 96×128, transparent |
| Root knot | `77e5c44b-3b99-41e4-821f-2a989d39fa6f` / 2210262 | 96×80, transparent |

Prompts requested original low-top-down fantasy woodland props: drooping mossy
blue-green canopy, gnarled trunk, selective purple outlines and restrained mint
fungal light; a twisted root mound with a pale core and violet fissures, no
humanoid face/text/background. Original downloads are retained as
`pixellab-*-original.png`. Each Aseprite master has a named generated base and an
empty future-refinement layer. Runtime PNGs were explicitly exported from those
masters; no hand-painted cleanup or AI animation is claimed.

Assessment: both are materially stronger than the flat prior placeholders.
The canopy silhouette, trunk layering and root's focal core give the forest a
coherent identity. Repeated trees and simple local character/prop geometry still
show the economical production method. Characters are clearer but less detailed
than generated vegetation. These are static assets; consistent animation,
directional AI output and a complete generated tileset pipeline are untested.
Aseprite source preparation/export and Godot integration were actually tested.

## Found references and missing provenance

Canonical document tabs were read. Its embedded image resolves to a green
pixel-face placeholder, not a useful environmental reference. The Notes tab
links [Clockwork Raven's Green Forest pack](https://clockworkraven.itch.io/raven-fantasy-pixel-art-tileset-green-forest)
and a Tiled tutorial. The publisher page identifies a warm 16-bit forest pack
and has usage terms; this does **not** prove that the repository's Snoblin-named
sheets or atlas came from that pack. No new pack was imported. Existing archive
notes call the player/NPC sheets prototypes/placeholders and supply no author
grant. No reliably attributable original Kobe art was found in tracked sources.
No design here is claimed Kobe-approved or legally cleared.

Best future inputs: Kobe's actual source sheets/reference folder with provenance,
one approved palette/style crop, and preferred protagonist/waykeeper silhouettes.
Optional: one short line or environmental motif he wants retained. These would
improve authenticity; his participation is not required for this playable slice.
