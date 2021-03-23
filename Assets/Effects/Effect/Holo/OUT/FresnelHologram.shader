Shader "Unlit/FresnelHolo"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _hololine("HologramLine",2D) = "white" {}
        _hnoise("Noise",2D) = "white"{}
        _innercolor("InnerColor",Color)=(1,1,1,1)
        _Color("RimColorS",Color)=(1,1,1,1)
        _inerintensity("InerColorIntensity",Float) = 1
        _F0("_F0",Range(0,1.0)) = 0.1  //入射角が0度の時の反射率
        _reflimit("反射率上限",Float)=1
        _repetition("乗算回数",Float) = 5
        [Toggle]_USENOISE("UseNoise",Int) = 0
        _noisecolor("NoiseColor",Color) = (1,1,1,1)
        _noiseintensity("NoiseIntensity",Float)=1       

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        //Blend SrcAlpha one
        Blend SrcAlpha OneMinusSrcAlpha
        Zwrite off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog
            #pragma  shader_feature _USENOISE_ON

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float2 holouv : TEXCOORD2;
                float3 worldnormal : TEXCOORD3;
                float3 codot : TEXCOORD4;
                float2 noiseuv:TEXCOORD5;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _hololine;
            float4 _hololine_ST;
            float4 _Color;
            sampler2D _hnoise;
            float4 _hnoise_ST;
            float _F0;
            float4 _noisecolor;
            float _repetition;
            float4 _innercolor;
            float _reflimit;
            float _noiseintensity;
            float _inerintensity;


            v2f vert (appdata v)
            {
                float3 screenpos = UnityObjectToViewPos(v.vertex).xyz;

                v2f o;
                float d = tex2Dlod(_hnoise, float4(v.uv.xy,0,0)).r;
                //v.vertex.x+=d*sin(_Time.y*10)*0.3;
                //v.vertex.z+=d*sin(_Time.y*10)*0.3;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.holouv = TRANSFORM_TEX(screenpos.xy,_hololine);
                //o.holouv = TRANSFORM_TEX(v.uv,_hololine);
                o.holouv.y -= _Time.y;
                o.noiseuv = TRANSFORM_TEX(v.uv,_hnoise);
                o.noiseuv -= _Time.y;
                o.worldnormal = UnityObjectToWorldNormal(v.normal);
                float3 ViewDir = normalize(ObjSpaceViewDir(v.vertex));
                o.codot = normalize(dot(ViewDir,o.worldnormal));
                //o.codot = (normalize(o.codot)*0.5)+0.2;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 holo = tex2D(_hololine,i.holouv);
                half fresnel = _F0 + (_reflimit - _F0) * pow(1.0 - i.codot, _repetition);//フレネル反射近似値
                float4 rimcol = fresnel*_Color; 
                col = (1-fresnel)*_innercolor*holo*_inerintensity;     
                col+= rimcol; 
                fresnel = (fresnel);
                return (i.codot,i.codot.x);
                col.a = fresnel;
                #ifdef _USENOISE_ON
                    fixed4 noise = tex2D(_hnoise,i.noiseuv);
                    col.rgb += noise*_noisecolor*_noiseintensity;
                    //col.a += noise;
                #endif
                
                
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
