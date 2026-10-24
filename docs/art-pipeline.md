# Editable art and runtime export

Edit `assets/art/source/<experience>/`; runtime PNGs live in
`assets/art/<experience>/` and audio in `assets/audio/<experience>/`.
`assets/art/source/.gdignore` prevents source imports. Track runtime `.import`
settings and script `.uid` sidecars; never track generated caches or previews.
Native scenes/TileSets remain authoritative for map layout, collision and markers.

```sh
make art-export SOURCE=assets/art/source/machine/governor.aseprite OUTPUT=assets/art/machine/governor.png
make fast-check CHECKS=machine
```

Override `ASEPRITE` if needed. The helper accepts one explicit single-frame
Aseprite sheet, preserves dimensions and writes atomically with temporary batch
preferences. It rejects source-directory outputs and animated files rather than
silently flattening them. Export animations deliberately with the intended
sprite-sheet layout. Keep nearest filtering; do not trim or repack atlases.
SVG and Aseprite versions do not automatically synchronize.

| Editable source | Runtime target |
| --- | --- |
| assets/art/source/pegasus/round2/*.aseprite | assets/art/pegasus/round2/*.png |
| assets/art/source/pegasus/cabin-atlas.aseprite | assets/art/pegasus/alpha02/cabin-atlas.png |
| assets/art/source/pegasus/cabin-player.aseprite | assets/art/shared/actors/astronaut.png |
| assets/art/source/bubby/*.aseprite | assets/art/bubby/*.png |
| assets/art/source/busboy/*.aseprite | assets/art/busboy/*.png |
| assets/art/source/machine/*.aseprite | assets/art/machine/*.png |

Never sweep/export private user art. The owner's untracked `art/Sprite.aseprite`
remains in the original checkout during isolated cleanup; Git cannot relocate
untracked files. Move it to `assets/art/source/Sprite.aseprite` only when applying
this structure there, preserving its bytes and untracked status.

## Pipeline evidence

The integrated Pegasus artwork uses layered original raster/Aseprite masters;
its [round-two report](releases/alpha-0.2-hub-round2.md) preserves the actual
experiment, visual assessment and PixelLab availability observed then. Bubby and
Busboy refinement PRs are separate, unmerged work; their findings do not imply
their assets are integrated here. No generation was needed for this refactor.
Do not print credentials, change account settings or incur paid generation
without authorization. Explicit exports isolate Aseprite preferences and avoid
its installed extension's batch-dialog issue without altering configuration.

Current provenance caveats: [licensing addendum](releases/alpha-0.2-licensing.md).
Successful import/export does not establish artistic acceptance or permissions.
