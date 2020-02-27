Shader "Unlit/Unlit_Worldiconvat"
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
			fixed4 _Color;
			float _speedratio;
			float _posoffset;

			void vert_vat(inout appdata v){
			//calcualte uv coordinates
			float timeInFrames = ((ceil(frac(-_Time.y * _speed*_speedratio) * _numOfFrames))/_numOfFrames) + (1.0/_numOfFrames);//((ceil(frac(-_Time.y * _speed*_speedratio) * _numOfFrames))/_numOfFrames) + (1.0/_numOfFrames);

			//get position and normal from textures
			float4 texturePos = tex2Dlod(_posTex,float4(v.vat.x, (timeInFrames + v.vat.y + _posoffset), 0, 0));
			float3 textureN = tex2Dlod(_nTex,float4(v.vat.x, (timeInFrames + v.vat.y + _posoffset ), 0, 0));

			//expand normalised position texture values to world space
			float expand = _boundingMax - _boundingMin;
			texturePos.xyz *= expand;
			texturePos.xyz += _boundingMin;
			texturePos.x *= -1;  //flipped to account for right-handedness of unity
			v.vertex.xyz += texturePos.xzy;  //swizzle y and z because textures are exported with z-up
		}
			
			v2f vert (appdata v)
			{
				//UNITY_SETUP_INSTANCE_ID(v);
				v2f o;
				//UNITY_INITIALIZE_OUTPUT(v2f,o);
				//UNITY_TRANSFER_INSTANCE_ID(v,o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				vert_vat(v);				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv)*_Color;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
