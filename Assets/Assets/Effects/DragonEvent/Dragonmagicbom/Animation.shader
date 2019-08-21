Shader "Vertex/Animation"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color",Color) = (1,1,1,1)
			
			_Cols("Cols Count", Int) = 5
			_Rows("Rows Count", Int) = 3
			_Frame("Per Frame Length", Float) = 0.5
			_scale("Scale",Float)=1
	}
	SubShader
	{
			Tags{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			//ZTest Always
			//ZWrite off
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
		uint _Cols;
		uint _Rows;
		float _Frame;
		float _scale;

		fixed4 shot(sampler2D tex, float2 uv, float dx, float dy, int frame) {
			return tex2D(tex, float2(
				(uv.x * dx) + fmod(frame, _Cols) * dx,
				1.0 - ((uv.y * dy) + (frame / _Cols) * dy)
				));
		}
		
				
				

		v2f vert(appdata v)
		{
			float4x4 scale = float4x4
			(
				_scale,0, 0, 0,
				0, _scale, 0, 0,
				0, 0, _scale, 0,
				0, 0, 0, 1.0
			);
			float4x4 move = float4x4
			(
				1.0, 0, 0, 0,
				0, 1.0, 0, 0,
				0, 0, 1.0, 0,
				0, 0, 0, 1.0
			);
			float4x4 rot = float4x4
			(
				cos(_Time.y*1.5), sin(_Time.y*1.5), 0, 0,
				-sin(_Time.y*1.5),cos(_Time.y*1.5), 0, 0,
				0, 0, 1.0, 0,
				0, 0, 0, 1.0
			);


			v2f o;
			//v.vertex = mul(rot,mul(move,mul(scale,v.vertex)));
			v.vertex = mul(unity_ObjectToWorld, mul(rot, v.vertex));
			o.vertex = mul(UNITY_MATRIX_VP,v.vertex);
			
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			UNITY_TRANSFER_FOG(o,o.vertex);
			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			int frames = _Rows * _Cols;
		float frame = fmod(_Time.y / _Frame, frames);
		int current = floor(frame);
		float dx = 1.0 / _Cols;
		float dy = 1.0 / _Rows;

		// not lerping to next frame
		// return shot(_MainTex, i.uv, dx, dy, current) * _Color;

		int next = floor(fmod(frame + 1, frames));
		
		//return lerp(shot(_MainTex, i.uv, dx, dy, current), shot(_MainTex, i.uv, dx, dy, next), frame - current) * _Color;
		return shot(_MainTex, i.uv, dx, dy, current) * _Color;
		}
		ENDCG
		}
	}
}
