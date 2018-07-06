Shader "Handout/TransparentVertexLit"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color1 ("Color1", Color) = (0,1,1,1)
		_Ambient ("Ambient", Range(0,1)) = 0.1
		_Alpha ("Alpha", Range(0,1)) = 0.3
	}
	SubShader
	{
		// TODO: Try out different combinations of options for ZWrite / ZTest / Cull / BlendOp / Blend - What do they mean?
		//ZWrite Off
		//ZWrite On
		//ZTest Off
		//ZTest Less
		//ZTest Greater

		//Cull Off
		//Cull Front
		//Cull Back

		//BlendOp Sub
	    //BlendOp Add
		//BlendOp Max
		//BlendOp Min

		//Blend One One
		//Blend Zero OneMinusDstColor
		Blend SrcAlpha OneMinusSrcAlpha
		//Blend One OneMinusSrcAlpha
		//Blend OneMinusDstColor One
		//Blend DstColor Zero


		Tags {
			// TODO: Try out different queues for this shader. What do they mean?
			//"Queue" = "BackGround"
			//"Queue" = "Geometry-1"
			//"Queue" = "Geometry"
			//"Queue" = "Geometry+1"
			"Queue" = "Transparent"

			"LightMode"="ForwardBase"		// Needed to get the correct (consistent) info in _WorldSpaceLightPos0
		}

		////// To get a perfect transparent material, nothing below this line needs to be changed! //////////////////////////////////////////////////

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
			float4 _Color1;
			float _Ambient;
			float _Alpha;

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
				float4 col = _Color1;
				col.a = _Alpha;
				return tex2D(_MainTex,i.uv) * i.diffuseLight * col;
			}
			ENDCG
		}

		//UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"	// An easy way to enable shadow casting
	}
}
