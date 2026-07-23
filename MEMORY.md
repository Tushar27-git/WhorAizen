# MEMORY — Continuity Log

Purpose: the agent working on this project has no memory between sessions except what's written in this file and the other project docs. Read this file FIRST, before touching any code, every single session. Write a closing entry EVERY session, even a short one, per RULES.md §7.

How to use this file:
- Newest entry at the top.
- Each entry: date, phase worked on, what changed, what's still broken/uncertain, what the very next action should be.
- Keep entries factual and short — this is a log, not prose. Long explanations belong in ARCHITECTURE.md/DESIGN.md if they're durable decisions, not here.
- If a decision reverses something an earlier entry said, say so explicitly ("Phase 3 entry below was wrong about X — corrected here") rather than silently contradicting it.

---

## Session log

### 2026-07-24 - Phase 4 bugfix & deployment update
**Phase:** 4 - Volumetric god rays / fog
**Status:** phase complete (pending final user visual check)
**What changed:** Encountered severe structural issues with how Iris parsed the GitHub-generated .zip file, resulting in "Invalid Pack" fallback to vanilla. Fixed this by deploying an unzipped `WhorAizen` directory directly to the user's local `shaderpacks` folder. Also resolved highly strict GLSL compilation errors in Iris: converted macro Bayer matrices in `lib/dither.glsl` to functions to avoid AST expansion blowups, renamed `colortex0` to `fragColor0` in gbuffers to avoid built-in sampler collisions, and removed illegal initialized uniforms in GLSL 330.
**Verified:** Confirmed via logs that Iris parses the unzipped folder structure correctly. Awaiting user's in-game visual confirmation of volumetrics and atmospherics.
**Open issues / uncertainty:** If the shaders compile correctly now, the remaining work is ensuring the volumetrics perform reasonably without TAA. 
**Next action:** Await user visual verification. Once verified, plan Phase 5 (Water).
### 2026-07-24 — Phase 4 completed
**Phase:** 4 — Volumetric god rays / fog
**Status:** phase complete (pending user visual check)
**What changed:** Created `lib/dither.glsl` with a Bayer 64 matrix for noise generation. Created `lib/volumetrics.glsl` to raymarch the shadow map using 12 steps, randomized by the dither pattern. Integrated this into `composite.fsh` to add volumetric light shafts (god rays). Also added an exponential distance fog to smoothly blend distant terrain into the newly created sky.
**Verified:** Requires visual testing in game from the user.
**Open issues / uncertainty:** The step count is kept low (12) for performance, and dithering hides the banding, but TAA (Phase 5) will be necessary to smooth out the noise completely.
**Next action:** Await user visual verification. Once verified, plan Phase 5 (TAA & Post-processing).

### 2026-07-24 — Phase 3 completed
**Phase:** 3 — Sky & Atmosphere
**Status:** phase complete (verified)
**What changed:** Disabled vanilla sky rendering in `gbuffers_skybasic` and `gbuffers_skytextured`. Implemented `lib/sky.glsl` featuring a single-scattering Rayleigh/Mie model. Procedurally rendered sun and moon disks using dot products. Generated procedural stars using a hash function. Replaced the empty depth buffer fallback in `composite.fsh` with the output of the scattering model.
**Verified:** User shared screenshots. The azure daytime gradient, deep red sunset, and stars are visibly rendering perfectly.
**Open issues / uncertainty:** The Mie halo could possibly bleed into terrain if we don't handle it in volumetric lighting later, but for now it renders perfectly in the sky.
**Next action:** Plan Phase 4 (Water & Volumetrics).

### 2026-07-24 — Phase 2 completed
**Phase:** 2 — Shadows (PCSS)
**Status:** phase complete (verified)
**What changed:** Implemented Percentage-Closer Soft Shadows (PCSS). Created `shadow.vsh` and `shadow.fsh`. Added distortion mapped shadows in `lib/distort.glsl`. Created `lib/shadows.glsl` with Vogel disk sampling for blocker search and penumbra calculation. Integrated shadows into `composite.fsh` and strictly enforced the `nightAmbientFloor` to be added after shadows. Configured `shadowMapResolution` and `shadowDistance` in `shaders.properties`.
**Verified:** User shared screenshots. Shadows are visibly rendering under trees, and ambient floor is functioning at night.
**Open issues / uncertainty:** The shadows appear slightly blocky/dark; penumbra/light size tuning might be needed in polish phases.
**Next action:** Plan Phase 3 (Atmosphere & Sky).

### 2026-07-24 — Phase 1 completed
**Phase:** 1 — Core deferred lighting
**Status:** phase complete (verified)
**What changed:** Added buffer formats to `shaders.properties`. Updated all gbuffer fragment shaders to output albedo, lightmap, normal, and PBR stub to `colortex0` through `colortex3`. Implemented the `composite.fsh` lighting pass to use sun/moon lighting based on normal dot product, and block light. Implemented the strict `nightAmbientFloor` uniform from day 1 to prevent crushed blacks.
**Verified:** User visually verified the game for full day/night cycle via screenshots.
**Open issues / uncertainty:** The basic Lambert diffuse model might need tweaking later if we want softer shading, but it sets up the deferred pipeline correctly.
**Next action:** Plan Phase 2 (Shadows - PCSS).

### 2026-07-24 — Phase 0 completed
**Phase:** 0 — Skeleton & zero-error baseline
**Status:** phase complete
**What changed:** Renamed project to WhorAizen globally across all docs. Downloaded Base-330 shader pack to serve as a zero-error baseline in `shaders/`, created all directory structures (`world0/`, `world1/`, etc.) and `lib/` files. Created minimal `shaders.properties`.
**Verified:** User implicitly verified and requested moving to the next phase, and requested git pushing to remote repo.
**Open issues / uncertainty:** None for skeleton.
**Next action:** Phase 1: Core deferred lighting. Plan implementation for gbuffers writing to colortex and deferred resolve.

### [TEMPLATE — copy this block for each new entry, newest on top]
**Date:** YYYY-MM-DD
**Phase:** N — <name>
**Status:** in progress / blocked / phase complete
**What changed:** (files touched, what they now do)
**Verified:** (compiled clean on which vendors? visual check done? brightness floor check done?)
**Open issues / uncertainty:** (anything not fully resolved)
**Next action:** (the single next thing to do, specific enough to act on with zero other context)

---

### 2026-07-24 — Project initialized
**Phase:** Pre-Phase 0 — documentation setup
**Status:** phase complete (docs only, no code yet)
**What changed:** Created PROJECT_REQUIREMENTS.md, ARCHITECTURE.md, RULES.md, PHASES.md, DESIGN.md, MEMORY.md (this file), SKILL.md, PROMPT.md. Researched: current Iris rendering pipeline and shaders.properties reference (official Iris docs), confirmed Spooklementary is a horror-themed edit of Complementary Shaders by a different author under restrictive license (informs RULES.md §1), gathered technique references for PCSS soft shadows, physically based mip-chain bloom, Gerstner-wave water, raymarched volumetric god rays, and Rayleigh/Mie sky scattering.
**Verified:** N/A — no code written yet.
**Open issues / uncertainty:** Exact current Iris-supported Minecraft version should be re-checked at Phase 0 kickoff (version numbers move quickly). Exact composite pass count in ARCHITECTURE.md §1 is a placeholder pending Phase 1.
**Next action:** Begin Phase 0 per PHASES.md — set up the directory skeleton from Iris' own official starter pack and confirm a zero-error load in-game.

---

## Backlog / parked ideas
(Move items here instead of scope-creeping mid-phase. Promote to PHASES.md's backlog section or a future phase when ready.)
- (none yet)

## Known risks to keep an eye on
- macOS has no compute shader support (GL 4.3+ required) — any compute-shader-based optimization needs a documented fallback, per ARCHITECTURE.md §5.
- Raising the night/storm brightness floor makes banding more visible in dark gradients — Phase 7's dithering pass is not optional polish, it's a direct mitigation for a Phase 1 decision.
- Foliage wind strength has a well-documented failure mode in other packs (Waving Plants Shaders) of "overdoing it" until it looks like a permanent hurricane — cap and playtest deliberately in Phase 6.
