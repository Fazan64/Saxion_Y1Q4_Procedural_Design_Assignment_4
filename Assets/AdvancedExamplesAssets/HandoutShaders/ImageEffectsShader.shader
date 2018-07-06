Shader "Handout/ImageEffects" 
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {} // somehow this is needed for Blit...
	}
	SubShader
	{
		Pass
		{
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc" // For DecodeDepthNormal
			#define UNITY_SHADER_NO_UPGRADE 1

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			// Nothing interesting happens here:
			v2f vert (appdata v)
			{
				v2f o;
				// Transform the point to clip space:
				o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);
				// Pass the UVs:
				o.uv = v.uv;
				return o;
			}

			sampler2D _MainTex;	// The input texture we will get from Graphics.Blit
			sampler2D _CameraDepthNormalsTexture; // The texture we will get when setting Camera.main.depthTextureMode = DepthTextureMode.DepthNormals
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the depth + normals texture:
				float depth;
				float3 normalValue;
				// For image effects, the incoming UVs (from a screen-sized quad) automatically match the screen grab texture -
				//  no conversion formulas necessary!:
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), depth, normalValue); 

				float effectStrength = sin(_Time.y) * 0.5 + 0.5;

				float4 col;
				// display depth:
				col = float4(depth,1-depth,fmod(depth*10,1),1);
				// display normal:
				//col = float4(normalValue,1);

				// depending on effect strength, display effect color or original color:
				return effectStrength * col + (1-effectStrength) * tex2D(_MainTex,i.uv);
			}
			ENDCG
		}
	}
}
