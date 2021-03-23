Shader "Unlit/Portal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",color)=(1,1,1,1)
        _Vortex("Vortex",2d) = "white"{}
        _Distortion("Distortion",2d) = "white"{}
        _highlight("Highlight",2d) = "white"{}
    }
    SubShader
    {
        //Tags { "RenderType"="Opaque" }
        //LOD 100
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite off

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
                float4 color :COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 color :COLOR;
                float2 vortexuv : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            sampler2D _Vortex;
            sampler2D _highlight;
            sampler2D _Distortion;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.color = v.color;

                float2 pivot = float2(0.5, 0.5);
                // Rotation Matrix
                float _Angle = radians(_Time.y*100%360);
                float cosAngle = cos(_Angle);
                float sinAngle = sin(_Angle);
                float2x2 rot = float2x2(cosAngle, -sinAngle, sinAngle, cosAngle);

                // Rotation consedering pivot
                float2 uv = v.uv.xy - pivot;
                o.vortexuv = mul(rot, uv);
                o.vortexuv += pivot;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 distortion = tex2D(_Distortion,float2(i.uv.x,i.uv.y+_Time.y*0.25));
                float4 vortex = tex2D(_Vortex,i.vortexuv);
                float2 vortexuv = i.uv;
                float2 distortionuv = i.uv;

                distortion = distortion*0.1;
                distortion.x = 0;
                vortexuv +=vortex;
                distortionuv +=distortion;

                //下二行必要であればコメントアウト
                float seed = sin(0.25*radians(_Time.y*55)); //35
                vortexuv = lerp(vortexuv,i.uv,(seed+9)/10);//sin(_Time.y*0.5)+0.25   //lerpの3つ目にseedだけ入れると回転が強すぎるので0.8~1の間にクランプ
                distortionuv = (distortionuv + vortexuv)*0.5;

                fixed4 col = tex2D(_MainTex, distortionuv);                
                fixed4 highlight = tex2D(_highlight,vortexuv);
                col += highlight;
                col*=_Color*1.4;        
                col.a = i.color.a;
                return col;
            }
            ENDCG
        }
    }
}
