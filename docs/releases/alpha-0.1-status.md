# Matrix Alpha 0.1 implementation status

Branch: `feature/alpha-0.1-release-pipeline`, based on merged main `eb091f5`.
PR: https://github.com/Fayed-Gaya/matrix/pull/4 (no merge authorized).
Owner reports native hub/all ten levels manually tested locally and working.
No Pages publication, release tag or archive removal is authorized.

- [x] GitHub Flow and agent/development documentation; no permanent dev branch.
- [x] Pinned Godot 4.7.2 CI; preserved archived Python checks.
- [x] Single-threaded Compatibility Web export, ten levels, runtime manifests,
  browser YOU explanation/return and preserved native camera implementation.
- [x] Web/source artifacts and manual-main-only Pages preparation; not deployed.
- [x] Preliminary licensing audit, inventory, notices and explicit blockers.
- [ ] Final corrected Edge smoke, final CI/artifact links and PR handoff.

## Verification and evidence

Local `make check`, `make runtime-check`, web export and isolated exported-PCK
validation passed. All 771 archive checksums pass; no archive changes.
New Python tooling passes Ruff and licensing inventory freshness checks.
Local Chrome/default GPU passed opening, real keyboard walk/terminal entry,
all ten codes/scenes, Escape return, resize and error assertions (2.3 minutes).
Local forced-SwiftShader cold Monsters loading stalled; default local tests now
use the normal GPU backend. Local Firefox/Edge acceptance is not certified.

CI run https://github.com/Fayed-Gaya/matrix/actions/runs/39694656251 on `84458b6`:
Godot validation, export/PCK and archived Checks passed; Chrome and Firefox
passed all ten routes (about 1.4 minutes each). Edge failed the test's terminal
approach: horizontal tolerance could leave the player beside an obstruction.
Corrected range keeps the player inside the clear corridor; the terminal
assertion remains. Earlier held-key polling overshot waypoints; short real key
pulses fixed that. Cold scene loading exceeded 20 seconds on some runs; tests
allow 60 seconds per launch/four minutes overall. Performance is not certified.
See the PR checks for the latest revision; record final results before handoff.

Artifacts are uploaded after export/PCK validation, before browser tests, so
failed smoke runs still retain a diagnosable build. Tests remain required for a
successful job/Pages deployment. CI records browser versions/screenshots/traces.
Logs: /tmp/matrix-alpha-{check,runtime,export,pack,browser-tests}.log and
/tmp/matrix-alpha-chrome-defaultgpu.log. Test diagnostics are opt-in read-only
DOM state, not gameplay controls. No automated physical camera activation.

## Release readiness

Read [web-release.md](web-release.md) for local commands, manual gameplay/audio,
focus/scaling/performance/native-camera checks and GitHub Pages settings.
Pages is suitable for the ~57 MB static single-threaded build. It remains
unconfigured/unpublished; dispatch defaults to build-only and only runs on main.

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
