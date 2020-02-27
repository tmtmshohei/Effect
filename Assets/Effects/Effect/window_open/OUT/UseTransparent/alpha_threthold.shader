Shader "Unlit/alpha_threthold"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _th("threthold",Range(0,1.3)) = 1.0
        _heighlight("HeighLight",2D)="white"{}
        _Tex2("Tex2",2D) = "white"{}

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry" }
        //Tags { "RenderType"="Trasparent" "Queue" = "Transparent" }
        LOD 100
        //Blend SrcAlpha OneMinusSrcAlpha

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float2 nuv :TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _alpha;
            float _th;
            sampler2D _heighlight;
            sampler2D _Tex2;
            sampler2D _noise;
            sampler2D _dir;
            float _th2;
            float4 _noise_ST;
            sampler2D _test;

            v2f vert (appdata v)
            {       
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.nuv = TRANSFORM_TEX(float2(v.uv.x*_th,v.uv.y),_noise);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 heighlight = tex2D(_heighlight, i.uv);
                fixed4 col2 = tex2D(_Tex2,i.uv);
                

                
                col = heighlight;
                col = tex2D(_MainTex, i.uv);
                col2 = tex2D(_Tex2,i.uv);
                if(_th<i.uv.x) col = col2;
                return col;

                
            }
            ENDCG
        }
    }
}
