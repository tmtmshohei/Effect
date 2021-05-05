Shader "Unlit/newKeijiban"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _text("Text",2D)="white"{}
        _color("col",Color)=(1,1,1,1)
        _intensity("intensity",Float)=1
        [Toggle]_TextureAnimation8("Use Texture Animation",Int)=0
        _perFrame("フレーム間隔",Float) = 0.03
        _row("行",Int) = 4
        _colum("列",Int) = 4
        _F0("F0",Range(0,1))=0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"  }
        LOD 100
        //Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _text;
            float4 _text_ST;
            float4 _color;
            float _intensity;

            float _perFrame;
            int _row;
            int _colum;
            float _F0;

            float4 hoge(sampler2D tex ,float2 uv, int index, float dx, float dy)
            {
                float uvy = 1-uv.y;
                float2 nuv = float2(uv.x*dx + fmod(index,_row)*dx , 1-(uvy*dy+(index/_colum)*dy	));
                float4 col = tex2D(tex,nuv);
                return col;
            }

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
                float2 textuv :TEXCOORD2;
            };

            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.textuv = TRANSFORM_TEX(v.uv,_text);
                //o.textuv.x *=0.25;
                //o.textuv.x += (_Time.y%36*0.1);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                int totalframe = _row*_colum;
                float current = fmod(_Time.y/_perFrame,totalframe);
                int index = floor(current);
                float dx = 1.0/_row;
                float dy = 1.0/_colum;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                //float4 text = tex2D(_text,i.textuv);
                //col *= text*_color*_intensity;

                col.rgb *= hoge(_text,i.textuv,index,dx,dy)*_intensity;
                //col += hoge(_text,i.textuv,index,dx,dy)*_intensity;
                
                //以下からテスト
                //時間部分の計算
                float time = _Time.y;
                float timeSpeed = 1.4;
                time*=timeSpeed;
                time = frac(time);

                //縦横の繰り返し回数
                float row = _row;
                float colum = _colum;
                float total = row*colum;
                float frame = floor(total*time); //0~15がかえってくる

                //横の繰り返し
                float rowNum = fmod(frame,row);//0~4を返す
                //縦の繰り返し
                float columNum = floor(frame/colum); //0から3が返ってくる 
                float2 rowColum = float2(rowNum,columNum);

                float2 seed = (1).xx/float2(row,colum); // 0.25
                rowColum *= seed; //1,0.75
                //return float4(rowColum.x,rowColum.y,0,1);
                //1コマのサイズ
                float2 uvSize = float2(i.uv.x,1-i.uv.y) *seed;
                float2 uv ;
                uv.x =rowColum.x+uvSize.x; //0.25
                uv.y =1-(rowColum.y+uvSize.y);

                col = tex2D(_text,uv);
                //col.rgb = col.b;
                //return col;
                
                //col.rgb = col.r;
                //return col;
                

                float timeseed = _Time.y*timeSpeed*0.25;
                timeseed = frac(timeseed);
                timeseed *=4;
                timeseed = floor(timeseed);
                //timeseed = fmod(timeseed,2);

                float4 red = float4(1,0,0,1);
                float4 blue = float4(0,0,1,1);
                float4 green = float4(0,1,0,1);
                float th = _F0;
                th *=10;
                th = floor(th);
                float4 color =  lerp(red,blue,th);
                //return color;






                if(timeseed<1)
                {
                    col.rgb  = col.r;
                }
                else if(timeseed==1)
                {
                    col.rgb  = col.g;
                }
                else if(timeseed>1)
                {
                    if(timeseed>2) col.rgb = 0;
                    else 
                    col.rgb  = col.b;
                }
                
                
                

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
