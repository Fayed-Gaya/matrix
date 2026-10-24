# Pegasus and asset consolidation

Work branch: `refactor/pegasus-assets`, based on integrated main `a3588fb`.
Matrix remains the application; Pegasus is its opening spaceship, not a level
registry entry. Bubby #18 and Busboy #19 remain independent, unmerged work.
Owner checkout edits, private artwork and audio commit are not incorporated.

## Legacy audit and decision

`legacy/` has 772 tracked files (40,339,647 bytes), including its ignore marker
and the 771-file Pygame baseline. `archive/` has 670 files (37,923,490 bytes),
primarily retired Godot modules and original spaceship resources, not a second
Pygame implementation. 183 legacy files have no byte-identical copy elsewhere
in this checkout (Git-normalized text, not a semantic equivalence comparison).
They include original Python gameplay, TMX/TSX/CSV sources and development notes.

Active Godot gameplay and exports do not need legacy files. Development still
uses them: `make check` → `archive-check`, licensing provenance matching,
project exclusion validation, archived Python CI and manual Windows packaging.
The historical Godot check reconstructs pinned `145771f` from Git independently.

**Retained.** AGENTS requires explicit archive removal authorization following
manual playtesting, in its own commit. The cleanup request conditionally defers
removal when significant unique material remains. A future decision must approve
retiring these unique working-tree sources to Git history and removing their
preservation check/archived CI/provenance lookup. Do not infer that approval
from this structural cleanup. No archive or excluded Bubby/Busboy source changed.

## Checkpoints

- Rename: Pegasus scene/classes, app property/router, inputs, mobile contexts,
  active tests/fixtures and current instructions updated together. Focused
  `make fast-check CHECKS="pegasus mobile"` passed.
- Next: consolidate runtime/source assets, update tooling and inventory, then
  full Godot/fresh runtime/audited web/browser validation.

Historical release/review records retain their original names and locations
as evidence of those revisions. Current paths and commands supersede them.
