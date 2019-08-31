Shader "Unlit/auraeffect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_range("Range",2D) = "white"{}
		_noise("Noise",2D) = "white"{}
		_threshold("Threshold",Float)=0
		_color("Color",Color) = (1,1,1,1)
		_light("Light",Float) =1
		_animationspeed("animationspeed",Float)=0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			Cull Off
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
			sampler2D _range;
			float _threshold;
			sampler2D _noise;
			float4 _noise_ST;
			float4 _color;
			float _light;
			float _animationspeed;
			
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
				fixed4 range = tex2D(_range, i.uv);
				fixed4 noise = tex2D(_noise, float2(i.uv.x - _Time.y*_animationspeed, i.uv.y - _Time.y*_animationspeed));
				range *= noise;
				clip(range.g - _threshold);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				col *= _color*_light;
				col.a = 0.5;
				return col;
			}
			ENDCG
		}
	}
}
