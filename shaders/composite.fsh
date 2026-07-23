#version 330 compatibility

#include "/lib/uniforms.glsl"
#include "/lib/shadows.glsl"
#include "/lib/sky.glsl"
#include "/lib/volumetrics.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform vec3 cameraPosition;

in vec2 texcoord;

/* DRAWBUFFERS:0 */
layout(location = 0) out vec4 color;

void main() {
	vec4 albedo = texture(colortex0, texcoord);
	vec2 lmcoord = texture(colortex1, texcoord).xy;
	vec3 normal = texture(colortex2, texcoord).xyz * 2.0 - 1.0;
	float depth = texture(depthtex0, texcoord).r;

    vec4 clipPos = vec4(texcoord * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
    vec4 viewPos = gbufferProjectionInverse * clipPos;
    viewPos /= viewPos.w;
    vec4 worldPos = gbufferModelViewInverse * viewPos;
    vec3 viewDir = normalize(worldPos.xyz);
    vec3 sunDir = normalize(sunPosition);

    vec3 skyColor = getAtmosphericScattering(viewDir, sunDir);

	if (depth == 1.0) {
		color = vec4(skyColor, 1.0);
		return;
	}

	vec3 lightDir = sunDir;
	if (sunPosition.y < 0.0) lightDir = -lightDir; // Moon

	float nDotL = max(dot(normal, lightDir), 0.0);
	
	float blockLight = lmcoord.x;
	float skyLight = lmcoord.y;

    vec3 shadow = vec3(1.0);
    if (nDotL > 0.0) {
        shadow = calculateShadow(worldPos.xyz, shadowModelView, shadowProjection);
    }

	float ambient = max(skyLight * 0.5, nightAmbientFloor);
	vec3 diffuse = vec3(nDotL * skyLight) * shadow;
	vec3 torch = vec3(blockLight) * vec3(1.0, 0.7, 0.4); 
	
	vec3 finalLighting = vec3(ambient) + diffuse + torch;
	vec3 terrainColor = albedo.rgb * finalLighting;

    // Volumetrics
    float volScattering = getVolumetricScattering(vec3(0.0), worldPos.xyz, shadowModelView, shadowProjection, texcoord);
    
    float mu = dot(viewDir, sunDir);
    float g = 0.76;
    float phaseM = 1.5 * ((1.0 - g * g) / (2.0 + g * g)) * (1.0 + mu * mu) / max(0.001, pow(1.0 + g * g - 2.0 * g * mu, 1.5));
    
    vec3 sunColor = vec3(1.0, 0.8, 0.6) * 20.0;
    vec3 volumetricLight = volScattering * phaseM * sunColor * 0.0005 * max(0.0, sunDir.y + 0.1);
    
    // Exponential height fog
    float dist = length(worldPos.xyz);
    float fogDensity = 0.003;
    float fogFactor = exp(-dist * fogDensity);
    
    vec3 finalColor = mix(skyColor, terrainColor, fogFactor);
    finalColor += volumetricLight;

	color = vec4(finalColor, albedo.a);
}
