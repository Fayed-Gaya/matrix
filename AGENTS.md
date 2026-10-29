# Matrix

Godot 4.7.2, typed GDScript, Compatibility renderer. Matrix is the application;
Pegasus is its opening spaceship, not a terminal-launched level.

- `app/` owns startup/routing; `pegasus/` the spaceship; `levels/` independent
  games; `shared/` reusable code. Level roots extend `MatrixLevel` and emit
  `return_requested`; consume Escape locally before returning to Pegasus.
- Native scenes/TileSets/collision markers are authoritative. Never regenerate
  maps from TMX/CSV/JSON. Preserve each game's movement and collision rules.
- Character sprites: `assets/art/sprites/<level>/<character>/` (or `shared/`).
  Runtime art/audio: `assets/art/<experience>/`, `assets/audio/<experience>/`.
  Editable originals: excluded `assets/art/source/`. Keep `.import` and `.uid`
  sidecars; do not commit caches, exports, credentials or local tools.
- Default to the primary local checkout `~/git/matrix` on `main`: implement and
  validate locally, then commit/push so this checkout stays in sync with remote.
  Use another worktree only when isolation is needed, and report where work lives.
  Codex may commit/push validated work
  at meaningful checkpoints. Fetch/reconcile safely; never force-push, overwrite
  user edits or rewrite published history. Branches/PRs are optional; honor
  explicit review gates. Preserve other worktrees and private artwork.
- During implementation use `make fast-check CHECKS=<component>`; before pushing
  runtime changes run `make smoke-check`. Docs-only changes need link/diff checks,
  not gameplay tests. Use broader checks only when warranted; see
  `docs/development.md` for commands. Automated YOU launches must set root metadata
  `matrix_test_mode=true` before instantiation; never activate physical cameras.
- Obtain explicit owner approval for release tags, GitHub Releases, public
  deployment/distribution and release acceptance. Published tags/artifacts are
  immutable. Preserve third-party notices and `archive/godot/` plus level source
  snapshots; unresolved licensing is not cleared by passing tests.
- No paid generation, accounts, persistence, cloud services or DLC without a
  request. Do not invent personal references or artistic approval.

Read module READMEs for gameplay/maps, `docs/art-pipeline.md` for art work, and
`docs/releases/` when preparing a release. Update documentation when behavior,
interfaces or meaningful decisions change; do not create routine task reports,
status journals or retrospectives.
