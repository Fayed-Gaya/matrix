# Matrix Alpha 0.1 implementation status

Published technical preview: `v0.1.0-alpha.1`, commit `f614691`.
- Play: https://fayed-gaya.github.io/matrix/
- Prerelease/packages: https://github.com/Fayed-Gaya/matrix/releases/tag/v0.1.0-alpha.1
- Deployment: https://github.com/Fayed-Gaya/matrix/actions/runs/39696864605

PR #4 merged as `34dda87`; explicit preview gate PR #5 merged as `f614691`.
Both used merge commits. The owner authorized technical-preview publication on
2026-10-21 with documented licensing issues unresolved. Publication occurred
2026-10-22 00:07:57 UTC (Oct 21 local). This is owner risk acceptance, not
third-party permission or licensing clearance. Archive removal is not authorized.

- [x] GitHub Flow and agent/development documentation; no permanent dev branch.
- [x] Pinned Godot 4.7.2 CI; preserved archived Python checks.
- [x] Single-threaded Compatibility Web export, ten levels, runtime manifests,
  browser YOU explanation/return and preserved native camera implementation.
- [x] Pages deployed and GitHub prerelease published with exact CI web/source
  packages and SHA256SUMS.txt; all ten levels and archive retained.
- [x] Preliminary licensing audit, inventory, notices and explicit blockers.
- [x] Final Chrome/Firefox/Edge smoke, CI/artifact links and PR handoff.

## Verification and evidence

Local `make check`, `make runtime-check`, web export and isolated exported-PCK
validation passed. All 771 archive checksums pass; no archive changes.
New Python tooling passes Ruff and licensing inventory freshness checks.
Local Chrome/default GPU passed opening, real keyboard walk/terminal entry,
all ten codes/scenes, Escape return, resize and error assertions (2.3 minutes).
Local forced-SwiftShader cold Monsters loading stalled; default local tests now
use the normal GPU backend. Local Firefox timed out during a Monsters screenshot at four minutes under
concurrent browser/software-rendering load. It needs an isolated Mac Firefox
performance/gameplay check; local Edge acceptance is not certified.

Final code CI: https://github.com/Fayed-Gaya/matrix/actions/runs/39695420048
on branch commit `08e1dab` / tested PR merge revision `c542ba7`.
Godot validation, export/PCK, archived Checks and all three browser smokes passed.
Chrome 156, Firefox 142 and Edge 155 completed all ten routes/returns and resize
(about 1.3, 1.2 and 1.5 minutes respectively); no asserted script/runtime/HTTP
errors. Earlier navigation tolerances and cold-load time budgets were corrected;
no test assertions or gameplay were weakened. Cold Monsters loading remains a
performance acceptance concern. Final follow-up changes only document evidence;
GitHub automatically reruns checks for that documentation commit.

- [Web build (26.8 MB ZIP)](https://github.com/Fayed-Gaya/matrix/actions/runs/39695420048/artifacts/12391275083)
- [Matching source (76.6 MB ZIP)](https://github.com/Fayed-Gaya/matrix/actions/runs/39695420048/artifacts/12390820838)
- [Browser evidence](https://github.com/Fayed-Gaya/matrix/actions/runs/39695420048/artifacts/12390294951)

Artifacts contain the tested merge revision, not an authorized release tag.
They expire under repository retention (currently 2027-01-19). The PR checks are
canonical for its latest head. The final local export records `08e1dab`, clean
working tree and the exact engine; its isolated PCK passed again.

Artifacts are uploaded after export/PCK validation, before browser tests, so
failed smoke runs still retain a diagnosable build. Tests remain required for a
successful job/Pages deployment. CI records browser versions/screenshots/traces.
Logs: /tmp/matrix-alpha-{check,runtime,export,pack,browser-tests}.log and
/tmp/matrix-alpha-chrome-defaultgpu.log. Test diagnostics are opt-in read-only
DOM state, not gameplay controls. No automated physical camera activation.

## Release readiness

Read [web-release.md](web-release.md) for local commands, manual gameplay/audio,
focus/scaling/performance/native-camera checks and GitHub Pages settings.
Pages is configured for GitHub Actions and serves the ~57 MB single-threaded
build. The deployment used deploy=true, licensing_cleared=false and
technical_preview_acknowledged=true. Godot checks, fresh runtime, isolated PCK,
Chrome/Firefox/Edge smoke and Pages deployment passed on `f614691`. Main CI
39696790181 passed on retry after a Godot 4.7.2 import-thread signal-11 crash;
the independent deployment validation passed initially. No tests were weakened.

The actual HTTPS URL was checked: opening screen, player movement, terminal,
YOU's browser camera explanation and Escape return worked through real keys.
Hosted build-info records `f614691`, dirty=false; WASM serves as application/wasm.
Full hosted gameplay/audio/performance, isolated Mac Firefox and local Edge
acceptance remain unverified. Local re-export passed with duplicate UID warnings
from ignored Playwright assets; published packages use the clean CI artifact.

Release package SHA-256:
- web: `ef88a16e274e9cf26129f28342c761375d6958a89f30b598fdec89920ae78a2c`
- source: `5d8f09de11278f9b9479f3e83faf6c0e739304c729831314431e2b139ef8233b`

The tag remains fixed at the published revision. Documentation-only follow-ups
on main do not republish Pages or move the tag. Future publications require
explicit authorization.

Read [licensing-audit.md](licensing-audit.md): Pong GPL version/combined-work scope,
non-commercial Pixeltype, conflicting Snoblin redistribution grants and missing
media/font permissions block publication clearance. No license election, asset
substitution or level removal was made. Inventory covers 678 active code/media/
resource files and six font records. Builds carry preliminary notices, OFL/GPL
reference texts and generated exact-engine component notices; these are not
clearance. Source ZIPs match each CI build revision and expire with artifacts.

## Preservation and local setup

Existing editor-saved project.godot/input serialization was preserved when
branching from updated main. Recovery files: /tmp/matrix-alpha-preexisting.patch
and /tmp/matrix-alpha-preexisting-project.godot. The already-open native editor
(PID 2004 at start) was left alone. No worktrees were created/reset/cleaned.
Official editor/templates URLs and SHA-256 are pinned in
scripts/release/godot-toolchain.json. Ignored build/toolchain contains verified
web templates and a local official Node 22.23.4 macOS binary. Playwright 1.56.1
and its dependency lock are tracked; generated tools/builds/caches are ignored.
