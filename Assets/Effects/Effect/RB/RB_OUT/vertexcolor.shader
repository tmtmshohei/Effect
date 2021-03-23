Shader "Unlit/simplevertexcolor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _color ("MainColor",Color) = (1,1,1,1)
        _timespeed("Speed",Float) = 1
        _colintensity("ColorIntensity",Float) = 1
        _alphaadd("AlphaAdd",Float) = 0
        [Toggle]_VERTEXSCALING("UseVertexScaling",Int) = 0
        [Toggle]_FADEOUT("UseFadeOut",Int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        Cull off
        Zwrite off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog
            #pragma shader_feature _VERTEXSCALING_ON
            #pragma shader_feature _FADEOUT_ON

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 vcol : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 vcol : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _color;
            float _timespeed;
            float _colintensity;
            float _alphaadd;

            v2f vert (appdata v)
            {
                v2f o;
                #ifdef _VERTEXSCALING_ON
                    v.vertex = frac(_Time.y*_timespeed) * v.vertex;
                #endif
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.vcol = v.vcol;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = i.vcol*_color*_colintensity;
                #ifdef _FADEOUT_ON
                    col.a = col.a+_alphaadd - frac(_Time.y*_timespeed);
                #endif
                return col;
            }
            ENDCG
        }
    }
}
