# The Bug

## Overview

The Bug is a small Pygame debug experiment. It displays a cat image and overlays
mouse position and mouse button state using the local debug helper.

## Run

From the repository root:

```bash
python3 -m levels.the_bug
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

This level uses paths based on the location of `the_bug.py`, so it can run from
the repository root.
