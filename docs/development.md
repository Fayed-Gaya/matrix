# Development workflow

Use Godot **4.7.2 stable**, typed GDScript, Compatibility renderer. Keep the
project at the repository root. Gameplay never needs Python or the archived
Pygame environment; Python 3 is development tooling. Override `GODOT` with the
engine executable on other machines. Node 22/npm and the pinned Playwright
package/browsers are needed only for browser checks.

## Everyday iteration

```sh
make editor
make run
make fast-check CHECKS=machine      # import/resources + one behavior suite
make fast-check CHECKS="hub bubby" # focused suites; bounce is an alias
make check                         # all seven behaviors/routes/maps + archive/tools
```

Targeted checks always verify engine version, imports and all active resource
loads. Unknown selectors fail; no silent omissions. `make check` retains every
active suite and archive-integrity guard. Cameras are synthetic/test-disabled.
Per-stage times are printed. Do not run full browser/manual matrices for every
local edit; run the affected path, then full checks at a meaningful checkpoint.
Native scenes/TileSets/collision/interaction markers are authoritative. Relevant
level READMEs describe the twelve maps. `make editor-map-check` opens and edits
all maps in a disposable actual desktop editor; it is slower and requires a
GUI, not a substitute for human editor/gameplay acceptance.

## Comprehensive automated release path

```sh
npm ci --prefix tests/web
(cd tests/web && npx playwright install chrome firefox msedge)
make release-check
# Optional real desktop editor persistence:
make editor-map-check
```

This runs full checks, fresh archive-free import/routes, inventory freshness,
web export with staged PCK resource/checksum/retired-import auditing, and the
complete configured desktop browser smoke matrix. CI retains full Godot/fresh
runtime and Chrome/Firefox/Edge coverage. The pack audit is inside web export,
so CI does not repeat it as a separate identical pass. Human full-path gameplay,
audio/feel/art acceptance and real device tests remain separately required.
See current acceptance gaps in `releases/alpha-0.2-status.md`.

```sh
make web-export                    # clean, audited local preview; never publishes
make web-serve                     # localhost:8060
python3 scripts/check_web_pack.py --godot /path/to/godot --pack /path/to/index.pck
```

Export builds in a staging directory, audits actual bytes, then replaces only
the generated local `exports/web/`. Failed builds/audits retain the previous
local preview; successful builds discard stale workers/sidecars. Keep source
files out of managed output. `build-info.json` includes runtime-input dirtiness
and PCK SHA-256; unrelated editable/private art does not mark unchanged runtime
bytes dirty. Build/export/test/art directories are excluded from Godot scanning.
No step deploys Pages, creates tags or changes published Alpha 0.1 bytes.

## GitHub Flow and release authority

`main` is integrated, validated code, with no permanent dev branch. Use short
feature/fix branches and meaningful checkpoint commits/pushes. Open PRs; merges
require explicit owner authorization. Use merge commits to preserve history;
never force-push main. Alpha 0.2 uses stacked PRs: retarget descendants after
approved base merges. CI also checks PRs targeting `feature/alpha-0.2-*`.

Published version tags are immutable. Alpha 0.1 remains `v0.1.0-alpha.1`.
Tagging/publishing Alpha 0.2 needs separate explicit approval; do not infer it
from permission to push feature branches. Pages remains manual and main-only.
The historical `releases/web-release.md` describes Alpha 0.1 packaging/settings;
current release gaps are in the Alpha 0.2 status file.

GitHub Settings → Rulesets/Branches: require PRs, `Godot validation` and `Web
export`, block force pushes/deletion, optionally require up-to-date branches.
Set human review requirements to owner preference. Protect published tags from
updates/deletion. These settings are documented, not automatically bypassed or
changed by this work.

## Catalog, archives and assets

Active codes: BOUNCE, BALLS, BUG, YOU, BUBBY, BUSBOY, MACHINE. PONG/JUMP/MARIO/
MONSTERS are excluded source references under `archive/godot/`. ZELDA/UNTITLED
are replaced without aliases; their complete original Godot sources remain in
Bubby/Busboy `source/`. All Pygame originals remain under `legacy/pygame/`.
`make archived-godot-check` runs the complete original ten-level Godot suite from
pinned historical `145771f` in a disposable tree; that commit must exist locally.
The archived Python quality workflow remains intact; Windows archive packaging
was already manual-only and remains so. No archive is removed in this milestone.

[Art pipeline](art-pipeline.md) covers explicit Aseprite exports, original draft
sources and PixelLab limitations. Current licensing inventory is separate from
the unchanged Alpha 0.1 historical snapshot:

```sh
python3 scripts/audit_licenses.py
python3 scripts/audit_licenses.py --check
```

Output: `releases/alpha-0.2-third-party-inventory.json`. It includes excluded
module source references for provenance, not only exported files. See
`releases/alpha-0.2-licensing.md`; no permissions are newly cleared. Never stage
unrelated user artwork, credentials, caches, generated previews or local tools.

## Phone browser checks

Landscape touch controls and the in-game terminal code picker are enabled on
touch devices. `make fast-check CHECKS=mobile` checks input/routing without
cameras; the full browser matrix includes mobile Chrome/WebKit emulation.
See [Alpha 0.2 mobile acceptance](releases/alpha-0.2-mobile-testing.md) for local
iPhone hosting and the physical-device checklist. Emulation is not iOS approval.

Native iOS is assessment-only: [toolchain and personal-device plan](releases/alpha-0.2-ios-feasibility.md).
