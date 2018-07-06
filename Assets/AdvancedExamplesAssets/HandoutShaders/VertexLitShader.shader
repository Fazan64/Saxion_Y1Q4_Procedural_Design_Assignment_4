Shader "Handout/VertexLit"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Ambient ("Ambient", Range(0,1)) = 0.1
	}
	SubShader
	{
		Tags {
			"RenderType" = "Opaque"		    // Needed to be included in the Depth+Normal render step of the camera!
			"LightMode"="ForwardBase"		// Needed to get the correct (consistent) info in _WorldSpaceLightPos0
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define UNITY_SHADER_NO_UPGRADE 1

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 diffuseLight : COLOR;
			};

			sampler2D _MainTex;
			float _Ambient;

			v2f vert (appdata v)
			{
				v2f o;
				// Transform the point to clip space:
				o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);
				// Pass the UVs:
				o.uv = v.uv;

				// The following lines are equivalent: 
				// (transform the normal to world space - only direction, no position change!)
				//half3 worldNormal = UnityObjectToWorldNormal(v.normal);
				half3 worldNormal = mul(UNITY_MATRIX_M,float4(v.normal,0));

                // dot product between normal and light direction for
                // standard diffuse (Lambert) lighting:
                float lt = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                // scale the range from [0,1] to [_Ambient,1], to take ambient light (=base value) into account:
                lt = lt * (1-_Ambient) + _Ambient;
                o.diffuseLight = float4(lt,lt,lt,1);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return tex2D(_MainTex,i.uv) * i.diffuseLight;
			}
			ENDCG
		}

		//UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"	// An easy way to enable shadow casting
	}
}
