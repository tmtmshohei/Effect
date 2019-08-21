Shader "hoge"
{
    Properties
    {
        //?
        [keywordEnum(Property,Camera)]
        _Methhod("DestructionMethod", Float) = 0
        _TintColor("Tint color",color) = (0.5.,0.5.,0.5,0.5)
        _MainTex("Particle Texture" , 2D) = "white" {}
        _InVFade("Soft Particles Factor" , Range(0.01,3.0,)) = 1.0
        _Destruction("Destruction Factor " , Range(0.0,1.0)) = 0.0
        _PositonFactor("Position Factor" , Range(0.0,1.0)) = 0.0
        _RotationFactor("RotatonFactor", Range(0.0,1.0)) = 0.0
        _ScaleFactro("scale" , Range(0.0,1.0)) = 1.0
        

        SubShader
        {
            Tags
            {
                "RenderType" = "Transparent"
                "Queue" = "Transparent"
                //?
                "IgnoreProjector" = "True"
                //?
                "PreviewType" = "Plane"
            }

            Pass
            {
                Blend SrcAlpha One
                ColorMask RGB
                Cull Off Lighting Off ZWrite Off

                CGPROGRAM
                #pragma vertex vert
                #pragma Geometry geom 
                #pragma fragment frag
                #pragma traget 4.0
                //?
                #pragma multi_compile_Particles
                //?
                #pragma multi_compile_METHOD_PROERTY_METHOD_CAMERA
                #include "unityCG.cginc" 
                #define PI 3.1415926535

                sampler2D _MainTex;
                fixed4 _MainTex_ST;
                fixed4 _TintColor;
                sampler2D_float _CameraDepthTexture;
                fixed _InvFade;
                fixed _Destruction;
                fixed _PositionFactor;
                fixed _RotationFactor;
                fixed _ScaleFactor;
                


                struct appdata_t 
                {
                    float4 vertex : POSITION;
                    fixed4 color : COLOR;
                    //TEXCOORD = UV座標
                    float2 texcoord : TEXCOORD0;
                    //
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                };

                struct g2f
                {
                    float4 vertex : SV_POSITION;
                    fixed4 color : COLOR;
                    float2 texcoord : TEXCOORD0;
                    UNITY_FOG_COORDS(1)
                    //#ifdefとすることでコンパイル時に条件分岐を行うようにすることで負荷が軽くなる
                #ifdef SOFTPARTICLES_ON
                        float4 projPos : TEXCOORD2;
                #endif
                ////シングルパスステレオのときに両目ともうつるようにするためのスクリプト
                    UNITY_VERTEX_OUTPUT_STEREO
                };

                //インライン展開することでオーバーヘッドを少なくし、処理を早める
                inline float rand(float2 seed)
                {
                    return frac(sin(dot(seed.xy, float2(12.9898, 78.233))) * 43758.5453);
                }

                float3 rotate(float3 p, float3 rotation)
                {
                    float3 a = normalize(rotation);
                    float angle = length(rotation);
                    if (abs(angle) < 0.001) return p;
                    float s = sin(angle);
                    float c = cos(angle);
                    float r = 1.0 - c;
                    float3x3 m = float3x3(
                        a.x * a.x * r + c,
                        a.y * a.x * r + a.z * s,
                        a.z * a.x * r - a.y * s,
                        a.x * a.y * r - a.z * s,
                        a.y * a.y * r + c,
                        a.z * a.y * r + a.x * s,
                        a.x * a.z * r + a.y * s,
                        a.y * a.z * r - a.x * s,
                        a.z * a.z * r + c
                    );
                    return mul(m, p);
                }

                appdata_t vert(appdata_t v)
                {
                    return v;
                }

                [maxvertexcount(3)]
                void geom(triangle appdata_t input[3], inout TriangleStream<g2f> stream)
                {

                    float3 center = (input[0].vertex + input[1].vertex + input[2].vertex).xyz / 3;

                    float3 vec1 = input[1].vertex - input[0].vertex;
                    float3 vec2 = input[2].vertex - input[0].vertex;
                    float3 normal = normalize(cross(vec1, vec2));

                #ifdef _METHOD_PROPERTY
                    fixed destruction = _Destruction;
                #else
                    float4 worldPos = mul(unity_ObjectToWorld, float4(center, 1.0));
                    float3 dist = length(_WorldSpaceCameraPos - worldPos);
                    fixed destruction = clamp((_StartDistance - dist) / (_StartDistance - _EndDistance), 0.0, 1.0);
                #endif

                    fixed r = 2 * (rand(center.xy) - 0.5);
                    fixed3 r3 = fixed3(r, r, r);

            }

        }
    }
}