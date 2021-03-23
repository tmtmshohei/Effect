Shader "ambr/SeaWave"
{
    Properties
    {
        _Color("BaseColor",Color) = (1,1,1,1)
        _Brightness("Brightness",float) = 1.5
        _MinDarkness("MinimumDarkness",Range(-0.5,1)) = 0.15
        _NormalMap("NormalMap",2D) = "bump"{}
        _NormalMap2("NormalMap2",2D) = "bump"{}
        _speed("speed",float)=1
        _specIntensity("SpecularIntensity",float)=1.0
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        _Emission("Emission",float)=1
        _WaveTiling ("Wave Tiling" , Vector     ) = (0, 0, 0, 0)
        _threshold("Threshold",Range(0,1))= 0.5
        _diffuseMinDarkness("DiffuseMinDarkness",Range(-0.5,1)) = 0.2
        _fakeLight ("FakeLIghtPos" , Vector     ) = (0, 0, 0, 0)

        

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityStandardUtils.cginc"

            

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
                float4 vertex : SV_POSITION;
                float4 selectedCol :COLOR;
                float3 normal : TEXCOORD1;
                float3x3 tbn : TEXCOORD2;
                float3 diff : TEXCOORD5;
            };

            sampler2D _NormalMap;
            sampler2D _NormalMap2;
            float4 _NormalMap_ST;
            float4 _Color;
            fixed _Brightness;
            fixed _MinDarkness;
            float _speed;
            float _specIntensity;
            float4 _SpecularColor;
            float _Emission;
            fixed4 _WaveTiling;
            float _threshold;
            fixed _diffuseMinDarkness;
            float3 _fakeLight;

            v2f vert (appdata v)
            {
                v2f o;
                //float amp = 0.05*sin(_Time.y + v.vertex.x * 1000);
                //v.vertex.xyz = float3(v.vertex.x, v.vertex.y+amp, v.vertex.z); 
                o.vertex = UnityObjectToClipPos(v.vertex);
                float3 worldpos = mul(unity_ObjectToWorld,v.vertex);
                float3 diff = _WorldSpaceCameraPos - worldpos;
                o.uv = TRANSFORM_TEX(v.uv, _NormalMap);
                float3 normal = UnityObjectToWorldNormal(v.normal);
                //カメラの視線ベクトルと法線の内積 
                float3 intensity = saturate(dot(normal, normalize(diff)));
                //リムを光らせたいので反転、その際に暗い部分が0にならないよう調整（ハーフランバート風）
                intensity = ((1-intensity)*(1-_MinDarkness) + _MinDarkness)*_Brightness;
                o.selectedCol = _Color;
                o.selectedCol.rgb *= intensity;

                float3 n = v.normal;
                float3 t = v.tangent.xyz;
                float3 b = normalize(cross(n,t)*v.tangent.w);
                o.tbn = float3x3(t,b,n);
                o.diff = normalize(diff);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 normal = UnpackNormal(tex2D(_NormalMap, i.uv*_WaveTiling.x+_Time.y*_speed));
                fixed3 normal2 = UnpackNormal(tex2D(_NormalMap, i.uv*_WaveTiling.y+_Time.y*_speed));
                fixed3 mergeNormal = BlendNormals(normal,normal2);

                fixed3 surfaceNormal = normalize(mul(mergeNormal,i.tbn));
                float4 col = float4(1,1,1,1);
                //float3 Lightdir = normalize(_WorldSpaceLightPos0.xyz);
                float3 Lightdir = normalize(_fakeLight);
                //float3 diffuse = _Color.rgb*max(0.0,dot(surfaceNormal,Lightdir));
                float3 halfdiffuse = ((max(0.0,dot(surfaceNormal,Lightdir))*_threshold)+_diffuseMinDarkness);
                float3 halfdiffuseReverse = 1-halfdiffuse;
                if(halfdiffuse.r<0.4) halfdiffuse=halfdiffuseReverse*_Emission;
                halfdiffuse *= _Color.rgb;
                
                float3 spec = _SpecularColor.rgb*pow(max(0.0,dot(reflect(-Lightdir,surfaceNormal),i.diff)),_specIntensity);
                col.rgb = halfdiffuse+spec;//*i.selectedCol+spec;
                //col.rgb = Lightdir;

                
                return col;
                
            }
            ENDCG
        }
    }
}
