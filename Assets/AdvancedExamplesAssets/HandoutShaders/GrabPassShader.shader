Shader "Handout/GrabPass"
{
	SubShader
	{
		// Grabs what has been rendered before and stores it in a texture called _GrabTex 
		// (Can be used by multiple objects - only updated once per frame!)
		GrabPass {
			"_GrabTex"
		}

		Tags {"Queue" = "Transparent-1"}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc" // For ComputeScreenPos
			#define UNITY_SHADER_NO_UPGRADE 1


			struct appdata
			{
				float4 vertex : POSITION;
				float2 UV : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 screenCoord : TEXCOORD0; 
				float2 UV : TEXCOORD1;
			};

			v2f vert (appdata v)
			{
				v2f o;
				// Transform the point to clip space:
				o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);
				// Also pass the camera space position (before perspective divide!) to the fragment shader:
				o.screenCoord = ComputeScreenPos(o.vertex);
				o.UV = v.UV;
				return o;
			}

			sampler2D _GrabTex;			// The texture we just grabbed
			float4 _GrabTex_TexelSize; // 1 divided by texture resolution, automatically set by Unity
			
			fixed4 frag (v2f i) : SV_Target
			{
				// The uv that corresponds to this pixel:
				// (Prespective divide must be done in fragment shader, to avoid warping!)
				float2 center= i.screenCoord.xy/i.screenCoord.w;

				float3 originalPixel = tex2D(_GrabTex,center);

				// invert: (Can also be done using ShaderLab's BlendOp=Sub)
				//return float4(1,1,1,1)-float4(originalPixel,0);

				// remove red component (Can also be done using ShaderLab's ColorMask):
				//originalPixel.r=0;
				//return float4(originalPixel,1);

				// hardcoded edge detection (see link in lecture 1 slides for more information and variants):
				float3 output=originalPixel * 4;
				output -= tex2D(_GrabTex,center-float2(_GrabTex_TexelSize.x,0)); // one pixel to the left
				output -= tex2D(_GrabTex,center+float2(_GrabTex_TexelSize.x,0)); // one pixel to the right
				output -= tex2D(_GrabTex,center-float2(0,_GrabTex_TexelSize.y)); // one pixel up
				output -= tex2D(_GrabTex,center+float2(0,_GrabTex_TexelSize.y)); // one pixel down
				return float4(output,1);
			}
			ENDCG
		}
	}
}
