Shader "Handout/DisplayCoordinates" {
	SubShader {
		Tags {"RenderType" = "Opaque" }

		Pass {
			CGPROGRAM
			#pragma vertex myVertexShader
			#pragma fragment myFragmentShader
			#define UNITY_SHADER_NO_UPGRADE 1
			#include "UnityCG.cginc" // For LinearEyeDepth


			struct vertexInput {
				float4 vertex : POSITION;
			};

			struct vertexToFragment {
				float4 vertex : SV_POSITION;
				float4 clipPos : TEXCOORD0;
			};

			vertexToFragment myVertexShader (vertexInput v) {
				vertexToFragment o;
				// Transform the point to clip space:
				o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);
				o.clipPos = o.vertex; // This should be redundant, right?
				return o;
			}

			float4 DisplayValue(float value) {
				return float4(-value,value,fmod(abs(value)*10,1),1);
			}
			
			fixed4 myFragmentShader (vertexToFragment i) : SV_Target {
				// TODO: Select which coordinate you want to display, and then play around with camera settings 
				//		 (near/far plane, field of view angle, orthographic / perspective)
				//	Think about:
				//		-What is the difference between i.vertex and i.clipPos? Where did this happen?
				//		-How are the various z values related to near and far plane?
				//		-What are _ProjectionParams.z, _ScreenParams.x and _ScreenParams.y?
				//		-What is the difference between clip space and screen space?
				float4 col;
				float value;
				float depth = LinearEyeDepth(i.vertex.z);

				// Select what you want to display here:
				//value = i.vertex.x/_ScreenParams.x;
				//value = i.vertex.y/_ScreenParams.y;
				//value = i.vertex.z;
				//value = depth;
				value = depth * _ProjectionParams.w;
				//value = i.clipPos.x;
				//value = i.clipPos.y;
				//value = i.clipPos.z;

				col = DisplayValue(value);
				// simple black and white:
				//col = float4(value,value,value,1);
				return col;
			}
			ENDCG
		}

		// UsePass "Legacy Shaders/VertexLit/SHADOWCASTER" // an easy way to enable shadow casting
	}
}

