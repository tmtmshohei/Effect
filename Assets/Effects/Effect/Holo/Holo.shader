Shader "Unlit/Holo"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Holoalpha("Holoalpha",2D) = "white" {}
        _Color("Color",Color)=(1,1,1,1)
        _heighlight("HeighLight",2D) = "white"{}
        _heighcolor("HeighLightColor",Color) = (1,1,1,1)
        _F0("_F0",Float) = 0.1
        _rimwidth("Rimwidth",Float) = 5
        _rimcolor("Rimcolor",Color)=(1,1,1,1)
        _hintensity("heighlightintensity",Float)=1
        _rintensity("rimintensity",Float)=1
        _perFrame("フレーム間隔",Float) = 0.016 //fps30の場合1フレームの間隔は0.033,fps60の場合0.016
        _row("行",Int) = 4
        _colum("列",Int) = 4
        _th("Threshold",Range(0,1))=0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        //Blend SrcAlpha one
        Blend SrcAlpha OneMinusSrcAlpha

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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float2 holouv : TEXCOORD2;
                float3 worldnormal : TEXCOORD3;
                float3 codot : TEXCOORD4;
                float2 heighlightuv:TEXCOORD5;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Holoalpha;
            float4 _Holoalpha_ST;
            float4 _Color;
            sampler2D _heighlight;
            float4 _heighlight_ST;
            float _F0;
            float4 _heighcolor;
            float _rimwidth;
            float4 _rimcolor;
            float _rintensity;
            float _hintensity;


            v2f vert (appdata v)
            {
                float3 screenpos = UnityObjectToViewPos(v.vertex).xyz;

                v2f o;
                float d = tex2Dlod(_heighlight, float4(v.uv.xy,0,0)).r;
                //v.vertex.x+=d*sin(_Time.y*10)*0.3;
                //v.vertex.z+=d*sin(_Time.y*10)*0.3;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.holouv = TRANSFORM_TEX(screenpos.xy,_Holoalpha);
                o.holouv.y -= _Time.y;
                o.heighlightuv = TRANSFORM_TEX(v.uv,_heighlight);
                o.heighlightuv -= _Time.y;
                o.worldnormal = UnityObjectToWorldNormal(v.normal);
                float3 ViewDir = normalize(ObjSpaceViewDir(v.vertex));
                o.codot = dot(ViewDir,v.normal);
                //o.codot = abs(dot(ViewDir,o.worldnormal));
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 holo = tex2D(_Holoalpha,i.holouv);
                fixed4 holocol = 1-holo;
                fixed4 heighlight = tex2D(_heighlight,i.heighlightuv);
                float4 color = _Color;
                //half fresnel = _F0 + (2.50h - _F0) * pow(1.0h - i.codot, _rimwidth);
                half fresnel = _F0 + (_rintensity - _F0) * pow(1.0h - i.codot, _rimwidth);
                float4 rimcol = fresnel*_rimcolor;
                col.a = holo.r+heighlight.r;
                //col.rgb *= (i.codot)  *_F0*color+rimcol;
                col.rgb *= color.rgb*holocol.rgb+rimcol.rgb;
                heighlight *= _heighcolor*_hintensity;
                //col.rgb  += heighlight.rgb;
                
                col.a = fresnel;
                
                //color *= holo;
                
                
                //col.a *=rimcol.a;
                //col.rgb += rimcol.rgb;
                //return col;
               // col.rgb += rimcol;
               
                //return col;
                
                
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
