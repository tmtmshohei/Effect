Shader "Example"
{
    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        _SphereMap ("Sphere Map", 2D) = "white" {}
        [Normal]
        _NormalMap ("Normal map", 2D) = "bump" {}
        _base("BaseColor",2D) = "white"{}
    }
    
    Subshader
    {       
        Pass
        {
            Lighting Off ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                half2 texcoord : TEXCOORD0;
                half3 normal : NORMAL;
                half4 tangent : TANGENT;
            };
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
                half3 normal : TEXCOORD2;
                half3 tangent : TEXCOORD3;
                half3 binormal : TEXCOORD4;
            };
            
            half4 _Color;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            sampler2D _SphereMap;
            sampler2D _base;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _NormalMap);

                // 各ベクトルをビュー空間で求める
                o.normal = mul((float3x3)UNITY_MATRIX_V, UnityObjectToWorldNormal(v.normal));
                o.tangent = mul((float3x3)UNITY_MATRIX_MV, v.tangent.xyz);
                o.binormal = normalize(cross(v.normal.xyz, v.tangent.xyz) * v.tangent.w * unity_WorldTransformParams.w);

                return o;
            }
            
            float4 frag (v2f i) : COLOR
            {
                // ノーマルマップから法線情報を取得する
                half3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));

                // ビュー空間に変換
                normal = (i.tangent * normal.x) + (i.binormal * normal.y) + (i.normal * normal.z);
                float2 uv = normal.xy * 0.5 + 0.5;
                float4 base = tex2D(_base,i.uv);
                //return base;
                return base + tex2D(_SphereMap, uv) * _Color;
            }

            ENDCG
        }
    }
    
    // Fallback "VertexLit"
}