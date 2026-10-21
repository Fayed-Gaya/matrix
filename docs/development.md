# Development workflow

Matrix follows GitHub Flow. `main` is the latest integrated, validated code;
there is no permanent dev branch. Start substantial work from updated main on
a short-lived `feature/...` or `fix/...` branch. Commit meaningful checkpoints,
push the branch and open a pull request targeting main. Codex may commit/push
feature work autonomously; merging requires explicit user authorization.
Use merge commits to retain implementation history. Do not force-push main.

Published releases use immutable annotated version tags (for example
`v0.1.0-alpha.1`). Create a tag only after release approval and checks. Never
move/reuse a published tag; fixes receive a new version. Alpha 0.1 is not tagged
or published by this pipeline preparation.

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
