# Zelda — ZELDA

Arrows move; Space attacks; Ctrl casts; Q/E cycle weapons/magic. M toggles the
upgrade menu; arrows select a stat and Space purchases an affordable upgrade.
Escape closes upgrades first, then returns to Matrix. Progress is memory-only.

The port contains the source floor/map layers, sorted character/object drawing,
player and four enemy types, five weapons, flame/heal magic, destructible grass,
particles, damage/attack/switch cooldowns, contact AI, hit reaction, XP, five-stat
upgrade costs/caps, regeneration, HUD, original sprites/font/music/effects.
The source's initial half health, 80% energy, 5000 XP and stat tables are retained.
The source has **no player death/reset routine**; this port does not invent one.

Assets/maps copied under `assets/` from `legacy/pygame/levels/zelda/`. The manifest
retains every CSV cell, source stat table and explicit sorted frame paths.
Rebuild with `python3 scripts/build_zelda_manifest.py` (reads archived settings).
No new artwork or attribution/licensing claim is introduced. Runtime uses only
this module's GDScript/data/assets, not Python or hub gameplay code.

The archived launcher currently fails: `level.py` requests MAP_DIR from settings,
which does not expose it, and fallback imports then report a missing `level`.
The archive is untouched. Reference captures were rendered using only a transient
in-memory MAP_DIR binding, without editing the archived files.

Differences: fixed 60-tick updates, shared-window fitting and Escape return;
spatial buckets accelerate the same rectangular obstacles. Rendering uses current
model positions instead of the source's draw-before-update lag. Enemy attack
sound triggers on entering attack rather than restarting every frame. Pause-edge
cooldown expiry, particle/timer phasing, UI text/rasterization, randomness and
audio loops can differ. No full gameplay or pixel parity is claimed.

Checks cover map/population, collision, weapon damage and immunity, contact
immunity, healing/costs, five-flame casting, insufficient energy, grass clearing,
XP on defeat, upgrade scaling/caps, pause/Escape, cleanup and all earlier ports.
World and upgrade-menu captures were inspected and compared with the reference.
Manual full-map combat, every weapon/magic combination, audible effects and
other-platform exports remain necessary.
