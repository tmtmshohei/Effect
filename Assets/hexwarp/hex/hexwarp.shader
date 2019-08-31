Shader "Unlit/hexwarp"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_inside("inside", 2D) = "white" {}
		_outside("outside", 2D) = "white" {}
		_outline("outline", 2D) = "white" {}
		_col ("Color" , Color) =(1,1,1,1)
			
			_linecol ("OutlineColor",Color) = (1,1,1,1)
			_threshold("Threshold",Float) =0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
		LOD 100
		//Blend SrcAlpha OneMinusSrcAlpha
		Cull off
		//ZWrite off

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
				float4 vcolor : COLOR;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 vcolor : TEXCOORD2;
				float3 normal : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _col;
			float _threshold;
			sampler2D _inside;
			sampler2D _outside;
			sampler2D _outline;
			float4 _linecol;

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.vcolor = v.vcolor;
				return o;
			}
			
			fixed4 frag (v2f i , fixed facing : VFACE) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				col.a = i.vcolor.a + 1;
				col.xy = lerp(col.xy, float2(_threshold, _threshold), i.normal);
				col.z = 0;
				//return col;
				fixed4 inside = tex2D(_inside, col.rg);
				fixed4 outside = tex2D(_outside, col.rg);
				fixed4 outline = tex2D(_outline, i.uv);
				
				col =   lerp(inside, outside, facing);
				col += outline*_linecol*3;
				
				//col *= i.vcolor*_col;
				if (-i.normal.y	 < _threshold)discard;
				// apply fog
				//col = float4(0, i.normal.x, 0, 1);UNITY_APPLY_FOG(i.fogCoord, col);
				//col = float4(i.uv.x, i.uv.y, 0, 1);
				//col = i.vcolor;
			
				return col;
			}
			ENDCG
		}
	}
}
