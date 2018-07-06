Shader "Unlit/WoodShader"
{
	Properties
	{
		_Color1 ("Color 1", color) = (1,1,1,1)
		_Color2 ("Color 2", color) = (0,0,0,0)
		_RingWidth ("Ring width", Range(0.01, 10)) = 0.2
		
		_Metallic ("Metallic", Range(0, 1)) = 0
		_Smoothness ("Smoothness", Range(0, 1)) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
		    Tags 
		    {
				"LightMode" = "ForwardBase"
			}
		
			CGPROGRAM
			
			#pragma target 3.0
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityPBSLighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
			};

			struct v2f
			{
                float4 vertex : SV_POSITION;
                float3 vertexWorldSpace : TEXCOORD0;
				float3 vertexObjectSpace : TEXCOORD1;
				float3 normal : TEXCOORD2;
			};

			float4 _Color1;
			float4 _Color2;
			float _RingWidth;
			
			float _Metallic;
			float _Smoothness;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertexObjectSpace = v.vertex;
				o.vertexWorldSpace = mul(unity_ObjectToWorld, v.vertex);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			inline float3 getAlbedo(v2f i)
			{			
			    float t = length(i.vertexObjectSpace.xy);
			    t = fmod(t, _RingWidth * 2) / (_RingWidth * 2);
			    t = abs((t - 0.5) * 2);
			    float3 col = lerp(_Color1, _Color2, t).xyz;
			    
			    return col;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{				
				i.normal = normalize(i.normal);
				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.vertexWorldSpace);

				float3 lightColor = _LightColor0.rgb;
				float3 albedo = getAlbedo(i);

				float3 specularTint;
				float oneMinusReflectivity;
				albedo = DiffuseAndSpecularFromMetallic(
					albedo, _Metallic, specularTint, oneMinusReflectivity
				);
				
				UnityLight light;
				light.color = lightColor;
				light.dir   = lightDir;
				light.ndotl = DotClamped(i.normal, lightDir);
				UnityIndirect indirectLight;
				indirectLight.diffuse  = 0;
				indirectLight.specular = 0;

				return UNITY_BRDF_PBS(
					albedo, specularTint,
					oneMinusReflectivity, _Smoothness,
					i.normal, viewDir,
					light, indirectLight
				);
			}
			ENDCG
		}
	}
}
