// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Unlit/halfSphere_aura"
{
    Properties
    {
        //_Color ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
        _MainTex ("Particle Texture", 2D) = "white" {}        
        _Speed("Speed", Vector) = (0,0,0,0)
        _UVGradientOffset("UV Gradient Offset", Float) = 0
        _Cutout("Cutout", Float) = 0
        _DisSolveTex("DisSolveTex",2d) = "white"{}
    }


    Category 
    {
        SubShader
        {
            Tags { "Queue"="Transparent"  "RenderType"="Transparent"  } //"IgnoreProjector"="True" //"PreviewType"="Plane"
            Blend SrcAlpha OneMinusSrcAlpha
            //ColorMask RGB
            Cull off
            //Lighting Off 
            ZWrite Off
            //ZTest LEqual
            
            Pass {
                
                CGPROGRAM
                
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0
                #pragma multi_compile_particles
                
                #include "UnityShaderVariables.cginc"
                #include "UnityCG.cginc"

                struct appdata_t 
                {
                    float4 vertex : POSITION;
                    fixed4 color : COLOR;
                    float4 texcoord : TEXCOORD0;
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                    
                };

                struct v2f 
                {
                    float4 vertex : SV_POSITION;
                    fixed4 color : COLOR;
                    float4 texcoord : TEXCOORD0;
                    float4 uv2 :TEXCOORD1;
                    
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                    UNITY_VERTEX_OUTPUT_STEREO
                    
                };
                
                
                #if UNITY_VERSION >= 560
                    UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
                #else
                    uniform sampler2D_float _CameraDepthTexture;
                #endif

                //Don't delete this comment
                // uniform sampler2D_float _CameraDepthTexture;

                uniform sampler2D _MainTex;
                // uniform fixed4 _Color;
                uniform float4 _MainTex_ST;
                uniform float _UVGradientOffset;
                uniform float4 _Speed;
                uniform float _Cutout;
                sampler2D _DisSolveTex;
                uniform float4 _DisSolveTex_ST;

                v2f vert ( appdata_t v  )
                {
                    v2f o;
                    UNITY_SETUP_INSTANCE_ID(v);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                    UNITY_TRANSFER_INSTANCE_ID(v, o);
                    v.vertex.xyz +=  float3( 0, 0, 0 ) ;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.color = v.color;
                    o.texcoord = v.texcoord;
                    o.uv2 = v.texcoord;
                    return o;
                }

                fixed4 frag ( v2f i  ) : SV_Target
                {
                    

                    float2 uv = i.texcoord.xy;
                    float uvGrad_Up = lerp(_UVGradientOffset , 1.0 , (1.0 - uv.y));
                    float uvGrad_Bot = lerp(_UVGradientOffset , 1.0 , uv.y);
                    float uvGrad = saturate(uvGrad_Bot * 4.0);

                    float2 MainTexOffset = uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                    float2 uvAnimation = _Time.y * _Speed.xy + MainTexOffset;

                    float4 tex = tex2D( _MainTex, uvAnimation );
                    float4 col = i.color * uvGrad * saturate( tex.r - _Cutout );//_Color * i.color * uvGrad * saturate( tex.r - _Cutout );//0~1にclamp
                    col.a = tex.a * uvGrad *i.color.a;
                    col = float4(col.rgb , saturate( (col).a ));
                    


                    // col = tex*_Color*20;
                    //float4 DisSolveTex = tex2D(_DisSolveTex,uv);
                    //float CutoutSeed = clamp(frac(_Time.y*1.5),0.05,1.1);//clamp(_Cutout,0.1,1.1);
                    //col.a= step(0,DisSolveTex.r-CutoutSeed);
                    return col;
                }
                ENDCG 
            }
        }	
    }
    CustomEditor "ASEMaterialInspector"
    
    
}
