# Matrix

Matrix is migrating to **Godot 4.7.2, GDScript, Compatibility renderer** in this
existing repository. Stage 1 preserves the original implementation; the Godot
project will be initialized at the repository root in Stage 2.

See [the migration inventory and plan](docs/migration/README.md).
The original [project documentation](legacy/pygame/README.md), games, assets,
Tiled workspace, and Windows packaging tools are in `legacy/pygame/`.

Run the archived hub using the existing local environment:

```sh
cd legacy/pygame
../../.venv/bin/python main.py
```

Or install `legacy/pygame/requirements.txt` into a Python environment and run
`python3 main.py` from that directory. Individual levels still support
`python3 -m levels.<level_name>` there.

The archive remains tracked until manual Godot playtesting and explicit
approval to remove it. No Godot gameplay parity is claimed at this stage.
