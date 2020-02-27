Shader "Unlit/roomChange_beforeRefactor"
{
    Properties
    {
        _MainTex ("room01", 2D) = "white" {}
        _tex2("room2",2D) = "white"{}
        _thtex("ThresholTexture",2D) = "white"{}
        _dir("thDirection",2D) = "white"{}
        _threshold("Threshold",Range(-0.1,1)) = -0.1
        _bcol("noiseColor",2D) = "white"{}
        _bcol2("noiseColor2",2D) = "white"{}
        [Toggle]_divon("div on",Int) = 0
        _downoffset("downoffset",Range(0,0.2)) = 0.05
        _upoffset("spoffset",Range(0,0.2)) = 0.02

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _tex2;
            float _threshold;
            sampler2D _thtex;
            sampler2D _dir;
            sampler2D _bcol;
            sampler2D _bcol2;
            int _divon;
            float _downoffset;
            float _upoffset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //_threshold -= frac(_Time.y);
                float div = floor(_threshold*40)*0.025;
                // sample the texture
                fixed4 room1 = tex2D(_MainTex, i.uv);
                fixed4 room2 = tex2D(_tex2,i.uv);
                fixed4 thtex = tex2D(_thtex,i.uv);
                fixed4 thtex2 = tex2D(_thtex,i.uv);//tex2D(_thtex,float2(i.uv.x,i.uv.y-0.08));
                fixed4 thtex3 = tex2D(_thtex,i.uv);//tex2D(_thtex,float2(i.uv.x,i.uv.y-0.05));
                fixed4 dir = tex2D(_dir,i.uv);
                fixed4 heighlight = thtex;
                fixed4 bcol = tex2D(_bcol,i.uv);
                fixed4 bcol2 = tex2D(_bcol2,i.uv);
                thtex *= dir;
                thtex2 *= dir;
                thtex3 *= dir;
                fixed4 col = (1).xxxx;
                float av = thtex.r;//(thtex.r+thtex.g+thtex.b)*0.3;
                float avdown = thtex2.r;
                float avup = thtex3.r;
                /* 
                if(av>_threshold) col = room1;                                                                      //downが上
                else if(av+0.04>=div) col = room2*bcol*2.5;
                else if(av+0.045>=div) col = bcol2;
               
                
                
                else if(av<_threshold)col = room2;
               
                else col = 0;//room2;
                */
                
                col = step(av,_threshold);
                fixed4 hoge = col;
                
                
                fixed4 down = step(avdown-_downoffset,_threshold);
                fixed4 downdiv = down - col;
                //down = down -col;
                fixed4 merge = down+col;
                
               // return merge;
                fixed4 up = step(avup-_upoffset,_threshold);//step(av+0.04,_threshold);
                
                fixed4 huga = up;
                up = down-up;// up-merge;
                //return up+downdiv;
                
                //return up-merge;
                //return down;
                fixed4 diff = downdiv;//down;//down-col;//up-col;
             
                fixed4 diff2 = up;//up-merge;//col-down;

                //diff2 -=diff;
                 
                
               //return  diff + diff2 + 1-(col+up+downdiv);
                diff = min(diff,bcol);//min(diff,bcol2);
                            //  return diff;
                diff2 = min(diff2,bcol2);//min(diff2,bcol)*room2;
                            
               //return diff + diff2;
                col = (1-hoge)*room1;
                //return col+diff+diff2;       
                   // return col + diff + diff2;


                col = diff2+col+diff; 
                //return col;
                fixed4 col2 = room2*(hoge); //room2*up;
                
                col += col2;

                

               
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
