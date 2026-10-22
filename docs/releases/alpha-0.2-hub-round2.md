# Hub creative refinement — round 2

Branch `feature/alpha-0.2-hub-refinement`, [PR #17](https://github.com/Fayed-Gaya/matrix/pull/17), based on `dab670f`.
Implementation commit: `c1aa0b6`; review captures/status follow in a separate commit.
Scope: improve room art and remove exposed terminal destinations. No merge,
tag, deployment or publication authorized. Pre-existing `project.godot` edits
and private `art/Sprite.aseprite` are preserved and excluded.

## Current checkpoint / next action

Implementation and actual desktop/mobile/chamber/depth captures are committed
on the existing refinement branch. Follow-up browser findings/corrections are
recorded at the end of this document; their retest is the current action. No creative decision blocks
this pass. Review the [new captures](../reviews/hub-round2/README.md) and latest
PR CI before any separately authorized merge. No merge/release action performed.

Local input run: three browsers passed (1.6 min); refreshed artwork/capture smoke:
two passed (1.1 min). Final native hub/mobile checks and rendered depth inspection
passed. CI on PR #17 runs the full suite and six-browser matrix against committed
settings, excluding the preserved user `project.godot` edits.

## Implemented

- Original shaded, layered raster assets: curved pod casings, opaque sealed cover,
  continuous empty ribbed berth (no head/torso-shaped cushions), latches, vents, mounting/service bay and instrumentation.
- Chamfered hull viewport with recessed glazing, subdued space and fasteners.
- Staggered quieter deck panels, structural ribs and less repetitive wall detail.
- Matching CRT/composite-wood work surface, journal, pencil, cup, tucked chair,
  storage with a folded cloth; scenery only, no personal facts or new interactions.
- Static native amber and teal PointLight2D nodes, separate editable light texture.
- Hub-specific shaded astronaut sheet, preserving shared actors in other levels.
- Minimal dark terminal: monospaced prompt, Matrix mark, enter/close, no directory,
  destination names, world/simulation labels or known-code buttons.
- Real browser DOM text input with autocorrect/suggestions off, 18-character limit,
  uppercase normalisation, native editing and submit, viewport-aware positioning.
  Phone users tap the field to request their OS keyboard. Native touch uses LineEdit.
- Hub movement remains 182 px/s; original seven-code routing is unchanged.

The Matrix Google Doc hub/literary sections were freshly read. The earlier
ChatGPT reference image was unavailable; no claim is made to have viewed it.
The essay is inspiration, not canon; occupant identity and ship lore remain open.

## PixelLab findings (no generation)

- Current session exposes zero PixelLab tools. Plugin discovery returned no match.
- Supported `codex mcp list --json` (filtered, secrets suppressed): PixelLab enabled,
  no disabled reason, auth status `bearer_token`. This is configuration presence,
  **not** a successful server handshake or evidence of valid credentials/allowance.
- Installed Aseprite extension: Pixel Lab 0.4.130. Generation/inpainting/animation/
  texture/quantisation scripts exist; no generation command was invoked.
- No local Codex diagnostic log files were available to establish a server failure.
  Exact cause remains unproven: configured local CLI server is not in this running
  host's tool catalog. Do not label the token expired or promise a restart fixes it.
- No credits/billing allowance could be verified. No paid calls, credential output,
  account changes or bypass via direct generation API.

Minimal unblock: in a local Codex client, inspect `/mcp` or MCP Settings for the
PixelLab connection/status, restart that connection/client if required, open a
session where its actual tools appear, and verify included allowance/account
balance before a controlled generation. Share a redacted connection error if it
still fails. This is optional for progress, required for a real PixelLab trial.

References: [Codex MCP setup/status](https://developers.openai.com/codex/mcp/),
[PixelLab MCP guide](https://api.pixellab.ai/mcp/docs),
[Godot LineEdit](https://docs.godotengine.org/en/stable/classes/class_lineedit.html).
The PixelLab guide specifically advises not bypassing missing MCP tools through
curl/API generation. Configuration alone does not validate the production pipeline.

## Actual art workflow

No AI image generation was used (no verified cost-free allowance). Original
raster brush/polygon/ellipse construction and controlled texture were authored
in `art/hub/round2/seed_art.py`; these are initial studies, not map generators.
Aseprite's Lua interface assembled four independent layers per single-frame
master: Shadow, Construction, Shading, Detail. Isolated batch settings preserve
the user's running GUI/preferences. Existing export helper produced runtime PNGs.
Editable `.aseprite` files are the masters; reseeding requires explicit `--reseed`
and overwrites original studies, so never run it over subsequent hand edits.
Godot native cells, independent props, shapes and lights own room composition.

## Artistic assessment and pipeline recommendations

### A. Tools actually used

Original Python raster brush construction (pixels, masks, polygons, ellipses,
shading ramps and controlled texture), Aseprite 1.3.18.6's Lua
API and isolated batch export, native Godot TileMapLayers, independent Sprite2D
props with floor anchors/native y-sorting, collision shapes and three
PointLight2D nodes. Eleven masters were checked
as single-frame/four-layer files and exported at their original sizes. No manual
GUI brush retouch, external illustration reference, PixelLab generation or
other AI image-generation call occurred. The old SVG construction was reviewed,
then replaced for current runtime art. No new dependency or paid service added.

### B. PixelLab outcome

Not accessible as callable tools in this session; no generation performed.
Configuration and installed extension are real, but neither proves a successful
MCP connection or included generation credits. The observed blocker is the gap
between local CLI configuration and this session's exposed tools. The cause
inside the host/server cannot be established from available diagnostics.
Minimal intervention: verify its active connection in a local client's `/mcp`,
restart/reopen there if needed, then verify the plan/balance and expose tools in
an agent session. Do not send credentials. Actual generation quality, style
consistency and cleanup time are **not validated**.

### C. How good is the art?

Actual native and browser frames were inspected, rather than judging only source
PNGs. Compared with round 1, the pods now have curved shading, rims, latches,
service panels and readable empty/opaque states. The recessed mounting bay,
chamfered viewport, static light, cast shadows and warm desktop make a stronger
shared material language. Journal/pencil/cup/cloth imply ordinary use without
inventing a biography. The matching hub avatar reduces the mismatch with props.
The second rendered pass softened deck seams, reduced repetitive wall vents and
replaced an artificial space hatch pattern with quieter texture.

This is a **materially improved illustrated draft**, not final-production art or
an assertion that the owner's target has been met. It still has an orthographic,
systematic arrangement; broad floor space and repeated hull modules remain
visible. Highlights and texture are code-authored and sometimes mechanical;
lighting lacks a hand-painted environment artist's nuanced bounce/contact work.
The tiny three-frame avatar is serviceable, not a distinctive character design.
The scene has more detail and warmth, but charm/style must be judged against an
approved reference that this session did not have. Export/test success says
nothing about artistic acceptance.

### D. Human involvement: essential versus optional

**Essential for the implemented gameplay:** none; routes, input and editable art
are implemented. Real iPhone keyboard presentation/dismissal cannot be certified
without device access, so owner/device participation is needed to verify that
specific platform claim (not to finish this development pass).

**Essential for a PixelLab trial:** an active tool-exposing connection and verified
included allowance or explicit cost authorization. No key/token needs sharing.

**Highest-value optional art inputs:** the earlier reference image, or one approved
room/prop crop with a few notes on what matters (perspective, density, hue, edge
style). This would reduce guesswork much more than adding more props. A simple
"warmer domestic" versus "cooler spacecraft" preference and one approved pod
silhouette would guide the next pass. Human pixel edits would add most value to
pod highlight clusters, viewport/hull perspective and the avatar's walk cycle.
No occupant identity, personal backstory or additional room decision is needed.

### E. Recommended repeatable pipeline

1. Approve a tiny style kit per experience: one environment crop, one prop and
   one character frame, palette ramps, light direction, camera angle and native
   pixel scale. Matrix, Bubby, Busboy and Machine can retain distinct styles;
   do not force this cabin's look onto all three RPGs.
2. Produce **one asset** at the agreed scale. Current low-cost path is a layered
   Aseprite draft; code-authored raster is useful for studies, repeatable panels,
   masks and functional prototypes. If PixelLab is genuinely connected and cost
   scope verified, trial one pod/terminal with the approved reference first.
   Compare silhouette, palette, cleanup effort and integration work honestly.
3. Refine the winning asset in Aseprite at native size, separating silhouette,
   material shading, fine detail and shadow. A human artist/owner should approve
   that style anchor before producing a whole atlas. AI output, if ever used,
   should be cleaned rather than assumed tile-ready or animation-consistent.
4. Export explicitly through the existing helper, preserving canvas/anchors,
   animation rows and nearest filtering. Commit editable master, runtime PNG,
   `.import` settings and provenance. Never reseed over later hand edits.
5. Assemble native Godot tiles/props/shapes/lights, then inspect real frames at
   desktop and phone sizes. Refine readability, scale and joins before adding
   content. Run focused input/collision checks; use full checks at checkpoints.

Codex can reliably automate asset packing/export validation, layer assembly,
scene placement, collision/resource integration, browser entry and test/capture
work. It can autonomously draft simple props and architectural studies. It
should not promise human-level illustration, a person's likeness, artistic
approval or generative consistency. Complex composition/lighting and the final
style anchor benefit most from a human artist. PixelLab remains an unvalidated
candidate, not a recommended proven accelerator.

## Verification and manual limits

- `make fast-check CHECKS="hub mobile"`: passed native input, seven routes/return,
  182 px/s movement, boundaries, pod/computer collision and native map fixtures.
- `make check`: passed all active suites, archive checksums and tool tests.
- `make runtime-check`: passed fresh archive/cache-free import and routes.
- `make editor-map-check`: all twelve editable scenes plus sixteen renderer
  transform combinations passed in a disposable real editor.
- `make web-export`: passed single-threaded Compatibility export and actual pack
  dependency/manifest/exclusion audit. No publication.
- Initial browser run: Chrome, mobile Chrome, mobile WebKit passed (3 tests,
  2.4 min); real DOM input/focus, unknown input, case normalization, seven routes,
  return, no visible directory, reduced viewport and rotation. Final 180px
  keyboard-space input run: **3 passed in 1.6 min**.
- Eleven Aseprite masters: one frame/four named layers each, exported successfully.
- Current licensing inventory freshness, Python art-source lint and diff checks
  passed. No files under levels/shared/archive/legacy were changed.

Emulation verifies actual DOM editing/focus, not the presence of a phone's OS
keyboard. Real iPhone Chrome/Safari keyboard behavior, zoom/scroll, human movement
feel, audible audio and final creative acceptance remain unverified. No manual
full-level regression was represented as performed. The existing release tag,
archives and unrelated user assets/settings are preserved.


## Resume / evidence

All current implementation is on PR #17. Check its latest CI status/artifacts;
no release tag or deployment was made. Local logs are under
`/tmp/matrix-hub-round2/`: `check.log`, `runtime.log`, `editor.log`, `export.log`,
`fast-final.log`, `browser-final.log`, `browser-captures.log`, `capture.log`,
`closeup.log` and `depth.log`. Captures and this assessment are tracked; temporary
render scripts/logs are not runtime dependencies.

Next artistic input with highest value: the unavailable reference image or one
approved style crop. PixelLab trial additionally needs active tool exposure and
verified allowance. Neither blocks this playable implementation. Physical phone
checks can happen when the owner chooses to test; do not imply they passed.

## Follow-up failures and corrections

Final-head CI run `39754958894` passed Godot/fresh runtime/export and four browser
checks, but both mobile navigation checks hit a real chair obstruction on the
horizontal approach. The chair collider extended to y=188 while the narrowest
pod-front corridor has player centre y=192 (hitbox top y=184). Its visible feet
end earlier. The collider now ends at y=184, preserving the object collision and
clear corridor; a headless long-frame walk reproduces that exact route. Browser
test tolerances, timeouts, routing assertions and console-error guards are unchanged.

An additional local Firefox run loaded/routed all levels but caught a native
canvas shader compilation error at the first terminal opening. Trace output
identified the unlit primitive path in the hidden native terminal drawing under
the HTML terminal. Web now renders the terminal once, through its actual DOM
interface; native terminal drawing remains for native builds. The three room
PointLight2D nodes are retained. The earlier lighting suspicion was not confirmed.

The strengthened native corridor regression passed. Both local mobile browsers
passed after correction. The first Firefox retest exceeded its unchanged 60s
cold-initialization guard before entering the game; the targeted retry passed
all seven routes in 1.7 minutes without shader errors. Evidence: `fixes-fast.log`,
`browser-fixed.log`, `firefox-fixed.log`. These failures were
investigated rather than ignored or hidden by weakening checks.

## Approved integration

Owner approved PR #17; merged with merge commit `a3588fb` on 2026-10-22.
Final feature CI and integrated main CI `39862548809` passed.
No tag, deployment or publication.
