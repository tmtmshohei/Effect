Shader "ambr/normaltest"
{
    Properties
    {
        _NormalMap("NormalMap",2D) ="bump"{}
        _Color("Color",color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase" }
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
                float4 tangent : TANGENT;
                float3 normal : NORMAL;

            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3x3 ntb : TEXCOORD2;
            };


            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _NormalMap);
                

                float3 n = normalize(v.normal);
                float3 t = v.tangent;
                float3 b = cross(n,t);
                o.ntb = float3x3(t,b,n);
                

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));
                fixed3 surfaceNormal = mul(i.ntb,normal);

                float4 col = float4(surfaceNormal,1);
                // return col;
                float3 Lightdir = normalize(_WorldSpaceLightPos0.xyz);
                float3 diffuse = _Color.rgb*max(0,dot(surfaceNormal,Lightdir));
                col.rgb = surfaceNormal;
                return col;
            }
            ENDCG
        }
    }
}
