# Alpha 0.1 desktop-browser build and deployment

Target: current desktop Chrome, Firefox and Edge with WebAssembly/WebGL 2.
Godot 4.7.2 stable, Compatibility, GDScript, no threads/GDExtensions/PWA.
All ten codes are included. YOU displays an explicit browser-unavailable notice
and Escape returns to Matrix; the native macOS camera path is preserved.
The owner reports all ten native levels manually tested locally and working.
Browser parity/performance/audio still need their own acceptance.

## Reproduce locally

```sh
make check
make runtime-check
make web-templates  # official ~1.3 GB TPZ, SHA-256 verified; keep only web templates
make web-export
python3 scripts/check_web_pack.py --godot /Applications/Godot.app/Contents/MacOS/Godot
make web-serve
# Open http://127.0.0.1:8060/ in Chrome, Firefox or Edge
```

Override `GODOT=/absolute/path/to/godot` on every make target when needed.
Python 3 and curl are development tools. `scripts/setup_godot.py --editor
--templates` installs the pinned Linux x86_64 toolchain for CI in ignored
`build/toolchain/godot`. URLs/digests are in scripts/release/godot-toolchain.json;
no engine version substitution or mutable template download is used.
An existing official TPZ can be supplied with `--templates --archive /path/file.tpz`.

Serve over HTTP localhost for testing, HTTPS for deployment; file:// is unsupported.
Single-threading avoids SharedArrayBuffer and COOP/COEP headers, making static
GitHub Pages suitable. Keep exported filenames together; do not rename index
companions. No service worker/offline persistence is configured. The build
contains JSON manifests explicitly and excludes archive, tests, docs, scripts,
source-only originals and toolchain files. `check_web_pack.py` launches the PCK
from an empty directory, checks exclusions and dynamic manifest resources, and
routes all ten scenes without using repository assets or cameras.

`exports/web/` is generated/ignored. Build-info records the engine and Git SHA.
A local dirty tree is marked in build-info; CI builds clean, exact revisions.
CI web artifacts include notices/engine licenses and have a companion exact-source
snapshot. This is a technical build, not release/licensing clearance.

## Browser smoke tests

Install Node 22 and run:

```sh
cd tests/web
npm ci
npx playwright install chrome firefox msedge
npm test
```

These open isolated browser profiles and use real keys to dismiss the opening,
walk to the terminal, enter every code, inspect each loaded scene, Escape back,
and resize. Opt-in `?matrix_smoke=1` reports read-only state in a DOM attribute;
it offers no launch, teleport or gameplay-control API. Automation never activates
physical cameras. The normal URL does not enable telemetry. Screenshots/traces
and browser versions are recorded by the test runner. CI uses Xvfb/Mesa on Linux.
Cold Monsters loading exceeded 20 seconds on some software-rendered runs; the
smoke allows 60 seconds per launch and four minutes for all ten. These are test
time budgets, not performance promises. Measure startup responsiveness on real
desktop hardware before release; loading/performance is not certified.
Local Chrome/Edge use the default GPU backend; only CI forces SwiftShader.
An installed Chrome/Edge channel is required; Firefox is Playwright's pinned build.

Keyboard focus and an initial click/key gesture are required for browser audio.
Web Stream playback preserves Godot mixing behavior but single-threading can add
latency/stutter. Esc may leave fullscreen first; click the canvas if keys stop
reaching the game. Tabs may throttle/background or suspend audio. Test speakers,
held/simultaneous keys, mouse mapping, zoom/high-DPI and multiple window sizes.
No controller/touch/mobile-browser support is promised for this milestone.

## CI and artifact retrieval

Godot and Web runs on PRs targeting main, pushes to main, manual dispatch and
reusable calls. `Godot validation` runs make check/runtime-check without cameras;
`Web export` builds, checks packed resources and smoke-tests Chrome/Firefox/Edge.
Archived Python quality/build workflows are retained. Failed jobs upload useful
logs, screenshots and traces. After export/PCK validation succeeds, CI uploads
`matrix-web-<sha>` and `matrix-source-<sha>` before browser smoke tests, so a
browser failure still leaves a diagnosable build. The job remains failed and
Pages deployment is blocked until all tests pass. Download from the Actions run's Artifacts section;
extract the web ZIP and serve its root. Artifacts expire per repository policy;
they are not immutable published releases. Do not confuse a PR's tested merge SHA
with a later approved main release SHA.

## Prepare GitHub Pages (not published by this work)

After merging is explicitly authorized and completed:

1. In Settings → Pages, choose GitHub Actions as the build/deployment source.
2. Configure the `github-pages` environment for main only and add a required
   owner approval if desired. Set branch protection/checks per development.md.
3. Resolve all licensing blockers in licensing-audit.md. Do not assert clearance
   based only on passing CI or free asset downloads.
4. Actions → Manual browser deployment → Run workflow, select main. With both
   inputs false, it validates/builds artifacts without publishing. Other branches
   are skipped. No workflow publishes every commit.
5. After explicit release approval, run on approved main with `deploy` and
   `licensing_cleared` true; approve the environment if configured. The deployment
   job alone gets pages:write/id-token:write. Expected project URL is
   https://fayed-gaya.github.io/matrix/ unless repository/domain settings differ.
6. Tag the approved tested revision under the immutable version policy only
   when separately authorized. No tags/releases were created during preparation.

Pages supports this static single-threaded build. If policy/storage/size constraints
later prevent Pages, a static HTTPS host such as itch.io can use the same build;
licensing and target-browser acceptance still apply. No alternate host is created.

## Manual acceptance before publication

- In each target browser, complete representative gameplay in all ten levels,
  including game-over/restart, local menus and return navigation; routing smoke
  tests do not certify the mechanics, collisions or balance.
- Listen to music/effects after the initial gesture and after tab suspension;
  check timing, volume and single-threaded latency under load.
- Test mouse controls, held/diagonal keys, focus recovery, fullscreen Escape,
  zoom/high-DPI and small/large desktop windows. Confirm no unexpected scroll.
- Read YOU's camera explanation, return to the hub, then regression-test native
  macOS camera permissions/live capture separately. Web tests never access cameras.
- After an approved main deployment, repeat smoke/gameplay tests at the actual
  project-subpath HTTPS URL and check network/console errors. Pages itself has
  not been deployed or verified by this preparation.
- Resolve the licensing audit blockers, configure branch/environment protection,
  and approve the exact release revision before any publication or version tag.
