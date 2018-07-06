Shader "Custom/Toon"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineThickness ("Outline thickness", Float) = 0.01
        _OutlineColor ("Outline color", Color) = (0,0,0,1)
        _NumColorBits ("Bits per color channel", Range(1, 8)) = 4
        
        _Metallic ("Metallic", Range(0, 1)) = 0
		_Smoothness ("Smoothness", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags 
        {
            "RenderType"  = "Opaque"
            "Queue" = "Transparent"
        }
        LOD 100
        
        Pass
        {
            ZWrite Off
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            
            #include "UnityCG.cginc"
            
            float _OutlineThickness;
            half4 _OutlineColor;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                UNITY_FOG_COORDS(0)
            };
                     
            v2f vert (appdata v)
            {
                v2f o;
                v.vertex.xyz += v.normal * _OutlineThickness;
                o.position = UnityObjectToClipPos(v.vertex);
                
                UNITY_TRANSFER_FOG(o, o.position);

                return o;
            } 
            
            fixed4 frag (v2f i) : SV_Target
            {
                half4 color = _OutlineColor;        
                UNITY_APPLY_FOG(i.fogCoord, col);
                return color;
            }
            
            ENDCG
        }
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
            
            int _NumColorBits;
                     
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
                 
            fixed4 frag (v2f i) : SV_Target
            {
                half4 col = tex2D(_MainTex, TRANSFORM_TEX(i.uv, _MainTex));
                
                col = GetColor(col, i.positionWorldSpace, i.normal);
                                
                UNITY_APPLY_FOG(i.fogCoord, col);
                
                const int numPossibleValues = 1 << _NumColorBits;
                col = round(col * numPossibleValues) / numPossibleValues;
               
                return col;
            }
            ENDCG
        }
    }
}