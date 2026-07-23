---
name: minecraft-iris-shader-development
description: Use this skill whenever working on this Minecraft Iris shader pack project ("WhorAizen") — writing or editing any .vsh/.fsh/.glsl/.csh file, editing shaders.properties, debugging shader compile errors or visual artifacts, or planning the next phase of the build. Also trigger this any time the user mentions Minecraft shaders, Iris, GLSL shader packs, god rays, volumetric lighting, PCSS/soft shadows, waving foliage, Gerstner waves, bloom, or cinematic Minecraft visuals in the context of this project. Always read PROJECT_REQUIREMENTS.md, ARCHITECTURE.md, RULES.md, PHASES.md, DESIGN.md, and MEMORY.md before writing any shader code — this skill is the entry point that tells you to do that.
---

# Minecraft Iris Shader Pack Development

This skill governs work on the WhorAizen Iris shader pack (or any Iris-exclusive, GLSL-based Minecraft shader pack built with the same project scaffold). It is a *process* skill: it tells you what order to do things in and where to look things up, not a code dump.

## Before touching any file
1. Read `MEMORY.md` top entry first — it tells you exactly where the project left off and what the next action is.
2. Read `PHASES.md` and confirm which phase is currently active (the first one with unchecked boxes, worked in order).
3. Skim `ARCHITECTURE.md` for the buffer/program layout relevant to the phase you're about to touch.
4. Skim `RULES.md` §1 (licensing) and §4 (brightness floor) — these two are the most commonly-violated-by-accident rules.
5. Only then start editing or writing shader code.

## Core working loop (repeat per change)
1. **Reason before writing.** State (briefly, in your thinking) what buffer(s) and coordinate space this touches, the expected visual delta, and the edge cases to check (night, thunderstorm, underwater, Nether, low profile).
2. **Write the smallest testable change.** Prefer isolating a new effect (dump-to-screen debug mode) before wiring it into the full composite chain — see RULES.md §2.
3. **Compile-check first.** Reload in-game, check the Iris debug log for errors *and* warnings/silent-fallback messages before judging the visual — Iris will quietly substitute a built-in program on some naming mismatches, so a "fine-looking" frame doesn't prove correctness.
4. **Then judge the visual** against `DESIGN.md`'s mood description for that feature.
5. **Then check the brightness floor** — screenshot the same night/cave/thunderstorm reference spot and confirm it hasn't regressed (RULES.md §4). This check applies to *every* lighting-adjacent change, not just Phase 1-2 work.
6. **Update the docs in the same session**: check off the relevant `PHASES.md` box, update `ARCHITECTURE.md` if the buffer/program layout changed, and write the `MEMORY.md` closing entry using its template.

## Where to look things up
- **Iris pipeline mechanics (program names, pass ordering, `#include`, feature flags, shaders.properties directives)**: search the official Iris documentation (deepwiki.com/IrisShaders or the current shaders.properties reference site) — this is the one place safe to pattern-match code from directly, alongside Iris' own Unlicense-covered tutorial pack.
- **Rendering technique theory (PCSS, bloom, volumetric raymarching, Gerstner waves, atmospheric scattering)**: search general graphics-programming references (LearnOpenGL, GPU Gems, SIGGRAPH/GDC talks, individual educators' MIT/CC-licensed write-ups). Re-derive the technique in this pack's own buffer layout and naming — do not paste external code verbatim.
- **Aesthetic/mood target for a specific feature**: check `DESIGN.md` first; if it doesn't cover the specific case, search for recent screenshots/footage of Complementary Reimagined, Complementary Unbound, or BSL Shaders for the *mood*, never for source code (see RULES.md §1 — Complementary and Spooklementary source is under a restrictive custom license and must never be copied, transcribed, or closely paraphrased).
- **Current Iris/Minecraft version support**: verify with a fresh search before starting a new phase; do not trust version numbers written earlier in the project docs without a quick re-check, since Minecraft ships on a quarterly cadence.

## Common pitfalls (check these first when something's broken)
- **"It compiles but looks wrong"**: almost always a program naming mismatch causing Iris to fall back to a built-in program, a space mismatch (view space vs. world space vs. screen space) in a coordinate transform, or a buffer read/write happening in the wrong pass order relative to ARCHITECTURE.md §1's ordering.
- **Banding in dark/gradient areas**: expected once the night brightness floor from RULES.md §4 is raised — the fix is `lib/dither.glsl`'s blue-noise dither in `final`, not lowering the floor back down.
- **Foliage motion looks chaotic instead of atmospheric**: wind strength scaling is too aggressive or lacks per-vertex phase offset — see PHASES.md Phase 6 and DESIGN.md's note on the Waving Plants Shaders overdo-it failure mode.
- **Shadows look flat/uniformly blurred instead of cinematic**: likely plain PCF instead of PCSS — check that `lib/shadows.glsl` actually implements the blocker-search → penumbra-estimate → variable-kernel steps, not a fixed-radius blur.
- **Reflections/SSR flicker or show seams**: usually a missing or wrong depth-test against `depthtex1` (opaque-only depth) versus `depthtex0` (full depth incl. translucents) — confirm which one a given trace step should be using.
- **Works on Nvidia, breaks on AMD/Intel**: check for implicit type conversions, non-constant array indexing, and `#version`/profile mismatches — GLSL compilers disagree on these more than most people expect; see RULES.md §5's cross-vendor testing requirement.
- **macOS user reports a crash/black screen on an otherwise-fine build**: check whether a compute-shader-only code path got shipped without the documented compatibility-profile fallback (ARCHITECTURE.md §5) — macOS has no GL 4.3+ compute shader support.

## When the user asks for something not in the docs
If a request doesn't map to anything in `PROJECT_REQUIREMENTS.md`'s feature checklist, don't just build it — add it to `PHASES.md`'s backlog section (or the current phase if it's genuinely in-scope and small), confirm scope with the user if it's a meaningfully large addition, and only then implement it. This keeps the requirements doc trustworthy as the single source of truth.
