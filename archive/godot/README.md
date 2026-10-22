# Godot source retained for reuse

Alpha 0.2 retires Jump, Mario, Monsters and Tom Pong from the playable catalog.
Their complete modules were moved here with Git, including artwork, import
settings, native maps, UIDs, READMEs and attribution. No assets were cleared or
relicensed. Original `res://levels/...` references are deliberately preserved as
historical source; these modules are not runnable directly from this directory.
Monsters' turn-based mechanics remain available for selective Busboy reuse.

`archive/.gdignore` and the explicit export exclusion keep this source out of
imports and browser packs. Archived fixtures/checks are under `validation/`.
`make archived-godot-check` runs the complete original ten-level Godot suite in
a disposable tree from pinned pre-Alpha-0.2 commit `145771f`, without restoring
retired codes to the current game or changing this worktree. This requires that
Git commit locally (normal clones contain it). The independent Pygame archive
is still under `legacy/pygame/`; `make archive-check` checks its preservation.
