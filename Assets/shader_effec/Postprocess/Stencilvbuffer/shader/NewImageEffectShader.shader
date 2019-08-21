Shader "Unlit/NewImageEffectShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Mask("Mask",int) = 1
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always
		Stencil {Ref [_Mask]  Comp equal}

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                // プラットフォームによってはUVの上下が逆になるので補正をいれる
                #if UNITY_UV_STARTS_AT_TOP 
                o.uv = float2(v.uv.x, 1.0 - v.uv.y); 
                #else
                o.uv = v.uv;
                #endif

                return o;
            }

            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return 1 - col; // 色を反転させる
            }
            ENDCG
        }
    }
}
