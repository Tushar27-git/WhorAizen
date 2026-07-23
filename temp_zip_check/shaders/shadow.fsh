#version 330 compatibility

uniform sampler2D tex;
in vec2 texcoord;
in vec4 glcolor;

layout(location = 0) out vec4 shadowcolor0;

void main() {
    vec4 color = texture(tex, texcoord) * glcolor;
    if (color.a < 0.1) discard;
    shadowcolor0 = color;
}
