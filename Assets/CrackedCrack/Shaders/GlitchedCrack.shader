Shader "CrackedCrack/CrackedCrack"
{
    Properties
    {
        _MainColor("MainColor",Color) = (0,0,0,0)
        _BackGroundColor("BackGroundColor",Color) = (0,0,0,0)
        _ColorWeight("ColorWeight",Range(0,1)) = 0.
        _EmissionRate("EmissionRate",Range(0,3)) = 1.
        _Scale ("Scale", Float) = 0.01
        _SphereSpace("SphereSpace",Float) = 1.0
        _SphereSize("SphereSize",Float) = 1.0
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
                fixed4 wpos : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainColor;
            float4 _BackGroundColor;
            float _ColorWeight;
            float _EmissionRate;
            float _Scale;
            float _SphereSpace;
            float _SphereSize;
            
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
                
                float r = random((length(pos) + pos.xy) + floor(_Time.y * 8.0 * random(pos.yz)));
                float scale = _Scale * (0.4 + 0.8 * r) * sqrt(0.4 + 0.8 * r) * l * 2.;
                pos.xyz -= float3(0.5,0.5,0.5) * scale;
                output.center = pos;
                output.pos.w = 1.0;
                
                float3 cp = UnityObjectToClipPos(pos);
                float3 fract = frac(cp);

                    output.pos.xyz = pos.xyz + (float3(0, 0, 0) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz  = pos.xyz + (float3(0, 1., 0) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz  = pos.xyz + (float3(1., 0, 0) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(1., 1., 0) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    outStream.RestartStrip();
                    
                    output.pos.xyz = pos.xyz + (float3(0., 0., 1.) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(1., 0., 1.) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(0., 1., 1.) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(1., 1., 1.) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    outStream.RestartStrip();

                    output.pos.xyz = pos.xyz + (float3(0., 1., 0.) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(0., 1., 1.) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(1., 1., 0) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(1., 1., 1.) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    outStream.RestartStrip();

                    output.pos.xyz = pos.xyz + (float3(1., 0., 1.) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz  = pos.xyz + (float3(0., 0., 1.) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(1., 0., 0.) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz  = pos.xyz + (float3(0., 0., 0.) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    outStream.RestartStrip();

                    output.pos.xyz = pos.xyz + (float3(0., 0., 0.) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(0., 0., 1.) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(0., 1., 0.) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(0., 1., 1.) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    outStream.RestartStrip();

                    output.pos.xyz = pos.xyz + (float3(1., 1., 1.) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(1., 0., 1.) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(1., 1., 0) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    output.pos.xyz = pos.xyz + (float3(1., 0., 0.) * scale);
                    output.wpos = mul(unity_ObjectToWorld, output.pos);
                    output.vertex = UnityObjectToClipPos(output.pos);
                    outStream.Append(output);
                    outStream.RestartStrip();
            }
            
			float sphere(float3 pos)
            {
                float3 fl = ceil(pos + 0.5);
                float t = _Time.y * 0.25 + (fl.x + fl.y + fl.z) * 0.1;
                float scaleR = (random(fl.xy) + random(fl.yz) + random(fl.zx))/3.;
                float fracT = frac(t);
                pos = (frac(pos /_SphereSpace + 0.5) - 0.5) * _SphereSpace;
                float3 rnd = float3(random(fl.yz + floor(t)),random(fl.zx+ floor(t)),random(fl.xy+ floor(t))) - 0.5;
                float3 rndNext = float3(random(fl.yz + floor(t + 1.)),random(fl.zx+ floor(t + 1.)),random(fl.xy+ floor(t + 1.))) - 0.5;
                float3 lerpedRnd = lerp(rnd * _SphereSpace,rndNext * _SphereSpace,sin(fracT * 3.14159265 / 2.));
                return length(pos + lerpedRnd * 0.3) - 0.06 * (0.5 + scaleR) * abs(fracT - 0.5) * _SphereSize;
            }
            float3 getColor(float3 pos){
                float posSum = pos.x + pos.y + pos.z;
                posSum *= 0.2;
                fixed4 ccol;
                ccol.x = sin(posSum + _Time.y);
                ccol.y = sin(posSum + _Time.y + 3.14 * 2. / 3.);
                ccol.z = sin(posSum + _Time.y - 3.14 * 2. / 3.);
                ccol.w = 1.0;
                ccol = ccol * 0.35 + 0.5;
                return ccol;
            }

			fixed4 frag(v2f i) : SV_Target
			{
				float3 pos = i.wpos.xyz;
				float3 rayDir = normalize(pos.xyz - _WorldSpaceCameraPos);

                for (int i = 0; i < 32; i++) {
                    float d = sphere(pos);
                    if (d < 0.001) {
                        fixed4 col;
                        col.xyz = getColor(pos.xyz);
                        col.xyz = lerp(col.xyz,_MainColor,_ColorWeight);
                        col.w = 1.;
                        col.xyz *= 1.0 + _EmissionRate;
						return col;
                    }
                    pos.xyz += d * rayDir.xyz;
                }
                return _BackGroundColor;
			}
            ENDCG
        }
    }
}
