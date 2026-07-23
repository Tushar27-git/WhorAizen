# CONTEXT — Orientation Anchor (read this if you feel lost)

This file is STATIC. Unlike `MEMORY.md`, it does not get rewritten session to session — it's the fixed north star, not a log. If you (the agent) ever lose the thread mid-session, stop and re-read this one page before doing anything else. For "what actually happened last session and what's the next concrete action," go to `MEMORY.md` instead — that's the dynamic one. This file only answers two questions: **what should this look like**, and **where are we in the build, conceptually**.

## What this project is, in one breath
WhorAizen: an Iris-exclusive Minecraft shader pack. Cinematic, moody, painterly — the Complementary/Spooklementary lineage of soft shadows, thick atmosphere, dramatic god rays, gorgeous water — but with the black level lifted, so night, caves, and thunderstorms stay beautiful and readable instead of collapsing to near-black. Bright-but-cinematic, not floodlit, not horror.

## Standing instruction: you are not working from memory alone
This is a real, professional-grade graphics project. Your training data goes stale the moment a new Iris version ships, a better technique gets published, or someone posts a smarter way to do volumetric fog. So, as standing behavior for the entire project, not just once at the start:
- **Search before you assume.** Before implementing or debugging anything non-trivial, go look for how it's actually done — current Iris/shaders.properties documentation for anything pipeline-related, and current graphics-programming writeups (papers, engine docs, well-known GLSL educators) for technique theory. Don't rely on a half-remembered version of a technique when a five-second search gets you the current, correct one.
- **Reason with what you find, don't just transplant it.** Search results give you the underlying logic and math, not a drop-in answer for this specific pack's buffer layout. Read the source, understand *why* it works, then re-derive it in WhorAizen's own code, naming, and pass structure. Your own judgment is what turns a technique write-up into a correct implementation here — use it.
- **This applies to looks as much as code.** If you're unsure whether a sunset gradient, a shadow softness, or a foliage sway speed hits the mood this project wants, go find reference footage/screenshots (Complementary Reimagined, Complementary Unbound, BSL Shaders — all real, well-documented, Iris-compatible packs) and compare by eye. Never source actual shader code from Complementary or Spooklementary specifically — both are under restrictive licenses; look, don't copy. See `RULES.md` §1 for the full rule.
- **When the internet disagrees with itself**, use your own reasoning to pick the technique that best fits this pack's stated goals (brightness floor, performance budget, Iris-only) rather than defaulting to whichever result loaded first.

## The look — condensed cheat sheet (full detail in DESIGN.md)
- Soft, directional, contact-hardening shadows. Never flat, never muddy.
- Volumetric god rays — dramatic at sunrise/sunset, present but restrained at noon, cool and present at night.
- Sunrise/sunset is the hero shot: real Rayleigh/Mie-driven color shift, soft sun/moon bloom halo, water mirroring the sky.
- Living world: grass/leaves/crops/vines wave, wind escalates with weather but never becomes a permanent hurricane.
- Water: soft multi-octave wave motion, reflections, refraction, shoreline foam — never flat or harshly tiled.
- Bloom is a real lens response (physically based, mip-chain), not a cheap glow sticker.
- **The one rule that matters most**: night / caves / thunderstorms never crush to near-black. There is a real, enforced brightness floor. Weather adds drama through fog/wind/motion/lightning bloom — never by making the base scene darker than a clear night.
- Cut entirely from the Spooklementary lineage: flicker-as-jumpscare, eyes in the dark, forced blood moons, static-noise stingers, default-on chromatic aberration/vignette.

## The phase map — condensed (full checklist in PHASES.md)
0. Skeleton — zero-error baseline, nothing rendered yet but it loads clean.
1. Core deferred lighting — bright, correct, unshadowed sun/moon/block light. Brightness floor goes in here, from day one.
2. Shadows — PCSS soft shadows, respecting the floor.
3. Sky & atmosphere — Rayleigh/Mie sky, sun/moon, the sunrise/sunset hero beat.
4. Volumetric god rays / fog.
5. Water — Gerstner waves, reflection, refraction, foam.
6. Waving foliage — living world, weather-reactive wind.
7. Bloom & post stack — physically based bloom, filmic tonemap, restrained grade.
8. TAA, reflection polish, optional PBR.
9. Profiles, QA, ship.

Work exactly one of these at a time, in order, per `RULES.md` §2. This list is intentionally short — if you need the acceptance criteria for the phase you're on, that's in `PHASES.md`, not here.

## If you only remember one thing from this file
Chase the current best technique, don't guess from memory. Chase the current best look, don't guess from vibes. Stay bright where Spooklementary goes dark. Move one phase at a time.
