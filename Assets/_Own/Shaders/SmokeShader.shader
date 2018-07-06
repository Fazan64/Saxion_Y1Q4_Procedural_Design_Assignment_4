Shader "Custom/SmokeShader"
{
	Properties
	{
		_MainTex ("MainTex", 2D) = "white" {}
		_Tint ("Tint", Color) = (1,1,1,1)
		_Offset ("Offset (A)", 2D) = "black" {}
		
		_OffsetSpeed ("Offset speed (XY)", Vector) = (1, 1, 0, 0)
        _OffsetRange ("Offset range (XY)", Vector) = (0.5, 0.5, 0, 0)
		_OffsetStrength ("Offset strength", Float) = 1
		
		_Metallic ("Metallic", Range(0, 1)) = 0
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
		
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
            #include "SimpleLighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
                float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 position : SV_POSITION;
                
                UNITY_FOG_COORDS(0)
                float2 uv : TEXCOORD1;
                float3 normal : TEXCOORD2;
                float3 positionWorldSpace : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
            half4 _Tint;
			
			sampler2D _Offset;
			float4 _Offset_ST;
			
			float2 _OffsetSpeed;
			float2 _OffsetRange;
			float _OffsetStrength;
			
			
			v2f vert (appdata v)
			{
				v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.positionWorldSpace = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                
                UNITY_TRANSFER_FOG(o, o.position);
                
                return o;
			}
			
			inline half4 GetAlbedo(float2 uv)
			{
                const float PI2 = 6.28318;
                
                float timeOffset = _OffsetStrength * tex2D(_Offset, TRANSFORM_TEX(uv, _Offset)).a;
			    float time = _Time.x + timeOffset;
			    
			    //return timeOffset.xxxx;
			    
			    float2 textureOffset;
			    textureOffset.x = _OffsetRange.x * cos(PI2 * _OffsetSpeed.x * time);
			    textureOffset.y = _OffsetRange.y * sin(PI2 * _OffsetSpeed.y * time);
                uv = TRANSFORM_TEX(uv, _MainTex) + textureOffset;
                
                half4 mainTexColor = tex2D(_MainTex, uv);
			    return half4(mainTexColor.rgb + _Tint.rgb, mainTexColor.a * _Tint.a);
			}
			
			fixed4 frag (v2f i) : SV_Target
			{				  
                half4 color = GetColor(GetAlbedo(i.uv), i.positionWorldSpace, i.normal);
                
                UNITY_APPLY_FOG(i.fogCoord, color);
                                                
                return color;
			}
			ENDCG
		}
	}
}
