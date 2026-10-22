# Alpha 0.2 browser acceptance

The unpublished development build supports landscape touch controls. The canvas
uses CSS-sized logical coordinates on touch browsers, avoiding tiny controls on
high-DPI phones. Desktop keyboard/mouse input remains available. Portrait pauses
and asks for rotation. This is a browser game; no installation/account is needed.

Touch: direction pad for exploration/BALLS; Use for doors/NPCs/dialogue/terminal;
Shoo in Bubby; Spark/Brace in Machine. Busboy combat uses its existing visible
Strike/Guard/Cleanse/Continue/Retreat buttons. Matrix returns directly from any
level. The terminal offers the same seven registered codes as tappable buttons.
BUG uses a held/dragged finger as its left mouse pointer. BOUNCE needs no gameplay
input. YOU explains browser camera unavailability and has a Matrix return button;
native macOS camera code is unchanged. No browser camera permission is requested.

## Automated reproduction

```sh
make fast-check CHECKS=mobile
make web-export
cd tests/web
npm ci
npx playwright install chrome firefox msedge webkit
npm test
```

Desktop Chrome/Firefox/Edge use real keyboard navigation. Mobile Chrome/WebKit
contexts use 844×390 CSS pixels and touch-enabled landscape. Local GPU-backed
Chrome and WebKit use DPR 3. Software-rendered CI Chrome runs the full route
test at DPR 1 plus a separate DPR-3 canvas/control-size/touch/rotation probe;
WebKit retains full DPR-3 navigation. Tests navigate
to the computer, tap every code, return, and rotate both ways. Browser touch
movement dispatches canvas touch events and waits for observed physics progress
and release (short timed pulses can fall between frames on software-rendered CI); these are simulated browser inputs, not
physical-device tests or setters of game state. Read-only `?matrix_smoke=1`
telemetry supports assertions; it cannot launch/move a character. Headless checks
also cover two fingers, release outside a button, focus loss and BUG field mapping.
All automated YOU launches use synthetic/no-camera paths.

Initial Linux CI passed desktop Chrome/Firefox/Edge but short timed touch presses
were unreliable; software-rendered Chrome also overshot tight waypoints. Inputs
now wait for observed movement and release inside the browser callback. The
actual terminal-proximity, seven-route and return assertions remain mandatory.
The density split avoids making high-DPI software rendering a timing benchmark
for physical phones. Failure traces retain DOM/network/source evidence; explicit
scene/failure screenshots remain, without continuous canvas screencasting.
[Playwright documents these trace options](https://playwright.dev/docs/api/class-testoptions#test-options-trace).
Hardware/browser performance acceptance is still required.

## Owner iPhone 17 check (Chrome and Safari separately)

After fetching the feature branch, `make web-export`, then host on your trusted
local network with `python3 -m http.server 8060 --bind 0.0.0.0 --directory exports/web`.
Open `http://YOUR-MAC-LAN-IP:8060` on the same Wi-Fi. This is temporary local
hosting, not a public release. Stop the server afterward. Do not change Pages
or deploy Alpha 0.2 for this check without publication authorization.

1. Launch in landscape; rotate to portrait and back. Check browser bars/notch,
   readable text, full controls and no stuck movement after leaving the app.
2. Walk to the computer. Tap all seven codes; Matrix must return each time.
3. Bubby: apartment → outside, pigeon shoo/contact/retry, envelope → table ending.
4. Busboy: Begin, exit cabin, NPC dialogue, roots encounter. Try Strike/Guard/
   Cleanse, retreat/retry and defeat. Win, cross gate, reach shrine ending.
5. Machine: bedroom/home/town, all three building conversations/relays, outskirts
   boss. Move and Spark/Brace with separate fingers; test damage/retry and ending.
6. BALLS: direction pad response; BUG: hold/drag/release pointer; BOUNCE: visible
   animation; YOU: clear unavailable-camera message and return.
7. Check audio starts after tapping, acceptable frame rate/loading, sleep/resume,
   and a fresh reload. Record minor issues; focus on playable paths and major bugs.

Physical iPhone Chrome/Safari, Android hardware, full human walkthroughs, audible
audio, real-device thermal/memory behavior and artistic/balance acceptance remain
manual. Playwright WebKit on macOS is useful evidence, not certification of iOS
Safari or Chrome. Android emulation/hardware coverage must be reported separately.
