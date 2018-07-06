#ifndef SIMPLE_LIGHTING_INCLUDED
#define SIMPLE_LIGHTING_INCLUDED

// Simple PBR rendering (metallic-smoothness workflow) with a single light.

#include "UnityPBSLighting.cginc"

float _Metallic;
float _Smoothness;

/// position and normal are in worldspace.
half4 GetColor(half4 albedo, float3 position, float3 normal)
{
    float3 viewDir  = normalize(UnityWorldSpaceViewDir (position));
    float3 lightDir = normalize(UnityWorldSpaceLightDir(position));

    UnityLight light;
    light.color = _LightColor0.rgb;
    light.dir   = lightDir;
    light.ndotl = DotClamped(normal, lightDir);
    
    UnityIndirect indirectLight; // Keep everything at zero for now
    indirectLight.diffuse  = 0;
    indirectLight.specular = 0;
    
    float3 specularTint;
    float oneMinusReflectivity;
    float3 diffuse = DiffuseAndSpecularFromMetallic(
        albedo, _Metallic, specularTint, oneMinusReflectivity
    );
    
    return half4(UNITY_BRDF_PBS(
        diffuse, specularTint,
        oneMinusReflectivity, _Smoothness,
        normal, viewDir,
        light, indirectLight
    ).xyz, albedo.w);
}

#endif //ifndef SIMPLE_LIGHTING_INCLUDED
