Shader "Unlit/spaceNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _noise("Noise",2D) = "white" {}
        _gradation("Gradation",2D) = "white" {}
        _gradation2("Gradation2",2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        cull off

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
				float mulseed = sin(Posterize(_Time.y, 2) * 10);

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
                float2 uv2 : TEXCOORD2;
                float2 uv3 : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _noise;
            sampler2D _gradation;
            float4 _noise_ST;
            float4 _gradation_ST;
            sampler2D _gradation2;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = TRANSFORM_TEX(v.uv,_noise);
                o.uv3 = TRANSFORM_TEX(v.uv,_gradation);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                i.uv.x = Glith(i.uv);
                i.uv2.x = Glith(i.uv2);
                i.uv3.x = Glith(i.uv3);
                float2 uv = i.uv;
                float2 uv2 = i.uv2;
                float2 uv3 = i.uv3;
                uv2+=frac(_Time.y*0.5);
                uv3.x += frac(sin(_Time.y))*0.2;
                uv3.y -= frac(cos(_Time.y))*0.1;
                float timeSeed =frac(_Time.y);
                timeSeed = sin(radians(timeSeed))*40;
                //uv.x+=timeSeed;
                fixed4 col = tex2D(_noise, uv);
                fixed4 noise = tex2D(_noise,uv2);
                float4 gradation = tex2D(_gradation,uv);
                float4 gradation2 = tex2D(_gradation2,uv);
                float4 gradation3 = tex2D(_gradation,uv3);
                float4 gradation5 = tex2D(_gradation,float2((uv3.x-0.15)*frac(_Time.x)*2,uv3.y-0.15));
                float4 maintex = tex2D(_MainTex,uv);
                
                //return gradation5;
                col*=noise;
                //gradation3*=col;
                float4 gradation4 = (1-gradation)*col;
                //return gradation4;
                gradation+=gradation3;
                gradation+=gradation5;
                gradation-=gradation4;
                
                gradation4 = gradation3*col;
                gradation+=gradation4;
                gradation = round(gradation);
                gradation *=gradation2;
                gradation = 1-step(gradation,0);
                if(gradation.x<0.01)discard;
                maintex*= gradation;
                return maintex;
                gradation*=gradation2;
                
                col=gradation;
                
                if(col.x>0.1)col=1;
                else col=0;
                return col;
                //noise+=col;
                
                noise+=0.4; 
                noise= round(noise*gradation);
                //return noise;
                float4 mix = col*noise;
                mix = round(mix+0.5);
                
                if(mix.x<0.1) discard;
                return mix;
                
                

                uv = (uv*2)-1;
                
                uv = distance(uv,0);
                uv = 1-uv;
                uv*=noise;
                
                return uv.x;

                float4 yoko = floor(uv2.x*10)*0.1;
                float4 tate = floor(uv2.y*10)*0.1;//+frac(_Time.y);
                return tate+uv.x;
                
                col = tate*yoko;
                // apply fog
                if(noise.g>0.25) discard;
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
