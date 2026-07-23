#version 330 compatibility
uniform sampler2D lightmap;
uniform sampler2D gtexture;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;

/* DRAWBUFFERS:0123 */
layout(location = 0) out vec4 fragColor0;
layout(location = 1) out vec4 fragColor1;
layout(location = 2) out vec4 fragColor2;
layout(location = 3) out vec4 fragColor3;

void main() {
	vec4 color = texture(gtexture, texcoord) * glcolor;
	if (color.a < 0.1) discard;
	
	fragColor0 = color;
	fragColor1 = vec4(lmcoord, 0.0, 1.0);
	fragColor2 = vec4(normal * 0.5 + 0.5, 1.0);
	fragColor3 = vec4(0.0, 0.0, 0.0, 1.0);
}
