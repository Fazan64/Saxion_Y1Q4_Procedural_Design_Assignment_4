Shader "Custom/WaterShader"
{
	Properties
	{
		_Metallic ("Metallic", Range(0, 1)) = 0
		_Smoothness ("Smoothness", Range(0, 1)) = 1
		
        _WaterColor    ("Water Color", color) = (0, 1, 1, 0.5)
		_WaveOrigin    ("Wave origin"   , Vector) = (0.0, 0.0, 0.0)
        _WaveLength    ("Wave length"   , Float)  = 0.75
        _WaveFrequency ("Wave frequency", Float)  = 0.5
        _WaveHeight    ("Wave height"   , Float)  = 0.5
	}
	SubShader
	{
        Blend SrcAlpha OneMinusSrcAlpha

		Tags 
		{ 
		    "LightMode" = "ForwardBase" 
            "Queue" = "Transparent"
		}

		Pass
		{
		    Cull Off
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc" // for _LightColor0
            #include "SimpleLighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
                float4 position : SV_POSITION;
                float3 normal : TEXCOORD0;
				float4 positionWorldSpace : TEXCOORD1;
			};

			float4 _WaterColor;
			float3 _WaveOrigin;
			float _WaveLength;
            float _WaveFrequency;
			float _WaveHeight;
			
			inline float3 GetDisplacedPosition(float3 position) 
            {
                const float PI2 = 6.28318;
                float dist = fmod(distance(position, _WaveOrigin), _WaveLength) / _WaveLength;
                //float dist = fmod(position.x, _WaveLength) / _WaveLength;
                position.y += _WaveHeight * sin(_Time.y * PI2 * _WaveFrequency + dist * PI2);
                
                return position;
            }
			
			v2f vert(appdata v)
			{
				v2f o;
							
				float3 alongX = GetDisplacedPosition(v.vertex.xyz + float3(0.1, 0, 0));
			    float3 alongZ = GetDisplacedPosition(v.vertex.xyz + float3(0, 0, 0.1));
				v.vertex.xyz = GetDisplacedPosition(v.vertex.xyz);

                o.normal = normalize(cross(alongZ - v.vertex.xyz, alongX - v.vertex.xyz));
                o.normal = UnityObjectToWorldNormal(o.normal);
				
				o.position = UnityObjectToClipPos(v.vertex);
                o.positionWorldSpace = mul(unity_ObjectToWorld, v.vertex);
                
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
			    i.normal = normalize(i.normal);
			    return GetColor(_WaterColor, i.positionWorldSpace, i.normal);
			}
			ENDCG
		}
	}
}
