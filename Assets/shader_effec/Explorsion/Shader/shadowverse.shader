Shader "Unlit/shadowverse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Mask ("Mask", 2D)  = "white" {}
        _Noise ("Noise", 2D) = "white" {}
        _Firegrade ("Firegrade", 2D) = "white" {}
        _Wave1 ("wave1", 2D) = "white" {}
        _Wave2 ("wave2", 2D) = "white" {}
        _Wavegrade ("wavegrade" , 2D) = "white"{}
 
        _Threshold("Threshold", Range(0,1))= 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent"  "Queue" = "Transparent"}
        LOD 100

        Pass
        {
            //Blend One One   
            //ZWrite off
            //Ztest GEqual
            Blend SrcAlpha OneMinusSrcAlpha
            //Blend SrcAlpha DstAlpha
            //cull off
  		  
        
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            

            #include "UnityCG.cginc"

            float rand(float co){
            return frac(sin(dot(co ,float2(12.9898,78.233))) * 43758.5453);
            }

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
            sampler2D _Mask;
            sampler2D _Noise;
            sampler2D _Firegrade;
            sampler2D _Wave1;
            sampler2D _Wave2;
            sampler2D _Wavegrade;
            half _Threshold;

            v2f vert (appdata v)
            {
                v2f o;      //0.03
                //float ampy = rand(0.1*(sin(abs(_Time*100 + v.vertex.y * 10))));
                //float ampx = 0.1*(cos(abs(_Time*10 + v.vertex.y * 10)));
                //v.vertex.xyz = float3(v.vertex.x+ampx, v.vertex.y+ampy, v.vertex.z);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                //o.uv.y *= (frac(_Time.y/2))+2
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                // sample the texture
                fixed4 base = tex2D(_MainTex, i.uv);//*float4(1.0,1.0,1.0,1.0);
                fixed4 mask = tex2D(_Mask, i.uv);//*float4(1.0,1.0,1.0,1.0);
                fixed4 noise = tex2D(_Noise , i.uv-(abs(_Time.y/10)));//*float4(1.0,1.0,1.0,1.0);
                fixed4 firegrade = tex2D(_Firegrade , i.uv);//float2(i.uv.x+((_Time.y)),i.uv.y-(_Time.y)));
                //fixed4 wave = tex2D(_Wave , float2(i.uv.x+((_Time.y*2)/9),i.uv.y-(_Time.y/2)));
                fixed4 wave1 = tex2D(_Wave1, float2(i.uv.x+((_Time.y/2)/10),i.uv.y-(_Time.y*0.7)));
                fixed4 wave2 = tex2D(_Wave2, float2(i.uv.x+((_Time.y/2)/10),i.uv.y-(_Time.y*0.5)));
                fixed4 wavegrade = tex2D(_Wavegrade , i.uv);
                float4 mixwave = float4(float3(wave1.rgb * wave2.rgb),1);
                _Threshold = (sin(abs(_Time.y*10))+1);
                mixwave = float4(mixwave.rgb + (wavegrade.rgb*1),1);
                //mixwave = Tobinary(mixwave,0.8);




                float3 maskcolor = mask.rgb * (noise.rgb*(_Threshold));
                float3 basecolor = base.rgb + (maskcolor.rgb*_Threshold);
                float3 wavecolor = mixwave.rgb * (firegrade.rgb);
                wavecolor = Tobinary(float4(float3(wavecolor.rgb),0.6),0.1);
                float3 color = basecolor.rgb * (wavecolor.rgb);

                if(color.r < 0.1){discard;}
                

                


                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                //return float4(wavecolor,1);
                //return  base  ;
                return float4(color.rgb,1);
            }
            ENDCG
        }
    }
}
