Shader "ambr/tumiki_Water_03" {
    Properties {
        _WaveTex1   ("Wave Tex 1"  , 2D         ) = "bump" {}
        _WaveTex2   ("Wave Tex 2"  , 2D         ) = "bump" {}
        _WaveTex1H  ("Wave Tex 1H" , 2D         ) = "white" {}
        _WaveTex2H  ("Wave Tex 2H" , 2D         ) = "white" {}
        _WaveTiling ("Wave Tiling" , Vector     ) = (0, 0, 0, 0)
        _Color      ("Color"       , Color      ) = (1, 1, 1, 1)
        _Glossiness ("Smoothness"  , Range(0, 1)) = 0.5
        _FlowSpeed  ("Flow Speed"  , Vector     ) = (0, 0, 0, 0)
        _Refraction ("Refraction"  , Vector     ) = (0, 0, 0, 0)
        _Displace   ("Displace"    , Vector     ) = (0, 0, 0, 0)
        _EdgeLength ("Edge length" , Range(3,50)) = 10
    }

    SubShader {
        Tags {
            "Queue"      = "Opaque" 
        }

        //GrabPass {}
        
        CGPROGRAM
        #pragma target 5.0
        #pragma surface surf Standard vertex:disp tessellate:tessEdge
        #include "Tessellation.cginc"

        sampler2D _GrabTexture;
        sampler2D _WaveTex1;
        sampler2D _WaveTex2;
        sampler2D _WaveTex1H;
        sampler2D _WaveTex2H;
        half4 _WaveTiling;
        fixed3 _Color;
        half _Glossiness;
        half4 _FlowSpeed;
        half4 _Refraction;
        half4 _Displace;
        half _EdgeLength;

        struct appdata {
            float4 vertex : POSITION;
            float4 tangent : TANGENT;
            float3 normal : NORMAL;
            float4 color  : COLOR;
            float2 texcoord : TEXCOORD0;
            float2 texcoord1 : TEXCOORD1;
            float2 texcoord2 : TEXCOORD2;
        };

        float4 tessEdge (appdata v0, appdata v1, appdata v2) {
            return UnityEdgeLengthBasedTessCull (v0.vertex, v1.vertex, v2.vertex, _EdgeLength, 1.5f);
        }

        void disp (inout appdata v) {
            fixed waveTex1 = tex2Dlod(_WaveTex1H, float4(v.texcoord.xy * _WaveTiling.x + float2(0, _Time.x * _FlowSpeed.x), 0, 0)).a * _Displace.x;
            fixed waveTex2 = tex2Dlod(_WaveTex2H, float4(v.texcoord.xy * _WaveTiling.y + float2(0, _Time.x * _FlowSpeed.y), 0, 0)).a * _Displace.y;
            fixed displace = waveTex1 + waveTex2;

            v.vertex.xyz += v.normal * displace;
        }

        struct Input {
            float2 uv_WaveTex1;
            float4 screenPos;
        };

        void surf (Input IN, inout SurfaceOutputStandard o) {
            fixed4 waveTex1 = tex2D(_WaveTex1, IN.uv_WaveTex1 * _WaveTiling.x + float2(0, _Time.x * _FlowSpeed.x));
            fixed4 waveTex2 = tex2D(_WaveTex2, IN.uv_WaveTex1 * _WaveTiling.y + float2(0, _Time.x * _FlowSpeed.x));

            fixed3 normal1 = UnpackNormal(waveTex1);
            fixed3 normal2 = UnpackNormal(waveTex2);
            fixed3 normal = BlendNormals(normal1, normal2);

            fixed3 distortion1 = UnpackScaleNormal(waveTex1, _Refraction.x);
            fixed3 distortion2 = UnpackScaleNormal(waveTex2, _Refraction.y);
            fixed2 distortion = BlendNormals(distortion1, distortion2).rg;


            half2 grabUV = (IN.screenPos.xy / IN.screenPos.w) * float2(1, -1) + float2(0, 1);
            half3 grab = tex2D(_WaveTex1H, grabUV + distortion).rgb * _Color;


            o.Albedo     = fixed3(0, 0, 0);
            o.Emission   = grab;
            o.Metallic   = 0;
            o.Smoothness = _Glossiness;
            o.Normal     = normal;
            o.Alpha      = 1;
        }
        ENDCG
    }

    FallBack "Transparent/Diffuse"
}