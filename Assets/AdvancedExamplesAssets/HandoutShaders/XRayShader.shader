Shader "Handout/XRay"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_RayColor ("RayColor", Color) = (0,1,0,1)
		_ScanPoint ("ScanPoint", Vector) = (0,0,0)
		_ScanSize ("ScanSize", float) = 1
	}
	SubShader
	{
		ZWrite On
		ZTest Less

		Cull Off

		BlendOp Add
		Blend SrcAlpha OneMinusSrcAlpha

		Tags {
			"Queue" = "Transparent-1"
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define UNITY_SHADER_NO_UPGRADE 1

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _RayColor;
			float3 _ScanPoint;
			float _ScanSize;

			v2f vert (appdata v)
			{
				v2f o;
				// Transform the point to clip space:
				o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);
				// Pass the world position:
				o.worldPos = mul(UNITY_MATRIX_M,v.vertex).xyz;
				// Pass the UVs:
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float distanceToScanPoint = length(i.worldPos - _ScanPoint);
				float alpha = saturate(distanceToScanPoint / _ScanSize);
				// interpolate between texture color and scan color, based on distance to scan point:
				return tex2D(_MainTex,i.uv) * alpha + _RayColor * (1-alpha);
			}
			ENDCG
		}
	}
}
