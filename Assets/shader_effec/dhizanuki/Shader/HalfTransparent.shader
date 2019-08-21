Shader "Unlit/HalfTransparent"
{
    Properties
    {
        _Alpha ("Alpha", Range(0.0, 1.0)) = 1.0
		_MainTex("Texture",2D) = "gray"{}
		_Color("Color",Color) = (1.0,1.0,1.0,1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
           #pragma vertex vert
           #pragma fragment frag
           #pragma target 3.0
            
           #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
            };
            
            struct v2f
            {
				float2 uv : TEXCOORD0;
            };

            sampler2D _DitherMaskLOD2D;
            half _Alpha;
			sampler2D _MainTex;
			fixed4 _Color;

            
            v2f vert (appdata v ,out fixed4 vertex : SV_POSITION)
            {
                v2f o;
                vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
                return o;
            }
            
            fixed4 frag (v2f i, UNITY_VPOS_TYPE vpos : VPOS) : SV_Target
            {
                // 4px x 4pxのブロック毎にテクスチャをマッピングする
                vpos *= 0.25;
                // ディザテクスチャのheightは4*16pxなので小数部分を16で割る（0.0625 = 1/16）
                // これでyは0 ～ 1/16の値を取る
                vpos.y = frac(vpos.y) * 0.015625;
                // Alphaに応じてyにオフセットを加える
                // Alphaが1のときはyが0.9375～1の値を取るように（0.9375 = 1 - 1/16）
                vpos.y += _Alpha * 0.9375;

                // ディザの値はAチャンネルに格納されている
                clip(tex2D(_DitherMaskLOD2D, vpos).a - 0.5);
				float4 col = tex2D(_MainTex,i.uv)*_Color;
                return col;
            }
            ENDCG
        }
    }
}
