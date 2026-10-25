# Development

Use Godot **4.7.2 stable**, typed GDScript and Compatibility rendering. The root
`project.godot` is authoritative. Python 3 is tooling only; Node 22/npm and pinned
Playwright browsers are needed only for browser validation. Override `GODOT`
with the executable path off this Mac; `make editor` / `make run` start Godot.

## Git

`main` is the only permanent development branch and may contain validated,
unreleased work. Codex may commit/push routine validated work directly to main.
Use meaningful checkpoints and ordinary fast-forward pushes; fetch/reconcile
remote advances and preserve user edits. Never force-push or rewrite published
history. Optional branches/worktrees/PRs help with risky or concurrent work and
explicit review requests. Manual gameplay acceptance is for releases, not pushes.

## Testing

| Tier | Command | Use |
| --- | --- | --- |
| Local | `make fast-check CHECKS=busboy` | Default iteration: import and selected focused mechanics/resources |
| Integration | `make smoke-check` or `make check` | Before runtime pushes; CI imports once, starts Pegasus and launches/returns every registered level |
| Release | `make release-check` | On demand: tooling/resources, focused regressions, fresh runtime, inventory, audited export and one Chromium terminal→BOUNCE→Pegasus flow |

Selectors: `pegasus bounce balls bug bubby busboy simulation you mobile`; combine
with spaces. `all` selects focused checks; `resources` adds full resource loading.
`bouncing_ball` aliases `bounce`; unknown/empty selectors fail. Godot import scans
the project but only selected behavior runs. `make tools-check` covers Python
helpers/layout when relevant. Docs-only edits normally need link/diff review.

Fix/retest affected failures; don't repeat successful unrelated suites. Success
output is compact; detailed engine/HTTP logs are under ignored `build/test-logs/`.
Zero-exit script errors still fail. Cameras are disabled/synthetic; screenshots
and traces are captured on browser failures, not ordinary successful runs.

```sh
npm ci --prefix tests/web
(cd tests/web && npx playwright install chromium)
make release-check
# Optional browser/input/layout compatibility:
(cd tests/web && npx playwright install firefox webkit)
make compatibility-check
```

Optional compatibility covers Firefox and landscape Chromium/WebKit, one level
each. `make regression-check` retains detailed historical traces/maps/walkthroughs;
these are not routine or release gates and need not freeze intentional design
changes. `make archived-godot-check` reconstructs the pinned original Godot suite
from Git history. `make editor-map-check` edits disposable maps in a real editor;
use it for authoring/persistence work. `make runtime-check` tests fresh resources.

## Maps, assets and builds

Edit native TileMapLayers, external TileSets, collision shapes and interaction/
spawn/portal markers directly. Module READMEs describe their maps and controls.
Keep depth-sorted prop anchors at floor level; maintain room bounds and clear
navigation when editing geometry. PNG export never regenerates a map.
[Art workflow](art-pipeline.md) covers editable masters and explicit exports.

`make web-templates` installs checksum-pinned templates. `make web-export` stages
and audits actual PCK bytes before replacing `exports/web/`; failure preserves
the prior preview. `make web-serve` hosts it on localhost:8060. Generated output
stays out of Git. CI on relevant main pushes is engine-only smoke; docs-only
pushes skip it. Release validation is manual and never deploys.

Update current provenance with `python3 scripts/audit_licenses.py`; use `--check`
to verify freshness. The frozen Alpha 0.1 inventory supplies historical source
matches without requiring the retired Pygame tree. Never infer redistribution
permission from matching hashes. See [release requirements](releases/alpha-0.2.md)
and [publication procedure](releases/publishing.md) only when preparing a release.

Documentation describes lasting behavior/interfaces/decisions, not every task.
Do not maintain parallel plans, implementation logs or completed-work reports.
