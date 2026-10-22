# Alpha 0.2 hub refinement

Branch: `feature/alpha-0.2-hub-refinement`, based on integrated main `fee16d7`.
Implementation commit: `371696c`; [PR #17](https://github.com/Fayed-Gaya/matrix/pull/17).
Scope: hub only; no merge, tag or publication authorized. Owner manually played
the previous hub and confirmed its loop, while requesting creative improvement.

## Implemented

- Compact 512×320 cabin, down from 640×352; clear floor and simple named shapes.
- Prominent paired half-cylinder chambers: raised/open empty berth and opaque
  sealed chamber with life-support indicators, no visible occupant or invented lore.
- Broad framed stars/hull viewport, amber wall lights, muted metal and navy palette.
- Modest corner computer, separate editable sprite with restrained Matrix M.
- Bounded terminal panel, code directory, input/error hierarchy and shared mobile
  button layout; all seven codes and keyboard entry preserved.
- Hub-only speed 260 → 182 px/s (30% slower); other actors untouched.
- Integer 2× desktop / 1× smaller-window rendering shows the entire cabin on
  landscape phones. Camera clamping remains for windows below native room size.
- Original SVG/Aseprite sources under `art/hub/refinement/`; runtime PNGs separate.

The Matrix Google Doc's hub/design/literary sections were read through Drive.
The essay remains inspiration, not canon: no inhabitant identity, caretaker,
dying universe, ship purpose or ending was added.

## Art pipeline finding

PixelLab HTTP configuration exists, but no PixelLab tools are available in this
session. No allowance/billing could be verified; **no PixelLab generation used**,
no paid charges initiated and no credentials/configuration changed. Original
editable pixel art proceeded independently. See [art source/export notes](../../art/hub/README.md). AI quality and
cleanup/time savings remain untested; do not describe this as a full PixelLab trial.

## Verification / next action

- `make check`: passed all stages, all 771 archived checksums and tooling tests.
- Targeted hub/mobile checks passed before the final scaling/sconce additions;
  the subsequent full check includes these additions and passed.
- `make runtime-check`: passed fresh archive/cache-free imports and seven routes.
- `make editor-map-check`: passed actual editor open/paint/erase/save/reload for
  all twelve scenes, plus sixteen native/custom renderer transform combinations.
- All six Aseprite sources exported through `scripts/export_art.py` successfully.
- `make web-export`: passed single-threaded Compatibility export and actual PCK
  route/manifest/excluded-content audit; local only, nothing published.
- Final actual Compatibility room/terminal captures and integration test passed.
- Local Playwright: **5 passed in 3.1 min** — desktop Chrome/Firefox, landscape
  mobile Chrome/WebKit seven-route navigation/return, plus DPR-3 layout/rotation.
  No browser script/resource errors were reported. Edge is covered by CI, not
  installed/tested locally. Mobile emulation is not real iPhone acceptance.
- `git diff --check` and current licensing inventory freshness passed.
- [Review captures](../reviews/hub-refinement/README.md): actual native room/UI
  and mobile Chrome DPR-3 room/UI, inspected visually.
- GitHub CI validates the committed project settings (local pre-existing settings
  remain excluded). Current CI evidence/artifacts live on PR #17.
- Real iPhone, human movement feel, audio and final creative acceptance remain
  unverified. No new manual full-level regression is required by this task.

Existing `project.godot` deletions and private `art/Sprite.aseprite` predate this
work; neither is included. Existing Codex/editor processes were inspected, not
terminated. No competing file edits were observed during implementation.
Archives, historical release records and unrelated user art remain intact.

## Handoff / next action

The hub refinement is ready for optional creative inspection in PR #17.
Implementation and review captures are separate commits; both are pushed.
Check the PR's latest CI status before any later authorized merge. No merge,
tag, deployment or public release was performed. No artistic decision blocks
this implementation; pod occupant/ship lore remain intentionally unspecified.

Logs for this session: `/tmp/matrix-hub-refinement/{check,runtime,editor,export,
browser,capture}.log`. Reproduce with `make check`, `make runtime-check`,
`make editor-map-check`, `make web-export`, then `npm --prefix tests/web test`.
The local run selected Chrome, Firefox, Mobile Chrome, Mobile Chrome HiDPI and
Mobile WebKit; CI additionally runs Edge.
