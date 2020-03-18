﻿Shader "Unlit/NormalMap"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Normal("Normal",2D) = "white"{}
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
				float4 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 wnormal : TEXCOORD2;
				float3 wtangent : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Normal;
			float4 _Normal_ST;

			float3 ConvertNormalMap(appdata v , sampler2D tex)
			{
				float3 btangent = float3 cross(v.normal.xyz,v.tangent.xyz);

				matrix3x3 ntb = matrix3x3(v.normal.xyz,v.tangent.xyz,btangent);
				
				return 
			}
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				float4 btangent = float4(cross(v.normal.xyz,v.tangent.xyz),1);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}