# Matrix migration guide

Matrix uses Godot 4.7.2, typed GDScript and Compatibility rendering. The
migration and native map authoring are merged. The owner manually tested the
hub and all ten levels locally; browser readiness is a separate milestone.
YOU retains native camera behavior with platform/hardware limitations.

## GitHub Flow

- `main` is integrated, validated code; no permanent dev branch.
- Use short-lived feature/fix branches and PRs targeting main for substantial work.
- Codex may commit and push meaningful feature checkpoints autonomously.
- Never merge into main without explicit authorization for that merge.
- Published releases use immutable version tags; do not create/move release tags
  or deploy/publish without authorization. See `docs/development.md`.
- Alpha 0.1 technical preview is published as `v0.1.0-alpha.1` at `f614691`.
  Use `docs/releases/alpha-0.2-status.md` for current implementation handoffs. Never move
  that tag or replace published package bytes. On 2026-10-21 the owner explicitly
  authorized merging,
  tagging and publishing Alpha 0.1 as a technical preview with documented licensing
  issues unresolved. Use the explicit preview acknowledgement; never claim legal
  clearance. Future releases need fresh authorization. Alpha 0.2 archives four Godot
  levels as requested; preserve their source and the independent Pygame archive.

## Project conventions

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
  levels/untitled/world.tscn, or levels/bubby/maps/*.tscn
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
- Web exports must include active runtime JSON manifests and the active catalog, exclude
  the archive/development sources, and provide a clear YOU fallback with hub return.
- Record limitations and blockers; never claim unchecked browser/platform parity.
- Preserve third-party notices; unresolved licensing remains a clearance blocker.
  Do not remove affected levels silently.
- Keep generated cache data, build output, credentials, and local tools out of Git.
  Track `.import` sidecars that define asset import settings; ignore `.godot/`.

To run the archive from the repository root:

```sh
(cd legacy/pygame && ../../.venv/bin/python main.py)
make -C legacy/pygame PYTHON=../../.venv/bin/python check
```

The root virtual environment is local and is not moved or committed. Its
availability is machine-specific; install archived requirements if needed.

## Alpha 0.2

Read docs/releases/alpha-0.2-status.md before continuing. Retired Godot modules
PONG/JUMP/MARIO/MONSTERS live in archive/godot with original paths preserved
as source references. Never import/bundle them into the active game. Historical
checks remain available via make archived-godot-check. art/ contains editable
sources and user work; copy only approved runtime exports to active modules.
Keep BOUNCE/BALLS/BUG/YOU, evolve ZELDA into BUBBY and UNTITLED into BUSBOY,
then implement MACHINE. No paid generation, fabricated personal references,
merges, release tags or deployments under the current authorization.
