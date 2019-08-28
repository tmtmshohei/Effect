Shader "Unlit/vertexcolor"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_color("Color",Color) = (1,1,1,1)
		_lightintensity("LightIntensity",Float) = 1
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
				float4 vcol : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 vcol : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _color;
			float _lightintensity;
			
			v2f vert (appdata v)
			{
				v2f o;
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.vcol = v.vcol;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				float xgradation = ((1-i.uv.x) * 2);
				float gradation = lerp(0,1.8,1-i.uv.y);
				i.uv.y -= _Time.y*3;
				//i.uv.x -= _Time.y*0.5;
				
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				col *= gradation;
					//col *= xgradation;
					// apply fog
				col *= i.vcol*_color*_lightintensity;
				//col *= i.vcol;
				
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
