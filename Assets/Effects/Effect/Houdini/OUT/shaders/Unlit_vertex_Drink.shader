Shader "Unlit/Unlit_vertex_Drink"
{
	Properties
	{
		[KeywordEnum(Opaque, Transparent)] _Overlay("Rendering mode", Float) = 0
		_Color ("Color", Color) = (1,1,1,1)
		_hColor ("hColor", Color) = (1,1,1,1)
		_alpha("Alpha",Range(0,1)) = 1
		//_MainTex ("Albedo (RGB)", 2D) = "white" {}
		[HideInInspector]_boundingMax("Bounding Max", Float) = 1.0
		[HideInInspector]_boundingMin("Bounding Min", Float) = 1.0
		_numOfFrames("Number Of Frames", int) = 240
		[MaterialToggle] _pack_normal ("Pack Normal", Float) = 0
		_posTex ("Position Map (RGB)", 2D) = "white" {}
		_nTex ("Normal Map (RGB)", 2D) = "grey" {}
		_colorTex ("Colour Map (RGB)", 2D) = "white" {}
		//_glow("Glow", 2D) = "white"{}
		_inputtime("InputTime" , Range(0,1)) = 0
		_inputtime_offset("InputTime_Offset",Range(-1,1)) = 0

			//[HideInInspector]
			[Enum(UnityEngine.Rendering.BlendMode)]
				_SrcBlend("Src Factor", Float) = 1
			//[HideInInspector]
			[Enum(UnityEngine.Rendering.BlendMode)]
				_DstBlend("Dst Factor", Float) = 0
			
			[Enum(UnityEngine.Rendering.CullMode)]_Cullingmode("Cullingmode",Float) = 2
			[KeywordEnum(Off, On)] _ZWrite("ZWrite",Float) = 1
			[Toggle]_AUTOANIMATION("AutoAnimation",Float) = 0
			_speed("AutoSpeed", Float) = 0.33

	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent"   }
		LOD 100
		Blend[_SrcBlend][_DstBlend]
		Cull[_Cullingmode]
		ZWrite[_ZWrite]

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			//#pragma multi_compile_fog
			#pragma shader_feature _AUTOANIMATION_ON
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 vat : TEXCOORD1;
				float4 color : COLOR;
				float3 normal :NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 vat : TEXCOORD1;
				//UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
				float3 normal : TEXCOORD3;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			//sampler2D _MainTex;
			sampler2D _posTex;
			sampler2D _nTex;
			sampler2D _colorTex;
			uniform float _pack_normal;
			uniform float _boundingMax;
			uniform float _boundingMin;
			uniform float _speed;
			uniform int _numOfFrames;
			//sampler2D _glow;
			//float4 _MainTex_ST;
			float4 _Color;
			float _inputtime;
			float _inputtime_offset;
			float4 _hColor;
			float  _alpha;


			void vert_vat(inout appdata v){
			//calculate uv coordinates
			_inputtime = smoothstep(_inputtime_offset,1,_inputtime);//アニメーションのスタート位置がずれることがあるので、オフセット可能なように
			#ifdef _AUTOANIMATION_ON
				float timeInFrames = ((ceil(frac(-_Time.y * _speed) * _numOfFrames))/_numOfFrames) + (1.0/_numOfFrames);
			#else
				float timeInFrames = ((ceil(frac(-_inputtime) * _numOfFrames)) / _numOfFrames) + (1.0 / _numOfFrames);
			#endif
			//get position, normal and colour from textures
			float4 texturePos = tex2Dlod(_posTex,float4(v.vat.x, (timeInFrames + v.vat.y), 0, 0));
			float3 textureN = tex2Dlod(_nTex,float4(v.vat.x, (timeInFrames + v.vat.y), 0, 0));
			float3 textureCd = tex2Dlod(_colorTex,float4(v.vat.x, (timeInFrames + v.vat.y), 0, 0));

			//expand normalised position texture values to world space
			float expand = _boundingMax - _boundingMin;
			texturePos.xyz *= expand;
			texturePos.xyz += _boundingMin;
			texturePos.x *= -1;  //flipped to account for right-handedness of unity
			v.vertex.xyz = texturePos.xzy;  //swizzle y and z because textures are exported with z-up

			//calculate normal
			if (_pack_normal){
				//decode float to float2
				float alpha = texturePos.w * 1023;
				float2 f2;
				f2.x = floor(alpha / 32.0) / 31.0;
				f2.y = (alpha - (floor(alpha / 32.0)*32.0)) / 31.0;
			
				//decode float2 to float3
				float3 f3;
				f2 *= 4;
				f2 -= 2;
				float f2dot = dot(f2,f2);
				f3.xy = sqrt(1 - (f2dot/4.0)) * f2;
				f3.z = 1 - (f2dot/2.0);
				f3 = clamp(f3, -1.0, 1.0);
				f3 = f3.xzy;
				f3.x *= -1;
				v.normal = f3;
			} else {
				textureN = textureN.xzy;
				textureN *= 2;
				textureN -= 1;
				textureN.x *= -1;
				v.normal = textureN;
			}

			//set vertex colour
			v.color.rgb = textureCd;
		}
			
			v2f vert (appdata v)
			{
				v2f o;
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				vert_vat(v);
				o.color = v.color;
				o.vertex = UnityObjectToClipPos(v.vertex);
				//o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float3 fakelight = float3(0.3,0,0.3);
				o.normal = v.normal;
				o.normal = dot(o.normal,fakelight);
				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = fixed4(1,1,1,1);//tex2D(_MainTex, i.uv)*_Color;
				col.rgb = col.rgb * i.normal;
				float4 hcol = _hColor;
				hcol.rgb  =hcol.rgb * (1-i.normal);
				col.rgb += hcol.rgb;
				col.a = _alpha;
				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
	CustomEditor "DrinkShaderGUI"
}
