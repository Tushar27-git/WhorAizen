#ifndef VOLUMETRICS_GLSL
#define VOLUMETRICS_GLSL

#include "/lib/distort.glsl"
#include "/lib/dither.glsl"

uniform float frameTimeCounter;

const int VOLUMETRIC_STEPS = 12;

float getVolumetricScattering(vec3 startPos, vec3 endPos, mat4 inShadowModelView, mat4 inShadowProjection, vec2 texcoord) {
    vec3 rayVector = endPos - startPos;
    float rayLength = length(rayVector);
    
    if (rayLength < 0.1) return 0.0;
    
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
        vec4 shadowView = inShadowModelView * vec4(currentPos, 1.0);
        vec4 shadowClip = inShadowProjection * shadowView;
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
