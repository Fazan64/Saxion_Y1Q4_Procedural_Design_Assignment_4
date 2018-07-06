﻿Shader "Custom/WoodShader"
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
			
			#include "SimpleLighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
			};

			struct v2f
			{
                float4 position : SV_POSITION;
                float3 positionWorldSpace : TEXCOORD0;
				float3 positionObjectSpace : TEXCOORD1;
				float3 normal : TEXCOORD2;
			};

			float4 _Color1;
			float4 _Color2;
			float _RingWidth;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.positionObjectSpace = v.vertex;
				o.positionWorldSpace = mul(unity_ObjectToWorld, v.vertex);
				o.position = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			inline float4 getAlbedo(v2f i)
			{			
			    float t = length(i.positionObjectSpace.xy);
			    t = fmod(t, _RingWidth * 2) / (_RingWidth * 2);
			    t = abs((t - 0.5) * 2);
			    float4 col = lerp(_Color1, _Color2, t);
			    
			    return col;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{				
				i.normal = normalize(i.normal);
				return GetColor(getAlbedo(i), i.positionWorldSpace, i.normal);
			}
			ENDCG
		}
	}
}