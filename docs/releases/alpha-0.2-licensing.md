# Alpha 0.2 asset/provenance addendum

This is an implementation inventory, **not distribution clearance**. The
[Alpha 0.1 audit](licensing-audit.md), notices and license texts remain intact.
Its original `third-party-inventory.json` is preserved as the historical
pre-Alpha-0.2 snapshot. Release validation checks the separate
`alpha-0.2-third-party-inventory.json` via `python3 scripts/audit_licenses.py --check`.
The active inventory includes module source-reference copies for provenance;
its counts do not equal exported resource counts. PCK auditing checks actual
archive/source exclusions and retired import-cache fingerprints.

| Content | Alpha 0.2 treatment | Remaining issue |
| --- | --- | --- |
| Pong/Jump/Mario/Monsters | Source/art/checks preserved under excluded archive/godot | Existing licensing questions remain; retirement is not a clearance finding |
| Original hub | Preserved as excluded reference; replaced with original local pixel art | Original notices retained; artistic acceptance of replacement pending |
| Bubby avatar/music and Zelda-derived exploration | Copied active assets; full original Zelda retained in excluded module source | Existing tutorial/code/art/audio permission questions unresolved |
| Busboy forest tiles, avatar/NPC, opening, ambience and Untitled exploration | Existing assets/code reused; full original module retained in excluded source | No evidence establishes Kobe ownership/approval; original grants remain unresolved |
| Busboy turn model | Small new model informed by archived Monsters action flow; no archived runtime/party/assets loaded | Retain provenance; do not infer tutorial-derived code clearance |
| New cabin, provisional Bubby environments/pigeon, provisional Busboy root/props, Machine settlement/governor | Locally authored SVG/raster/Aseprite source and PNG exports; no paid generation or external art input | Draft creative work; no Kate biography or Kobe direction implied |
| BOUNCE/BALLS/BUG/YOU/shared fonts | Retained | Original audit/open questions still apply |

No levels/notices were silently deleted or relicensed, and no new publication
or legal-clearance decision is made. Alpha 0.1 publication approval does not
automatically authorize an Alpha 0.2 release. Personal references and final art
approval remain separate from licensing questions and automated test results.

## Centralized asset paths

Current runtime graphics/audio live under `assets/art/<experience>/` and
`assets/audio/<experience>/`; editable masters live under excluded
`assets/art/source/`. Pegasus is the current spaceship name. Original assets
and attribution in archive/godot and level source snapshots are preserved.
Pygame sources were retired to Git history at `55c803c4c8488db9dd17b36bbecd62f775cd52d8`;
current auditing uses the frozen Alpha 0.1 inventory, not a missing source tree.
The refreshed current inventory records new paths and preserved content hashes;
relocation establishes no new permissions. Unassigned RedGIFs audio on a separate
local branch has unverified redistribution rights and is excluded from web export.
