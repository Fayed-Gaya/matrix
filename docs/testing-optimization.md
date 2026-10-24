# Testing optimization — 2026-10-24

Baseline: integrated main `eb2793d`. No expensive baseline was rerun.
Successful PR #20 run [40068539178](https://github.com/Fayed-Gaya/matrix/actions/runs/40068539178)
provides GitHub timings: Godot job 22 s; Web job 449 s; job span 474 s (7m54s).
Its steps: active/fresh validation 13 s, export 11 s, browser installation 71 s,
six-browser smoke 345 s (5m45s). Runner/cache effects apply.

## Coverage decisions

| Coverage | New treatment |
| --- | --- |
| Startup, every registered scene, transition, return/free/resume, critical errors | One canonical headless smoke, normal CI |
| Component mechanics | Focused reflection/wrap, pointer release, collision/terminal normalization, action cooldown/retry, turn locking/costs/failed casts/outcomes, brace/recovery, touch focus release |
| Fixed speed, exact authored layouts, long source traces, full gameplay scenarios | Retained in explicit `make regression-check`, not fast/CI/release defaults |
| Synthetic camera formats/pixels and detailed native editor persistence | Retained in optional historical/editor suites; all automated entry paths still disable physical cameras |
| Python preview replacement, layout/import paths and runner failure/selection guards | Twelve small tooling tests; tooling work and release only |
| Archived Pygame quality/preservation and pinned ten-level suite | Explicit/manual only; source/archive material unchanged |
| Fresh standalone runtime | Same smoke script, disposable resources; on-demand/release |
| Web pack/source exclusion and dynamic resource audit | Release export retained |
| Browser navigation | One Chromium terminal→BOUNCE→Pegasus flow for release |
| Firefox and landscape mobile Chromium/WebKit | Optional, one destination per project; tests focus keyboard/touch/rotation |
| Edge project, duplicate DPR-3 layout spec, routine success screenshots | Removed; Chromium/mobile coverage and Git history retain reference value |

Routine CI has one engine-only job and skips Markdown/docs/source-art/archive-only
pushes. Export templates, npm, browsers, builds and source artifacts move to the
explicit release workflow. Pages reuses that release workflow; its explicit
publication/licensing inputs and main guard remain unchanged. Nothing auto-deploys.

## Measurements and limitations

Local Mac observations (one run each, not a controlled benchmark): previous full
Godot stages summed to 27.77 s; previous Pegasus+mobile focused run 12.49 s;
previous five-browser run about 2.5 min. New focused Busboy: 8.25 s wall (180 console bytes);
new Pegasus+mobile pair: 7.58 s wall;
new integration smoke: 6.09 s wall (174 console bytes).
All focused components plus full resource loading passed in 7.39 s (engine stages).
The new complete local release command passed: fresh runtime, package audit and
one Chromium test (31.0 s including browser startup; 27.2 s test body). Cached import time varies substantially; the first import also
registers new test scripts. CI and Mac seconds must not be compared as identical
hardware/workloads.

Existing recent full local success log was 4,155 bytes. New smoke console output was 174 bytes, including Make
command echo. This compares different coverage scopes, not measured tokens; no
Codex token count/cost or token-savings percentage is inferred.
Fewer unrelated executions, no routine screenshots, and reading failure logs only
should reduce context/output use; removing browser installation/exports chiefly
reduces wall time and Actions work. No gameplay files, asset bytes, release tags
or published artifacts are changed.

Reduced routine coverage intentionally does not prove terminal typing, full
combat paths, map geometry, audio output, pixel appearance or device/browser
parity. Use the release/optional paths when those concerns are relevant, followed
by human gameplay/visual/audio and physical-device acceptance before publication.

Optional compatibility validation passed once on this Mac: Firefox, mobile
Chromium and mobile WebKit, three tests in 2.2 min. It is not part of routine CI.
Browser times reflect headless software rendering and are not controlled against
the earlier headed local run. Publication/device acceptance remain unverified.

## Main CI result

[New smoke run 40071326947](https://github.com/Fayed-Gaya/matrix/actions/runs/40071326947)
passed on `4fe26b3`: one integration job, **18 s**, including a cold editor-cache
installation. Import plus all registered route/return checks took **8 s** in
that job. The previous Godot/Web job span was **474 s**: roughly **96.2% shorter**
for this observed routine CI run. This is reduced coverage/work, not a controlled
engine benchmark. Cache hits may improve future runs; none are assumed here.
No templates, Node/browser setup, web/source builds or archive jobs ran; success
artifact upload was skipped. The optional/manual release workflow was not invoked.
