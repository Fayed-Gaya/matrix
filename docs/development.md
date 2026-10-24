# Development workflow

Use Godot **4.7.2 stable**, typed GDScript, Compatibility renderer. Keep the
project at the repository root. Gameplay never needs Python or the archived
Pygame environment; Python 3 is development tooling. Override `GODOT` with the
engine executable on other machines. Node 22/npm and the pinned Playwright
package/browsers are needed only for browser checks.

## Three testing tiers

| Tier | Command | When / scope |
| --- | --- | --- |
| 1 — local | `make fast-check CHECKS=busboy` | Default during implementation: import, load selected scene and check a few useful mechanics. Space-separated selectors work. |
| 2 — integration | `make smoke-check` (also `make check`) | Before pushing integrated runtime changes; automatically on relevant main pushes. One import, Pegasus startup, every registered level launch/return, error/leak guard. |
| 3 — release | `make release-check` | Explicit milestone/release candidate: tooling, focused regressions/resources, fresh runtime, inventory, audited web export and one Chromium terminal→BOUNCE→Pegasus flow. Never publishes. |

Selectors: `pegasus bounce balls bug bubby busboy machine you mobile`; `all`
selects those focused checks, `resources` explicitly adds whole-project resource
loading, and `bouncing_ball` aliases `bounce`. Unknown/empty selectors fail.
A selected check does not execute unrelated levels or a full walkthrough.
Imports are Godot's project-wide scan; already imported assets are reused.

```sh
make editor                         # or make run
make fast-check CHECKS="pegasus mobile"
make smoke-check                    # integrated runtime changes
make tools-check                    # Python tooling/layout changes only
```

Documentation-only changes normally need link/diff review, not gameplay tests;
CI skips Markdown/docs-only pushes. Run targeted tests, fix failures and retest
the affected path; do not repeatedly rerun unrelated successful suites. Success
output is compact. Detailed engine logs are in ignored `build/test-logs/`;
failures print diagnostics and fail even if Godot returned zero. Cameras are
always disabled/synthetic in automation. No automatic screenshots on success.

## On-demand release and compatibility checks

```sh
npm ci --prefix tests/web
(cd tests/web && npx playwright install chromium)
make release-check
# Only for relevant browser/input/layout changes:
(cd tests/web && npx playwright install firefox webkit)
make compatibility-check
```

The optional compatibility set is desktop Firefox plus landscape Chromium/WebKit
with one representative destination each. No seven-level-by-browser matrix.
Edge uses Chromium; assess it manually when warranted rather than maintaining
a duplicate automatic project. Browser failures retain screenshots/traces;
normal successful runs do not generate review images. Physical iPhone/Android,
audible audio, art and full gameplay acceptance remain release-readiness work;
automation does not establish acceptance. See `releases/alpha-0.2-mobile-testing.md`.

Manual GitHub **Release validation (no publication)** runs the same release
command, installing only Chromium unless compatibility is explicitly selected.
Normal **Matrix smoke** CI installs only the engine, not templates or browsers;
there is no routine export, source package, archive job or success artifact upload.

## Optional historical evidence and tools

`make regression-check` runs retained migration traces, exact map/layout checks,
complete gameplay scenarios and native edit/save tests. These are opt-in evidence,
not routine or release gates; intentional design changes need not preserve old
speeds, coordinates or balance. A selected historical suite can be invoked with
`python3 scripts/validate_godot.py --godot /path/to/godot --regression --only busboy`.
`make archive-check`, `make archived-godot-check` and `make legacy-check` remain
explicit preservation/reference tools; archived Python CI is manual-only.
Do not edit/delete preserved archives just because their checks are optional.

`make runtime-check` runs the same canonical route smoke from fresh archive-free
resources. `make editor-map-check` opens disposable maps in a real editor; use
it for editor persistence changes, not ordinary gameplay edits. Native scenes,
TileSets, collisions and markers remain authoritative. Never regenerate maps.

```sh
make web-export                     # audited local export only
make web-serve                      # localhost:8060
```

Export stages/audits actual PCK bytes before replacing local `exports/web/`;
failure preserves the previous preview. `build-info.json` records runtime-input
dirtiness and the pack checksum. Source/private art and archives are excluded.
No validation command creates release tags, publishes a Release or deploys Pages.
Timing/coverage audit: [testing optimization](testing-optimization.md).

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

Headless integration CI validates relevant pushes to main and optional PRs;
release/browser validation is manually invoked.
CI failure logs and on-demand build artifacts are validation outputs, not accepted public releases.
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
The archived Python quality workflow is manual-only; Windows archive packaging
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
cameras; optional compatibility checks include mobile Chromium/WebKit emulation.
See [Alpha 0.2 mobile acceptance](releases/alpha-0.2-mobile-testing.md) for local
iPhone hosting and the physical-device checklist. Emulation is not iOS approval.

Native iOS is assessment-only: [toolchain and personal-device plan](releases/alpha-0.2-ios-feasibility.md).
