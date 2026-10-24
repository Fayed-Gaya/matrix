# Pegasus and asset consolidation

Work branch: `refactor/pegasus-assets`, based on integrated main `a3588fb`.
Matrix remains the application; Pegasus is its opening spaceship, not a level
registry entry. Bubby #18 and Busboy #19 remain independent, unmerged work.
Owner checkout edits, private artwork and audio commit are not incorporated.

## Legacy audit and decision

`legacy/` has 772 tracked files (40,339,647 bytes), including its ignore marker
and the 771-file Pygame baseline. `archive/` has 670 files (37,923,490 bytes),
primarily retired Godot modules and original spaceship resources, not a second
Pygame implementation. 183 legacy files have no byte-identical copy elsewhere
in this checkout (Git-normalized text, not a semantic equivalence comparison).
They include original Python gameplay, TMX/TSX/CSV sources and development notes.

Active Godot gameplay and exports do not need legacy files. Development still
uses them: `make check` → `archive-check`, licensing provenance matching,
project exclusion validation, archived Python CI and manual Windows packaging.
The historical Godot check reconstructs pinned `145771f` from Git independently.

**Retained.** AGENTS requires explicit archive removal authorization following
manual playtesting, in its own commit. The cleanup request conditionally defers
removal when significant unique material remains. A future decision must approve
retiring these unique working-tree sources to Git history and removing their
preservation check/archived CI/provenance lookup. Do not infer that approval
from this structural cleanup. No archive or excluded Bubby/Busboy source changed.

## Checkpoints

- Rename: Pegasus scene/classes, app property/router, inputs, mobile contexts,
  active tests/fixtures and current instructions updated together. Focused
  `make fast-check CHECKS="pegasus mobile"` passed.
- Assets: centralized 59 runtime files (57 PNGs, two audio files) plus 59
  import sidecars, and all tracked editable art. Exactly 100 media/editable
  files compared byte-identical; all import UIDs and `[params]` retained.
- Full Godot, archive (771 files), fresh runtime and isolated PCK checks pass.
  Five available browser projects passed (2.5 minutes): desktop Chrome/Firefox,
  mobile Chrome, DPR-3 Chrome layout and mobile WebKit. Local Edge is absent; CI
  installs it. Final export includes explicit unassigned-audio/source exclusions.

Historical release/review records retain their original names and locations
as evidence of those revisions. Current paths and commands supersede them.

## Resulting layout

```text
app/                     Matrix application and routing
pegasus/                 opening spaceship scenes/scripts/TileSet
levels/                  seven independent modules; maps/JSON stay here
shared/                  reused scripts/resources
assets/art/source/       editable originals; .gdignore excludes imports
assets/art/{pegasus,bubby,busboy,machine,bounce,bug,shared}/
assets/audio/{bubby,busboy}/
archive/                 excluded historical Godot implementations (unchanged)
legacy/                  preserved Pygame sources (retirement deferred)
docs/ scripts/ tests/ LICENSES/ .github/
```

`Pegasus`, `PegasusWorld`, `PegasusPlayer`, `PegasusOverlay` and
`PegasusWebTerminal` replace spaceship-specific class names. `MatrixApp` owns
`pegasus` and `return_to_pegasus`; `MatrixLevel`/`return_requested` remain
application-wide. Input/context/check selector names use `pegasus`; bindings,
movement, map cells and all seven terminal codes are unchanged.

## Applying alongside existing work

This isolated worktree is `/tmp/matrix-pegasus-cleanup`; the original checkout
is deliberately not switched or modified. Its dirty TileSets/project settings,
private `art/Sprite.aseprite` and separate audio commit `f08b12e` are preserved.
Git moves tracked artwork only. When integrating in that checkout, move the
private sprite to `assets/art/source/Sprite.aseprite` separately, retaining its
untracked status; do not overwrite any file. Bubby #18 and Busboy #19 will need
asset-path and app/input-name reconciliation when eventually integrated. Their
creative commits have not been changed or included here.

The standalone RedGIFs audio is not introduced from its separate local branch.
If later integrated, its explicit export exclusion and PCK absence check prevent
accidental browser packaging. Redistribution rights remain unverified.

## Final verification

- `make check`: six Python tool/layout tests, exact Godot 4.7.2 import,
  all active resource/scene loads, Pegasus input/collision/terminal/routes,
  seven gameplay suites, native edit/save/reload, mobile and startup passed.
- `make runtime-check`: fresh archive/cache-free imports and seven routes passed.
- `make web-export`: single-threaded Compatibility export and isolated PCK audit
  passed. Final exclusion-only export rerun verifies staged bytes before delivery.
- Local Playwright: five projects passed; checks include keyboard and touch entry,
  all seven returns, resizing/rotation and browser error guards.
- Relocated Aseprite single-frame export passed; temporary probe PNG removed.
- Current inventory freshness, focused Ruff and `git diff --check` passed.
- Archive/level-source trees unchanged. Historical releases/review records retain
  original terminology; migration docs clearly separate current editing paths
  from historical evidence. No new CI workflow is needed: existing active CI
  runs the updated Makefile/tools; archived CI remains because legacy is retained.

No human gameplay, audible-audio or physical-device acceptance claimed.
Owner authorized PR #20 integration on 2026-10-24: merged at `64675b4` with
all three commits preserved after successful PR CI. No release/tag/deployment.
Reconcile the still-open creative branches separately. Routine development now
uses the direct-main/optional-PR policy in `docs/development.md`; the original
branch checkpoint above records this cleanup's historical execution.
