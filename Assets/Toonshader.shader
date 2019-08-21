﻿Shader "Unlit/Toonshader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_heighlight("HeighLight",Color) = (1,1,1,1)
		_midlight("MidLight",Color) = (0.5,0.5,0.5,0.5)
		_shadow("Shadow",Color) = (0.1,0.1,0.1,0.1)
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
		LOD 100
			Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _heighlight;
			float4 _midlight;
			float4 _shadow;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				col.rgb = step(1, col.rgb);
				// apply fog
				if (col.r ==1)col = _heighlight;
			
			//else if (col.r > 0.7 && 0.3 > col.r) col = _midlight;
			//else col = _shadow;
				
				//col = float4(col.b, col.b, col.b, 1);
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
