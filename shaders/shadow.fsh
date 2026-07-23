#version 330 compatibility

uniform sampler2D gtexture; // Optifine/Iris standard alias for block texture

in vec2 texcoord;
in vec4 glcolor;

layout(location = 0) out vec4 fragColor;

void main() {
    vec4 color = texture(gtexture, texcoord) * glcolor;
    if (color.a < 0.1) discard;
    fragColor = color;
}
