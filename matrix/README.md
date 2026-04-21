# Matrix Hub

## Overview

Matrix is the top-level hub world. The player starts here, walks to a terminal,
enters a level code, and launches one of the existing levels.

## Run

From the repository root:

```bash
python3 main.py
```

Or run the hub package directly:

```bash
python3 -m matrix
```

## Controls

- `W`, `A`, `S`, `D` or arrow keys: move.
- `E`: open the terminal when near it.
- `Enter`: submit a terminal code.
- `Backspace`: edit terminal input.
- `Escape`: close the terminal, or quit Matrix when the terminal is closed.

## Level Codes

| Code | Level |
| --- | --- |
| `JUMP` | Jump |
| `MARIO` | Mario |
| `ZELDA` | Zelda |
| `PONG` | Tom Pong |
| `BALLS` | Balls |
| `BOUNCE` | Bouncing Ball |
| `BUG` | The Bug |
| `YOU` | You |

## Notes

Launching a level currently transfers control to that level. Returning to Matrix
after a level exits is intentionally out of scope for this first hub pass.
