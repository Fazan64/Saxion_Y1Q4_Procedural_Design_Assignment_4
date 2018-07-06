Shader "Handout/GraphDepthAndNormals"
{
	SubShader
	{
		Tags {"Queue" = "Transparent"}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc" // For ComputeScreenPos and DecodeDepthNormal
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
				// Also pass the camera space position to the fragment shader:
				o.screenCoord = ComputeScreenPos(o.vertex);
				o.UV = v.UV;
				return o;
			}

			sampler2D _CameraDepthNormalsTexture; // The texture we will get when setting Camera.main.depthTextureMode = DepthTextureMode.DepthNormals
			
			fixed4 frag (v2f i) : SV_Target
			{
				// The uv that corresponds to this pixel:
				// (Prespective divide must be done in fragment shader, to avoid warping!)
				float2 pixelUV= i.screenCoord.xy/i.screenCoord.w;

				float depth;
				float3 normalValue;

				// depth and normalValue are "out" parameters, set by this method (from UnityCG.cginc):
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, pixelUV ), depth, normalValue);

				// display depth:
				return float4(0,depth,fmod(depth*10,1),1);
				// display normal:
				//return float4(normalValue,1);
			}
			ENDCG
		}
	}
}
