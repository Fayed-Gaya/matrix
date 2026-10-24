# Alpha 0.2 release readiness

Unpublished development, not accepted for release. Publication/tagging/deployment
needs explicit owner approval. The existing Alpha 0.1 tag/artifacts remain intact.

## Outstanding decisions

- [Licensing blockers](alpha-0.2-licensing.md) remain unresolved. Obtain permissions
  and required notices/source, or explicit authorization for a documented technical
  preview; neither implies legal clearance.
- Bubby [#18](https://github.com/Fayed-Gaya/matrix/pull/18) and Busboy
  [#19](https://github.com/Fayed-Gaya/matrix/pull/19) await creative review. Do not
  merge those existing formal-review PRs without approval. Their pre-cleanup paths
  and app/input names need reconciliation with centralized assets and Pegasus.
- Kate apartment/likeness/personal story references are pending. Current Bubby
  furnishings/story and Machine premise/art/balance remain provisional. Kobe
  authorship/approval and asset provenance must not be invented.
- Native iOS is optional future work, not a browser-alpha requirement;
  [feasibility notes](../ios.md) describe what must be rechecked.

## Acceptance before sharing

The owner deferred full manual/physical-device testing during development.
Automated passes do not establish gameplay, artistic, audible-audio or device
acceptance. Review the following against the exact intended release revision;
record only meaningful unresolved issues/accepted limitations.

- Complete each active level from Pegasus, including terminal typing, menus,
  success/failure/retry and return; verify collisions, feedback, audio and pacing.
- On iPhone 17, Chrome and Safari separately: landscape/browser bars/notch, readable
  UI, portrait rotation/resume, no stuck touch input, simultaneous movement/actions,
  sleep/resume, loading/frame rate/memory and audio after a user gesture.
- Terminal: Use → tap actual text field → verify OS keyboard → edit/submit code
  with Go/ENTER → return/reopen/close. Check keyboard dismissal, zoom/scroll and
  controls afterward. The terminal intentionally reveals no code directory.
- BUG: hold/drag/release pointer. YOU: browser-unavailable explanation and return;
  native camera permissions/format/disconnection require real hardware checks.
- Android Chrome is desirable; unavailable hardware does not block the private
  alpha. Emulated WebKit/Chromium is evidence, not physical iOS acceptance.

For a private phone check, run `make web-export`, then temporarily serve trusted
LAN access with `python3 -m http.server 8060 --bind 0.0.0.0 --directory exports/web`.
Open `http://YOUR-MAC-LAN-IP:8060` on the same Wi-Fi; stop afterward. This is local
testing, not permission to update Pages. See [development](../development.md) for
automated tiers and [publishing](publishing.md) for authorized release steps.
