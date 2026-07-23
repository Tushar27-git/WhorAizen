#ifndef VOLUMETRICS_GLSL
#define VOLUMETRICS_GLSL

#include "/lib/distort.glsl"
#include "/lib/dither.glsl"

uniform float frameTimeCounter;
// Note: shadowtex0 is already defined in shadows.glsl if included first, but we can re-declare or rely on it.
// We'll rely on it being included after shadows.glsl

const int VOLUMETRIC_STEPS = 12;

float getVolumetricScattering(vec3 startPos, vec3 endPos, mat4 shadowModelView, mat4 shadowProjection, vec2 texcoord) {
    vec3 rayVector = endPos - startPos;
    float rayLength = length(rayVector);
    vec3 rayDir = rayVector / rayLength;
    
    if (rayLength > 128.0) {
        rayLength = 128.0;
        rayVector = rayDir * 128.0;
    }
    
    float stepSize = rayLength / float(VOLUMETRIC_STEPS);
    vec3 stepVec = rayDir * stepSize;
    
    float dither = fract(getDither(texcoord * 2000.0) + frameTimeCounter * 13.37);
    vec3 currentPos = startPos + stepVec * dither;
    
    float scattering = 0.0;
    
    for (int i = 0; i < VOLUMETRIC_STEPS; i++) {
        vec4 shadowView = shadowModelView * vec4(currentPos, 1.0);
        vec4 shadowClip = shadowProjection * shadowView;
        vec3 shadowPos = shadowClip.xyz / shadowClip.w;
        
        shadowPos = distortShadow(shadowPos);
        shadowPos = shadowPos * 0.5 + 0.5;
        
        if (shadowPos.x > 0.0 && shadowPos.x < 1.0 && 
            shadowPos.y > 0.0 && shadowPos.y < 1.0 && 
            shadowPos.z > 0.0 && shadowPos.z < 1.0) {
            
            float shadowDepth = texture(shadowtex0, shadowPos.xy).r;
            if (shadowDepth > shadowPos.z - 0.0003) {
                scattering += 1.0;
            }
        }
        
        currentPos += stepVec;
    }
    
    return scattering * stepSize;
}

#endif
