# Balls — BALLS

Launch Matrix with `make run` and enter `BALLS` at the terminal. WASD moves both
circles; Escape returns to the same pegasus position. Closing the window quits the
application. There are no collisions between circles, score, sound, or game-over
state in the source or this port.

## Preserved behavior

- Logical 1280×720 field, Pygame purple `(160, 32, 240)`, red radius-40 circles
  starting at `(590, 360)` and `(690, 360)`.
- The left circle moves `300 * previous_frame_dt` per axis. The right moves five
  pixels per frame (`300 / 60`). These are intentionally different timing models.
- No diagonal normalization. Opposite directions cancel, and both centers wrap
  modulo the field dimensions, including negative movement.
- Drawing occurs before each movement update. Initial elapsed time is zero.
- Edge copies and all four corner copies appear while a circle crosses a seam;
  copies are clipped to the logical playfield.
- A 60 FPS cap, now temporarily applied through `Engine.max_fps` and restored
  when the level leaves the scene tree, including application teardown.

Reference: `legacy/pygame/levels/balls/balls.py`. This module uses native drawing
and GDScript; there are no external assets or runtime Python dependencies.

## Differences and limits

The source opens a fixed-size window. The Godot level instead scales its logical
field uniformly to fit the existing resizable window, with black margins.
An onscreen controls/return hint and Escape return are additions. A fresh launch
resets both circles; pegasus position is retained in memory only.

Godot circle tessellation, subpixel drawing, and scaling can differ from Pygame's
integer rasterization. Vector precision also differs: the 400-update trace
measured about 0.0002 logical pixels of elapsed-time position error (checked
within 0.001 pixel across wrap seams); the frame-based circle matched exactly.
Actual elapsed-time sampling, scheduler behavior and VSync
may differ, especially during stalls or on slow machines. The timing distinction
and source update sequence are preserved; exact wall-clock or pixel parity is
not claimed. Manual movement/appearance checks and other-platform exports remain
necessary. Godot documents runtime FPS limits in the official
[Engine reference](https://docs.godotengine.org/en/stable/classes/class_engine.html#class-engine-property-max-fps).

## Validation

`make check` includes a level suite with 400 variable-delta source movement
updates and 13 original drawing cases, covering all four corners, exact edge
contact and single-axis seams. The fixture is
`scripts/validation/balls_reference.json`: movement rows were recorded by
executing the archived Python movement statements with Pygame Vector2; drawing
cases were recorded from the archived `draw_wrapped_circle` function with a
capture draw target. Expected data is independent of the Godot implementation.

The suite passed in headless mode and a real OpenGL Compatibility window.
Center and corner-wrap screenshots were inspected, including a direct comparison
with a freshly rendered Pygame center view. A pixel check verifies that corner
copies do not bleed into black letterbox margins.

Additional checks cover live WASD processing, opposing keys, first-frame zero
delta, draw-before-update, frame-vs-delta movement, modulo wrapping, resize fit,
FPS restoration, routing, Escape cleanup, same-position pegasus return, and fresh
state on reentry.

Manual review: enter `BALLS`, hold WASD through horizontal/vertical seams and
all corners, compare the two circles while moving diagonally, resize the window,
then return and launch again. At a steady 60 FPS they should travel nearly
together; frame stalls can expose their different timing models.
