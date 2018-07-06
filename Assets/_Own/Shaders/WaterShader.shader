Shader "Custom/WaterShader"
{
	Properties
	{
		_MainTex       ("Main texture"  , 2D)     = "white" {}
        _WaterColor    ("Water Color"   , Color)  = (0, 1, 1, 0.5)
		_WaveOrigin    ("Wave origin"   , Vector) = (0.0, 0.0, 0.0)
        _WaveLength    ("Wave length"   , Float)  = 0.75
        _WaveFrequency ("Wave frequency", Float)  = 0.5
        _WaveHeight    ("Wave height"   , Float)  = 0.5
        
        _Metallic   ("Metallic"  , Range(0, 1)) = 0
		_Smoothness ("Smoothness", Range(0, 1)) = 0
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
            #pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
            #include "SimpleLighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
                float4 position : SV_POSITION;
                
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
				float4 positionWorldSpace : TEXCOORD2;
			};

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
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
				v.vertex.xyz  = GetDisplacedPosition(v.vertex.xyz);

                o.normal = normalize(cross(alongZ - v.vertex.xyz, alongX - v.vertex.xyz));
                o.normal = UnityObjectToWorldNormal(o.normal);
				
				o.position = UnityObjectToClipPos(v.vertex);
                o.positionWorldSpace = mul(unity_ObjectToWorld, v.vertex);
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
				return o;
			}
			
			inline half4 GetAlbedo(v2f i)
			{			    
			    return tex2D(_MainTex, i.uv) * _WaterColor;
			}
			
			half4 frag(v2f i) : SV_Target
			{
			    i.normal = normalize(i.normal);
			    return GetColor(GetAlbedo(i), i.positionWorldSpace, i.normal);
			}
			ENDCG
		}
	}
}
