Shader "CrackedCrack/IllumiCube"
{
    Properties
    {
        _Scale ("Scale", Float) = 0.01
        _MainColor("MainColor",Color) = (0,0,0,0)
        _ColorWeight("ColorWeight",Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : TEXCOORD0;
                fixed4 center : TEXCOORD1;
                fixed4 color :COLOR0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Scale;
            float4 _MainColor;
            float _ColorWeight;
            
            float random (fixed2 p) { 
                return frac(sin(dot(p, fixed2(12.9898,78.233))) * 43758.5453);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.pos = v.vertex;
                o.center = fixed4(0.,0.,0.,0.);
                return o;
            }
            
            [maxvertexcount(36)]
            void geom(triangle v2f input[3], inout TriangleStream<v2f> outStream)
            {
                v2f output;
                float4 pos = (input[0].pos + input[1].pos + input[2].pos)/3.;
                float l = (length(input[0].pos.xyz - pos.xyz) + length(input[1].pos.xyz - pos.xyz) + length(input[2].pos.xyz - pos.xyz))/3.;
                
                float r = random(floor(length(pos * 12.) + pos.xy) + floor(_Time.y * 8.0 * random(floor(pos.zx * 12.))));
                float scale = _Scale * (0.4 + 0.8 * r) * (0.4 + 0.8 * r) * l;
                pos.xyz -= float3(0.5,0.5,0.5) * scale;
                output.center = pos;
                output.pos.w = 1.0;
                
                float emissionRate = r < 0.75 ? 2.0 : 1.0;
                fixed4 col;
                fixed4 ccol;
                float posSum = pos.x + pos.y + pos.z;
                ccol.x = sin(posSum + _Time.y);
                ccol.y = sin(posSum + _Time.y + 3.14 * 2. / 3.);
                ccol.z = sin(posSum + _Time.y - 3.14 * 2. / 3.);
                ccol.w = 1.0;
                ccol = ccol * 0.5 + 0.5;
                
                col.xyz = r < 0.75 ? lerp(ccol,_MainColor,_ColorWeight) : r * 0.25;
                col.w = 1.0;
                col = col * emissionRate;
                output.color = col;
                  
                    output.pos.xyz = pos.xyz + (float3(0, 0, 0) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz  = pos.xyz + (float3(0, 1., 0) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz  = pos.xyz + (float3(1., 0, 0) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(1., 1., 0) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    outStream.RestartStrip();
                    
                    output.pos.xyz = pos.xyz + (float3(0., 0., 1.) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(1., 0., 1.) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(0., 1., 1.) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(1., 1., 1.) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    outStream.RestartStrip();

                    output.pos.xyz = pos.xyz + (float3(0., 1., 0.) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(0., 1., 1.) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(1., 1., 0) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(1., 1., 1.) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    outStream.RestartStrip();

                    output.pos.xyz = pos.xyz + (float3(1., 0., 1.) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz  = pos.xyz + (float3(0., 0., 1.) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(1., 0., 0.) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz  = pos.xyz + (float3(0., 0., 0.) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    outStream.RestartStrip();

                    output.pos.xyz = pos.xyz + (float3(0., 0., 0.) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(0., 0., 1.) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(0., 1., 0.) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(0., 1., 1.) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    outStream.RestartStrip();

                    output.pos.xyz = pos.xyz + (float3(1., 1., 1.) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(1., 0., 1.) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(1., 1., 0) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(1., 0., 0.) * scale);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    outStream.RestartStrip();
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = i.color;
                return col;
            }
            ENDCG
        }
    }
}
