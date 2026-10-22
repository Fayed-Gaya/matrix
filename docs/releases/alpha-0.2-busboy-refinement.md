# Busboy creative refinement

## Current checkpoint

2026-10-22. Branch `feature/alpha-0.2-busboy-refinement` in isolated worktree
`~/git/matrix-busboy-refinement`, based directly on integrated main `a3588fb`.
Bubby PR #18 is independent and untouched. No merge/tag/deployment authorized.

## Scope / next action

Refine existing cabin → forest → waykeeper → one turn-based root encounter →
cleared passage/shrine. Keep magic stain, improve readable consequences and
turn feedback. No new regions, XP, inventory, persistence or definitive lore.
Implemented: layered woodland/refuge, native trail/props/depth sorting, original
hooded traveller and waykeeper, two PixelLab tree/root assets, restrained NPC
writing, explicit magic/stain tradeoff, immediate defeat retry, clear turn UI and
a lit shrine ending reflecting remaining stain. Local rendered frames inspected;
face-layer/crop defects corrected. Current state passed full make check, fresh
runtime and audited web export; targeted route/combat/mobile checks also passed.
Browser route/button smoke and phone UI inspection completed successfully; the
compact review set and final handoff are ready. Final delivery checks/export,
inventory freshness and source lint passed. Next: owner creative review of the
focused PR, not additional regions or integration without approval.

## References and provenance

Read all four canonical Google Doc tabs: Overview, Art Style, Task Breakdown,
Notes. The embedded Art Style image currently resolves to a green pixel-face
placeholder, not a usable environment reference. Notes link Clockwork Raven's
Green Forest pack and a Tiled tutorial. The pack is a style reference; no proof
identifies the repository's Snoblin-named sheets/atlas as Kobe-authored or that
pack. Existing archived asset notes identify prototype/placeholder sprites but
supply no author/license grants. Original art actually attributable to Kobe has
not been located. Do not describe new work as Kobe-approved or cleared.

Read original Untitled source/docs/assets, PR #10 and hub/Bubby art findings.
Inspected actual unchanged forest/battle renders and original 16px atlas. Main
weaknesses: empty flat ground, sparse disconnected props, geometric enemy,
uninformative battle canvas and tiny characters. Retain movement/ambience and
native editing contracts; replace the provisional art selectively.

## Tool trial

PixelLab is callable; read-only balance: trial 38 included generations, $0
credits. At most two targeted included-generation assets (tree/root knot).
Two jobs completed (tree `e313cb05-b7ff-46fa-bb43-e3a8f19a5fb6`, root
`77e5c44b-3b99-41e4-821f-2a989d39fa6f`), balance **36 / $0** afterward. Aseprite
masters and raw PNGs preserved; both runtime PNGs exported explicitly. One second
request was rejected by the one-job concurrency limit before submission, then
submitted after the first completed. No purchases, paid credit fallback,
credentials or configuration changes. Full details: `art/busboy/refinement/README.md`.

## Acceptance gaps

Human gameplay/art/balance, audible audio and physical phone acceptance remain
unverified. Future Earth/Fire/Blood and antagonist arc remain outside scope.

## Validation and review checkpoint

Implementation checkpoint `d666520`, scope/reference checkpoint `5950e1f`.
Passed: full `make check` (771 archive checksums, tool checks, all seven active
modules), fresh archive-free `make runtime-check`, audited web export and targeted
`busboy mobile` checks. Native full path exercises actual collision walking,
waykeeper gating, dialogue lock, scene cell/region/collision save/reload, magic
costs/stacked stain/guard mitigation, non-magic and mixed victories, failed cast,
defeat/immediate retry, retreat, gate removal, lit shrine/ending and Matrix return.

Actual Compatibility-window progression passed and frames were visually reviewed.
Three browser contexts passed in **2.1 min**: Chrome, mobile Chrome DPR3 and mobile
WebKit DPR3. They use actual keys/touches to navigate the refuge/forest, speak,
cast/guard, verify exact mana/stain/reply values, reject a low-mana cast, retreat
and return; all seven terminal routes, rotation and error guards remain.

Final dialogue/portrait layout also passed a focused mobile Chrome run (46.4 s).
Visual review led to two small draw-only corrections: actor shadows now align
with revised foot anchors and the phone dialogue footer avoids the movement pad.
Final targeted rendering/resource checks and audited delivery export passed after
those corrections. Browser smoke covers the encounter's first turns; native fixtures
cover the full victory, defeat/retry and ending. No human walkthrough/physical
phone/audio/balance acceptance is claimed.

[Six compact actual review captures](../reviews/busboy-refinement/README.md).
Forest/tree/root detail is materially stronger; local characters and cabin remain
simpler, repeated canopy shapes/ground litter are noticeable, and props are static.
An artist's palette/edge/silhouette pass would improve cohesion. Current style,
conversation and shrine beats are provisional, not Kobe-approved canon.

Useful inputs, in priority order:
1. Kobe's actual source sprites/reference folder, with filenames/authorship/license
   information and which elements he considers central.
2. One approved style/palette crop plus protagonist/waykeeper silhouette direction.
3. A short approved environmental motif or dialogue line to preserve. The original
   Untitled bus-a-boy fallback line remains archived; it was not treated as a new
   approved plot requirement.
His participation is not required to play/review this introductory slice.

## Resume / authority

Three local recovery checkpoints; one final push and PR targeting main. Locate
the PR by branch `feature/alpha-0.2-busboy-refinement`. Next action: owner creative
review of that PR, not further scope expansion. Do not merge this branch or Bubby
PR #18, tag or deploy without explicit authorization. Bubby worktree remains at
`2f95f55`; it is not an ancestor/dependency. Archives, other level assets, original
checkout settings/private sprite and immutable Alpha 0.1 remain preserved.

Local logs: `/tmp/matrix-busboy-{full,runtime,export,fast-final2,browsers,mobile-final,
capture-final,foot-check,export-delivery}.log`. Generated exports/tool links stay
out of Git. To inspect locally: `make -C ~/git/matrix-busboy-refinement run`.
Use this existing worktree for future Busboy work; inspect activity/status first.
