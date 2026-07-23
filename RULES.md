# RULES — WhorAizen Iris Shader Pack

These are hard constraints. If a phase's implementation would violate one of these, stop and flag it in MEMORY.md rather than silently working around it.

## 1. Licensing and originality (read first, non-negotiable)
- Complementary Shaders ships under a **custom, non-open license**; Spooklementary is an authorized *edit* of that code by a different author, also under restrictive terms. **Never copy, transcribe, decompile, or closely paraphrase either pack's actual `.glsl`/`.vsh`/`.fsh` source.** Downloading them to *look at rendered results, screenshots, and publicly documented feature lists* for aesthetic inspiration is fine; opening their shader source and porting code is not.
- The only shader source we may study and pattern-match against is permissively licensed material: Iris' own official tutorial pack (Unlicense), the Iris/shaders.properties documentation, and general public GLSL technique write-ups (LearnOpenGL, GPU Gems, academic papers, individual devs' MIT/CC-licensed shadertoy or GitHub demos) — implement techniques from first principles using those as *conceptual* references, not copy sources.
- Every technique implemented from an external write-up should be re-derived/re-typed by the agent, not pasted verbatim, and adapted to this pack's actual buffer layout and naming.

## 2. Working method — chain-of-thought, phase-gated, error-first
- **Think before writing.** For every non-trivial shader change, reason step by step (in your own scratch/thinking, and briefly summarized in the commit or MEMORY.md note) about: what buffer(s) this touches, what space (screen/view/world/shadow) the math is in, what the expected visual delta is, and what could break in dark/bright/underwater/nether edge cases — *then* write the code.
- **One phase at a time.** Follow PHASES.md in order. Do not start Phase N+1 until every acceptance box for Phase N is checked in PROJECT_REQUIREMENTS.md §6 and MEMORY.md has a closing entry for it. If you notice work that clearly belongs to a later phase, note it in MEMORY.md's backlog and keep moving — do not context-switch mid-phase.
- **Compile clean before iterating on looks.** After every meaningful edit: reload the shader pack, confirm zero errors/warnings in the Iris debug log, *then* judge the visual. A shader that "looks right" but throws a silent fallback warning is not done — Iris silently substitutes a built-in program on some naming mismatches, so "no visible bug" is not proof of correctness; always check the log.
- **Isolate before you integrate.** When adding a new effect (e.g., god rays), first get it rendering in isolation (dump it straight to the screen in a debug output mode) before blending it into the main composite chain. This makes it obvious whether a bug is in the new effect's math or in the blend/compositing step.
- **Small diffs.** Prefer several small, testable changes over one large rewrite of a pass — easier to bisect if something regresses.

## 3. Research discipline
- Before implementing a technique the pack doesn't already have a documented pattern for (e.g., a new bloom variant, a new fog model), search for how modern real-time engines/shader authors implement it, prioritizing: official engine/API docs > peer-reviewed or conference papers (SIGGRAPH, GPU Gems, GDC talks) > well-known individual GLSL educators (LearnOpenGL, Inigo Quilez, gm shaders) > forum answers. Note the source's *technique*, not its code, in MEMORY.md.
- Re-verify current Iris/Minecraft version support before starting a new phase — Minecraft's release cadence and Iris compatibility both move; don't assume the version numbers in this doc set are still current by the time you act on them.

## 4. Brightness floor — how to actually enforce it, not just say it
- Define an explicit minimum ambient term (a small constant added post-shadow, pre-tonemap, in the composite deferred-resolve pass) that scales with time-of-day and dimension so night/thunderstorm/cave scenes never fall below a chosen luminance floor. Implement it as a named, tunable value in `lib/uniforms.glsl` (e.g. `nightAmbientFloor`), not a magic number buried in composite.fsh, so art direction can tune it in one place.
- Weather (rain/thunder) must modulate fog density, cloud coverage, wind strength, and lightning-flash bloom — it must **not** independently lower the ambient floor. If a thunderstorm currently reads as darker than a clear night, that's a bug against §5 of PROJECT_REQUIREMENTS.md, not a stylistic choice.
- No effect is allowed to defeat the floor after the fact — vignette, chromatic aberration, and any "horror-style" post effect must be additive/cosmetic on top of a correctly floored image, applied in `final`, and OFF by default.
- Sanity-check the floor by screenshotting the same cave/night/thunderstorm location at every profile tier (Potato → Ultra) each phase that touches lighting — the floor must hold across all of them, not just Ultra.

## 5. Performance discipline
- Every pass added must have a stated cost budget (rough ms or "half-res"/"quarter-res" note) in ARCHITECTURE.md before it's implemented, and an entry in shaders.properties gating it off on lower profiles.
- Prefer half/quarter-resolution + bilateral upsample for expensive raymarched effects (volumetrics, SSR) over full-res, per the architecture doc.
- Re-test FPS on the stated target GPU tier for each profile after any pass is added or modified; regressions get fixed or the effect gets moved to a higher profile tier, not silently shipped.

## 6. Naming and style conventions
- Follow Iris' own doc conventions: reference specific files with their extension (`gbuffers_water.fsh`), reference a program family with a wildcard (`gbuffers_*.fsh`), and use `rgba` swizzles only for actual color channels — use `xyzw` for positions/vectors, to keep intent obvious at a glance.
- All shared functions/constants go in `lib/` and are pulled in via `#include /lib/<file>.glsl` (absolute path from the shaders root, per Iris' supported include syntax) — no copy-pasted helper functions across multiple `.fsh` files.
- Every non-obvious uniform, magic number, or space-conversion needs a one-line comment stating its unit/space (e.g., `// view-space, meters`).

## 7. Documentation discipline
- PROJECT_REQUIREMENTS.md, ARCHITECTURE.md, and MEMORY.md are living documents. Any change to buffer layout, program list, feature scope, or brightness targets gets written back into the relevant file in the same work session it happened, not "later."
- MEMORY.md gets a closing entry at the end of every session/phase, even a short one — assume the next working session starts with zero conversational memory and only these files.
