#ifndef SHADOWS_GLSL
#define SHADOWS_GLSL

#include "/lib/distort.glsl"

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;

const int BLOCKER_SEARCH_SAMPLES = 16;
const int PCF_SAMPLES = 16;
const float LIGHT_SIZE = 0.05;

vec2 vogelDisk(int sampleIndex, int samplesCount, float phi) {
    float r = sqrt(float(sampleIndex) + 0.5) / sqrt(float(samplesCount));
    float theta = float(sampleIndex) * 2.4 + phi;
    return vec2(r * cos(theta), r * sin(theta));
}

float findBlockerDepth(vec3 shadowPos, float searchRadius) {
    float blockers = 0.0;
    float avgBlockerDepth = 0.0;
    
    float phi = fract(sin(dot(shadowPos.xy, vec2(12.9898, 78.233))) * 43758.5453) * 6.2831853;

    for (int i = 0; i < BLOCKER_SEARCH_SAMPLES; i++) {
        vec2 offset = vogelDisk(i, BLOCKER_SEARCH_SAMPLES, phi) * searchRadius;
        float depth = texture(shadowtex0, shadowPos.xy + offset).r;
        if (depth < shadowPos.z - 0.0001) {
            avgBlockerDepth += depth;
            blockers += 1.0;
        }
    }

    if (blockers > 0.0) {
        return avgBlockerDepth / blockers;
    }
    return -1.0;
}

float calculatePCF(vec3 shadowPos, float penumbraSize) {
    float shadow = 0.0;
    float phi = fract(sin(dot(shadowPos.xy, vec2(12.9898, 78.233))) * 43758.5453) * 6.2831853;

    for (int i = 0; i < PCF_SAMPLES; i++) {
        vec2 offset = vogelDisk(i, PCF_SAMPLES, phi) * penumbraSize;
        float depth = texture(shadowtex0, shadowPos.xy + offset).r;
        if (shadowPos.z - 0.0001 < depth) {
            shadow += 1.0;
        }
    }
    
    return shadow / float(PCF_SAMPLES);
}

vec3 calculateShadow(vec3 worldPos, mat4 inShadowModelView, mat4 inShadowProjection) {
    vec4 shadowView = inShadowModelView * vec4(worldPos, 1.0);
    vec4 shadowClip = inShadowProjection * shadowView;
    vec3 shadowPos = shadowClip.xyz / shadowClip.w;
    
    shadowPos = distortShadow(shadowPos);
    shadowPos = shadowPos * 0.5 + 0.5;

    if (shadowPos.x < 0.0 || shadowPos.x > 1.0 || 
        shadowPos.y < 0.0 || shadowPos.y > 1.0 || 
        shadowPos.z < 0.0 || shadowPos.z > 1.0) {
        return vec3(1.0);
    }

    float searchRadius = LIGHT_SIZE * (shadowPos.z); 
    float blockerDepth = findBlockerDepth(shadowPos, searchRadius);

    if (blockerDepth < 0.0) {
        return vec3(1.0);
    }

    float penumbraSize = max(0.001, (shadowPos.z - blockerDepth) * LIGHT_SIZE / blockerDepth);

    float visibility = calculatePCF(shadowPos, penumbraSize);
    
    vec4 transparentShadowColor = texture(shadowcolor0, shadowPos.xy);
    if (transparentShadowColor.a > 0.0 && visibility < 1.0) {
        return mix(vec3(visibility), transparentShadowColor.rgb, (1.0 - visibility) * transparentShadowColor.a);
    }

    return vec3(visibility);
}
#endif
