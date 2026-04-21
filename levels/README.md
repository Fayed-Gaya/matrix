# Levels

The `levels/` directory contains independent Pygame games, demos, and
experiments. Each level owns its own code and assets unless noted otherwise.

## Catalog

| Level | Type | Notes |
| --- | --- | --- |
| `jump` | Endless runner | Current default game launched by `python main.py`. |
| `mario` | Platformer | Larger project with overworld, levels, enemies, coins, audio, and UI. |
| `zelda` | Top-down RPG | Larger project with combat, enemies, weapons, magic, upgrades, audio, and UI. |
| `tom_pong` | Pong clone | Two-player paddle game. |
| `balls` | Movement demo | WASD movement with screen wrapping. |
| `bouncing_ball` | Minimal demo | Image bounces around the window. |
| `the_bug` | Debug demo | Mouse position and button state overlay. |
| `you` | Camera demo | Displays camera input in a Pygame window. |

## Running Levels

Some levels can be run as Python modules from the repository root. Others still
have legacy internals, but every launchable level now exposes the same package
entrypoint. Check each level's README for controls and notes.

The default root command is:

```bash
python3 main.py
```

Run a specific level with:

```bash
python3 -m levels.<level_name>
```

## Documentation Standard

Each level README should include:

- A short overview.
- A run command.
- Controls.
- Important files and assets.
- Known path assumptions or other quirks.
