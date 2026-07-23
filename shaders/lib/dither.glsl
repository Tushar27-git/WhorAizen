#ifndef DITHER_GLSL
#define DITHER_GLSL

float bayer2(vec2 a) {
    a = floor(a);
    return fract(dot(a, vec2(0.5, a.y * 0.75)));
}
#define bayer4(a)   (bayer2(0.5 * (a)) * 0.25 + bayer2(a))
#define bayer8(a)   (bayer4(0.5 * (a)) * 0.25 + bayer2(a))
#define bayer16(a)  (bayer8(0.5 * (a)) * 0.25 + bayer2(a))
#define bayer64(a)  (bayer16(0.5 * (a)) * 0.25 + bayer2(a))

float getDither(vec2 pos) {
    return bayer64(pos);
}

#endif
