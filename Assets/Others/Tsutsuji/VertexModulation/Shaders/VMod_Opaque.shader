// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:9361,x:33516,y:32961,varname:node_9361,prsc:2|emission-8127-OUT,voffset-863-OUT;n:type:ShaderForge.SFN_NormalVector,id:1583,x:31620,y:32785,prsc:2,pt:False;n:type:ShaderForge.SFN_NormalVector,id:5579,x:31890,y:33384,prsc:2,pt:False;n:type:ShaderForge.SFN_ComponentMask,id:8425,x:32054,y:33399,varname:node_8425,prsc:2,cc1:0,cc2:1,cc3:-1,cc4:-1|IN-5579-OUT;n:type:ShaderForge.SFN_RemapRange,id:1514,x:32340,y:33423,varname:node_1514,prsc:2,frmn:-1,frmx:1,tomn:0,tomx:1|IN-8425-OUT;n:type:ShaderForge.SFN_Rotator,id:5344,x:32528,y:33441,varname:node_5344,prsc:2|UVIN-1514-OUT,PIV-7921-OUT,SPD-2183-OUT;n:type:ShaderForge.SFN_Panner,id:7644,x:32709,y:33486,varname:node_7644,prsc:2,spu:0,spv:1|UVIN-5344-UVOUT,DIST-8104-OUT;n:type:ShaderForge.SFN_Multiply,id:8104,x:32528,y:33595,varname:node_8104,prsc:2|A-3443-T,B-1238-OUT;n:type:ShaderForge.SFN_Time,id:3443,x:31623,y:33289,varname:node_3443,prsc:2;n:type:ShaderForge.SFN_Slider,id:1238,x:32041,y:33730,ptovrint:False,ptlb:Noise Scroll Speed,ptin:_NoiseScrollSpeed,varname:node_1238,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-1,cur:0.2,max:1;n:type:ShaderForge.SFN_Tex2d,id:4636,x:32880,y:33441,ptovrint:False,ptlb:Noise Texture,ptin:_NoiseTexture,varname:node_4636,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:78281eaf33bd330429580057821d1a0c,ntxv:0,isnm:False|UVIN-7644-UVOUT;n:type:ShaderForge.SFN_Multiply,id:863,x:33395,y:33435,varname:node_863,prsc:2|A-2662-OUT,B-1666-OUT;n:type:ShaderForge.SFN_RemapRangeAdvanced,id:2662,x:33168,y:33456,varname:node_2662,prsc:2|IN-1645-OUT,IMIN-8578-OUT,IMAX-5790-OUT,OMIN-5624-OUT,OMAX-327-OUT;n:type:ShaderForge.SFN_Vector1,id:8578,x:32985,y:33551,varname:node_8578,prsc:2,v1:0;n:type:ShaderForge.SFN_Vector1,id:5790,x:32608,y:33369,varname:node_5790,prsc:2,v1:1;n:type:ShaderForge.SFN_Slider,id:3462,x:32685,y:33660,ptovrint:False,ptlb:Offset Inside,ptin:_OffsetInside,varname:node_3462,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.25,max:2;n:type:ShaderForge.SFN_Slider,id:327,x:32709,y:33758,ptovrint:False,ptlb:Offset Outside,ptin:_OffsetOutside,varname:node_327,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.25,max:2;n:type:ShaderForge.SFN_Negate,id:5624,x:33007,y:33623,varname:node_5624,prsc:2|IN-3462-OUT;n:type:ShaderForge.SFN_Power,id:1645,x:33071,y:33298,varname:node_1645,prsc:2|VAL-4636-RGB,EXP-6688-OUT;n:type:ShaderForge.SFN_Slider,id:7905,x:32351,y:33325,ptovrint:False,ptlb:Noise Contrast,ptin:_NoiseContrast,varname:node_7905,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-1,cur:0,max:1;n:type:ShaderForge.SFN_Add,id:6688,x:32769,y:33263,varname:node_6688,prsc:2|A-7905-OUT,B-5790-OUT;n:type:ShaderForge.SFN_Dot,id:980,x:31938,y:32909,varname:node_980,prsc:2,dt:3|A-1583-OUT,B-4578-OUT;n:type:ShaderForge.SFN_ViewVector,id:4578,x:31623,y:33056,varname:node_4578,prsc:2;n:type:ShaderForge.SFN_Power,id:8889,x:32154,y:32953,varname:node_8889,prsc:2|VAL-980-OUT,EXP-4596-OUT;n:type:ShaderForge.SFN_Slider,id:4596,x:31781,y:33118,ptovrint:False,ptlb:Rim Power,ptin:_RimPower,varname:node_4596,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.2,max:3;n:type:ShaderForge.SFN_Color,id:2030,x:32135,y:32406,ptovrint:False,ptlb:Outside Color,ptin:_OutsideColor,varname:node_2030,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Color,id:2646,x:32135,y:32566,ptovrint:False,ptlb:Inside Color,ptin:_InsideColor,varname:node_2646,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0,c2:0,c3:0,c4:1;n:type:ShaderForge.SFN_Lerp,id:6736,x:32446,y:32723,varname:node_6736,prsc:2|A-2030-RGB,B-2646-RGB,T-8889-OUT;n:type:ShaderForge.SFN_Sin,id:5958,x:32129,y:33194,varname:node_5958,prsc:2|IN-9627-OUT;n:type:ShaderForge.SFN_Multiply,id:9627,x:31938,y:33244,varname:node_9627,prsc:2|A-3443-T,B-3437-OUT;n:type:ShaderForge.SFN_Slider,id:3437,x:31399,y:33487,ptovrint:False,ptlb:Flash Speed,ptin:_FlashSpeed,varname:node_3437,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:5,max:10;n:type:ShaderForge.SFN_RemapRangeAdvanced,id:7542,x:32690,y:33086,varname:node_7542,prsc:2|IN-5958-OUT,IMIN-4114-OUT,IMAX-1247-OUT,OMIN-5725-OUT,OMAX-1247-OUT;n:type:ShaderForge.SFN_Vector1,id:4114,x:32291,y:33184,varname:node_4114,prsc:2,v1:-1;n:type:ShaderForge.SFN_Vector1,id:1247,x:32291,y:33240,varname:node_1247,prsc:2,v1:1;n:type:ShaderForge.SFN_Slider,id:6333,x:32114,y:33103,ptovrint:False,ptlb:Flash Power,ptin:_FlashPower,varname:node_6333,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:1,max:1;n:type:ShaderForge.SFN_OneMinus,id:5725,x:32442,y:33076,varname:node_5725,prsc:2|IN-6333-OUT;n:type:ShaderForge.SFN_Lerp,id:8127,x:33029,y:32964,varname:node_8127,prsc:2|A-7866-OUT,B-6736-OUT,T-7542-OUT;n:type:ShaderForge.SFN_Lerp,id:7866,x:32478,y:32912,varname:node_7866,prsc:2|A-8312-RGB,B-7286-RGB,T-8889-OUT;n:type:ShaderForge.SFN_Color,id:8312,x:32129,y:32722,ptovrint:False,ptlb:Outside Color Flash,ptin:_OutsideColorFlash,varname:node_8312,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:0,c2:0,c3:0,c4:1;n:type:ShaderForge.SFN_Color,id:7286,x:32154,y:32842,ptovrint:False,ptlb:Inside Color Flash,ptin:_InsideColorFlash,varname:node_7286,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,c1:1,c2:1,c3:1,c4:1;n:type:ShaderForge.SFN_Sin,id:1764,x:31850,y:33694,varname:node_1764,prsc:2|IN-3144-OUT;n:type:ShaderForge.SFN_Append,id:3997,x:32039,y:33567,varname:node_3997,prsc:2|A-9743-OUT,B-1764-OUT;n:type:ShaderForge.SFN_Cos,id:9743,x:31850,y:33556,varname:node_9743,prsc:2|IN-3144-OUT;n:type:ShaderForge.SFN_RemapRange,id:7921,x:32198,y:33467,varname:node_7921,prsc:2,frmn:-1,frmx:1,tomn:0,tomx:1|IN-3997-OUT;n:type:ShaderForge.SFN_NormalVector,id:1666,x:33210,y:33589,prsc:2,pt:False;n:type:ShaderForge.SFN_Slider,id:1219,x:31363,y:33908,ptovrint:False,ptlb:Noise Rotate Speed,ptin:_NoiseRotateSpeed,varname:node_1219,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:-1,cur:0.5,max:1;n:type:ShaderForge.SFN_Multiply,id:2183,x:31987,y:33830,varname:node_2183,prsc:2|A-1219-OUT,B-30-OUT;n:type:ShaderForge.SFN_Vector1,id:30,x:31700,y:34041,varname:node_30,prsc:2,v1:2;n:type:ShaderForge.SFN_Multiply,id:3144,x:31670,y:33694,varname:node_3144,prsc:2|A-3443-T,B-8602-OUT,C-1219-OUT;n:type:ShaderForge.SFN_Vector1,id:8602,x:31425,y:33750,varname:node_8602,prsc:2,v1:5;proporder:2030-2646-8312-7286-4636-1238-1219-7905-3462-327-4596-3437-6333;pass:END;sub:END;*/

Shader "Tsutsuji/VertexModulation_Opaque" {
    Properties {
        _OutsideColor ("Outside Color", Color) = (1,1,1,1)
        _InsideColor ("Inside Color", Color) = (0,0,0,1)
        _OutsideColorFlash ("Outside Color Flash", Color) = (0,0,0,1)
        _InsideColorFlash ("Inside Color Flash", Color) = (1,1,1,1)
        _NoiseTexture ("Noise Texture", 2D) = "white" {}
        _NoiseScrollSpeed ("Noise Scroll Speed", Range(-1, 1)) = 0.2
        _NoiseRotateSpeed ("Noise Rotate Speed", Range(-1, 1)) = 0.5
        _NoiseContrast ("Noise Contrast", Range(-1, 1)) = 0
        _OffsetInside ("Offset Inside", Range(0, 2)) = 0.25
        _OffsetOutside ("Offset Outside", Range(0, 2)) = 0.25
        _RimPower ("Rim Power", Range(0, 3)) = 0.2
        _FlashSpeed ("Flash Speed", Range(0, 10)) = 5
        _FlashPower ("Flash Power", Range(0, 1)) = 1
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
            Cull Off
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float _NoiseScrollSpeed;
            uniform sampler2D _NoiseTexture; uniform float4 _NoiseTexture_ST;
            uniform float _OffsetInside;
            uniform float _OffsetOutside;
            uniform float _NoiseContrast;
            uniform float _RimPower;
            uniform float4 _OutsideColor;
            uniform float4 _InsideColor;
            uniform float _FlashSpeed;
            uniform float _FlashPower;
            uniform float4 _OutsideColorFlash;
            uniform float4 _InsideColorFlash;
            uniform float _NoiseRotateSpeed;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 posWorld : TEXCOORD0;
                float3 normalDir : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                float4 node_3443 = _Time;
                float4 node_7073 = _Time;
                float node_3144 = (node_3443.g*5.0*_NoiseRotateSpeed);
                float node_5344_ang = node_7073.g;
                float node_5344_spd = (_NoiseRotateSpeed*2.0);
                float node_5344_cos = cos(node_5344_spd*node_5344_ang);
                float node_5344_sin = sin(node_5344_spd*node_5344_ang);
                float2 node_5344_piv = (float2(cos(node_3144),sin(node_3144))*0.5+0.5);
                float2 node_5344 = (mul((v.normal.rg*0.5+0.5)-node_5344_piv,float2x2( node_5344_cos, -node_5344_sin, node_5344_sin, node_5344_cos))+node_5344_piv);
                float2 node_7644 = (node_5344+(node_3443.g*_NoiseScrollSpeed)*float2(0,1));
                float4 _NoiseTexture_var = tex2Dlod(_NoiseTexture,float4(TRANSFORM_TEX(node_7644, _NoiseTexture),0.0,0));
                float node_5790 = 1.0;
                float node_8578 = 0.0;
                float node_5624 = (-1*_OffsetInside);
                v.vertex.xyz += ((node_5624 + ( (pow(_NoiseTexture_var.rgb,(_NoiseContrast+node_5790)) - node_8578) * (_OffsetOutside - node_5624) ) / (node_5790 - node_8578))*v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
////// Lighting:
////// Emissive:
                float node_8889 = pow(abs(dot(i.normalDir,viewDirection)),_RimPower);
                float4 node_3443 = _Time;
                float node_4114 = (-1.0);
                float node_1247 = 1.0;
                float node_5725 = (1.0 - _FlashPower);
                float3 emissive = lerp(lerp(_OutsideColorFlash.rgb,_InsideColorFlash.rgb,node_8889),lerp(_OutsideColor.rgb,_InsideColor.rgb,node_8889),(node_5725 + ( (sin((node_3443.g*_FlashSpeed)) - node_4114) * (node_1247 - node_5725) ) / (node_1247 - node_4114)));
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float _NoiseScrollSpeed;
            uniform sampler2D _NoiseTexture; uniform float4 _NoiseTexture_ST;
            uniform float _OffsetInside;
            uniform float _OffsetOutside;
            uniform float _NoiseContrast;
            uniform float _NoiseRotateSpeed;
            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float4 posWorld : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                float4 node_3443 = _Time;
                float4 node_8640 = _Time;
                float node_3144 = (node_3443.g*5.0*_NoiseRotateSpeed);
                float node_5344_ang = node_8640.g;
                float node_5344_spd = (_NoiseRotateSpeed*2.0);
                float node_5344_cos = cos(node_5344_spd*node_5344_ang);
                float node_5344_sin = sin(node_5344_spd*node_5344_ang);
                float2 node_5344_piv = (float2(cos(node_3144),sin(node_3144))*0.5+0.5);
                float2 node_5344 = (mul((v.normal.rg*0.5+0.5)-node_5344_piv,float2x2( node_5344_cos, -node_5344_sin, node_5344_sin, node_5344_cos))+node_5344_piv);
                float2 node_7644 = (node_5344+(node_3443.g*_NoiseScrollSpeed)*float2(0,1));
                float4 _NoiseTexture_var = tex2Dlod(_NoiseTexture,float4(TRANSFORM_TEX(node_7644, _NoiseTexture),0.0,0));
                float node_5790 = 1.0;
                float node_8578 = 0.0;
                float node_5624 = (-1*_OffsetInside);
                v.vertex.xyz += ((node_5624 + ( (pow(_NoiseTexture_var.rgb,(_NoiseContrast+node_5790)) - node_8578) * (_OffsetOutside - node_5624) ) / (node_5790 - node_8578))*v.normal);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                i.normalDir = normalize(i.normalDir);
                i.normalDir *= faceSign;
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 normalDirection = i.normalDir;
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
