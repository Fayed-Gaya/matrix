# Native iOS feasibility

Assessed 2026-10-22 after the browser implementation. A personal-device build is
plausible, but **not built or verified**. It is separate from the committed
Alpha 0.2 browser deliverable. No tools installed, account enrolled, device
paired, certificate/profile created, signing changed or app published.

## Observed local blockers

| Item | Read-only result |
| --- | --- |
| Mac | Intel Core i5-8257U, x86_64, MacBookPro15,4 |
| OS | macOS 15.8.1 (24H32) |
| Active developer tools | `/Library/Developer/CommandLineTools` |
| Full Xcode | No Xcode app bundle under /Applications; xcodebuild reports full Xcode required |
| iOS SDK | `xcrun --sdk iphoneos --show-sdk-version` fails: SDK unavailable |
| Godot iOS templates | None in project toolchain or matching installed export-template directory; only web templates present |
| Free space | About 19 GiB reported; plan space for Xcode/SDKs/builds before installing; nothing deleted |
| Device/signing | iPhone OS version, pairing, Developer Mode and signing readiness not inspected/verified |

Apple identifies this model as the 13-inch 2019 two-port MacBook Pro, with
[Sequoia as its newest supported OS](https://support.apple.com/en-us/108052).
Apple's [Xcode compatibility table](https://developer.apple.com/xcode/system-requirements)
lists Xcode 26.3 with macOS 15.6+ support and iOS 26.2 SDK; it is a candidate on
this host, not a tested recommendation. Newer Xcode versions in the table require
Tahoe, so installing the latest Xcode is not a safe assumption. Confirm the
actual phone OS/device support and Godot template linkage with the chosen
Xcode. An SDK version, deployment target and device-debugging support range are
different constraints. If a supported combination cannot build/run on this
phone, use a newer compatible Mac; do not patch macOS or buy hardware here.

## Smallest future personal-device milestone

1. With owner agreement, obtain a compatible full Xcode and required SDKs, check
   storage, launch it and select its developer directory. Keep changes local.
2. Obtain official **matching Godot 4.7.2** iOS templates, verify provenance/hash
   (the existing template-bundle manifest is pinned), and extract/install iOS
   support deliberately. Current setup script only provisions web templates;
   no unverified substitute engine/template version should be used.
3. Add a dedicated iOS preset with the same active asset/JSON inclusion and
   archive exclusions. Preserve Compatibility, choose landscape orientations,
   review icons/safe areas, and keep exported Xcode projects under ignored
   `exports/ios/`. Reuse the seven independent modules and touch actions.
4. Choose a unique bundle ID and the owner's actual team ID; no fabricated
   credentials. [Godot's iOS export guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html)
   requires macOS, full Xcode, export templates and those identifiers. Export an
   Xcode project with a simple distinct output name, then build from Xcode.
5. Owner signs into Xcode, chooses personal development signing and pairs the
   iPhone. [Apple supports personal-device testing with a free Personal Team](https://developer.apple.com/help/account/basics/about-your-developer-account);
   its profiles expire after seven days and need periodic reprovisioning.
   Signing may create development credentials/profiles: obtain approval before
   doing that. Paid enrollment is not required for this initial milestone.
6. Owner enables [Developer Mode](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device)
   after pairing, confirms its restart prompt, and permits running the local
   development build. Do not automate the owner's account/device confirmations.
7. Run on the **physical phone**, not just a simulator: hub/computer, all seven
   levels, return paths, landscape/rotation, readable scaling, safe areas,
   simultaneous movement/action, sound, interruption/resume and performance.

The current touch browser implementation normalizes CSS coordinates on web.
Native iOS scaling/safe areas still need their own verification/configuration;
shared controls alone do not prove native usability. YOU's native camera code
already includes iOS in its platform path, but real iOS permissions, camera
formats and shader output remain untested. Add a truthful camera usage
explanation in packaging and verify denial/unavailable/return behavior before
claiming native camera support. Leave native macOS behavior intact.

No native export/signing pipeline was added to CI because its prerequisites
are missing and assessment is the authorized scope. TestFlight, App Store,
distribution certificates and paid services are outside this milestone. Asset
licensing remains unresolved independently of whether installation succeeds.
