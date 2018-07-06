Shader "Unlit/WaterShader"
{
	Properties
	{
		_WaterColor ("Water Color", color) = (0,1,1,0.5)
	}
	SubShader
	{
        Blend SrcAlpha OneMinusSrcAlpha

		Tags 
		{ 
		    "LightMode" = "ForwardBase" 
            "Queue" = "Transparent"
		}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
                float4 vertex : SV_POSITION;
				float4 vertexObjectSpace : TEXCOORD0;
			};

			float4 _WaterColor;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertexObjectSpace = v.vertex;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
			    float4 col = _WaterColor;
			    
				return col;
			}
			ENDCG
		}
	}
}
