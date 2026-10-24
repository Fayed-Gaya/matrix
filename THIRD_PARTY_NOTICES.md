# Matrix technical preview — third-party notices

Current development builds retain seven active levels; excluded original
Godot modules remain as source references. This preliminary notice is not a blanket
license for Matrix or clearance to publish. See docs/releases/licensing-audit.md
in the corresponding source snapshot for unresolved permissions and obligations.

- Tom's Pong v0.4: Tom Chance, http://tomchance.org.uk/projects/pong.
  Original code declares GNU GPL without a version. The GDScript port derives
  from that implementation. GPL-2.0.txt and GPL-3.0.txt are supplied for reference;
  no version election or whole-project relicensing is made by this notice.
- Zelda tutorial: Clear Code; upstream identifies code as CC0 and credits
  Pixel-boy and AAA's Ninja Adventure assets/music as CC0. Exact imported
  versions and separate Joystix font terms need confirmation.
- Mario and Jump: tutorial-derived code/assets; attribution to Clear Code is
  provisional provenance, not proof of redistribution permission. Jump's
  Pixeltype font identifies thejman0205 (2015) and a FontStruct Non-Commercial License.
- Monsters: Clear Code tutorial; archived notes credit Scarloxy artwork and
  multiple OpenGameArt sound/music sources. Scarloxy permits commercial game
  use; exact versions, full source-redistribution terms and audio mapping remain
  unresolved. Attribution leads (confirm against actual files): Bart K., Spell 4
  (fire), https://opengameart.org/content/spell-4-fire; The Berklee College of
  Music, Knife sharpening slice 2,
  https://opengameart.org/content/knife-sharpening-slice-2; tcarisland, NES
  Overworld Theme, https://opengameart.org/content/nes-overworld-theme. These
  works offer CC BY options (3.0 for the first two, 4.0 for Overworld); exact
  chosen grants and modification notices still need confirmation. Further
  CC0 source leads: Independent.nu, 5 break, crunch impacts; Luke.RUSTLTD,
  10 8bit coin sounds; nene, Boss Battle #1. Full source links and caveats
  are recorded in the corresponding source audit.
- Pixeloid Sans: © 2020–2022 GGBotNet, SIL OFL 1.1; see LICENSES/Pixeloid.txt
  and LICENSES/OFL-1.1.txt.
- Dogica Pixel / Bold: © 2020 Roberto Mocci, reserved names apply, SIL OFL 1.1;
  see LICENSES/Dogica.txt. Font files remain unmodified.
- Joystix: © 1996–2018 Typodermic Fonts Inc / Ray Larabie. Arcadepix:
  © 2001 Reekee of Dimenzioned. Exact bundled font grants remain unresolved.
- Hub/Untitled sprites (Snoblin filenames), tilesets, opening backgrounds and
  ambience, Bouncing Ball GIF and Bug cat image: provenance/permissions incomplete.
- Godot Engine and bundled third-party libraries: see LICENSES/Godot-engine.txt
  generated from the exact build engine, and https://godotengine.org/license/.

Corresponding source is the exact Git commit recorded in build-info.json.
CI supplies a separate source snapshot artifact, including build scripts,
native scenes/TileSets and source assets. Historical Pygame sources and notices
remain available in Git history at 55c803c4c8488db9dd17b36bbecd62f775cd52d8;
see the frozen inventory in docs/releases/third-party-inventory.json. Public
releases must accompany their binary/site with that same-version source and
all applicable notices, and resolve the blockers before distribution approval.
