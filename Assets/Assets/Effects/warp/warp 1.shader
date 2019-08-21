Shader "Unlit/warp"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_alpha ("alpha" , Range(0,1)) = 1  
		_gradation ("Gradation" , 2D) = "white" {}
		_Color ("Color" , Color) = (0.5,0.5,0,1)
		_alphacutout("AlphaCutOut" , Range(0,1)) =0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha
		//AlphaTest Greater [_alphacutout]


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
			float _alpha;
			sampler2D _gradation;
			float4 _Color;
			float _alphacutout;
			
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
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 grad = tex2D(_gradation , i.uv);
				
				//grad.rgb *=-1;
				//grad = Tobinary(0.1f , grad);
				grad.a =step(_alphacutout,1-grad.r);
				grad.rgb = _Color.rgb;
				grad.a *=_Color.a;
				//grad *=0.5;
				
				//grad.a *= _alpha;
				col.a *= _alpha;
				col.a =	 1-grad.a;
				col += grad;
				//grad.a = grad.r;
				//clip(grad.a - _alphacutout);
				
				

				//_Color *= grad;
				//col +=_Color;
				

				
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
