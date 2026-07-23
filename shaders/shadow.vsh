#version 330 compatibility

#include "/lib/distort.glsl"

out vec2 texcoord;
out vec4 glcolor;

void main() {
    gl_Position = ftransform();
    gl_Position.xyz = distortShadow(gl_Position.xyz);
    
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    glcolor = gl_Color;
}
