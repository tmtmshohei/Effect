Shader "Unlit/GUItest"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Noise ("Noise",2D) ="white" {}
		[HideInInspector]
		[Enum(UnityEngine.Rendering.BlendMode)]
		_SrcBlend("Src Factor", Float) = 1
		[HideInInspector]
		[Enum(UnityEngine.Rendering.BlendMode)]
		_DstBlend("Dst Factor", Float) = 0
		[KeywordEnum(Geometry, Transparent)] _Overlay("Overlay mode", Float) = 0
		[Enum(UnityEngine.Rendering.CullMode)]_Cullingmode("Cullingmode",Float) = 2
		[KeywordEnum(Off, On)] _ZWrite("ZWrite",Float) = 1
		_rgba("RGBA",Color) = (1,1,1,1)
		_growintensity("GrowIntensity",Float) = 1

	}
	SubShader
	{
		Tags { "RenderType"="Opaque"  "Queue" ="Transparent"}
		Blend [_SrcBlend][_DstBlend]
		Cull [_Cullingmode]
			ZWrite [_ZWrite]
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
			sampler2D _Noise;
			float4 _rgba;
			float _growintensity;
			
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
				fixed4 noise = tex2D(_Noise, i.uv);

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				col *= _rgba	* _growintensity;
				col *= noise;
				//col.a = _alpha;
				return col;
			}
			ENDCG
		}
	}
		CustomEditor "ShaderGUItest"
}
