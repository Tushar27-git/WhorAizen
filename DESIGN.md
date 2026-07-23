# DESIGN — Art Direction & Mood

This is the taste document. When ARCHITECTURE.md and RULES.md tell you *how* to build something, this file tells you what it should *feel* like when it's right. If a technically-correct implementation doesn't match this mood, it isn't done.

## 1. The one-sentence brief
Complementary/Spooklementary's cinematic, painterly, high-contrast atmosphere — soft directional light, thick believable fog, dramatic sunsets, moody weather — but with the black level lifted, so the pack reads as "cinematic dusk" rather than "horror map."

## 2. What we're keeping from the Spooklementary/Complementary lineage
- Soft, filmic contrast curve rather than a flat/washed-out default look.
- Heavier, more atmospheric fog than vanilla — fog is a mood tool, used generously.
- Strong, obvious weather storytelling: rain and thunderstorms should visibly change the world (cloud density, wind, fog, lightning bloom), not just tint the sky.
- A slightly desaturated, cool-leaning base palette that a warm sunset/sunrise or a torch's warm light can punch through dramatically — contrast between warm/cool light sources is a major part of what makes Complementary-style packs feel cinematic.
- Big, soft bloom on bright light sources (sun, lava, torches at night) — bloom should feel like a real lens response, not a cheap glow sticker.

## 3. What we're explicitly cutting from Spooklementary
- Crushed near-black night/cave/storm scenes — replaced by the brightness floor in RULES.md §4.
- Flicker used as a horror cue (light sources flickering unpredictably to unsettle the player) — light sources should behave believably (torches flicker gently and consistently like real fire, not erratically like a horror-movie bulb).
- Random "eyes in the dark," leaf-disappearance glitches, static-noise audio-visual stingers — none of these are shader-pack rendering features in the traditional sense anyway; they're horror gimmicks layered on top, and they have no place here.
- Forced blood moons.
- Chromatic aberration and vignette as *defaults* — available as opt-in toggles for people who want a more filmic frame, never forced.

## 4. Lighting philosophy
- **Key light**: sun/moon, always the dominant directional light, always casting a soft-but-legible shadow.
- **Fill**: sky ambient + the brightness floor — this is what keeps shadow-side surfaces from disappearing.
- **Bounce/GI approximation**: a cheap colored ambient tint that nods toward nearby lit surfaces without needing full path-traced GI — warm ambient near lava/torches, cool ambient in deep shade.
- **Practical lights** (torches, lava, glowstone, etc.): warm, soft-edged, bloom-heavy, gently flickering — the emotional "cozy in the dark" beat that horror packs deliberately deny; we want the opposite, a torch should feel like a genuine safe haven of light, not a dim, doomed candle.

## 5. Sunrise/sunset — the hero beat
This is the single moment every viewer of a Minecraft cinematic shader screenshots. Treat it as such:
- Sky gradient should shift convincingly from blue through orange/pink to deep purple/indigo near the horizon as the sun drops (Rayleigh scattering effect: blue scatters out of the low sun's long light path first, leaving red/orange; Mie scattering adds the soft glowing halo around the sun disk itself).
- Sun/moon disk carries a soft bloom halo that grows as it nears the horizon.
- God rays should be at their most dramatic here — long, visible, warm-colored light shafts.
- Clouds should pick up the sunset/sunrise color on their undersides.
- Water should mirror the sky color dramatically at this time of day — this is often the single most impressive shot in a good cinematic pack.

## 6. Weather moods
- **Clear day**: bright, blue-skewed, gentle foliage motion, minimal fog.
- **Overcast**: sky desaturates and flattens, ambient cools slightly, fog thickens a little — still fully readable, moodier not darker.
- **Rain**: fog thickens further, foliage wind picks up, water surfaces get rain-ripple detail if budget allows, puddle/wet-surface specular if PBR is present.
- **Thunderstorm**: heaviest fog and cloud density, strongest wind/foliage motion, lightning flashes drive a brief warm/cool bloom pulse across the scene — but the *baseline* luminance floor must not drop below the clear-night floor (this is the specific bug we are correcting relative to Spooklementary).

## 7. Color palette notes
- Base cool-neutral grade for daylight midtones, avoiding a hard blue or teal cast.
- Warm-leaning highlights (sun, torches, lava) to keep contrast between light sources readable and pleasant.
- Night should skew gently blue/indigo rather than pure gray or pure black — cinematic "day for night" grading logic, not literal darkness.
- Avoid heavy vignetting/orange-teal LUT clichés by default; they're available as opt-in "cinematic mode" toggles for people who want that specific look, but the pack's own identity is cleaner than that.

## 8. Reference-gathering note for future phases
When a phase needs a concrete visual target (e.g., "what should god rays through leaves look like"), search for recent screenshots/videos of Complementary Reimagined, Complementary Unbound, and BSL Shaders (all Iris-compatible, all well documented) for the *mood and lighting balance*, and separately search general real-time-rendering technique articles for the *how*. Never source actual shader code from a search result of a copyrighted pack — see RULES.md §1.
