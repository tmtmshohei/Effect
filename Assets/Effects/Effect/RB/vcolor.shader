Shader "Unlit/vcolor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _color ("MainColor",Color) = (1,1,1,1)
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
            #pragma multi_compile_fog

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

            v2f vert (appdata v)
            {
                v2f o;
                v.vertex = frac(_Time.y*0.65) * v.vertex;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.vcol = v.vcol;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, float2(i.uv.x,i.uv.y-_Time.y));
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                //col.a = col.r*i.vcol.a*_color.a;
                col *= i.vcol*_color*1.5;
                return col;
            }
            ENDCG
        }
    }
}
