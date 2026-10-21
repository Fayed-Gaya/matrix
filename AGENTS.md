# Matrix migration guide

The repository is migrating from Pygame CE to Godot 4.7.2 with GDScript and
Compatibility rendering. Stage 2 establishes the root Godot project; gameplay migration is pending.

- Keep `project.godot` at the repository root. Use typed GDScript for gameplay.
- `app/` owns startup/routing, `hub/` the spaceship/terminal, `levels/` the
  independent games, `shared/` reused resources, `scripts/` validation tools.
- `legacy/.gdignore` excludes Python/assets from Godot imports. Copy required
  assets into their Godot module; keep the archive independent and intact.
- Commit Godot `.uid` sidecars; ignore `.godot/` and generated exports.
- `make check` validates exact engine version, imports, resource loads and startup.
  `make editor` opens the project; `make run` launches it. Override `GODOT`
  with the executable path on other machines. Python 3 runs validation tooling
  only; the Godot game must not depend on Python or the archived environment.
- Use independent level modules inside one application, with a small hub/router.
- Preserve terminal codes and distinguishing mechanics; track parity explicitly.
- Do not add persistence, accounts, cloud services, or downloadable content.
- `legacy/pygame/` is the preserved runnable reference. Do not delete it until
  the user authorizes removal after manual gameplay testing, in its own commit.
- Read `legacy/pygame/AGENTS.md` for archived Python development instructions.
- Use `docs/migration/README.md` for inventory, risks, and milestone status.
- Commit meaningful milestones; do not push or merge automatically.
- Pause for review between migration milestones. Never claim unchecked parity.
- Keep generated imports, build output, credentials, and local tools out of Git.

To run the archive from the repository root:

```sh
(cd legacy/pygame && ../../.venv/bin/python main.py)
make -C legacy/pygame PYTHON=../../.venv/bin/python check
```

The root virtual environment is local and is not moved or committed. Its
availability is machine-specific; install archived requirements if needed.
