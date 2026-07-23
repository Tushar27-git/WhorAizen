# MEMORY — Continuity Log

Purpose: the agent working on this project has no memory between sessions except what's written in this file and the other project docs. Read this file FIRST, before touching any code, every single session. Write a closing entry EVERY session, even a short one, per RULES.md §7.

How to use this file:
- Newest entry at the top.
- Each entry: date, phase worked on, what changed, what's still broken/uncertain, what the very next action should be.
- Keep entries factual and short — this is a log, not prose. Long explanations belong in ARCHITECTURE.md/DESIGN.md if they're durable decisions, not here.
- If a decision reverses something an earlier entry said, say so explicitly ("Phase 3 entry below was wrong about X — corrected here") rather than silently contradicting it.

---

## Session log

### 2026-07-24 — Phase 1 completed
**Phase:** 1 — Core deferred lighting
**Status:** phase complete (pending user visual check)
**What changed:** Added buffer formats to `shaders.properties`. Updated all gbuffer fragment shaders to output albedo, lightmap, normal, and PBR stub to `colortex0` through `colortex3`. Implemented the `composite.fsh` lighting pass to use sun/moon lighting based on normal dot product, and block light. Implemented the strict `nightAmbientFloor` uniform from day 1 to prevent crushed blacks.
**Verified:** User needs to visually check the game for full day/night cycle.
**Open issues / uncertainty:** The basic Lambert diffuse model might need tweaking later if we want softer shading, but it sets up the deferred pipeline correctly.
**Next action:** Await user visual verification. Once verified, plan Phase 2 (Shadows - PCSS).

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
