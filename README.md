# Matrix

A Godot 4.7.2 / GDScript / Compatibility game anthology. **Pegasus** is the opening
spaceship; its terminal launches independent experiences inside one application.
Move with WASD/arrows, interact with E, and use Escape for local menus/return.
**Rebirth (Alpha 0.2)** is in development; no release date or tag is finalized.
Landscape touch controls are available. See [level codes](app/level_registry.gd)
and each [module README](levels/README.md) for gameplay.

```sh
make editor
make run
make fast-check CHECKS=pegasus
make smoke-check
```

- [Development and testing](docs/development.md)
- [Art workflow](docs/art-pipeline.md) · [Pegasus visual reference](docs/reviews/hub-round2/README.md)
- [Rebirth (Alpha 0.2) roadmap and release requirements](docs/releases/alpha-0.2.md)
- [Publishing](docs/releases/publishing.md) · [Licensing](docs/releases/alpha-0.2-licensing.md)

`app/` routes, `pegasus/` starts the game, `levels/` owns independent gameplay,
and `shared/` holds reused code. Runtime media lives in `assets/art/` and
`assets/audio/`; editable originals are excluded under `assets/art/source/`.
Native scenes and TileSets are authoritative. Historical Godot modules remain
under excluded `archive/godot/`; the retired Pygame implementation is available
[in Git history](https://github.com/Fayed-Gaya/matrix/tree/55c803c4c8488db9dd17b36bbecd62f775cd52d8/legacy/pygame).

[Published Alpha 0.1 preview](https://fayed-gaya.github.io/matrix/) ·
[Immutable release/source/checksums](https://github.com/Fayed-Gaya/matrix/releases/tag/v0.1.0-alpha.1).
That ten-level technical preview was authorized with unresolved licensing issues;
it is not clearance or acceptance of current development. Routine validated
work can be pushed to main; tags, public releases/deployments and release
acceptance still require explicit owner approval.
