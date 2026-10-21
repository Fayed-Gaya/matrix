# Stage 3 hub parity

This checkpoint migrates the hub, not the ten individual games. Those codes
currently route to a clearly labeled pending screen with return controls.
Stage 2 commit `2f67df7` was pushed at the user's request before this work.

| Original behavior | Godot implementation / evidence |
| --- | --- |
| Any-key opening with existing background | Same image and cover crop, key dismisses without activating another action; windowed capture inspected |
| Starting room and art | Same 800×800 map, Ground/Details/Above TileMapLayers and atlas coordinates; all 7,500 layer cells compared to source; rendered room compared visually with freshly rendered archived Pygame room |
| Player art and animation | Same 32×32 sheet rows 3/4/5, mirrored left, idle frame 1, 10 fps walking; manual directional-animation review still needed |
| Movement and collision | 260 world units/sec, normalized diagonals, 16×16 hitbox, axis-separated movement, ten rounded source rectangles and map bounds; speed, obstacle blocking and bounds checked |
| Camera and resize | 2× internal rendering, viewport clipped to map, centered margins, clamped camera; automated checks at 1280×720, 1920×1080 and 640×480 |
| Terminal proximity and pause | Same 24×24 rectangle around the map's point object; reachable without crossing a collision; E interaction and movement lock checked |
| Code entry | Uppercase printable input, 18-character limit, Backspace, Enter, trim/case-insensitive lookup, invalid/empty feedback and Escape closure checked |
| Registered codes | All ten original codes preserved, including UNTITLED; tested through actual terminal key events |
| Launching actual games | Pending Stage 4. All ten currently show explicit pending screens, never substitute generic games |
| Return to hub | New improvement: Escape or pending-screen button frees level and resumes same hub instance/position; opening and terminal stay closed |
| Independent level contract | Tested with a separate fixture scene extending MatrixLevel; root and child timer/audio nodes released on return |

## Intentional differences and remaining limits

Godot uses its fallback font rather than Pygame's built-in font. Text glyphs,
metrics, background resampling and shadow rasterization may differ. The map and
player artwork have not been redesigned. The source room is an open green
space with furniture, not a newly invented spaceship interior.

Movement uses floating-point positions with fixed physics updates and substeps
instead of rounding each Pygame frame's displacement. This avoids low-speed
rounding and thin-wall tunneling, but requires manual feel comparison. Camera
translation is snapped to pixels for crisp drawing. Source rectangle rounding,
hitbox size, speed and layer order are preserved.

The terminal does not show the original transient “Launching …” message: it
switches to the level destination after a deferred frame. No game is launched
as another process. There is no persistence; the hub is retained in memory only.

The return contract removes/frees the entire level root. Future levels must
own their timers/audio/camera under that root and release external resources
(such as camera hardware) when exiting the tree. The fixture tests ownership
cleanup, not real hardware or future port behavior.

## Automated and visual verification

- `make check`: engine pin, imports, script/resource loads, scene instantiation,
  complete tile and collision conversion comparison, input bindings, terminal
  input/proximity/lock, all ten code routes, return and cleanup, camera/resize,
  and application startup.
- The integration suite also ran in a real OpenGL Compatibility window and
  captured opening, room, terminal and pending screens. Captures are temporary
  review artifacts under `/tmp/matrix-hub-review/`, not repository assets.
- A fresh archived Pygame room was rendered with dummy video/audio and compared
  visually with the Godot capture. This is a layout check, not full pixel parity.
- All 771 archived baseline files match their original SHA-256 checksums.
  `make legacy-check`, Python tooling Ruff lint/format, and `git diff --check`
  passed. No archive removal is authorized.
- No Windows/web/mobile export or hardware/input-device testing is claimed.

The development wrapper checks error output as well as process status. Headless
rendering cannot establish visual correctness; the windowed capture supplements
those checks. Reference API documentation: [TileMapLayer](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html)
and [Viewport](https://docs.godotengine.org/en/stable/classes/class_viewport.html).

## Manual review before moving on

Run `make run` and check:

1. Opening crop/text and room drawing at normal and resized window sizes.
2. WASD and arrows in all directions; diagonal speed, animation and collision
   around the bookcase, couch, counter and small furniture.
3. Walk down/right from spawn, around the small obstacles to the computer on
   the bottom counter; press E when prompted. Check invalid input and editing.
4. Try a registered code, inspect the pending notice, press Escape or Return,
   and verify the same player position and responsive controls.
5. Escape closes the terminal; Escape from the room quits the application.

Next milestone: Stage 4, Bouncing Ball (`BOUNCE`), then the other simple games
before the larger platformer/RPG ports. Pause for review at each level commit.
