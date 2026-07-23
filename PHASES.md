# PHASES — WhorAizen Iris Shader Pack

Work exactly one phase at a time, in order, per RULES.md §2. Do not begin a phase until the previous one's checklist is fully checked and MEMORY.md has a closing entry. Update the checkboxes below in place as work happens — this file is the visible progress tracker.

## Phase 0 — Skeleton & zero-error baseline
Goal: a shader pack that Iris loads with zero errors, doing nothing but passing vanilla rendering through unchanged.
- [x] Set up directory layout exactly per ARCHITECTURE.md §1
- [x] Base everything on Iris' own official "Base" starter pack (Unlicense) rather than starting from a blank file — confirms the minimum working skeleton
- [x] Write a minimal `shaders.properties` (profile list stub, no options yet)
- [x] Confirm the pack selects and runs in-game with no log errors/warnings, on at least one GPU vendor
- [x] Commit + MEMORY.md entry

## Phase 1 — Core deferred lighting
Goal: correct, bright, unshadowed sun/moon/block-light lighting.
- [x] gbuffers_terrain/entities/hand/block write albedo, normal, lightmap, PBR-stub data to colortex per ARCHITECTURE.md §2
- [x] composite (deferred resolve) reconstructs world position and mixes sun/moon + block light + a flat ambient term
- [x] Implement the brightness-floor uniform (RULES.md §4) even before shadows exist, so it's load-bearing from day one, not bolted on later
- [x] Visual check: full day/night cycle looks correct and readable with no shadows yet (flat but bright, no crushed blacks)
- [x] MEMORY.md entry

## Phase 2 — Shadows (PCSS)
Goal: soft, contact-hardening directional shadows that respect the brightness floor.
- [x] shadow.vsh/.fsh render depth + colored translucent shadow data
- [x] `lib/distort.glsl` implements shadow map distortion (Iris tutorial pattern) to concentrate resolution near the player
- [x] `lib/shadows.glsl` implements blocker search → penumbra estimate → variable-kernel filtered sample (PCSS), not flat PCF
- [x] Verify shadow floor: fully shadowed geometry at night/thunderstorm still sits at/above the ambient floor from Phase 1
- [x] Visual check against DESIGN.md mood reference: shadows should read as soft and cinematic, not muddy or banded
- [x] MEMORY.md entry

## Phase 3 — Sky & atmosphere
Goal: physically-grounded Rayleigh/Mie sky with genuinely good sunrises/sunsets.
- [x] `gbuffers_skybasic`/`gbuffers_skytextured` disable vanilla sky rendering
- [x] `composite.fsh` draws the atmospheric scattering sky when `depth == 1.0`
- [x] `lib/sky.glsl` implements a single-scattering Rayleigh/Mie model
- [x] Sun and moon discs rendered procedurally via `dot(viewDir, lightDir)`
- [x] Visual check: daytime sky should be a vibrant azure, sunset should feature a rich red/orange gradient, and nights should have a visible starry mood
- [x] MEMORY.md entry

## Phase 4 — Volumetric god rays / fog
Goal: raymarched light shafts, strongest at low sun angle, present at night from the moon, restrained at noon.
- [ ] `lib/volumetrics.glsl`: camera-to-scene raymarch sampling the shadow map per step, accumulating in-scattered light
- [ ] Run at half/quarter resolution with depth-aware bilateral upsample (perf budget from RULES.md §5)
- [ ] Tie intensity/density to sun angle, weather, and dimension (denser/moodier in Nether fog, colder/thinner at night)
- [ ] Visual check: light shafts through tree canopy and windows read as "cinematic," not "hazy screen"
- [ ] MEMORY.md entry

## Phase 5 — Water
Goal: soft, realistic wave motion with reflection/refraction/foam.
- [ ] `lib/water.glsl`: multi-octave Gerstner wave sum for vertex displacement in gbuffers_water
- [ ] Normal-mapped micro-detail layered on top of the macro Gerstner normal, with distance-based normal smoothing to avoid specular shimmer far from camera
- [ ] composite2: SSR trace for reflections with procedural-sky fallback on trace miss; refraction via wave-normal-perturbed screen UV sampling
- [ ] Shoreline foam
- [ ] Visual check: open ocean, small pond, and underwater-looking-up all read correctly
- [ ] MEMORY.md entry

## Phase 6 — Waving foliage & world motion
Goal: living, wind-reactive world, storm-reactive without becoming chaotic.
- [ ] `lib/foliage_wave.glsl`: shared displacement function parameterized by wind strength + a per-vertex phase offset (position-hashed) so nearby plants don't move in lockstep
- [ ] Apply to grass, leaves, crops, vines, and any other Iris-tagged "waving" block types in gbuffers_terrain
- [ ] Wind strength scales with weather (calmer clear-day baseline, escalating through rain into thunderstorm) — cap the top end so it reads as "storm," not "hurricane" (learn from Waving Plants Shaders' known overdo-it failure mode and avoid it)
- [ ] Visual check across weather states
- [ ] MEMORY.md entry

## Phase 7 — Bloom & post stack
Goal: physically based bloom + filmic tonemap + restrained color grade.
- [ ] `lib/bloom.glsl`: prefilter (bright-pass with Karis average to kill fireflies) → mip-chain downsample → mip-chain upsample with tent filter and additive blend
- [ ] `lib/tonemap.glsl`: exposure control (auto or time-of-day-driven) + filmic tonemap curve
- [ ] Color grade pass: push the "bright cinematic" identity — keep contrast and mood, lift the shadow floor, avoid orange-teal cliché unless it genuinely serves the sunset beat
- [ ] `lib/dither.glsl`: blue-noise dither in `final` to prevent banding, especially now that the night floor is higher (more visible gradient to band)
- [ ] Optional, default-OFF toggles: vignette, chromatic aberration
- [ ] MEMORY.md entry

## Phase 8 — TAA, reflections polish, optional PBR
Goal: temporal stability and materials fidelity.
- [ ] composite14: TAA reprojection using motion vectors + colortex7 history, with a clamp/rectification step to avoid ghosting
- [ ] Extend SSR to opaque wet/specular surfaces (not just water) if PBR specular data is present
- [ ] Optional LabPBR-compatible resource-pack support (normal/specular maps) behind a feature flag, gracefully absent when a resource pack doesn't provide them
- [ ] MEMORY.md entry

## Phase 9 — Profiles, QA, and ship
Goal: Potato → Ultra profile tuning and a full error/perf sweep.
- [ ] Define each profile's `program.<name>.enabled` gating and resolution scaling per ARCHITECTURE.md §4
- [ ] FPS pass on target GPU tier per profile (RULES.md §5)
- [ ] Full cross-vendor error sweep (Nvidia/AMD/Intel) at Medium profile minimum
- [ ] End-to-end visual review: full day/night/weather cycle, all biomes touched at least once, Nether and End checked for correct (non-broken) lighting
- [ ] Update PROJECT_REQUIREMENTS.md §6 — every box checked
- [ ] Final MEMORY.md entry marking v1 shipped, plus a backlog section for anything deferred (path tracing, custom entity model support, etc.)

## Backlog (park ideas here instead of scope-creeping mid-phase)
- (empty — add here as they come up)
