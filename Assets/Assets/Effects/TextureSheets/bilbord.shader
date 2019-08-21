Shader "Unlit/bilbord"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_color ("color",Color) =(1,1,1,1)
		_seed ("seed",Range(-1,1))=0
		_scalex("ScaleX",Float) =1	
		_scaley("ScaleY",Float) =1
			_Cols("Cols Count", Int) = 5
			_Rows("Rows Count", Int) = 3
			_Frame("Per Frame Length", Float) = 0.5
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" =  "Transparent" }
		LOD 100
		Cull Off
		//Blend SrcAlpha OneMinusSrcAlpha


		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			#pragma enable_d3d11_debug_symbols
			
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
				float4 pos : SV_POSITION;
				float4 viewdir : TEXCOORD1;
				float4 color : COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _seed;
			float _scalex;
			float _scaley;
			float4 _color;
			uint _Cols;
			uint _Rows;
			float _Frame;

			fixed4 shot(sampler2D tex, float2 uv, float dx, float dy, int frame) {
				return tex2D(tex, float2(
					(uv.x * dx) + fmod(frame, _Cols) * dx,
					1.0 - ((uv.y * dy) + (frame / _Cols) * dy)
					));
			}

			float4x4 rotmat(float x ,float y ,float z)
			{
				float4x4 xrot =
				(
					1,0,0,0,
					0,cos(x),-sin(x),0,
					0,sin(x),cos(x),0,
					0,0,0,1
				);
				float4x4 yrot = 
				(
					cos(y), 0, sin(y), 0,
					0, 1, 0, 0,
					-sin(y), 0, cos(y), 0,
					0, 0, 0, 1
				);
				float4x4 zrot = 
				(
					cos(z),-sin(z),0,0,
					sin(z),cos(z),0,0,
					0,0,1,0,
					0,0,0,1
				);

				return mul(zrot,mul(xrot,yrot));
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				//o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv.xy;

				
				float4x4 scalemat=float4x4(
						1,0,0,0,
						0,1,0,0,
						0,0,1,0,
						0,0,0,1
				
				);
				float4x4 movemat = 
				(
					1,0,0,0,
					0,1,0,0,
					0,0,1,0,
					0,0,0,1
				);	

				float4x4 zrot =
				float4x4(
						float4(cos(0), -sin(0), 0, 0),
						float4(sin(0), cos(0), 0, 0),
						float4(0, 0, 1, 0),
						float4(0, 0, 0, 1)
				);

				v.vertex = mul(zrot, v.vertex);

				//float4x4 modelmat = mul(movemat,mul(rotmat(0,0,0) ,scalemat));
				//float4x4 modelmat = movemat*rotmat(30,0,0)*scalemat;
				//o.pos = mul(UNITY_MATRIX_P,mul(UNITY_MATRIX_V,mul(modelmat,float4(v.vertex.xyz,1))));
				//unity_ObjectToWorld._m00=
				o.pos = UnityObjectToClipPos(v.vertex);

				// billboard mesh towards camera
				//float3 vpos = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz);
				//float4 worldCoord = float4(unity_ObjectToWorld._m03, unity_ObjectToWorld._m13, unity_ObjectToWorld._m23, 1);
				//float4 viewPos = mul(UNITY_MATRIX_V, worldCoord) + float4(vpos, 0)*float4(_scalex,_scaley,1,1);
				//float4 outPos = mul(UNITY_MATRIX_P, viewPos);
				//o.pos = outPos;
				
				//o.pos = mul(UNITY_MATRIX_P,
					//mul(UNITY_MATRIX_MV, float4(0.0, 2.0, 0.0, 1.0))
					//- float4(v.vertex.y, v.vertex.x, 0.0, 0.0)
					//* float4(1, 1, 0.0, 1.0));
						
				
				//float3 scale = mul(scalemat,(v.vertex.xyz));


				//float4 m= mul(unity_ObjectToWorld,float4(0,0,0, 1));
				//float4x4 ymat = UNITY_MATRIX_V;
					//float3 forward = UNITY_MATRIX_V._m20_m21_m22;
					//ymat._m00_m11_m22 = 1;
					//ymat._m01_m02_m10_m12 = 0;
					//ymat._m20_m21 = 0;
				//float4 v1= mul(ymat,m)+float4(v.vertex.x,v.vertex.y,0,0);
				//o.pos = mul(UNITY_MATRIX_P,v1);

				//o.pos = outPos;

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			


			fixed4 frag (v2f i) : SV_Target
			{
				
				//fixed4 col = tex2D(_MainTex, float2(i.uv.x , i.uv.y	));
				//_MainTex_ST.z =_seed;
				//col *= _color;
				//fixed2 resolution = _ScreenParams;
				//fixed2 position = (i.uv*resolution / resolution.xy );
				//fixed4 col = float4(0.1+UNITY_MATRIX_V._m10,0,0,1);
	
				//fixed4 col = float4(unity_ObjectToWorld._m10, 0, 0, 1);
				
				//col = i.color;
				//return col;

				int frames = _Rows * _Cols;
			float frame = fmod(_Time.y / _Frame, frames);
			int current = floor(frame);
			float dx = 1.0 / _Cols;
			float dy = 1.0 / _Rows;

			// not lerping to next frame
			// return shot(_MainTex, i.uv, dx, dy, current) * _Color;

			int next = floor(fmod(frame + 1, frames));
			//return lerp(shot(_MainTex, i.uv, dx, dy, current), shot(_MainTex, i.uv, dx, dy, next), frame - current) * _Color;
			return shot(_MainTex, i.uv, dx, dy, current) * _color;
			}
			ENDCG
		}
	}
}
