#version 330 compatibility
uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform float alphaTestRef = 0.1;
in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;
in vec3 normal;

/* DRAWBUFFERS:0123 */
layout(location = 0) out vec4 colortex0;
layout(location = 1) out vec4 colortex1;
layout(location = 2) out vec4 colortex2;
layout(location = 3) out vec4 colortex3;

void main() {
	vec4 color = texture(gtexture, texcoord) * glcolor;
	if (color.a < alphaTestRef) discard;
	
	colortex0 = color;
	colortex1 = vec4(lmcoord, 0.0, 1.0);
	colortex2 = vec4(normal * 0.5 + 0.5, 1.0);
	colortex3 = vec4(0.0, 0.0, 0.0, 1.0);
}
