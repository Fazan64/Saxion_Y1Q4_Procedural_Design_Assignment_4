#ifndef SIMPLE_LIGHTING_INCLUDED
#define SIMPLE_LIGHTING_INCLUDED

#include "UnityPBSLighting.cginc"

float _Metallic;
float _Smoothness;

half4 GetColor(half4 albedo, float3 position, float3 normal)
{
    float3 viewDir = normalize(_WorldSpaceCameraPos - position);
    float3 lightDir = _WorldSpaceLightPos0.xyz;

    UnityLight light;
    light.color = _LightColor0.rgb;
    light.dir   = lightDir;
    light.ndotl = DotClamped(normal, lightDir);
    
    UnityIndirect indirectLight; // Set everything to zero for now
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

#endif //#ifndef SIMPLE_LIGHTING_INCLUDED
