# Bouncing Ball — BOUNCE

Launch Matrix with `make run`, enter `BOUNCE` at the terminal, and watch the ball
reflect off the edges. Escape returns to the same pegasus position. Closing the
application window quits Matrix.

This is a movement demo, with no score, player input, sound, or game-over state.
The original image starts at (0, 0), moving down and right. Each update moves
one logical pixel per axis; crossing an edge reverses that axis. Exact contact
does not reverse direction, and the one-pixel overshoot is retained and clipped
at the playfield boundary.

## Source and assets

Reference: [original Pygame source](https://github.com/Fayed-Gaya/matrix/blob/55c803c4c8488db9dd17b36bbecd62f775cd52d8/legacy/pygame/levels/bouncing_ball/bouncing_ball.py) at the Stage 1
baseline. `source/intro_ball.gif` is an unchanged copy of the original asset,
excluded from Godot import scanning. `assets/intro_ball.png` is its 111×111
Pygame-rendered surface converted to RGBA PNG for Godot, including color-key
transparency. Every decoded/rendered pixel was compared successfully. No art
was redrawn, and no new attribution or licensing claim is introduced.

Runtime uses only the GDScript scene and PNG in this module; it does not require
Python, Pygame, or the archive.

## Differences and validation

- **Timing:** the Pygame loop is uncapped and advances one pixel per iteration,
  so wall-clock speed depends on the machine/display. Godot retains the update
  rule but runs it at a fixed 60 ticks per second: 60 logical pixels per second
  on each axis. This is an intentional pacing change, not exact timing parity.
- **Window:** the original creates a fixed 1200×1000 window. Within the shared
  Godot app, that logical field scales uniformly to fit the existing resizable
  window and is centered with black margins. No window-size change is forced.
- **Return:** Escape and a small onscreen hint are new; the source only quits.
- Texture sampling at fractional scales can differ; manual visual/feel review
  and other-platform testing remain necessary.

Optional `make regression-check` verifies a historical 5,000-tick trace produced by the original Pygame Rect
update sequence, image dimensions, contact/overshoot/corner behavior, fixed tick
rate, live scene motion, resize fitting, `BOUNCE` routing, Escape cleanup, pegasus
position preservation, and fresh state on reentry. These checks passed, along
with imported transparency checks and a real OpenGL Compatibility-window run.
The window capture was visually inspected. Manual review: launch `BOUNCE`,
watch each axis bounce (about 15–19 seconds to the first edges at this pacing),
resize the window, return with Escape, and launch again. Other-platform exports
have not been tested.

The trace is `scripts/validation/bouncing_ball_reference.json`: each row is
`[x, y, direction_x, direction_y]` after one source iteration, starting at
`Rect(0, 0, 111, 111)`, speed `[1, 1]`, bounds 1200×1000. It was recorded with
the archived Pygame implementation's move-then-reflect rule; the Godot test
consumes it as expected results, not a second Godot implementation.

Godot's fixed-tick behavior is documented in the official
[processing guide](https://docs.godotengine.org/en/stable/tutorials/scripting/idle_and_physics_processing.html).
