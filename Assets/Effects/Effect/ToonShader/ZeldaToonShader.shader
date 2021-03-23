Shader "Unlit/ZeldaToonShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",color) = (1,1,1,1)
        _AmbientColor("AmbientColor",color)=(0.5,0.5,0.5,1)
        _SpecularColor("SpecularColor",color) = (0.8,0.8,0.8,1)
        _Glosiness("Glosiness",Range(1,1024)) = 128
        _RimColor("RimColor",color)=(1,1,1,1)
        _RimAmount("RimAmount",Range(0,1))=0.75
        _RimThreshold("RimThreshold",Range(0,1))=0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"  "LightMode" = "ForwardBase" "PassFlags" = "OnlyDirectional"}
        LOD 100

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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL;
                float3 viewDir : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float4 _AmbientColor;
            float _Glosiness;
            float4 _SpecularColor;
            float4 _RimColor;
            float _RimAmount;
            float _RimThreshold;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = (UnityObjectToWorldNormal(v.normal));
                o.viewDir = (WorldSpaceViewDir(v.vertex)); //頂点からカメラ方向へのベクトル取得+正規化
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal = normalize(i.worldNormal);
                float NdotL = dot(_WorldSpaceLightPos0,normal);
                float lightintensity = smoothstep(0,0.01,NdotL);
                //float lightintensity = step(0,NdotL);

                float3 viewDir = normalize(i.viewDir);
                float3 halfVector = normalize(viewDir+_WorldSpaceLightPos0);
                float3 NdotH = dot(normal,halfVector);
                float specularIntensity = pow(NdotH*lightintensity,_Glosiness);
                specularIntensity = smoothstep(0.005,0.01,specularIntensity);
                float specular = specularIntensity*_SpecularColor;

                float rimDot = 1-dot(normal,viewDir);
                float4 rimIntensity = rimDot*pow(NdotL,_RimThreshold);
                rimIntensity = smoothstep(_RimAmount-0.05,_RimAmount+0.05,rimIntensity);
                float4 rim = rimIntensity*_RimColor;
                

                fixed4 col = tex2D(_MainTex, i.uv);
                col *= (lightintensity+_AmbientColor+specular+rim)*_Color;
                return col;
            }
            ENDCG
        }
    }
}
