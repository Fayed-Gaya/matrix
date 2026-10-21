# Matrix Alpha 0.1 implementation status

Branch: `feature/alpha-0.1-release-pipeline`, based on merged main `eb091f5`.
Owner reports hub and all ten levels manually tested locally and working.
No browser release, Pages publication, release tag or archive removal authorized.

- [x] Phase 1: GitHub Flow, feature branch, workflow/agent documentation.
- [x] Phase 2: pinned Godot CI plus preserved archived tests.
- [ ] Phase 3: web export and isolated PCK pass locally; real browser smoke in progress.
- [x] Phase 4: build artifact and manual-main-only Pages preparation.
- [ ] Phase 5: third-party inventory, obligations and unresolved release blockers.
- [ ] Phase 6: final checks, pushed milestones and PR; no merge/publish/tag.

Initial checkout was the old migration branch. A pre-existing editor save in
project.godot was retained when creating this branch; input bindings remain as
saved. A recovery copy/patch is at /tmp/matrix-alpha-preexisting-project.godot
and /tmp/matrix-alpha-preexisting.patch. No user files discarded.

Installed Godot reports 4.7.2.stable.official.ed1daf0bf. Web templates were absent.
Official Godot release URLs and SHA-256 digests are being pinned for setup.
See development.md for GitHub Flow; forthcoming release docs record build,
deployment and licensing details. Keep this status updated at each milestone.

Milestone 2: Godot CI + single-threaded Web export + manual Pages preparation.
Pinned official SHA-256 editor/templates in scripts/release/godot-toolchain.json.
Custom templates live in ignored build/toolchain/godot; setup verifies the entire
TPZ and extracts only the no-thread web templates. All ten exported scenes and
runtime JSON/dynamic resources load from the isolated PCK. Removed ten unused
.import sidecar entries accidentally present in Monsters' audio manifest.
Native full checks and Chrome/Firefox smoke are running; CI will also test Edge.
Diagnostics are opt-in (?matrix_smoke=1), read-only state; tests use real keys.
No physical feed is activated. YOU has an explicit web explanation and Escape.

Preliminary licensing findings: Pong GPL declaration (version unspecified);
Pixeltype embeds a FontStruct Non-Commercial License; many original asset grants
are missing. No blanket Matrix license or release clearance is assumed. Preserve
all levels; complete the detailed audit and notices before any approved release.

Local tools: Node 22.23.4 checksum-verified official macOS binary installed in
ignored build/toolchain/node for tests. Pinned Playwright 1.56.1 and lockfile.
Recent logs: /tmp/matrix-alpha-export.log, /tmp/matrix-alpha-pack.log,
/tmp/matrix-alpha-browser-tests.log, /tmp/matrix-alpha-check.log,
/tmp/matrix-alpha-runtime.log. Native Godot editor PID 2004 was already open;
it was left running and its pre-existing project save is preserved.
