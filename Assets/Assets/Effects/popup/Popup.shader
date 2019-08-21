Shader "Unlit/Popup"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_noise("Noise" , 2D) = "white" {}
		_noise2("Noise" , 2D) = "white" {}
		_Color ("Color",Color) = (1,1,1,1)
		_threshold ("Threshold" , Range(0,1))=0
		_uvoffset ("UVOffset" , Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

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
				float2 uv2 : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv2 :TEXCOORD1;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _noise;
			float4 _Color;
			float _threshold;
			float _uvoffset;
			sampler2D _noise2;

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv2 = o.uv;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				//i.uv.x +=_uvoffset*_Time.y;
				i.uv.y +=_uvoffset*_Time.y*3;
				i.uv2.x +=(_uvoffset+_Time.y*2);

				fixed4 m = tex2D(_noise, i.uv);
				fixed4 n = tex2D(_noise2 , i.uv2);
				m *= n;
				half g = m.r * 0.2 + m.g * 0.7 + m.b * 0.1;
				if(g < _threshold)
				{
					discard;
				}
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col*_Color*2;
			}
			ENDCG
		}
	}
}
