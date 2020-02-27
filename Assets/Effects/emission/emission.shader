Shader "Unlit/emission"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_effecttex ("Effect",2D) = "white" {}
		_noise("Noise" , 2D) = "white" {}
		_Color ("Color",Color) = (1,1,1,1)
		_threshold ("Threshold" , Range(0,1))=0
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
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			sampler2D _effecttex;
			float _threshold;
			sampler2D _noise;
			
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

				fixed4 m = tex2D(_noise, i.uv);
				half g = m.r * 0.2 + m.g * 0.7 + m.b * 0.1;
				if(g < _threshold)
				{
					discard;
				}


				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 eff = tex2D(_effecttex,i.uv);
				col *=_Color*((sin(_Time.y*10)+2));
				col *=eff;
				
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
