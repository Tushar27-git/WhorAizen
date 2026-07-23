#ifndef DITHER_GLSL
#define DITHER_GLSL

float bayer2(vec2 a) {
    a = floor(a);
    return fract(dot(a, vec2(0.5, a.y * 0.75)));
}
float bayer4(vec2 a) {
    return bayer2(0.5 * a) * 0.25 + bayer2(a);
}
float bayer8(vec2 a) {
    return bayer4(0.5 * a) * 0.25 + bayer2(a);
}
float bayer16(vec2 a) {
    return bayer8(0.5 * a) * 0.25 + bayer2(a);
}
float bayer64(vec2 a) {
    return bayer16(0.5 * a) * 0.25 + bayer2(a);
}

float getDither(vec2 pos) {
    return bayer64(pos);
}

#endif
