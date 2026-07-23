# ARCHITECTURE — WhorAizen Iris Shader Pack

Grounded in the official Iris rendering pipeline (gbuffers → shadow → composite/deferred → final). Do not deviate from Iris' program/file naming conventions — Iris falls back silently to built-in programs when a name is wrong, which manifests as confusing "it works but looks wrong" bugs rather than a compile error. When in doubt, re-check the official docs rather than guessing a filename.

## 1. Directory layout
```
shaders/
  shaders.properties
  world0/                     # overworld-specific program overrides (optional, only if needed)
  world1/                     # the Nether
  worldm1/                    # legacy nether id, mirror world1 if targeted
  world_end/                  # the End (world1 id may differ by version — verify)
  lib/                        # shared GLSL, included via `#include /lib/...`
    common.glsl                # shared constants, math helpers (saturate, remap, etc.)
    uniforms.glsl               # centralizes custom uniform declarations
    space_conversion.glsl       # screen/view/world space transforms
    sky.glsl                    # Rayleigh/Mie sky model, sun/moon color
    shadows.glsl                 # PCSS blocker search + penumbra + sampling
    distort.glsl                 # shadow map distortion (Iris tutorial pattern)
    water.glsl                   # Gerstner wave sum + normal reconstruction
    foliage_wave.glsl            # wind displacement function shared by all waving geometry
    volumetrics.glsl             # raymarched god ray / fog integrator
    bloom.glsl                   # dual-filter downsample/upsample kernels
    tonemap.glsl                 # exposure + filmic tonemap + color grade
    dither.glsl                  # blue-noise dithering for banding reduction
  gbuffers_basic.vsh/.fsh
  gbuffers_textured.vsh/.fsh
  gbuffers_terrain.vsh/.fsh          # opaque terrain — waving foliage lives here
  gbuffers_terrain_cutout.vsh/.fsh
  gbuffers_water.vsh/.fsh            # translucent terrain incl. water — Gerstner + refraction here
  gbuffers_entities.vsh/.fsh
  gbuffers_hand.vsh/.fsh
  gbuffers_hand_water.vsh/.fsh
  gbuffers_weather.vsh/.fsh          # rain/snow particles
  gbuffers_block.vsh/.fsh
  gbuffers_skybasic.vsh/.fsh
  gbuffers_skytextured.vsh/.fsh      # sun/moon textures composited over sky.glsl gradient
  shadow.vsh/.fsh
  shadowcomp.vsh/.fsh                # optional: shadow-space post pass, colored shadow prep
  composite.vsh/.fsh                 # 1: deferred lighting resolve (sun/moon/block light + shadows)
  composite1.vsh/.fsh                # 2: volumetrics / god rays raymarch
  composite2.vsh/.fsh                # 3: reflections (SSR) + water compositing
  composite3.vsh/.fsh                # 4: fog blend (height fog + weather fog)
  composite4.vsh/.fsh - composite8.vsh/.fsh   # bloom mip downsample chain
  composite9.vsh/.fsh - composite12.vsh/.fsh  # bloom mip upsample chain
  composite13.vsh/.fsh               # bloom composite back onto scene
  composite14.vsh/.fsh               # TAA resolve
  final.vsh/.fsh                     # tonemap, color grade, dither, vignette (opt-in), output
```
Exact composite index count is a placeholder — finalize the real count in Phase 1 and update this file. The point is the **ordering logic**: geometry → shadows → deferred lighting → volumetrics → reflections/water → fog → bloom chain → TAA → final grade. Never reorder without updating this doc.

## 2. Buffer (colortex) budget
Iris/OpenGL gives a limited number of color attachments — treat this like a scarce resource and document every claim on it here before writing code that uses it.

| Buffer | Format | Contents | Written in | Read in |
|---|---|---|---|---|
| colortex0 | RGBA16F | Scene albedo / final color accumulator | gbuffers_*, composite* | final |
| colortex1 | RGBA8 | Lightmap coords (sky/block light) + material mask | gbuffers_* | composite (lighting resolve) |
| colortex2 | RGB10A2 or RGBA16F | World-space or view-space normals | gbuffers_* | composite, composite2 (SSR) |
| colortex3 | RGBA8 | PBR data: specular, roughness, emissive, subsurface (LabPBR-style packing) | gbuffers_* | composite |
| colortex4 | RGBA16F | Translucent/water color + alpha, pre-refraction | gbuffers_water | composite2 |
| colortex5 | RGBA16F | Volumetrics/god-ray accumulation buffer (often half-res) | composite1 | composite (final blend) |
| colortex6 | RGBA16F | Bloom mip chain working buffer | composite4-13 | composite13 |
| colortex7 | RGBA16F | TAA history (previous frame) | composite14 | composite14 (next frame) |
| depthtex0 | depth | Full scene depth incl. translucents | gbuffers_* | everywhere |
| depthtex1 | depth | Depth excl. translucents (Iris auto-provides) | — | composite2 (refraction depth test) |
| shadowtex0/1 | depth | Shadow map (opaque / incl. translucent) | shadow | shadows.glsl |
| shadowcolor0 | RGBA8 | Colored shadow data (stained glass, leaves tint) | shadow | shadows.glsl |

Revisit this table the moment a phase needs a buffer that isn't listed — update the table, don't just add a colortex ad hoc.

## 3. Program responsibilities
- **gbuffers_terrain**: opaque terrain geometry. Vertex shader applies `foliage_wave.glsl` displacement to grass/leaf/crop/vine vertex classes (detected via `mc_Entity`/block id or the `PLANTS_ARE_WAVING` optifine-style attribute, whichever Iris exposes cleanly — confirm in Phase 6). Fragment shader writes albedo, normal, PBR data, lightmap to the gbuffer targets — no lighting math here, this pass only produces G-buffer data.
- **gbuffers_water**: translucent terrain incl. water. Vertex shader runs the Gerstner wave sum from `water.glsl` on water-tagged geometry only. Fragment shader writes pre-lit translucent color + alpha + normal (perturbed by wave normal + micro normal map) for the deferred/reflection passes to consume.
- **shadow**: renders the scene from the light's POV into shadowtex0/1 + shadowcolor0. Apply the distortion function from `distort.glsl` (per Iris' own tutorial) to concentrate shadow map resolution near the player.
- **composite (deferred resolve)**: reconstructs world position from depth, computes sun/moon/block-light contribution, samples the shadow map through `shadows.glsl`'s PCSS blocker-search → penumbra-estimate → filtered-sample pipeline, applies ambient/GI approximation, and enforces the brightness floor from RULES.md §4 here — this is the single most important place that floor gets enforced, so treat it as a hard gate, not a suggestion.
- **composite1 (volumetrics)**: raymarches from the camera through view-space depth, sampling the shadow map at each step (per `volumetrics.glsl`) to accumulate in-scattered light — this is the god-ray pass. Run at half or quarter resolution and upsample with a depth-aware bilateral filter to keep cost sane.
- **composite2 (reflections/water)**: screen-space reflection trace using colortex2 normals + depthtex1, falling back to the procedural sky color from `sky.glsl` when the SSR trace misses. Composites water's refraction (screen color displaced by wave normal) and foam.
- **composite3 (fog)**: height fog + weather-driven fog density, blended using the weather uniform-consistent with the "no more contrast-crushing thunderstorm darkness" requirement — fog raises perceived atmosphere, brightness floor still applies underneath it.
- **composite4-13 (bloom chain)**: physically based bloom per the mip-chain downsample/upsample method (13-tap downsample filter, Karis average on the first downsample to suppress fireflies, 3x3 tent upsample with additive blend) rather than a cheap single Gaussian blur pass.
- **composite14 (TAA)**: reprojects colortex7 history using motion vectors, resolves jitter, feeds clean image to final.
- **final**: exposure, filmic tonemap (ACES-fitted curve or similar), color grade, blue-noise dither (from `dither.glsl`) to fight banding introduced by the brighter night floor, optional vignette/CA toggles (default OFF).

## 4. Uniform & feature-flag strategy
- Centralize all custom uniforms (time-of-day derived values, weather strength, wind gust factor, etc.) in `lib/uniforms.glsl` and declare them via shaders.properties custom uniform directives rather than recomputing per-shader — one source of truth, fewer transcription bugs.
- Use Iris feature flags to gate anything that requires a newer Iris version or GL capability (e.g., compute-shader bloom variant) and mark those flags `required` only where genuinely required, so lower-end/incompatible systems fail gracefully to a documented fallback instead of a hard crash.
- Use `program.<name>.enabled=<bool expression>` (from shaders.properties) to toggle whole passes off by profile (e.g., disable composite2 SSR entirely on the Potato profile) rather than branching heavily inside a shader that still runs on low end.

## 5. Cross-vendor / cross-profile discipline
- Compatibility profile (`#version 330 compatibility`) is the default baseline; anything requiring core-profile-only or GL 4.3+ features (compute shaders) must have a `#version` gate and a documented fallback path, because compute shaders are unavailable on macOS.
- Test matrix per phase: Nvidia + AMD + Intel, each on at least the Medium profile, before marking a phase done — driver GLSL compilers disagree on edge cases (implicit type conversion, array indexing with non-constant expressions) more than people expect.
