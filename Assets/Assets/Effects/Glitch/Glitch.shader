Shader "Unlit/Glitch"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_brightness("Brightness",Float) = 1
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

			


			float rand(float2 co) 
			{
				return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
			}

			float Posterize(float In, float Steps)
			{
				return floor(In / (1 / Steps)) * (1 / Steps);
			}

			float Glith(float2 uv)
			{
				float x = 0.5;
				float y = Posterize((rand(float2(fmod(_Time.y,10),6))),300);
				float mulseed = sin(Posterize(_Time, 2) * 10);

				float stepy = step(y + 0.2,uv.y);
				float stepy2 = step(y,uv.y);
				float stepy3 = step(y + 0.3, uv.y);
				float stepy4 = step(y, uv.y);

				float stepx = step(x + 0.2, uv.x);
				float stepx2 = step(x, uv.x);


				float stepxsubst = (stepx*mulseed) - (stepx2*mulseed);
				float stepysubst = (stepy*mulseed) - (stepy2*mulseed);
				float stepysubst2 = (stepy3*mulseed) - (stepy4*mulseed);
				stepysubst = lerp(stepysubst, stepysubst2, fmod(_Time.y,100));


				return uv.x += stepysubst;
				//return float2(uv.x, 0);
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
			float _brightness;
			
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
				i.uv.x = Glith(i.uv);
				
				float4 col = (1).xxxx;
				float colnoise = Posterize(rand(float2(fmod(1, 10),1)),24)*0.05;
				col.r = tex2D(_MainTex, i.uv);
				col.g = tex2D(_MainTex, float2(i.uv.x+colnoise,i.uv.y));
				col.b = tex2D(_MainTex, float2(i.uv.x-colnoise,i.uv.y));
				
					
			
				return col*_brightness;//(stepysubst).xxxx;
			}
			ENDCG
		}
	}
}
