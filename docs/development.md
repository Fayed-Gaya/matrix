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
make fast-check CHECKS="pegasus bubby" # focused suites; bounce is an alias
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
audio/feel/art acceptance and real device tests remain release-readiness checks,
not prerequisites for routine development pushes.
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

## Git and autonomous development

`main` is the single permanent development branch, not a release channel. It
may contain validated unreleased work. Codex is authorized to implement, run
appropriate checks, commit meaningful checkpoints and push routine validated
work directly to main without approval for every push. Push at logical
checkpoints, not after every small edit. No permanent dev branch is needed.

Fetch before integrating/pushing. Preserve uncommitted user work; reconcile
remote advances/conflicts safely and rerun affected checks. Use ordinary
fast-forward pushes; never force-push or rewrite published history. Optional
short-lived branches/worktrees help isolate concurrent work. PRs are optional
for major architectural changes, risky experiments, concurrent integration or
explicit formal review, not an automatic step for every task or phase. Honor
any explicit task-specific review gate. Preserve commits when integrating PRs.

Normal loop: understand the architecture → implement → focused validation →
diagnose/iterate → commit → push validated work → report changes/checks/SHA.
Use comprehensive checks at meaningful milestones; do not run the full release
or browser matrix for every small edit. Do not push failing changes as validated;
report blockers outside scope. Human gameplay/device acceptance belongs to
release readiness and does not gate routine development commits or pushes.

## Release authority and GitHub settings

Explicit owner authorization is required before creating/changing release tags,
publishing GitHub Releases or distribution artifacts, deploying/updating the
public website, or declaring a version accepted for release. Published versions
are immutable tags plus GitHub Releases; preserve their artifacts. Alpha 0.1
remains `v0.1.0-alpha.1`. Routine main pushes authorize none of those actions.

Godot/Web CI validates pushes to main; optional PR validation remains enabled.
CI logs/build artifacts are validation outputs, not accepted public releases.
Pages is manual-only, with publication/licensing acknowledgement inputs and a
main-only guard. Ordinary pushes do not deploy. **Pages builds the main SHA at
workflow dispatch, not the latest release tag.** Before an approved dispatch,
verify its exact `github.sha` against the approved revision and review matching
build-info/source artifacts; cancel if they differ. Before a future release,
consider a pinned approved tag/SHA or validated-artifact input so deployment can
select release bytes independently of ongoing main development. No deployment
workflow or public site is changed by this documentation update.

Repository inspection on 2026-10-24 found main unprotected and the Basic ruleset
disabled, so direct pushes need no GitHub setting change. If enabling protection,
allow the intended direct writer rather than requiring all changes through PRs;
keep CI enabled and block force pushes/deletion. Protect published tags. Do not
silently bypass or change repository rules/settings. Existing release settings
and Alpha 0.1 evidence are in `releases/web-release.md`; that historical policy
is superseded here for routine development.

No repository-local Codex config/override was found. The only nested AGENTS is
the preserved Python archive guide, with no conflicting Git policy. The inspected
user config trusts this repo and has no explicit Git-policy/instruction override;
it was not modified. Global/project/nested instructions can combine; see
[Codex instruction scope](https://learn.chatgpt.com/docs/agent-configuration/agents-md).
Report any future conflicting configuration instead of editing user-level settings.

## Catalog, archives and assets

Active codes: BOUNCE, BALLS, BUG, YOU, BUBBY, BUSBOY, MACHINE. PONG/JUMP/MARIO/
MONSTERS are excluded source references under `archive/godot/`. ZELDA/UNTITLED
are replaced without aliases; their complete original Godot sources remain in
Bubby/Busboy `source/`. All Pygame originals remain under `legacy/pygame/`; see the [retirement audit](repository-cleanup.md).
Runtime graphics/audio are centralized in `assets/art/` and `assets/audio/`;
editable masters live in excluded `assets/art/source/`. Module JSON/maps/TileSets stay with their code.
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

Landscape touch controls are enabled on touch devices. The terminal has no
code directory: tap its real text field to open the browser/OS keyboard and
enter a code, then Go/ENTER. `make fast-check CHECKS=mobile` checks input/routing without
cameras; the full browser matrix includes mobile Chrome/WebKit emulation.
See [Alpha 0.2 mobile acceptance](releases/alpha-0.2-mobile-testing.md) for local
iPhone hosting and the physical-device checklist. Emulation is not iOS approval.

Native iOS is assessment-only: [toolchain and personal-device plan](releases/alpha-0.2-ios-feasibility.md).
