# Bubby creative refinement

## Current checkpoint

2026-10-22: based on validated main `a3588fb` (approved hub PR #17 merge).
Branch `feature/alpha-0.2-bubby-refinement`; isolated worktree
`~/git/matrix-bubby-refinement`. Original checkout's project settings and private
sprite remain untouched. Local checkpoints; one final push/PR when coherent.

## Scope and next action

Apartment exploration → occupied balcony → scattering small birds → oversized
cute pigeon with telegraphed hops and shoo recovery windows → reclaimed balcony.
Replace unrelated envelope errand. Forgiving immediate retry, keyboard and touch.
Apartment, furnishings, avatar likeness and personal ending remain provisional.
No XP, persistence, other-level redesign, merge, release tag or deployment.

Implemented: native apartment/balcony redesign, optional notebook, scattering
birds, six-shoo Grand Coo with locked landing tells, five-point composure,
retry/retreat, unharmed departure, cleanup and ending. Twelve layered original
Aseprite environment masters plus one actual PixelLab pigeon. Targeted Bubby and
mobile checks passed, including movement+shoo fingers and touch retry. Actual
Compatibility renders inspected; a floor-coordinate defect was caught visually
and fixed with a new guard. HUD now reserves space above the whole room.

Implementation is coherent and validated. Local checkpoints: `fd20aee` hub
integration record, `b6628d0` adventure/art, `dfefd32` curtain/export correction.
Final handoff commit adds the review gallery and this evidence. One final push
and PR targeting main; locate it by `feature/alpha-0.2-bubby-refinement`.
Next action: owner creative review of that PR/captures. Do not merge, tag or
publish without separate authorization. No additional gameplay work is pending
for this iteration; authentic personalization awaits references.

## Art evidence

PixelLab tools are exposed in this session. Balance inspection reported a trial
with 39 included generations and $0 credits. One 96px pigeon trial submitted
(job `0aa8cca5-8951-4909-b3f3-0faeb740b199`, seed 220226, cost one generation).
Generation completed and was downloaded/inspected: strong cute silhouette,
static view; imported to a layered Aseprite master (base plus empty refinement
layer). No hand cleanup claimed. No paid credits, subscription/configuration or
credential changes. See `art/bubby/refinement/README.md`.

## References

Read Bubby Google Doc tab and PR #9. Latest owner scope matches the balcony/boss
vision; older delivery objective is implemented baseline, not desired narrative.
Read hub's raster/Aseprite findings. No reliable Kate/apartment photos supplied.

## Validation / remaining acceptance

Passed locally: full `make check` (archive771/tools/all seven levels),
`make runtime-check`, audited `make web-export`, targeted `bubby mobile`, and
actual Compatibility-window complete progression/captures. Aseprite exported
all twelve environment masters; explicit pigeon-master export was pixel-identical
to the original PixelLab PNG. Balance after the trial: 38 generations, $0 credits.

Browser round one exposed a genuine oversized curtain collider: its lower end
extended below the visible curtain, blocking a natural y≈272 approach. Fixed to
match its actual visible extent; added long-frame native approaches at y=268,
282 and 306. Browser waypoint tolerances/assertions were unchanged. Targeted
checks and fresh audited export passed after correction. Final Chrome, mobile
Chrome DPR3 and mobile WebKit DPR3: **3 passed in 1.5 min**, including actual
apartment-to-balcony navigation, shoo-window hit, all seven routes/returns,
rotation and simultaneous movement+shoo touch input. Console/script/network
error guards passed. This browser smoke does not play the entire boss to victory;
native checks/window fixtures cover win/failure/retry/ending. Final PR CI will
also exercise Firefox/Edge and Chrome DPR3 layout on a clean Linux checkout.
No archive/other-level assets or Alpha 0.1 records changed.

Physical
iPhone gameplay/audio/OS keyboard and artistic acceptance remain unverified.

## Artistic assessment / next owner inputs

[Five actual review captures](../reviews/bubby-refinement/README.md) show the
apartment, occupied balcony, boss tell, ending and mobile controls. The pigeon
has the strongest silhouette and shading. The environment is softer and more
coherent, but furnishings are simpler and the layout generic; no final Kate
likeness, authentic apartment or personal narrative is implied. Flying birds
have no bespoke wing animation. Human balance/feel/audio acceptance is deferred.

Prioritized references (needed for authenticity, not for this playable draft):
1. Rough floor plan and a few apartment/balcony photos, especially connecting
   doors, rail and important furnishings; identify what should be recognizable.
2. Approved Kate likeness references: hair/outfit and front/side appearance.
3. One meaningful object, true shared reference or preferred affectionate ending
   line. No fabricated personal details or memories have been added.
Optional: one approved style image/crop to unify environment/character edgework.

Recommended pipeline: choose a small approved palette/scale; trial one high-value
sprite with verified included allowance; inspect the actual result; preserve raw
provenance and an Aseprite master; export explicitly, then compose independent
props/native tiles and collisions in Godot; inspect game frames at desktop/phone
sizes. Codex can automate exports, state logic, placement and checks. A human's
best contribution is authentic references and selective silhouette/edge/likeness
work. One successful static pigeon does not validate whole-room or animation
consistency. No paid tools or new dependencies were introduced.


## Evidence / resuming

Local logs: `/tmp/matrix-bubby-{full,runtime,fast-final,export-final,browsers-final,
capture-final,pixels}.log`. Old failure evidence is retained in `browsers.log`.
Five tracked captures are the compact review set. Generated exports/caches and
local toolchain links stay out of Git. Original checkout still has only its
pre-existing `project.godot` edit and private sprite; archives are untouched.

To inspect/play this branch without switching the owner's original checkout:
`make -C ~/git/matrix-bubby-refinement run`. For future work, inspect Git status
and activity first; use the existing refinement worktree. PR checks are visible
on GitHub; do not rerun the full local matrix solely to repeat green CI.
