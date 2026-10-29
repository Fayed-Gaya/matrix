# Art workflow

Editable masters live in `assets/art/source/<experience>/`, excluded from imports
by `.gdignore`. Runtime characters belong in `assets/art/sprites/<level>/<character>/`
(or `sprites/shared/<character>/`); other PNGs in `assets/art/<experience>/`. Audio belongs
in `assets/audio/<experience>/`. Track import settings and preserve pixel scale,
nearest filtering, atlas cell positions and transparency. Scene/TileSet editing
owns maps, collision and depth anchors; image export never regenerates them.

```sh
make art-export SOURCE=assets/art/source/simulation/governor.aseprite OUTPUT=assets/art/sprites/simulation/governor/governor.png
```

The helper accepts one explicit single-frame Aseprite source, preserves dimensions
and writes atomically with isolated batch preferences. Override `ASEPRITE` if
needed. Isolation avoids the installed extension's batch-dialog issue without
altering user preferences. Animated sheets need deliberate Aseprite export;
never silently flatten/trim/repack them. SVGs and Aseprite copies do not synchronize.
Never auto-export unrelated/private artwork or overwrite hand edits.

Pegasus's current masters are `assets/art/source/pegasus/round2/`; runtime art is
`assets/art/pegasus/round2/`, with the player in `assets/art/sprites/pegasus/player/`.
The masters use four named raster layers. The local
`seed_art.py --reseed` replaces initial studies: do not run it over later artist
edits. Earlier drafts remain source references, not the current cabin layout.
[Rendered reference](reviews/hub-round2/README.md) shows the approved direction;
inspect real Godot frames when changing visuals, not on unrelated tasks.

PixelLab availability depends on tools exposed to the session. Check callable
capabilities/allowance before experiments; do not incur paid generation or alter
account configuration without authorization. Keep meaningful editable originals
and provider/provenance evidence, and distinguish generation from manual editing.
Do not claim artistic approval or permissions from an import/export success.
See [licensing](releases/alpha-0.2-licensing.md) when adding third-party content.
