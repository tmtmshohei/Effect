Shader "Unlit/Explorsion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("NoiseTexture",2D) = "white" {}
   		_Threshold("Threshold", Range(0,1))= 0.0
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
			#pragma multi_compile_instancing

            #include "UnityCG.cginc"


            sampler2D _MainTex;
            sampler2D _NoiseTex;
            float4 _MainTex_ST;
			half _Threshold;
            float modulus = 61.0;



            //// ランダム数値生成器？
			    float2 mBBS(float2 val, float modulus) 
                {
                    val = fmod(val, modulus); // For numerical consistancy.
                    return fmod(val * val, modulus);
                }

                //// 事前に生成したノイズテクスチャからランダムにテクセルをフェッチ
                float mnoise(float3 pos,sampler2D nzw , float modulus, float2 uv)
                {
                    float intArg = floor(pos.z);
                    float fracArg = frac(pos.z);
                    float2 hash = mBBS(intArg * 3.0 + float2(0, 3), modulus);
                    float4 g = float4(tex2D(nzw, float2(uv.x, uv.y + hash.x) / modulus).xy,
                    tex2D(nzw, float2(uv.x, uv.y + hash.y) / modulus).xy) * 2.0 - 1.0;
                    return lerp(g.x + g.y * fracArg,
                                g.z + g.w * (fracArg - 1.0),
                                smoothstep(0.0, 1.0, fracArg));
                }

                const int octives = 4;
                const float lacunarity = 2.0;
                const float gain = 0.5;


                //// 雰囲気的にパーリンノイズ風？
                float turbulence(float3 pos , sampler2D nzw , float modulus,float2 uv) 
                {
                    float sum = 0.0;
                    float freq = 1.0;
                    float amp = 1.0;
                    for(int i = 0; i < octives; i++) 
                    {
                        sum += abs(mnoise(pos*freq , nzw , modulus , uv)) * amp;
                        freq *= lacunarity;
                        amp *= gain;
                    }
                    return sum;
                }

                const float magnatude = 1.3;
                //float time = _Time.y;


                //// 炎テクスチャからランダムにテクセルをフェッチ
                float4 sampleFire(float3 loc, float4 scale , sampler2D noise , float modulus ,  sampler2D fire , float2 uv ) 
                {
                    // Convert xz to [-1.0, 1.0] range.
                    loc.xz = loc.xz * 2.0 - 1.0;

                    // Convert to (radius, height) to sample fire profile texture.
                    float2 st = float2(sqrt(dot(loc.xz, loc.xz)), loc.y);

                    // Convert loc to 'noise' space
                    loc.y -= _Time.y * scale.w; // Scrolling noise upwards over time.
                    loc *= scale.xyz; // Scaling noise space.

                    // Offsetting vertial texture lookup.
                    // We scale this by the sqrt of the height so that things are
                    // relatively stable at the base of the fire and volital at the
                    // top.
                    //// turbulance = 乱流。おそらく参照点に揺らぎを加味してサンプルしている。
                    //// st.y == loc.y。st生成時にYは補正していない。意味的にはfire textureの高さ？
                    float offset = sqrt(st.y) * magnatude * turbulence(loc , noise , modulus , uv  );
                    st.y += offset;

                    // TODO: Update fireProfile texture to have a black row of pixels.
                    // 高さが1.0を超えた場合はblack pixelにする。
                    /*if (st.y > 1.0) 
                    {
                        return float4(0, 0, 0, 1);
                    }*/

                    //// 計算した結果のポイントをサンプリング。
                    float4 result = tex2D(fire, uv);

                    // Fading out bottom so slice clipping isnt obvious
                    /*if (st.y < .1) 
                    {
                        result *= st.y / 0.1;
                    }*/

                    return result;
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



                float3 color = sampleFire(i.vertex,float4(1.0, 2.0, 1.0, 0.5),_NoiseTex,modulus,_MainTex,i.uv).xyz;
				
                //float4 color = tex2D(_MainTex,i.uv);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return float4(color*1.5,1);
            }
            ENDCG
        }
    }
}
