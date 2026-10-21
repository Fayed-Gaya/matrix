# Matrix migration guide

The repository is migrating from Pygame CE to Godot 4.7.2 with GDScript and
Compatibility rendering. The hub, Bouncing Ball, Balls, The Bug, Pong, and Jump are migrated; five level ports
are pending.

- Keep `project.godot` at the repository root. Use typed GDScript for gameplay.
- `app/` owns startup/routing, `hub/` the spaceship/terminal, `levels/` the
  independent games, `shared/` reused resources, `scripts/` validation tools.
- `legacy/.gdignore` excludes Python/assets from Godot imports. Copy required
  assets into their Godot module; keep the archive independent and intact.
- Commit Godot `.uid` sidecars; ignore `.godot/` and generated exports.
- `make check` validates exact engine version, imports, resource loads and startup.
  It also verifies converted map data, terminal behavior, routing/return, and both movement demos against source traces.
  `make hub-map` regenerates the native hub map from its copied TMX source.
  `make editor` opens the project; `make run` launches it. Override `GODOT`
  with the executable path on other machines. Python 3 runs validation tooling
  only; the Godot game must not depend on Python or the archived environment.
- Use independent level modules inside one application, with a small hub/router.
  Level roots extend `MatrixLevel` and emit `return_requested`; the router
  frees the level tree and resumes the hub. Consume Escape for local menus.
  Add completed scene paths to `app/level_registry.gd`. Empty paths deliberately
  show pending status, and must never be described as migrated gameplay.
- Preserve terminal codes and distinguishing mechanics; track parity explicitly.
- Do not add persistence, accounts, cloud services, or downloadable content.
- `legacy/pygame/` is the preserved runnable reference. Do not delete it until
  the user authorizes removal after manual gameplay testing, in its own commit.
- Read `legacy/pygame/AGENTS.md` for archived Python development instructions.
- Use `docs/migration/README.md` for inventory, risks, and milestone status.
- Commit and push each completed level to the migration branch, as authorized
  by the user. Do not merge.
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
