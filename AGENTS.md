# Matrix migration guide

The repository is migrating from Pygame CE to Godot 4.7.2 with GDScript and
Compatibility rendering. The hub and all ten registered levels have Godot modules. You uses native camera
feeds with platform/hardware limitations; full gameplay parity is not certified.

- Keep `project.godot` at the repository root. Use typed GDScript for gameplay.
- `app/` owns startup/routing, `hub/` the spaceship/terminal, `levels/` the
  independent games, `shared/` reused resources, `scripts/` validation tools.
- `legacy/.gdignore` excludes Python/assets from Godot imports. Copy required
  assets into their Godot module; keep the archive independent and intact.
- Commit Godot `.uid` sidecars; ignore `.godot/` and generated exports.
- `make check` validates exact engine version, imports, resource loads and startup.
  It also verifies native map cells/regions, native edit/save/reload behavior,
  terminal behavior, routing/return, and movement demos against source traces.
  Godot scenes/TileSets are authoritative: open hub/world.tscn,
  levels/untitled/world.tscn, or levels/{mario,zelda,monsters}/maps/*.tscn
  and paint TileMapLayers directly. Never regenerate maps from TMX/CSV/JSON.
  Preserve each game's custom movement, collision and animation algorithms;
  shared/maps reads native placements and preserves those runtime rules.
  Read docs/migration/native-maps.md for editor instructions and verification.
  `make editor-map-check` opens/edits all maps in a disposable actual editor
  project (requires a desktop display); no authored scenes are changed.
  `make editor` opens the project; `make run` launches it. Override `GODOT`
  with the executable path on other machines. Python 3 runs validation tooling
  only; the Godot game must not depend on Python or the archived environment.
- Use independent level modules inside one application, with a small hub/router.
  Level roots extend `MatrixLevel` and emit `return_requested`; the router
  frees the level tree and resumes the hub. Consume Escape for local menus.
  Add completed scene paths to `app/level_registry.gd`. Empty paths deliberately
  show pending status, and must never be described as migrated gameplay.
- Preserve terminal codes and distinguishing mechanics; track parity explicitly.
- Automated scenes that launch YOU must set root metadata `matrix_test_mode` to
  true before launch, to avoid activating physical cameras. Test with synthetic
  CameraFeeds; real hardware/permission checks remain manual.
- Do not add persistence, accounts, cloud services, or downloadable content.
- `legacy/pygame/` is the preserved source reference. Do not delete it until
  the user authorizes removal after manual gameplay testing, in its own commit.
- Read `legacy/pygame/AGENTS.md` for archived Python development instructions.
- Use `docs/migration/README.md` for inventory, risks, and milestone status;
  `docs/migration/parity-checklist.md` records verified behavior and manual gaps.
- `make archive-check` verifies all 771 archived baseline checksums.
  `make runtime-check` validates fresh imports/routes without the archive/cache.
- Exports are not configured/certified yet. Include runtime `*.json` manifests
  and camera permissions when creating platform packaging.
- Commit and push validated milestones to `migration/native-godot-maps`, as
  authorized by the user. Do not merge.
- Continue level by level without review pauses, as authorized by the user.
  Record limitations and blockers; never claim unchecked parity.
- Keep generated cache data, build output, credentials, and local tools out of Git.
  Track `.import` sidecars that define asset import settings; ignore `.godot/`.

To run the archive from the repository root:

```sh
(cd legacy/pygame && ../../.venv/bin/python main.py)
make -C legacy/pygame PYTHON=../../.venv/bin/python check
```

The root virtual environment is local and is not moved or committed. Its
availability is machine-specific; install archived requirements if needed.
