# Matrix assets

- `art/source/<experience>/`: editable Aseprite/SVG sources and authoring notes;
  excluded from Godot imports and web exports by `.gdignore` and export rules.
- `art/<experience>/`: runtime graphics, atlases and sprites, with tracked
  `.import` sidecars. Pegasus, Bubby, Busboy, Machine, Bounce, Bug and shared
  graphics have independent subdivisions.
- `audio/<experience>/`: runtime audio with import settings preserved.

Maps, TileSets, scripts and JSON configuration remain in their owning modules.
See [art workflow](../docs/art-pipeline.md). Historical assets in `archive/`,
level `source/` snapshots are intentionally not consolidated. Pygame origins
are retained in the frozen licensing inventory and Git history.
Existing notices and unresolved permissions still apply. Unassigned experimental
recordings are not approved game content; the known RedGIFs recording is explicitly
excluded from browser exports if present. Do not publish it without rights review.
