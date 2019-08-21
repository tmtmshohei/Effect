Shader "Unlit/Explorsion2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [KeywordEnum(Property, Camera)]
    _Method("DestructionMethod", Float) = 0
    _Destruction("Destruction Factor", Range(0.0, 1.0)) = 0.0
    _PositionFactor("Position Factor", Range(0.0, 1.0)) = 0.2
    _RotationFactor("Rotation Factor", Range(0.0, 1.0)) = 1.0
    _ScaleFactor("Scale Factor", Range(0.0, 1.0)) = 1.0
    _AlphaFactor("Alpha Factor", Range(0.0, 1.0)) = 1.0
    _StartDistance("Start Distance", Float) = 0.6
    _EndDistance("End Distance", Float) = 0.3
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
