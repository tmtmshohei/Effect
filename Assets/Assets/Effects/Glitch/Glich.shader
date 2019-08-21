Shader "Unlit/Glich"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("NoiseTexture" , 2D) = "white" {}
		_Threshold ("Threshold" , Float) = 0
		_Binarythreshold("Binarythreshold" , Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent"  "Queue" = "Transparent" }
		Blend One  OneMinusSrcColor 
		
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			
			#include "UnityCG.cginc"

			float4 Tobinary(float4 noise,float threshold)
            {
                float noiser = (step(threshold,noise.r));
                float noiseg = (step(threshold,noise.g));
                float noiseb = (step(threshold,noise.b));

                return float4(noiser,noiseg,noiseb,noise.a);
            }

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
			sampler2D _NoiseTex;
			float _Threshold;
			float _Binarythreshold;
			
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

				float2 resolution = _ScreenParams;
				float2 pos = (i.uv  *resolution/ resolution.xy);
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 col2 = fixed4(0.0 , 0.0 , 0.1 ,1);
				fixed4 noise = tex2D(_NoiseTex , i.uv);
				noise = Tobinary(noise,_Binarythreshold);
				
				col2 *= noise;
				
			
				//col += col2;

				fixed4 spritcol ;
				float2 pos2 ;
				if(i.uv.x <0.5)
				{
					pos2 = i.uv;
				}

				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				spritcol = tex2D(_MainTex,pos2);
				return spritcol	;

				//return col2;
			}
			ENDCG
		}
	}
}
