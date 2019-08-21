Shader "Unlit/DitherTransparent"
{
   Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _DitherTex ("Dither Pattern (R)", 2D) = "white" {}
        _Alpha ("Alpha", Range(0.0, 1.0)) = 1.0
    }
    SubShader {
        Tags { "RenderType"="Opaque" }

        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex: POSITION;
                float2 texcoord: TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 clipPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DitherTex;
            float _Alpha;

            v2f vert (appdata v) {
                v2f o = (v2f)0;
                o.pos = UnityObjectToClipPos(v.vertex);

                // クリップ座標を求める
                o.clipPos = UnityObjectToClipPos(v.vertex);

                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            float4 frag (v2f i): COLOR {
                float4 color = tex2D(_MainTex, i.uv);

                // クリップ座標からビューポート座標を求める
                float2 viewPortPos = i.clipPos.xy / i.clipPos.w * 0.5 + 0.5;

                // スクリーン座標を求める
                float2 screenPos = viewPortPos * _ScreenParams.xy;

                // ディザリングテクスチャ用のUVを作成
                float2 ditherUv = screenPos / 4;

                float dither = tex2D(_DitherTex, ditherUv).r;
                clip(_Alpha - dither);

                return color;
            }
            ENDCG
        }
    }
}
