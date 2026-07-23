#ifndef SKY_GLSL
#define SKY_GLSL

const vec3 rayleighScattering = vec3(0.0058, 0.0135, 0.0331);
const float mieScattering = 0.002;
const float sunIntensity = 20.0;

float hash13(vec3 p3) {
    p3  = fract(p3 * .1031);
    p3 += dot(p3, p3.zyx + 31.32);
    return fract((p3.x + p3.y) * p3.z);
}

vec3 getAtmosphericScattering(vec3 viewDir, vec3 sunDir) {
    float mu = dot(viewDir, sunDir);
    float zenith = max(viewDir.y, 0.0);
    
    // Rayleigh phase function
    float phaseR = 0.75 * (1.0 + mu * mu);
    
    // Mie phase function
    float g = 0.76;
    float phaseM = 1.5 * ((1.0 - g * g) / (2.0 + g * g)) * (1.0 + mu * mu) / max(0.001, pow(1.0 + g * g - 2.0 * g * mu, 1.5));

    // Optical depth
    float opticalDepthR = 8.0 / (zenith + 0.15);
    float opticalDepthM = 1.2 / (zenith + 0.15);

    vec3 betaR = rayleighScattering;
    float betaM = mieScattering;
    
    vec3 extinction = exp(-(betaR * opticalDepthR + betaM * opticalDepthM));
    
    // Sun & Moon Disks
    float sunAngularRadius = 0.9998;
    float sunDisk = smoothstep(sunAngularRadius, sunAngularRadius + 0.0001, mu);
    vec3 sunColor = vec3(1.0, 0.8, 0.6) * sunIntensity * sunDisk;
    
    float moonDisk = smoothstep(sunAngularRadius, sunAngularRadius + 0.0001, dot(viewDir, -sunDir));
    vec3 moonColor = vec3(0.5, 0.6, 0.8) * 1.5 * moonDisk;

    // Scattering (very basic single scattering approximation)
    vec3 inscatter = (betaR * phaseR + vec3(betaM * phaseM)) * sunIntensity * (1.0 - extinction) * max(0.0, sunDir.y + 0.2);
    
    // Stars
    vec3 stars = vec3(0.0);
    if (sunDir.y < 0.1 && viewDir.y > 0.0) {
        float starVal = hash13(viewDir * 400.0);
        if (starVal > 0.99) {
            stars = vec3(pow(starVal, 20.0)) * 50.0 * (1.0 - smoothstep(-0.1, 0.1, sunDir.y)); 
        }
    }

    return inscatter + sunColor * extinction + moonColor + stars;
}

#endif
