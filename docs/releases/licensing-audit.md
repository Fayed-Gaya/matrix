# Preliminary licensing audit — Alpha 0.1

Reviewed 2026-10-21. **Distribution clearance is not established.** This records
known evidence and open questions, not a new license grant or a decision that
all components can legally be combined. No level/asset was removed or replaced.
The owner explicitly authorized technical-preview publication on 2026-10-21
with these issues unresolved. This acknowledges the risks; it does not resolve
permissions, establish licensing clearance or change the obligations below.

`third-party-inventory.json` records every active GDScript/shader, scene/TileSet,
manifest and media file with SHA-256, size, module, exact archived matches and
embedded font notices. It also includes source-only copies for provenance; its
count is not the number of exported resources. This Alpha 0.1 inventory is frozen;
`python3 scripts/audit_licenses.py` / `--check` maintain the separate current
`alpha-0.2-third-party-inventory.json`. Historical source paths can be inspected
at Git revision `55c803c4c8488db9dd17b36bbecd62f775cd52d8`. Godot paths below
refer to the immutable `v0.1.0-alpha.1` tree, before later module renames/retirement. Matching a
hash establishes identity, not permission. Derived atlas/scale/map resources
retain their original content's obligations. No root Matrix LICENSE existed.

## Findings by component

| Component and paths | Known evidence | Required work / release status |
| --- | --- | --- |
| Pong code: `levels/tom_pong/*.gd`, archived `tom_pong.py` v0.4 | Tom Chance header declares GNU GPL; no version or full text bundled originally. GDScript port retains source physics and derives from it. | **Blocker:** confirm applicable GPL version and copyright notices; determine GPL scope/compatibility for this combined application and choose appropriate Matrix licensing with owner authorization. A language port does not erase obligations. Preserve original notice, identify modifications, provide applicable license and corresponding source/build instructions. GPL-2.0/3.0 texts are supplied for reference, not a version election. |
| Pong PNGs and scaled derivatives | Original `source/` and archive retain art; code's GPL header does not independently establish every asset's grant. | Confirm assets' author/license and source distribution terms. |
| Jump code, `graphics/`, `audio/` | Appears from Clear Code's [UltimatePygameIntro](https://github.com/clear-code-projects/UltimatePygameIntro). No explicit grant found in the checked upstream landing page or archive. | **Unresolved:** obtain original version/license for code, sky/ground/player/snail/fly art, music and jump sound. Public/tutorial availability is not blanket permission. |
| Mario code, graphics and audio | [Tutorial repository](https://github.com/clear-code-projects/2D-Mario-style-platformer) is a credible provenance lead; no explicit license located in its checked landing page/archive. | **Unresolved:** identify grants/authors for each art/audio pack and tutorial code. Native map editing does not change asset rights. Do not infer a Nintendo license from the level name or claim content is Nintendo-owned without evidence. |
| Zelda code, Ninja Adventure sprites/tiles/audio | [Clear Code upstream](https://github.com/clear-code-projects/Zelda) states CC0 for code and credits Pixel-boy and AAA's [Ninja Adventure](https://pixel-boy.itch.io/ninja-adventure-asset-pack) art/soundtrack as CC0. | Strong permission evidence; retain provenance and optionally credit authors. Confirm imported files/version match this pack; separate font terms below still apply. |
| Monsters code | [Python-Monsters upstream](https://github.com/clear-code-projects/Python-Monsters) explicitly states CC0 for code, while separately attributing artwork/audio. | Retain Clear Code provenance; CC0 code statement does not cover all third-party media. |
| Monsters art, atlas pages and cutouts | Upstream identifies Scarloxy's [MyPixelWorld Special Pack 01](https://scarloxy.itch.io/mpwsp01). Publisher describes it as original and commercially usable. | Positive game-use evidence. Confirm exact assets/version and retain the pack's full terms, especially raw-source redistribution rights; no bundled grant was found. No assumption that a paid license is required. |
| Hub/Untitled Snoblin player/NPC sheets | Filename/provenance lead: [prototype character page](https://snoblin.itch.io/pixel-rpg-free-npc) allows project use/edits but prohibits asset redistribution/resale. A separate [Godot store listing](https://store.godotengine.org/asset/snoblin/top-down-prototype-character/) says CC0. | **Blocker:** reconcile the applicable version/acquisition grant and exact file match. Do not choose the more permissive listing without evidence. Raw files in source snapshots/GPL compatibility need clarification. |
| Hub/Untitled tilesets, backgrounds, forest ambience | Archived filenames and copies preserved, but no complete author/license chain for `interiors_free_16x16.png`, `16x16.png`, opening JPG/forest PNG or ambience MP3. | **Unresolved:** obtain source pack URLs, license files and any modification/credit requirements. Names containing “free” are not a license. |
| Bouncing Ball GIF/PNG; Bug cat PNG | Exact archived matches/converted source preserved; no author or license record located. | **Unresolved:** identify provenance and redistribution permission for both images. |
| Balls / You and new routing/map/CI code | Local source/project history; no external media for Balls/You beyond engine/default resources. No repository-wide source license selected. | Owner to establish code rights/license, considering Pong copyleft. New code is not silently relicensed here. |
| Godot runtime, web loader/WASM and bundled libraries | [Godot license](https://godotengine.org/license/) is MIT with separate third-party notices. | Exact-engine MIT/component notices are generated into the build's `LICENSES/Godot-engine.txt`; retain them and the engine credit link. Python/Pygame are development/archive dependencies and are not in the web runtime. |

## Monsters audio attribution leads

The upstream README links the following original works. These are source-page
licenses, **not completed file-level audio fingerprint matches**. Confirm each
actual WAV/OGG/MP3 (including edits/transcoding) against the chosen original.
Keep title, author, source URL, license URL and change notice for attribution.

| Likely role | Source / author | Listed license and obligation |
| --- | --- | --- |
| Fire | [Spell 4 (fire)](https://opengameart.org/content/spell-4-fire), Bart K. | Multiple alternatives incl. CC BY 3.0, BY-SA, GPL and OGA-BY. Select/document an applicable option; under BY, credit author/work/source/license and identify changes. |
| Slash | [Knife sharpening slice 2](https://opengameart.org/content/knife-sharpening-slice-2), The Berklee College of Music (uploaded by qubodup) | CC BY 3.0; attribution/license/change notice. |
| Crunch | [5 break, crunch impacts](https://opengameart.org/content/5-break-crunch-impacts), Independent.nu (uploaded by qubodup) | CC0; provenance credit retained voluntarily. |
| Overworld | [NES Overworld Theme](https://opengameart.org/content/nes-overworld-theme), tcarisland | CC BY 4.0; attribution/license/change notice. |
| Notice | [10 8bit coin sounds](https://opengameart.org/content/10-8bit-coin-sounds), Luke.RUSTLTD | CC0; provenance credit retained voluntarily. |
| Battle | [Boss Battle #1](https://opengameart.org/content/boss-battle-1-8-bit-re-upload), nene | CC0; verify version and loop/transcoding changes. |

`heal`, `scratch`, `explosion`, `splash`, evolution music and any otherwise
unmapped sounds require explicit mapping; do not assume all OpenGameArt files
share one license. Runtime explosion WAV was converted from ADPCM to PCM16;
its original remains available in source/archive. Atlas/color-key and image
scaling transformations are also modifications to record where required.

## Embedded font evidence

All six fonts were inspected directly; full metadata is retained in the inventory.

| Font | Embedded evidence | Status |
| --- | --- | --- |
| Pixeltype (Jump) | Copyright thejman0205 2015; “FontStruct Non-Commercial License” | **Blocker:** obtain exact terms and permission for the intended distribution/monetization; non-commercial restrictions may conflict with GPL-covered combined distribution. Do not replace silently. |
| Arcadepix (Mario) | © 2001 Reekee of Dimenzioned; no embedded license grant | **Unresolved:** obtain exact font license/embedding rights. |
| Joystix (Zelda) | © 1996–2018 Typodermic Fonts Inc / Ray Larabie; no embedded grant | **Unresolved:** obtain terms covering this bundled version; current “free font” terms cannot simply be assumed retroactive. |
| Pixeloid Sans | © 2020–2022 GGBotNet, SIL OFL 1.1 | Include copyright/OFL text; do not sell font alone; retain license. `LICENSES/Pixeloid.txt` and `OFL-1.1.txt` included. |
| Dogica Pixel / Bold | © 2020 Roberto Mocci, SIL OFL 1.1, reserved font name(s) | Include copyright/OFL, respect reserved names if modifying, retain font license. Embedded license copied to `LICENSES/Dogica.txt`; font binaries unmodified. |

See the [official OFL](https://openfontlicense.org/) for bundling/modified-font
conditions. OFL font embedding does not itself license the game's code.

## Corresponding-source and release checklist

1. Resolve Pong GPL version, combined-work scope and compatibility before
   choosing a repository/application license. Do not claim mere archive retention
   or a public GitHub link alone is complete GPL compliance. Review the applicable
   [GPL text](https://www.gnu.org/licenses/gpl-3.0.html) and source-delivery rules.
2. Supply the exact released revision's preferred source: GDScript/shaders,
   native scenes/TileSets, required asset sources, build/export scripts and
   dependency/toolchain instructions, plus notices and modification information.
   On-demand release validation creates a corresponding source snapshot alongside
   the web artifact.
   WebAssembly/compiled GDScript is not a substitute for preferred source.
3. Resolve grants for unlicensed media and redistribution restrictions above.
   Archive all actual license/permission evidence. Confirm required BY credits
   and whether any ShareAlike option is actually used. Do not silently remove,
   substitute or relicense content to pass the audit.
4. Keep `THIRD_PARTY_NOTICES.md`, bundled font/GPL reference texts and generated
   engine notices with the browser distribution. Update preliminary credits once
   file-level provenance is confirmed. Do not claim this notice is final clearance.
5. Only after owner approval, clear the manual deployment gate and publish/tag.
   Current CI artifacts are technical verification outputs, not an approved
   future release; their existence does not resolve these distribution issues.
