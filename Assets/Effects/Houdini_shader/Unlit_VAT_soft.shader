Shader "Unlit/Unlit_VAT_soft"
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
		_inputtime ("InputTime" , Range(0.1,1)) =0
		_threshold ("Threshold" , Range(0,1))=0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
		LOD 200
		ZWrite Off
		//Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			#pragma target 3.0
			
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
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 vat : TEXCOORD1;
				UNITY_FOG_COORDS(2)
				//float4 vertex : SV_POSITION;
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
			float _threshold;


			void vert_vat(inout appdata v){
			//calcualte uv coordinates
			//_inputtime = sin((_Time.y*0.5));
			float timeInFrames = ((ceil(sin(frac(-_inputtime)) * _numOfFrames))/_numOfFrames) + (1.0/_numOfFrames);//((ceil(frac(-_Time.y * _speed*_speedratio) * _numOfFrames))/_numOfFrames) + (1.0/_numOfFrames);

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
				
				
				
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv)*_Color;
				//col *= _threshold*5;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
