Shader "Unlit/OutlineFlagmentShader" {

    Properties {
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 0)
        _OutlineWidth("Outline Width", float) = 0.1
        _MainColor("Main Color", Color) = (1, 1, 1, 1)
    }

    SubShader {
        Tags {
            "Queue"="Geometry"
        }

        //1パス目.
        Pass {

            Cull Front

            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            float4 _OutlineColor;
            float _OutlineWidth;
            float4 _MainColor;

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v) {
                float distance = UnityObjectToViewPos(v.vertex).z;
                v.vertex.xyz += v.normal * _OutlineWidth;// * -distance ; 

                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                return _OutlineColor;
            }

            ENDCG
        }

        //2パス目.
        Pass {

            Cull Back

            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            float4 _MainColor;

            struct appdata {
                float4 vertex : POSITION;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                return _MainColor;
            }

            ENDCG
        }
    }
}