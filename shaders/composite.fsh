#version 330 compatibility

#include "/lib/uniforms.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;

in vec2 texcoord;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 color;

void main() {
	vec4 albedo = texture(colortex0, texcoord);
	vec2 lmcoord = texture(colortex1, texcoord).xy;
	vec3 normal = texture(colortex2, texcoord).xyz * 2.0 - 1.0;
	float depth = texture(depthtex0, texcoord).r;

	if (depth == 1.0) {
		color = albedo; // Sky
		return;
	}

	vec3 lightDir = normalize(sunPosition);
	if (sunPosition.y < 0.0) lightDir = -lightDir; // Moon

	float nDotL = max(dot(normal, lightDir), 0.0);
	
	float blockLight = lmcoord.x;
	float skyLight = lmcoord.y;

	// Enforce ambient floor per RULES.md §4
	float ambient = max(skyLight * 0.5, nightAmbientFloor);
	
	vec3 diffuse = vec3(nDotL * skyLight);
	vec3 torch = vec3(blockLight) * vec3(1.0, 0.7, 0.4); // Warm torch light

	vec3 finalLighting = vec3(ambient) + diffuse + torch;

	color = vec4(albedo.rgb * finalLighting, albedo.a);
}
