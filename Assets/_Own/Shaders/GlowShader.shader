Shader "Custom/GlowShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Emission ("Emission", 2D) = "black" {}
        _EmissionIntensity ("Emission intensity", Float) = 1
        _EmissionMapOffsetSpeed ("Emission map offset speed (XY)", Vector) = (0, 0, 0, 0)
        
        _Metallic ("Metallic", Range(0, 1)) = 0
		_Smoothness ("Smoothness", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
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
            
            sampler2D _Emission;
            float4 _Emission_ST;
            float _EmissionIntensity;
            float2 _EmissionMapOffsetSpeed;
                     
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
            
            inline half4 GetEmission(float2 uv)
            {
                float2 offset = _Time.yy * _EmissionMapOffsetSpeed;
                uv = TRANSFORM_TEX(uv, _Emission) + offset;
                return tex2D(_Emission, uv) * _EmissionIntensity;
            }
                 
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 col = tex2D(_MainTex, TRANSFORM_TEX(i.uv, _MainTex));
                
                col = GetColor(col, i.positionWorldSpace, i.normal);
                
                col += GetEmission(i.uv);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
               
                return col;
            }
            ENDCG
        }
    }
}