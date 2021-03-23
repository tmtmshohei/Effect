Shader "Unlit/SheetAnimation"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color",Color) = (1,1,1,1)
			
			_Cols("Cols Count", Int) = 5
			_Rows("Rows Count", Int) = 3
			_Frame("Per Frame Length", Float) = 0.5

		[HideInInspector]
		[Enum(UnityEngine.Rendering.BlendMode)]
			_SrcBlend("Src Factor", Float) = 1
		[HideInInspector]
		[Enum(UnityEngine.Rendering.BlendMode)]
			_DstBlend("Dst Factor", Float) = 0
		[KeywordEnum(Geometry, Transparent)] _Overlay("Rendering mode", Float) = 0
		[Enum(UnityEngine.Rendering.CullMode)]_Cullingmode("Cullingmode",Float) = 2
		[KeywordEnum(Off, On)] _ZWrite("ZWrite",Float) = 1
		
				[Toggle]_LOOKINGCAMERA("LookAtCamera",Float) = 0
				[Toggle]_Fix_Y("Fix Y", Float) = 0
	}
	SubShader
	{
			Tags{
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
		}
			//Blend SrcAlpha OneMinusSrcAlpha
			//Cull Off
			//ZTest Always
			//ZWrite off
				Blend[_SrcBlend][_DstBlend]
				Cull[_Cullingmode]
				ZWrite[_ZWrite]
		LOD 100

	Pass
	{
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
				// make fog work
		#pragma multi_compile_fog
		#pragma shader_feature _LOOKINGCAMERA_ON
		#pragma shader_feature _FIX_Y_ON
		
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
			float4 col : COLOR;
		};

		float4x4 inverse(float4x4 input)
		{
			// https://answers.unity.com/questions/218333/shader-inversefloat4x4-function.html
			#define minor(a,b,c) determinant(float3x3(input.a, input.b, input.c))
			//determinant(float3x3(input._22_23_23, input._32_33_34, input._42_43_44))

			float4x4 cofactors = float4x4(
				minor(_22_23_24, _32_33_34, _42_43_44),
				-minor(_21_23_24, _31_33_34, _41_43_44),
				minor(_21_22_24, _31_32_34, _41_42_44),
				-minor(_21_22_23, _31_32_33, _41_42_43),

				-minor(_12_13_14, _32_33_34, _42_43_44),
				minor(_11_13_14, _31_33_34, _41_43_44),
				-minor(_11_12_14, _31_32_34, _41_42_44),
				minor(_11_12_13, _31_32_33, _41_42_43),

				minor(_12_13_14, _22_23_24, _42_43_44),
				-minor(_11_13_14, _21_23_24, _41_43_44),
				minor(_11_12_14, _21_22_24, _41_42_44),
				-minor(_11_12_13, _21_22_23, _41_42_43),

				-minor(_12_13_14, _22_23_24, _32_33_34),
				minor(_11_13_14, _21_23_24, _31_33_34),
				-minor(_11_12_14, _21_22_24, _31_32_34),
				minor(_11_12_13, _21_22_23, _31_32_33)
				);
			#undef minor
			return transpose(cofactors) / determinant(input);
		}


		float3 getCameraPos() {
			float3 cameraPos =
			#if defined(USING_STEREO_MATRICES)
				(unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) * .5
			#else
				_WorldSpaceCameraPos.xyz
			#endif
				;

			return cameraPos;
		}

		sampler2D _MainTex;
		float4 _MainTex_ST;
		float4 _Color;
		uint _Cols;
		uint _Rows;
		float _Frame;
		float _scale;

		fixed4 animation(sampler2D tex, float2 uv, float dx, float dy, int frame) {
			return tex2D(tex, float2(
				//(uv.x * dx) + fmod(frame, _Cols) * dx,
				//1.0 - ((uv.y * dy) + (frame / _Cols) * dy)
				(dx+(-uv.x* dx) + fmod(frame, _Cols) * dx),
				1-((-uv.y * dy) + (frame / _Cols) * dy)
				//uv.y
				));
		}
		
				
				

		v2f vert(appdata v)
		{
			v2f o;
			float3 cameraPos = getCameraPos();
			float3 worldPos = mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz;
			o.col = float4(worldPos, 1);
			o.col = float4(cameraPos, 1);
			float3 cameraZ = normalize(worldPos - cameraPos);//カメラがワールド座標の原点に対してどの位置にあるのかを求めている
			float3 cameraX = normalize(cross(float3(0, 1, 0), cameraZ));
			float3 cameraY = normalize(cross(cameraZ, cameraX));

			float px = dot(cameraPos, cameraX);
			float py = dot(cameraPos, cameraY);
			float pz = dot(cameraPos, cameraZ);

			float4x4 camera_matrix = float4x4(
				cameraX.x, cameraX.y, cameraX.z, -px,
				cameraY.x, cameraY.y, cameraY.z, -py,
				cameraZ.x, cameraZ.y, cameraZ.z, -pz,
				0, 0, 0, 1
				);

			float3 fixVal = float3(
				1
				,
			#ifdef _FIX_Y_ON
				0
			#else
				1
			#endif
				,
				1
				);

			//unity_ObjectToWorldからスケール成分だけ抜き取る

			float scaleX = length(float3(unity_ObjectToWorld[0].x, unity_ObjectToWorld[1].x, unity_ObjectToWorld[2].x));
			float scaleY = length(float3(unity_ObjectToWorld[0].y, unity_ObjectToWorld[1].y, unity_ObjectToWorld[2].y));

			float3 scale = float3(-scaleX, scaleY, 1);// *_Scale.w;

			#ifdef _LOOKINGCAMERA_ON
				o.pos = UnityObjectToClipPos(
					mul(unity_WorldToObject,
						mul(inverse(camera_matrix),
							mul(camera_matrix, float4(worldPos, 1))
							+ float4(fixVal * v.vertex * scale, 0)
						)
						+ v.vertex * float4((float3(1, 1, 1) - fixVal) * scale, 0)
					)
				);
			#else
				o.pos = UnityObjectToClipPos(v.vertex);
			#endif
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			UNITY_TRANSFER_FOG(o, o.pos);

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
			return animation(_MainTex, i.uv, dx, dy, current) * _Color;
		}
		ENDCG
		}
	}
	CustomEditor "ShaderGUIEditor"
}
