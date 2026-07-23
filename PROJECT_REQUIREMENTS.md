# PROJECT REQUIREMENTS — "WhorAizen" Iris Shader Pack

Status: LIVING DOCUMENT — keep this file up to date after every phase. Anything not written here does not count as a requirement.
Last updated: 2026-07-24

## 1. One-line pitch
A cinematic, Iris-exclusive Minecraft: Java Edition shader pack that keeps the moody, painterly, high-contrast "Complementary/Spooklementary" atmosphere everyone loves — volumetric god rays, soft directional shadows, gorgeous water, waving world — but rebalanced so nights, caves, and thunderstorms stay readable and beautiful instead of crushed to near-black.

## 2. Reference packs (inspiration only — see RULES.md §1 on licensing)
- **Complementary Shaders (Unbound / Reimagined)** by EminGT — the base aesthetic language: soft shadow falloff, clean deferred lighting, strong color grading, huge install base (130M+ downloads on CurseForge), tiered profiles from Potato to Ultra.
- **Spooklementary** by SpacEagle17 — a moody/horror edit of Complementary: desaturated palette, flickering block light, heavy fog, blood moons, chromatic aberration in the dark, oppressive night/cave darkness. We want its **cinematic moodiness and fog/atmosphere language**, explicitly WITHOUT its horror-driven darkness (no crushed blacks, no flicker-as-jumpscare, no blood moon, no static/chromatic-aberration horror stingers, no "eyes in the dark").
- Iris' own official "Your First Shaderpack" tutorial series (deepwiki.com/IrisShaders, shaders.properties docs) — this is our **architectural** reference, and the only place we may look for actual reusable code patterns.

## 3. Target platform
- Loader: **Iris only** (not OptiFine). Use Iris-exclusive features freely (feature flags, custom uniforms/textures/SSBOs, `program.<name>.enabled`, compute shaders where they help) but keep a graceful fallback path on the Potato/Low profile for machines without compute shader support (macOS has no compute shaders — see ARCHITECTURE.md).
- Minecraft version: latest Java Edition release Iris currently supports (26.1.2 / 26.2 line at time of writing) — verify current version before each phase since MC now ships quarterly drops.
- GLSL baseline: `#version 330 compatibility` (per Iris' compatibility-vs-core guidance) with higher-version blocks gated behind feature flags where they add real value (e.g. compute-shader bloom on GL 4.3+).

## 4. Visual pillars (the non-negotiable aesthetic goals)
1. **Cinematic but bright.** Never let the "cinematic" look become an excuse for a dark screen. Establish and respect a minimum scene luminance floor (see RULES.md §4) at night, underground, and in thunderstorms.
2. **Soft, directional shadows.** PCSS-style contact hardening — hard near the object, soft the further the penumbra travels — not the flat blurred slabs of basic PCF.
3. **Volumetric, cinematic god rays.** Visible light shafts through leaves/windows/fog, strongest at low sun angles (sunrise/sunset), present but restrained at noon, still present but cool-toned at night from the moon.
4. **Goated sunrises/sunsets.** Physically-grounded Rayleigh + Mie sky gradient so the sky actually reddens/purples correctly at the horizon and the sun/moon carry a soft bloom halo — this is the single most "wow" visual beat and should be treated as a first-class feature, not a byproduct of the sky box.
5. **Living world.** Waving grass/leaves/crops/vines with wind strength that visibly escalates in rain and especially thunderstorms (motion should communicate weather, this is one of the few places Spooklementary's "storm intensity" idea is worth keeping).
6. **Soft, realistic water.** Multi-octave Gerstner displacement + normal-mapped micro-detail, soft foam at shorelines, reflections of sky/sun/terrain, no harsh tiling.
7. **Restrained, physically-motivated post stack.** HDR pipeline, physically based bloom (mip-chain, not a cheap single-pass blur), filmic tonemap, gentle color grade. No forced chromatic aberration, no forced film grain/vignette as default — these are OFF by default and available as opt-in toggles only.

## 5. Brightness rebalancing target (the core ask — read this twice)
Spooklementary's complaint, precisely stated: ambient/ minimum light level at night and during thunderstorms is pushed so low that gameplay visibility and screenshot detail both collapse to near-black, and effects (flicker, static, chromatic aberration) actively fight visibility for horror effect.

Our target:
- Night ambient floor should sit noticeably higher than Spooklementary's night floor, closer to Complementary Reimagined's baseline but with a slightly cooler/moodier color temperature so it still *feels* nocturnal and cinematic, not floodlit.
- Thunderstorms should look dramatic (heavier fog, more saturated lightning flash bloom, faster cloud motion, stronger foliage wind) but the base scene luminance during a storm should not drop below the clear-night floor — drama comes from motion, cloud density, and lightning-driven light pulses, not from crushing black level.
- Caves keep a real "you need a torch" feel but must never rely on rendering geometry as literal black-on-black the way Spooklementary explicitly does — light falloff should be readable within ~1 render pass of any placed light source.
- No player-facing jump-scare/horror mechanics survive from Spooklementary: no random eyes, no random leaf disappearance, no static-noise cue, no forced blood moon.

## 6. Feature checklist (acceptance criteria live here — check off per phase)
- [ ] Deferred lighting core (gbuffers → colortex → composite) with correct sun/moon/block-light mixing
- [ ] Shadow mapping with distortion + PCSS soft penumbra + colored translucent shadows (stained glass, leaves)
- [ ] Procedural Rayleigh/Mie sky with dynamic sunrise/sunset gradient, sun/moon disks, stars, weather blending
- [ ] Volumetric god rays (raymarched, shadow-map-sampled, intensity keyed to sun angle + weather)
- [ ] Waving foliage (grass/leaves/crops/vines) with weather-scaled wind strength
- [ ] Water: Gerstner displacement, normal-mapped detail, reflection (SSR + sky fallback), refraction, foam
- [ ] Physically based bloom (mip-chain downsample/upsample, Karis-averaged prefilter)
- [ ] Filmic tonemap + restrained color grade LUT-or-curve
- [ ] TAA / temporal stabilization
- [ ] Optional PBR (LabPBR-compatible specular/normal maps) toggle for resource-pack support
- [ ] Performance profiles: Potato / Low / Medium / High / Ultra, each with a stated target FPS range and GPU tier
- [ ] Zero shader-compile errors/warnings across Nvidia, AMD, and Intel drivers, on both compatibility and (where used) core profile paths

## 7. Non-goals (explicitly out of scope, write here if scope creeps)
- Ray tracing / path tracing (SEUS PTGI-style) — out of scope for v1.
- OptiFine compatibility — Iris-only, don't spend budget on OptiFine quirks.
- Horror/atmosphere toggles beyond what's listed — this is not a Spooklementary fork, it's a bright cinematic sibling.
- Custom entity models, connected textures — those are Iris-companion-mod territory (Entity Model Features, Continuity), not shader pack territory.

## 8. Definition of done (per phase and for v1 ship)
A phase is done when: it compiles with zero errors/warnings on all three vendors tested, it visibly matches the DESIGN.md mood reference for that feature, MEMORY.md has been updated, and PHASES.md's checklist for that phase is fully checked. v1 ships when every box in §6 is checked and a full day/night/weather cycle has been visually reviewed end to end.
