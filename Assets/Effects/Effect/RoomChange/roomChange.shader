Shader "Unlit/roomChange"
{
    Properties
    {
        _MainTex ("room01", 2D) = "white" {}
        _tex2("room2",2D) = "white"{}
        _thtex("ThresholTexture",2D) = "white"{}
        _dir("thDirection",2D) = "white"{}
        _bcol("noiseColor",2D) = "white"{}
        _bcol2("noiseColor2",2D) = "white"{}
        _th("Threshold",Range(0,1)) = -0
        _upoffset("upoffset",Range(0,0.2)) = 0.06
        _downoffset("downoffset",Range(0,0.2)) = 0.1
        _intensity("Intensity",Float) = 3.5
    }
    
    SubShader
    {
        //Tags { "RenderType"="Opaque" }
        Tags { "RenderType"="Transparent"  "Queue" = "Transparent-2" }
        LOD 100
        Blend One OneMinusSrcAlpha
        Zwrite off
        // Ztest off

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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _tex2;
            float _th;
            sampler2D _thtex;
            sampler2D _dir;
            sampler2D _bcol;
            sampler2D _bcol2;
            int _divon;
            float _downoffset;
            float _upoffset;
            float _intensity;
            float _Strength;

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

                fixed4 room1 = tex2D(_MainTex, i.uv);
                fixed4 room2 = tex2D(_tex2,i.uv);
                fixed4 thtex = tex2D(_thtex,i.uv);
                fixed4 dir = tex2D(_dir,i.uv);
                fixed4 bcol = tex2D(_bcol,i.uv);
                fixed4 bcol2 = tex2D(_bcol2,i.uv);

                _th *=1+_downoffset;
                dir *= thtex;
                fixed4 col = step(dir.x,_th);
                float4 col2 = step(dir.x,_th-_downoffset);
                float4 col3 = step(dir.x,_th-_upoffset);
                float4 down = col-col2;
                float4 up = col-col3;
                down -= up;
                down *= bcol2;
                up   *= bcol*room1*_intensity;
                col2 *=room2;
                col = 1-col;
                col *=room1;
                col = col+up+col2+down;               
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
