Shader "HOTATE/Matcap" {
    Properties {
        _MatCap ("MatCap", 2D) = "white" {}
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }


            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma only_renderers d3d9 d3d11 glcore gles gles3 metal 
            #pragma target 2.0
            uniform sampler2D _MatCap; uniform float4 _MatCap_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float3 normalDir : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.normalDir = mul((float3x3)UNITY_MATRIX_V, v.normal);
                o.normalDir = o.normalDir * 0.5 + 0.5;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                float4 _MatCap_var = tex2D(_MatCap, i.normalDir);
                return _MatCap_var;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}