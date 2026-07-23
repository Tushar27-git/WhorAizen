#ifndef DISTORT_GLSL
#define DISTORT_GLSL

float distortionFactor(vec2 position) {
    return length(position) * 0.85 + 0.15;
}

vec3 distortShadow(vec3 position) {
    float factor = distortionFactor(position.xy);
    return vec3(position.xy / factor, position.z * 0.2);
}

#endif
