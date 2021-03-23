Shader "Unlit/uvDistortion"
{
    Properties
    {
        //_Color("Color",color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _noise("NoiseTex",2d) = "white" {}
        _gradation("GradationTex",2d) = "white" {}
        _noiseStrength("NoiseStrength",vector) =(0.5,0.5,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite off
        //Cull off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color :COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 color :COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _noise;
            sampler2D _gradation;
            //float4 _Color;
            float4 _noiseStrength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed2 distUV = (i.uv+tex2D(_noise,i.uv).r);
                distUV *= _noiseStrength.xy;
                fixed4 gradation = tex2D(_gradation,i.uv);
                //distUV.x+=_Time.x;
                fixed4 col = tex2D(_MainTex, distUV)*i.color;//*_Color;
                col.a *= gradation.x;
                
                return col;
            }
            ENDCG
        }
    }
}
