# Rebirth (Alpha 0.2)

Unpublished development, not accepted for release. Publication/tagging/deployment
needs explicit owner approval. No release date or tag has been finalized.
The existing Alpha 0.1 tag/artifacts remain intact.

## Development roadmap

1. **Bubby:** improve the art pipeline while refining the apartment, balcony,
   characters and environment using authentic real-life references. Evaluate
   SpriteLab, PixelLab, Ludo.ai and Aseprite. Reference gathering and tool evaluation
   precede new artwork; this roadmap update does not authorize generation or
   creative changes.
2. **Busboy:** refine its visual identity using Fayed and Kobe's discussions, the
   [Busboy planning document](https://docs.google.com/document/d/183hSTmkQ3NHhDRTlgq8zJkLPunC7iQTP3-npaEApzno/edit)
   and Kobe's supplied assets. Do not invent his preferences or claim approval.
3. **Simulation:** develop the original showcase previously called Machine.
   The rename changes neither its gameplay nor its story; its terminal code is
   `SIMULATION`, with no `MACHINE` alias.

After these three levels, prepare Rebirth subject to final acceptance, licensing
decisions and explicit publication approval. Balls, Bouncing Ball, Bug and You
remain included, with no substantial development planned this cycle. Pegasus is
ready for Rebirth in its current form; further spaceship development is deferred
to the release following Rebirth.

## Outstanding decisions

- [Licensing blockers](alpha-0.2-licensing.md) remain unresolved. Obtain permissions
  and required notices/source, or explicit authorization for a documented technical
  preview; neither implies legal clearance.
- Bubby refinement #18 is integrated; authentic apartment/likeness references and
  owner creative acceptance remain pending. Busboy refinement #19 is integrated;
  its art direction and provenance remain provisional.
- Kate apartment/likeness/personal story references are pending. Current Bubby
  furnishings/story and Simulation premise/art/balance remain provisional. Kobe
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
