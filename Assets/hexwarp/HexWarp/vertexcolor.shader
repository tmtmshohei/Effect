Shader "Unlit/vertexcolor"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_color("Color",Color) = (1,1,1,1)
		_lightintensity("LightIntensity",Float) = 1
		_speed("Speed",Float) =1
			_noise("noise",2D) ="white"{}
		_noisecolor("noisecolor",Color) = (1,1,1,1)
		//_fadeout("FadeOut",2D) = "white"{}
		//_threshold("Threshold",Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha 
			ZWrite off
			//Cull off
			

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
			float _speed;
			//sampler2D _fadeout;
			//float _threshold;
			sampler2D _noise;
			float4 _noisecolor;
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
				float2 quateruv = float2(i.uv.x *0.5, i.uv.y *0.5);
				float4 noise = tex2D(_noise,float2(i.uv.x+_Time.y*0.5,i.uv.y));
				noise *= _noisecolor;
				
				i.uv.y -= _Time.y *_speed;
				//flowuv = float2(i.uv.x, uv.y * 2 - 1);
				//i.uv.y = _Time.y *_speed;
				i.uv.x -= _Time.y*0.25;
				
				fixed4 col = tex2D(_MainTex, i.uv);
				//col *= gradation;
				
				col += noise;
				//return col;
				col *= i.vcol*_color*_lightintensity;
				

				
				//float4 fadeout = tex2D(_fadeout, i.uv);
				//col = lerp(col, fadeout, _threshold);
				//col *= i.vcol;
				
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
