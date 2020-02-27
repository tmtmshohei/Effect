Shader "Unlit/Unlit_VAT_HexWarp"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_boundingMax("Bounding Max", Float) = 1.0
		_boundingMin("Bounding Min", Float) = 1.0
		_numOfFrames("Number Of Frames", int) = 240
		_speed("Speed", Float) = 0.33
		_speedratio("Speed Ratio",Float) = 1 
		_posoffset("Pos Offset",Range(0,1)) = 0
		[MaterialToggle] _pack_normal ("Pack Normal", Float) = 0
		_posTex ("Position Map (RGB)", 2D) = "white" {}
		_nTex ("Normal Map (RGB)", 2D) = "grey" {}
		
			[HideInInspector]
			[Enum(UnityEngine.Rendering.BlendMode)]
				_SrcBlend("Src Factor", Float) = 1
			[HideInInspector]
			[Enum(UnityEngine.Rendering.BlendMode)]
				_DstBlend("Dst Factor", Float) = 0
			[KeywordEnum(Geometry, Transparent)] _Overlay("Rendering mode", Float) = 0
			[Enum(UnityEngine.Rendering.CullMode)]_Cullingmode("Cullingmode",Float) = 2
			[KeywordEnum(Off, On)] _ZWrite("ZWrite",Float) = 1
			[Toggle]_AUTOANIMATION("AutoAnimation",Float) = 0

					_inside("inside", 2D) = "white" {}
				_outside("outside", 2D) = "white" {}
				_outline("outline", 2D) = "white" {}
				_col("Color" , Color) = (1,1,1,1)

					_linecol("OutlineColor",Color) = (1,1,1,1)
					_threshold("Threshold",Float) = 0
					_inputtime("InputTime" , Range(0.029,1)) = 0
			
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" = "Geometry"  "IgnoreProjector" = "True"  }
		LOD 200
		//ZWrite Off Blend One One
					Blend[_SrcBlend][_DstBlend]
					Cull[_Cullingmode]
					ZWrite[_ZWrite]

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			#pragma target 3.0
			#pragma shader_feature _AUTOANIMATION_ON
			
			#include "UnityCG.cginc"

			float rand(float co)
			{
				return frac(sin(dot(co.x ,(12.9898,78.233))) * 43758.5453);
			}


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 vat : TEXCOORD1;
				float3 normal :NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 vat : TEXCOORD1;
				UNITY_FOG_COORDS(2)
					//float4 vertex : SV_POSITION;
					float3 normal : TEXCOORD3;
				UNITY_POSITION(vertex);
				UNITY_VERTEX_OUTPUT_STEREO
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _posTex;
			sampler2D _nTex;
			uniform float _pack_normal;
			uniform float _boundingMax;
			uniform float _boundingMin;
			uniform float _speed;
			uniform int _numOfFrames;
			half _Glossiness;
			half _Metallic;
			fixed4 _Color;
			float _speedratio;
			float _posoffset;
			float _inputtime;



			float4 _col;
			float _threshold;
			sampler2D _inside;
			sampler2D _outside;
			sampler2D _outline;
			float4 _linecol;

			void vert_vat(inout appdata v){
			//calcualte uv coordinates
			#ifdef _AUTOANIMATION_ON
				float timeInFrames = ((ceil(frac(-_Time.y * _speed*_speedratio) * _numOfFrames))/_numOfFrames) + (1.0/_numOfFrames);
			#else
				float timeInFrames = ((ceil(frac(-_inputtime) * _numOfFrames))/_numOfFrames) + (1.0/_numOfFrames);
			#endif
			

			//get position and normal from textures
			float4 texturePos = tex2Dlod(_posTex,float4(v.vat.x, (timeInFrames + v.vat.y + _posoffset), 0, 0));
			float3 textureN = tex2Dlod(_nTex,float4(v.vat.x, (timeInFrames + v.vat.y + _posoffset ), 0, 0));

			//expand normalised position texture values to world space
			float expand = _boundingMax - _boundingMin;
			texturePos.xyz *= expand;
			texturePos.xyz += _boundingMin;
			texturePos.x *= -1;  //flipped to account for right-handedness of unity
			v.vertex.xyz += texturePos.xzy;  //swizzle y and z because textures are exported with z-up

			//calculate normal
			/*if (_pack_normal){
				//decode float to float2
				float alpha = texturePos.w * 1024;
				float2 f2;
				f2.x = floor(alpha / 32.0) / 31.5;
				f2.y = (alpha - (floor(alpha / 32.0)*32.0)) / 31.5;

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
			}*/
		}
			
			v2f vert (appdata v)
			{
				//UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				//UNITY_INITIALIZE_OUTPUT(v2f,o);
				//UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				vert_vat(v);
				
				
				//return v;
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				
				
				
				
				return o;
			}
			
			fixed4 frag (v2f i, fixed facing : VFACE) : SV_Target
			{
				_threshold = sin(_Time.y);
				// sample the texture
				//fixed4 col = tex2D(_MainTex, i.uv)*_Color;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				//return float4(i.normal.y, 0, 0, 1);
			fixed4 col = tex2D(_MainTex, i.uv);
			//col.a = i.vcolor.a + 1;
			col.xy = lerp(col.xy, float2(_threshold, _threshold), i.normal);
			//col.xy = lerp((_threshold-1).xx, (_threshold).xx, i.normal);
			//float2 n = float2(i.normal.y,i.normal.y) * _threshold;
			col.z = 0;
			
			//return col;
			fixed4 inside = tex2D(_inside, col.rg);
			fixed4 outside = tex2D(_outside, col.rg);
			fixed4 outline = tex2D(_outline, i.uv);

			col = lerp(inside, outside, facing);
			//col = outside;
			col += outline * _linecol * 3;

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
	//CustomEditor "ShaderGUIEditor"
}
