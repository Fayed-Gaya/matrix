# Tom Pong — PONG

A/Z move the left bat; Up/Down move the right. Escape returns to Matrix.
The port retains the actual source mechanics: 640×480 black field, 33×33 ball,
22×22 square bats (the original bat image is square), initial angle 0.47 and
speed 13, integer-truncated displacement, ten-pixel bat steps, rejected boundary
steps, shrunken collision rectangles and alternating hit suppression. Releasing
either bat key stops it, matching the source. Missed shots bounce from side
walls; the source implements no scoring, AI, sound or victory condition.

The original caps a frame loop at 60; this port runs its update rule at 60 fixed
physics ticks/sec. The logical field fits the shared resizable window. A controls
hint and Escape return are new. Texture resampling/rendering and event cadence
can differ. Manual simultaneous-key/feel checks and other-platform exports are
still needed; wall-clock/pixel parity is not claimed.

Source: `legacy/pygame/levels/tom_pong/tom_pong.py`, Tom Chance's Tom's Pong
version 0.4, http://tomchance.org.uk/projects/pong. The original declares
“Released under the GNU General Public License”; this derived port retains
that attribution/license notice. Original PNGs remain in `source/`; `assets/`
contains the source loader's smoothscaled runtime images. The archive retains
all original code and documentation. No new ownership claim is made.

The behavior check compares 1,600 updates against actual source Ball/Bat objects,
including positions, angles, hit state, boundary reflections and scripted paddle
motion. The fixture `scripts/validation/pong_reference.json` starts with the
source defaults, uses movement `[-10,0,10,0][(tick//31+index)%4]`, and updates the
ball before both paddles. Hub routing and cleanup are checked separately.
