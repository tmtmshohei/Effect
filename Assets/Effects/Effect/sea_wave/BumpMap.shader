Shader "ambr/BumpMap" {
    Properties {
        _Color ("Color", Color) = (1,1,1,1)
        _BumpMap ("Bump map", 2D) = "bump" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM

            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _BumpMap;

            fixed4 _Color;

            // 接空間へ変換する行列を生成する
            // ※ 接空間からローカル空間への変換の逆行列で、ローカルのライトを接空間に変換する
            float4x4 InvTangentMatrix(float3 tan, float3 bin, float3 nor)
            {
                float4x4 mat = float4x4(
                float4(tan, 0),
                float4(bin, 0),
                float4(nor, 0),
                float4(0, 0, 0, 1)
                );

                // 正規直交系行列なので、逆行列は転置行列で求まる
                return transpose(mat);
            }

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 lightDir : TEXCOORD2;
            };

            v2f vert(appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.uv = v.texcoord;

                // ローカル空間上での接空間ベクトルの方向を求める
                float3 n = normalize(v.normal);
                float3 t = v.tangent;
                float3 b = cross(n, t);

                // ワールド位置にあるライトをローカル空間へ変換する
                float3 localLight = mul(unity_WorldToObject, _WorldSpaceLightPos0);

                // ローカルライトを接空間へ変換する（行列の掛ける順番に注意）
                o.lightDir = mul(localLight, InvTangentMatrix(t, b, n));

                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float3 normal = float4(UnpackNormal(tex2D(_BumpMap, i.uv)), 1);
                float3 light = normalize(i.lightDir);
                float diff = max(0, dot(normal, light));
                return diff * _Color;
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}