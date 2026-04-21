# You

## Overview

You is a camera capture experiment. It opens a Pygame window and displays frames
from the first detected camera.

## Run

From the repository root:

```bash
python -m levels.you.you
```

## Controls

- `Escape`: stop the camera and quit.
- Close the window to quit.

## Files

- `you.py`: camera initialization, capture loop, and display updates.

## Notes

This level requires a camera device and camera permissions. It raises an error
if no camera is detected.
