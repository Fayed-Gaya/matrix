# Development workflow

Matrix follows GitHub Flow. `main` is the latest integrated, validated code;
there is no permanent dev branch. Start substantial work from updated main on
a short-lived `feature/...` or `fix/...` branch. Commit meaningful checkpoints,
push the branch and open a pull request targeting main. Codex may commit/push
feature work autonomously; merging requires explicit user authorization.
Use merge commits to retain implementation history. Do not force-push main.

Published releases use immutable annotated version tags (for example
`v0.1.0-alpha.1`). Create a tag only after release approval and checks. Never
move/reuse a published tag; fixes receive a new version. Alpha 0.1 is published at `v0.1.0-alpha.1`; preserve that tag and its artifacts.
Current Alpha 0.2 work is unreleased; see `releases/alpha-0.2-status.md`.

Reproduce checks with Godot 4.7.2 stable and Python 3:

```sh
make check GODOT=/path/to/godot
make runtime-check GODOT=/path/to/godot
make editor-map-check GODOT=/path/to/godot # optional real desktop editor
```

The first checks include archive integrity, resource/script/scene loading, hub
and level behavior, native map editing, startup, and fresh archive-free routing.
Automated camera tests inject synthetic feeds and never activate physical feeds.
The archived Python workflows remain separate source-quality/build checks.

In GitHub Settings → Rules → Rulesets (or Branches), protect main: require a PR,
require the `Godot validation` and `Web export` checks once they have run, require
an up-to-date branch if desired, block force pushes and deletion. Configure human
review requirements to match the owner's policy. These settings are documented,
not changed automatically. Configure tag rules to prevent modifying/deleting
published version tags. No rule is bypassed by this work.

## Alpha 0.2 catalog and archived checks

The current branch retains BOUNCE, BALLS, BUG, YOU and the two RPG foundations.
BUBBY/BUSBOY replace their public codes during their implementation checkpoints;
MACHINE is added only when playable. PONG, JUMP, MARIO and MONSTERS are source
references under `archive/godot/`, excluded from imports and exported packs.
`make check` and browser smoke tests cover the active catalog. To run the full
original ten-level Godot suite without changing this worktree:

```sh
make archived-godot-check GODOT=/path/to/godot
make web-export GODOT=/path/to/godot
python3 scripts/check_web_pack.py --godot /path/to/godot
make web-serve
```

The pack check walks exported directories to reject retired module assets and
checks dynamic JSON dependencies and all active routes from the isolated PCK.
`art/` is editable source, excluded from imports/exports; approved runtime images
belong in their owning module. Do not stage unrelated user artwork. Historical
Alpha 0.1 release documentation describes that release, not the current catalog.

Alpha 0.2 may use stacked feature PRs while earlier phases await merge. The
Godot/Web workflow also checks PRs targeting `feature/alpha-0.2-*`; public Pages
deployment remains manually authorized from main. Merge none of these branches
without owner authorization; retarget descendants after their base is merged.
