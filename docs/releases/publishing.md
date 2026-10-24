# Publication

Development pushes and validation never authorize publication. Obtain explicit
owner approval for the exact revision and for release tags, GitHub Releases,
public distribution/deployment and release acceptance. Published tags and package
bytes are immutable. Keep [Alpha 0.2 requirements](alpha-0.2.md), licensing notices
and corresponding preferred source with the intended build.

## Validate a candidate

Use `make release-check` locally or GitHub **Release validation (no publication)**.
The manual workflow builds audited single-threaded Compatibility web output,
runs one Chromium flow, and uploads `matrix-web-<sha>` and matching source ZIP.
Select optional compatibility checks when relevant. These artifacts are test
outputs until explicitly approved; running validation never deploys anything.

`build-info.json` records engine, source commit, runtime-input dirtiness and PCK
SHA-256. Verify those against the approved revision. Preserve required notices,
license texts, engine notices and exact-version source/build instructions;
compiled GDScript/WASM is not a substitute for preferred source. Asset permissions
and source obligations remain in [the licensing audit](alpha-0.2-licensing.md).
Historical Pygame attribution paths resolve at `provenance_revision` in the current
inventory; no current build depends on that retired working tree.

## Authorized Pages deployment

Pages stays manual and main-only. GitHub Settings → Pages → Source must use
GitHub Actions; retain the `github-pages` environment and owner access controls.
Do not change these settings without a relevant request.

After approval, dispatch **Manual browser deployment** from main. Its build calls
the release-validation workflow. `deploy` defaults false; publication also needs
`licensing_cleared` or explicit `technical_preview_acknowledged`. The latter is
an acknowledgement of unresolved issues, never a clearance claim.

The workflow builds `github.sha` at dispatch, not the latest published tag.
Check it is the exact approved SHA; cancel if not. A future approved release may
add pinned revision/artifact selection to decouple deployment from ongoing main
work. Check source/notices and the resulting site after authorized deployment.
No automated push trigger deploys. Tag/release creation remains a separate,
explicitly authorized action; never move a published tag or replace its downloads.

## Existing publication

Alpha 0.1 `v0.1.0-alpha.1` fixes `f6146918b424af8cc64e1969c7447892b766cacb`:
[desktop preview](https://fayed-gaya.github.io/matrix/) ·
[release/source/checksums](https://github.com/Fayed-Gaya/matrix/releases/tag/v0.1.0-alpha.1).
Its ten-level preview was explicitly authorized with documented licensing issues
unresolved. Preserve that acknowledgement, tag and published bytes; it does not
authorize or certify another release.
