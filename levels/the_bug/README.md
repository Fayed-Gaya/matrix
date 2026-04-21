# The Bug

## Overview

The Bug is a small Pygame debug experiment. It displays a cat image and overlays
mouse position and mouse button state using the local debug helper.

## Run

This level currently uses local relative imports and asset paths, so run it from
the level directory:

```bash
cd levels/the_bug
python the_bug.py
```

## Controls

- Move the mouse to update the debug overlay.
- Click mouse buttons to update the button-state display.
- Close the window to quit.

## Files

- `the_bug.py`: Pygame loop and mouse/debug display.
- `debug.py`: debug text helper.
- `cat.png`: displayed image asset.

## Notes

This level has not yet been adapted to run from the repository root.
